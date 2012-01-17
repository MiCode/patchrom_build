#
# Targets defined by this makefile:
# 	1) make sign    - to sign apks #todo
# 	2) make zipfile - to create the full ZIP file for i9100 phone zip file
# 	3) make zip2sd  - to push the ZIP file to phone in recovery mode
# 	4) make zipone  - zipfile + zip2sd
# 	5) make apktool-if - install the framework for apktool
# 	6) make apkname.apk.sign - to generate a single apkname.apk and sign/push to phone
# 	7) make .build/xxxx.jar-phone  - to make out a single jar file and push to phone
#          note: for single 2,3, need to 'adb remount' first.
# 	8) make clean - clear everything for output of this makefile, 
# 			but left the build-out apk/jars from the android-make
# 	9) make reallyclean - clear everything of related.
#      10) make clean-appname / make appname (just as android-make xxx at android-top)
#

include $(PORT_BUILD)/localvar.mk

TMP_DIR     := .build
ZIP_DIR     := $(TMP_DIR)/ZIP
OUT_ZIP     := $(TMP_DIR)/$(OUT_ZIP_FILE)
SYSOUT_DIR  := $(ANDROID_OUT)/system
TOOLDIR     := $(PORT_ROOT)/tools
APKTOOL     := $(TOOLDIR)/apktool
SIGN        := $(TOOLDIR)/sign.sh
ADDMIUI     := $(TOOLDIR)/add_miui_smail.sh
MAKE_ATTOP  := make -C $(ANDROID_TOP)

JARS        := services android.policy framework
BLDAPKS     := $(addprefix $(TMP_DIR)/,$(addsuffix .apk,$(APPS)))
BLDJARS     := $(addprefix $(TMP_DIR)/,$(addsuffix .jar,$(JARS)))
PHN_BLDJARS := $(addsuffix -phone,$(BLDJARS))
ZIP_BLDJARS := $(addsuffix -tozip,$(BLDJARS))
SIGNAPKS    := 
TOZIP_APKS  :=
CLEANJAR    :=
CLEANMIUIAPP:=


#
# Extract the jar file from ZIP file and replaced with smail from git
# $1: the jar name, such as services
# $2: the dir under build for apktool-decoded files, such as .build/services
define JAR_template
$(TMP_DIR)/$(1).jar-phone:$(TMP_DIR)/$(1).jar
	adb push $$< /system/framework/$(1).jar

$(TMP_DIR)/$(1).jar-tozip:$(TMP_DIR)/$(1).jar
	cp $$< $(ZIP_DIR)/system/framework/$(1).jar

$(TMP_DIR)/$(1).jar: $(2) $(2)_miui
	@echo build $$@...
	@echo --------------------------------------------
	cp -r $(1).jar.out/smali $(2)
	$(ADDMIUI) $(2)_miui $(2)
	$(APKTOOL) b $(2) $$@

$(2): $(ZIP_FILE)
	@echo "unzip and decode $(1) from $(ZIP_FILE)"
	@echo --------------------------------------------
	unzip $(ZIP_FILE) system/framework/$(1).jar -d $(TMP_DIR)
	$(APKTOOL) d -f $(TMP_DIR)/system/framework/$(1).jar $(2)

$(2)_miui: $(SYSOUT_DIR)/framework/$(1).jar
	$(APKTOOL) d -f $$< $$@

$(SYSOUT_DIR)/framework/$(1).jar:
	$(MAKE_ATTOP) $(1)

CLEANJAR += clean-$(1)
clean-$(1):
	$(MAKE_ATTOP) clean-$(1)
endef

#
# To apktool build one apk from the decoded dirctory under .build
# $1: the apk name, such as LogsProvider
# $2: the dir name, might be different from apk name, such as framework-res.out
# $3: action, e.g: need firstly to be decoded from miui-apks or zip files
define APP_template
$(TMP_DIR)/$(1).apk: $(3)_$(1) $(TMP_DIR)
	@echo build $$@...
	@echo --------------------------------------------
	cp -r $(2) $(TMP_DIR)
	$(APKTOOL) b $(TMP_DIR)/$(2) $$@

nop_$(1):
	@echo nothing to do for $(1)

decode_miui_$(1): $(SYSOUT_DIR)/app/$(1).apk
	$(APKTOOL) d -f $(SYSOUT_DIR)/app/$(1).apk $(TMP_DIR)/$(2)

# todo, now this target is only for framework-res
decode_zip_$(1):
	unzip $(ZIP_FILE) system/framework/$(1).apk -d $(TMP_DIR)
	$(APKTOOL) d -f $(TMP_DIR)/system/framework/$(1).apk $(TMP_DIR)/$(2)

endef

#
# Used to sign one single file, e.g: make .build/LogsProvider.apk.sign
# for zipfile target, just to copy the unsigned file to correct ZIP-directory.
# also create a seperate target for command line, such as : make LogsProvider.apk.sign
# $1: the apk file need to be signed
# $2: the path/filename in the phone
define SIGN_template
SIGNAPKS += $(1).sign
$(notdir $(1)).sign $(1).sign: $(1)
	@echo sign apk $(1) and push to phone as $(2)...
	@echo --------------------------------------------
	java -jar $(TOOLDIR)/signapk.jar $(TOOLDIR)/platform.x509.pem $(TOOLDIR)/platform.pk8 $(1) $(1).signed
	adb push $(1).signed $(2)

TOZIP_APKS += $(1).tozip
$(1).tozip : $(1)
	@echo cp apks-unsinged to zip dirs
	cp $(1) $(ZIP_DIR)$(2)
endef

#
# Used to build and clean the miui apk, e.g: make clean-Launcher2
# $1: the apk name
define BUILD_CLEAN_APP_template
$(SYSOUT_DIR)/app/$(1).apk:
	$(MAKE_ATTOP) $(1)

CLEANMIUIAPP += clean-$(1)
clean-$(1):
	$(MAKE_ATTOP) $$@
endef

#> TARGETS EXPANSION START
$(foreach jar, $(JARS), \
	$(eval $(call JAR_template,$(jar),$(TMP_DIR)/$(jar))))

$(eval $(call APP_template,framework-res,framework-res.out,decode_zip))
$(eval $(call SIGN_template,$(TMP_DIR)/framework-res.apk,/system/framework/framework-res.apk))

$(foreach app, $(APPS), \
	$(eval $(call APP_template,$(app),$(app),nop)))
$(foreach app, $(APPS), \
	$(eval $(call SIGN_template,$(TMP_DIR)/$(app).apk,/system/app/$(app).apk)))
$(foreach app, $(MIUIAPPS), \
	$(eval $(call SIGN_template,$(SYSOUT_DIR)/app/$(app).apk,/system/app/$(app).apk)))
$(foreach app, $(MIUIAPPS) MIUISystemUI, $(eval $(call BUILD_CLEAN_APP_template,$(app))))
$(eval $(call SIGN_template,$(SYSOUT_DIR)/framework/framework-miui-res.apk,/system/framework/framework-miui-res.apk))

$(eval $(call APP_template,MIUISystemUI,SystemUI,decode_miui))
$(eval $(call SIGN_template,$(TMP_DIR)/MIUISystemUI.apk,/system/app/SystemUI.apk))

#< TARGET EXPANSION END

#> TARGET FOR ZIPFILE START
$(TMP_DIR):
	@mkdir -p $(TMP_DIR)

empty-zip-filename:
	$(error local-zip-file must be defined to specify the ZIP file)

$(ZIP_DIR): $(TMP_DIR) $(ZIP_FILE)
	unzip $(ZIP_FILE) -d $@

remove-rund-apks:
	@echo To remove all unnecessary apks:
	rm -f $(addprefix $(ZIP_DIR)/system/app/, $(addsuffix .apk, $(RUNDAPKS)))
	
# use zipfile instead of $(OUT_ZIP) to let zip2sd could be reached if $(OUT_ZIP) exists
zipfile: $(ZIP_DIR) $(ZIP_BLDJARS) $(TOZIP_APKS) $(ACT_PRE_ZIP)
	$(SIGN) sign.zip $(ZIP_DIR)
	cd $(ZIP_DIR); zip -r ../../$(OUT_ZIP) ./
	@echo The output zip file is: $(OUT_ZIP)

zipone: zipfile $(ACT_AFTER_ZIP)

#< TARGET FOR ZIPFILE END

include $(PORT_BUILD)/util.mk

