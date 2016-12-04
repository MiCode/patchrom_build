include $(PORT_BUILD)/localvar.mk

#> Start of global variable
# The global variable could be used in local makefile, and the name
# would not be changed in future
SHELL       := /bin/bash
TMP_DIR     := out
ZIP_DIR     := $(TMP_DIR)/ZIP
OUT_ZIP     := $(TMP_DIR)/$(OUT_ZIP_FILE)
TOOL_DIR    := $(PORT_ROOT)/tools
BUILD_PROP  := $(ZIP_DIR)/system/build.prop
MIUI_PROP   := $(PORT_BUILD)/miui.prop
SKIA_FILE	:= $(ZIP_DIR)/system/lib/libskia.so
SYSOUT_DIR  := $(OUT_SYS_PATH)
DATAOUT_DIR  := $(OUT_DATA_PATH)

# Tool alias used in the makefile
APKTOOL     := $(TOOL_DIR)/apktool $(APK_VERBOSE)
AAPT        := $(TOOL_DIR)/aapt
SIGN        := $(TOOL_DIR)/sign.sh $(VERBOSE)
ADDMIUI     := $(TOOL_DIR)/add_miui_smail.sh $(VERBOSE)
PREPARE_PRELOADED_CLASSES := $(TOOL_DIR)/prepare_preloaded_classes.sh $(VERBOSE)
ADDMIUIRES  := $(TOOL_DIR)/add_miui_res.sh $(VERBOSE)
PATCH_MIUI_APP  := $(TOOL_DIR)/patch_miui_app.sh $(VERBOSE)
FIX_9PATCH_PNG  := $(TOOL_DIR)/fix_9patch_png.sh $(VERBOSE)
SETPROP     := $(TOOL_DIR)/post_process_props.py
REWRITE		:= $(TOOL_DIR)/rewrite.py
UNZIP       := unzip $(VERBOSE)
ZIP         := zip $(VERBOSE)
MERGE_RES   := $(TOOL_DIR)/ResValuesModify/jar/ResValuesModify $(VERBOSE)
MERGE_RULE  := $(TOOL_DIR)/ResValuesModify/jar/config
RM_REDEF    := $(TOOL_DIR)/remove_redef.py $(VERBOSE)
PATCH_MIUI_FRAMEWORK  := $(TOOL_DIR)/patch_miui_framework.sh $(INFO)
RLZ_SOURCE  := $(TOOL_DIR)/release_source.sh $(VERBOSE)
FIX_PLURALS := $(TOOL_DIR)/fix_plurals.sh $(VERBOSE)
RESTORE_OBSOLETE_KEYGUARD := $(TOOL_DIR)/restore_obsolete_keyguard.sh $(VERBOSE)
BUILD_TARGET_FILES := $(TOOL_DIR)/build_target_files.sh $(INFO)
ADB         := adb
#< End of global variable

ROM_BUILD_NUMBER  := $(shell date +%Y%m%d.%H%M%S)

ifeq ($(USE_ANDROID_OUT),true)
    MIUI_SRC_DIR:=$(ANDROID_TOP)/miui
else
    MIUI_SRC_DIR:=$(PORT_ROOT)/miui/src
endif

PLATFORM_OVERLAY := $(strip $(shell grep "OVERLAY" $(PORT_ROOT)/android/README | cut -d'=' -f2))

DEVICE_OVERLAY_RES:=overlay/framework-res/res
OVERLAY_RES:=$(MIUI_SRC_DIR)/config-overlay/v6/common/frameworks/base/core/res/res $(addsuffix /frameworks/base/core/res/res, $(addprefix $(MIUI_SRC_DIR)/config-overlay/v6/platform/, $(PLATFORM_OVERLAY)))
I18N_RES:=$(addsuffix /frameworks/base/core/res/res, $(addprefix $(MIUI_SRC_DIR)/I18N_res/v6/platform/, $(PLATFORM_OVERLAY))) $(MIUI_SRC_DIR)/I18N_res/v6/common/frameworks/base/core/res/res
MIUI_OVERLAY_RES:=$(DEVICE_OVERLAY_RES) $(OVERLAY_RES) $(I18N_RES)

MIUI_RES := overlay/framework-ext-res/res \
	$(addsuffix /miui/frameworks/base/core/res/res, $(addprefix $(MIUI_SRC_DIR)/I18N_res/v6/platform/, $(PLATFORM_OVERLAY))) \
	$(MIUI_SRC_DIR)/I18N_res/v6/common/miui/frameworks/base/core/res/res \
	$(MIUI_SRC_DIR)/frameworks/base/core/res/res \
	$(MIUI_SRC_DIR)/frameworks/opt/ToggleManager/res

JARS        := $(MIUI_JARS) $(PHONE_JARS)
BLDAPKS     := $(addprefix $(TMP_DIR)/,$(addsuffix .apk,$(APPS)))
JARS_OUTDIR := $(addsuffix .jar.out,$(MIUI_JARS))
APPS_OUTDIR := $(APPS) framework-res
BLDJARS     := $(addprefix $(TMP_DIR)/,$(addsuffix .jar,$(JARS)))
PHN_BLDJARS := $(addsuffix -phone,$(BLDJARS))
ZIP_BLDJARS := $(addsuffix -tozip,$(BLDJARS))

SIGNAPKS    := 
TOZIP_APKS  :=
CLEANJAR    :=
CLEANMIUIAPP:=
RELEASE_MIUI:=
RELEASE_PATH:= $(PORT_ROOT)/miui
MAKE_ATTOP  := make -C $(ANDROID_TOP)

# helper functions
define all-files-under-dir
$(strip $(filter-out $(1),$(shell find $(1) -name "*.*" 2>/dev/null)))
endef

#
# Extract the jar file from ZIP file and replaced the modified smails
# with MIUI features, and these smali files are stored in xxxx.jar.out
# $1: the jar name, such as services
# $2: the dir under build for apktool-decoded files, such as .build/services
define JAR_template
$(TMP_DIR)/$(1).jar-phone:$(TMP_DIR)/$(1).jar
	$(ADB) remount
	$(ADB) shell stop
	$(ADB) push $$< /system/framework/$(1).jar
	$(ADB) shell start

$(TMP_DIR)/$(1).jar-tozip:$(TMP_DIR)/$(1).jar
	$(hide) cp $$< $(ZIP_DIR)/system/framework/$(1).jar
	@touch $$@

source-files-for-$(1) := $$(call all-files-under-dir,$(1).jar.out)

$(TMP_DIR)/$(1).jar: $(2)_miui $$(source-files-for-$(1))
	@echo ">>> build $$@..."
	$(hide) rm -rf $(2)
	$(hide) cp -r $(1).jar.out/ $(2)
	$(ADDMIUI) $(2)_miui $(2)
	$(APKTOOL) b $(2) -o $$@
	$(PREPARE_PRELOADED_CLASSES) $(2) $(subst /$(DENSITY)/,/,$(OUT_JAR_PATH))
	$(hide) if [ -f $(1).jar.out/preloaded-classes ]; then \
		jar -uf $$@ -C $(1).jar.out preloaded-classes; \
	elif [ -f $(2)/p/reloaded-classes ];then \
		jar -uf $$@ -C $(2) preloaded-classes; \
	fi
	@echo "<<< build $$@ completed!"

$(2)_miui: $(subst /$(DENSITY)/,/,$(OUT_JAR_PATH))/$(1).jar
	$(APKTOOL) d -f $$< -o $$@

ifeq ($(USE_ANDROID_OUT),true)
$(OUT_JAR_PATH)/$(1).jar: $(ERR_REPORT)
	$(MAKE_ATTOP) $(1)

CLEANJAR += clean-$(1)
clean-$(1):
	$(MAKE_ATTOP) clean-$(1)

RELEASE_MIUI += $(RELEASE_PATH)/system/framework/$(1).jar
$(RELEASE_PATH)/system/framework/$(1).jar: $(OUT_JAR_PATH)/$(1).jar
	$(hide) mkdir -p $(RELEASE_PATH)/system/framework
	$(hide) cp $$< $$@
endif

# targets for initial workspace
$(1).jar.out:
	mkdir -p $(TMP_DIR)/system/framework
	cp -rf $(STOCKROM_DIR)/system/framework/$(1).jar $(TMP_DIR)/system/framework
	$(APKTOOL) d -f $(TMP_DIR)/system/framework/$(1).jar -o $$@
	$(hide) rm $(TMP_DIR)/system/framework/$(1).jar

endef

#
# Template to apktool-build the jar-file that is from phone(i.e, not MIUI)
# the decoded smali files are located at JARNAME.jar.out
# $1: the jar name, such as framework2
define JAR_PHONE_template
$(TMP_DIR)/$(1).jar-phone:$(TMP_DIR)/$(1).jar
	$(ADB) push $$< /system/framework/$(1).jar

$(TMP_DIR)/$(1).jar-tozip:$(TMP_DIR)/$(1).jar
	$(hide) cp $$< $(ZIP_DIR)/system/framework/$(1).jar
	@touch $$@

source-files-for-$(1) := $$(call all-files-under-dir,$(1).jar.out)
$(TMP_DIR)/$(1).jar: $$(source-files-for-$(1)) | $(TMP_DIR)
	@echo ">>> build $$@..."
	#$(hide) rm -rf $(TMP_DIR)/$(1).jar.out
	$(hide) cp -r $(1).jar.out $(TMP_DIR)/
	$(APKTOOL) b $(TMP_DIR)/$(1).jar.out -o $$@
	@echo "<<< build $$@ completed!"

endef

#
# To apktool build one apk from the decoded dirctory under .build
# $1: the apk name, such as LogsProvider
# $2: the dir name, might be different from apk name
# $3: to specify if the smali files should be decoded from MIUI first
# $4: to specify app dir, for kitkat only
define APP_template
source-files-for-$(2) := $$(call all-files-under-dir,$(2))
$(TMP_DIR)/$(1).apk: $$(source-files-for-$(2)) $(3) | $(TMP_DIR)
	@echo ">>> build $$@..."
	$(hide) cp -r $(2) $(TMP_DIR)
	$(hide) find $(TMP_DIR)/$(2) -name "*.part" -exec rm {} \;
	$(hide) find $(TMP_DIR)/$(2) -name "*.smali.method" -exec rm {} \;
	$(APKTOOL) b -a $(AAPT) $(TMP_DIR)/$(2) -o $$@
	@echo "9Patch png fix $$@..."
ifeq ($(3),)
	$(FIX_9PATCH_PNG) $(1) $(STOCKROM_DIR)/system/$(4) $(TMP_DIR)
else
	$(FIX_9PATCH_PNG) $(1) $(OUT_APK_PATH:app=$(4)) $(TMP_DIR) $(1)/res
endif
	@echo "fix $$@ completed!"
	@echo "<<< build $$@ completed!"

$(3): $(OUT_APK_PATH:app=$(4))/$(1).apk
	$(hide) rm -rf $(3)
	$(APKTOOL) d -t miui -f $(OUT_APK_PATH:app=$(4))/$(1).apk -o $(3)
	$(hide) sed -i "/tag:/d" $(3)/apktool.yml
	$(hide) sed -i "/forced-package-id:/d" $(3)/apktool.yml
	$(PATCH_MIUI_APP) $(2) $(3)

endef

# Target to build framework-res.apk
# copy the framework-res, add the miui overlay then build
#TODO need to add changed files for all related, and re-install framework-res.apk make sense?
framework-res-source-files := $(call all-files-under-dir,framework-res)
framework-res-overlay-files:= $(call all-files-under-dir,$(MIUI_OVERLAY_RES)) $(call all-files-under-dir,overlay)

$(TMP_DIR)/framework-res.apk: $(TMP_DIR)/apktool-if $(framework-res-source-files) $(framework-res-overlay-files)
	@echo ">>> build $@..."
	$(hide) rm -rf $(TMP_DIR)/framework-res
	$(hide) cp -r framework-res $(TMP_DIR)
	#for call ./customize_framework-res.sh
	$(hide) $(ADDMIUIRES) $(TMP_DIR)/framework-res/res $(TMP_DIR)/framework-res/res
	$(hide) $(AAPT) p -f -x --auto-add-overlay --wlan-replace Wi-Fi --wlan-replace WiFi \
		--min-sdk-version $(subst v,,$(ANDROID_PLATFORM)) --target-sdk-version $(subst v,,$(ANDROID_PLATFORM)) \
		$(addprefix -S ,$(wildcard $(MIUI_OVERLAY_RES))) \
		-S $(TMP_DIR)/framework-res/res -A $(TMP_DIR)/framework-res/assets \
		-M $(TMP_DIR)/framework-res/AndroidManifest.xml -F $@
	@echo "9Patch png fix $@..."
	#$(FIX_9PATCH_PNG) framework-res $(STOCKROM_DIR)/system/framework $(TMP_DIR) $(MIUI_OVERLAY_RES_DIR) $(OVERLAY_RES_DIR)
	@echo "fix $@ completed!"
	$(APKTOOL) if $@
	@echo "<<< build $@ completed!"

$(TMP_DIR)/framework-ext-res.apk: $(TMP_DIR)/framework-res.apk $(OUT_JAR_PATH)/framework-ext-res.apk
	@echo ">>> build $@..."
	#$(APKTOOL) d -f -t miui $(OUT_JAR_PATH)/framework-ext-res.apk -o $(TMP_DIR)/framework-ext-res
	$(hide) $(AAPT) p -f -x --auto-add-overlay --rename-manifest-package com.miui.rom --wlan-replace Wi-Fi --wlan-replace WiFi \
		--min-sdk-version $(subst v,,$(ANDROID_PLATFORM)) --target-sdk-version $(subst v,,$(ANDROID_PLATFORM)) \
		$(addprefix -S ,$(wildcard $(MIUI_RES))) -M $(MIUI_SRC_DIR)/frameworks/base/core/res/AndroidManifest.xml \
		-I $(APKTOOL_IF_RESULT_FILE)/1.apk -I $(APKTOOL_IF_RESULT_FILE)/16.apk -F $@
	$(APKTOOL) if $@
	@echo "<<< build $@ completed!"

#
# To prepare the workspace to modify the APKs from zip file
# $1 the apk name, also the dir name to save the smali files
# $2 the apk location under system, such as app or framework
define APP_WS_template
$(1):
	mkdir -p $(TMP_DIR)/system/$(2)
	if cp -rf $(STOCKROM_DIR)/system/$(2)/$(1).apk $(TMP_DIR)/system/$(2) 2>/dev/null; then \
	$(APKTOOL) d -f $(TMP_DIR)/system/$(2)/$(1).apk -o $$@ ; else \
	echo system/$(2)/$(1).apk does not exist, ignored!;  fi
	$(hide) rm -f $(TMP_DIR)/system/$(2)/$(1).apk

endef

# To decide dir of the apk
# $1 the apk name
define MOD_DIR_template
ifeq ($(USE_ANDROID_OUT),true)
ifeq ($(wildcard $(ANDROID_OUT)/system/priv-app/$(1).apk),$(wildcard $(STOCKROM_DIR)/system/priv-app/$(1).apk))
	$(call SIGN_template,$(TMP_DIR)/$(1).apk,/system/app/$(1).apk)
else
	$(call SIGN_template,$(TMP_DIR)/$(1).apk,/system/priv-app/$(1).apk)
endif
else
ifeq ($(wildcard $(RELEASE_PATH)/$(DENSITY)/system/priv-app/$(1).apk),$(wildcard $(STOCKROM_DIR)/system/priv-app/$(1).apk))
	$(call SIGN_template,$(TMP_DIR)/$(1).apk,/system/app/$(1).apk)
else
	$(call SIGN_template,$(TMP_DIR)/$(1).apk,/system/priv-app/$(1).apk)
endif
endif
endef

# To decide dir of the apk
# $1 the apk name
# $2: to specify if the smali files should be decoded from MIUI first
define APP_DIR_template
ifeq ($(USE_ANDROID_OUT),true)
ifeq ($(wildcard $(ANDROID_OUT)/system/priv-app/$(1).apk),)
	$(call APP_template,$(1),$(1),$(2),app)
else
	$(call APP_template,$(1),$(1),$(2),priv-app)
endif
else
ifeq ($(wildcard $(RELEASE_PATH)/$(DENSITY)/system/priv-app/$(1).apk),)
	$(call APP_template,$(1),$(1),$(2),app)
else
	$(call APP_template,$(1),$(1),$(2),priv-app)
endif
endif
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
	#java -jar $(TOOL_DIR)/signapk.jar $(PORT_ROOT)/build/security/platform.x509.pem $(PORT_ROOT)/build/security/platform.pk8 $(1) $(1).signed
	java -jar $(TOOL_DIR)/signapk.jar $(PORT_ROOT)/build/security/testkey.x509.pem $(PORT_ROOT)/build/security/testkey.pk8 $(1) $(1).signed
	$(ADB) remount
	$(ADB) push $(1).signed $(2)

mark-tozip-for-$(1) := $(TMP_DIR)/$$(shell basename $(1))-tozip
TOZIP_APKS += $$(mark-tozip-for-$(1))
$$(mark-tozip-for-$(1)) : $(1)
	$(hide) cp $(1) $(ZIP_DIR)$(2)
	@touch $$@
endef

#
# Used to build and clean the miui apk, e.g: make clean-Launcher2
# $1: the apk name
# $2: the dir name
define BUILD_CLEAN_APP_template
ifeq ($(USE_ANDROID_OUT),true)
$(OUT_APK_PATH:app=$(2))/$(1).apk:
	$(MAKE_ATTOP) $(1)

CLEANMIUIAPP += clean-$(1)
clean-$(1):
	$(MAKE_ATTOP) $$@
endif
endef

define RELEASE_MIUI_APP_template
ifeq ($(USE_ANDROID_OUT),true)
RELEASE_MIUI += $(RELEASE_PATH)/$(DENSITY)/system/$(2)/$(1).apk
$(RELEASE_PATH)/$(DENSITY)/system/$(2)/$(1).apk: $(OUT_APK_PATH:app=$(2))/$(1).apk
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/$(2)
	$(hide) cp $$< $$@
endif
endef

zipone: zipfile $(ACT_AFTER_ZIP)

otapackage: metadata target_files
	$(BUILD_TARGET_FILES) $(INCLUDE_THIRDPART_APP)

#> TARGETS EXPANSION START
$(foreach jar, $(MIUI_JARS), \
	$(eval $(call JAR_template,$(jar),$(TMP_DIR)/$(jar))))
$(foreach jar, $(PHONE_JARS), \
	$(eval $(call JAR_PHONE_template,$(jar))))

$(foreach app, $(APPS), \
	$(eval $(call APP_DIR_template,$(app),)))

$(foreach app, $(MIUIAPPS_MOD), \
	$(eval $(call APP_DIR_template,$(app),$(TMP_DIR)/$(app))))

$(foreach app, $(APPS) $(MIUIAPPS_MOD), \
	$(eval $(call MOD_DIR_template,$(app))))

$(foreach app, $(MIUIAPPS) , \
	$(eval $(call SIGN_template,$(OUT_APK_PATH)/$(app).apk,/system/app/$(app).apk)))

$(foreach app, $(PRIV_MIUIAPPS) , \
	$(eval $(call SIGN_template,$(OUT_APK_PATH:app=priv-app)/$(app).apk,/system/priv-app/$(app).apk)))

$(eval $(call SIGN_template,$(TMP_DIR)/framework-ext-res.apk,/system/framework/framework-ext-res.apk))

$(eval $(call SIGN_template,$(TMP_DIR)/framework-res.apk,/system/framework/framework-res.apk))

$(foreach app, $(MIUIAPPS) $(MIUIAPPS_MOD), $(eval $(call BUILD_CLEAN_APP_template,$(app),app)))

$(foreach app, $(PRIV_MIUIAPPS), $(eval $(call BUILD_CLEAN_APP_template,$(app),priv-app)))

$(foreach app, $(ALL_MIUIAPPS), $(eval $(call RELEASE_MIUI_APP_template,$(app),app)))

$(foreach app, $(ALL_PRIV_MIUIAPPS), $(eval $(call RELEASE_MIUI_APP_template,$(app),priv-app)))

$(foreach app, $(APPS), \
	$(eval $(call APP_WS_template,$(app),app)))

$(foreach app, $(APPS), \
	$(eval $(call APP_WS_template,$(app),priv-app)))

$(eval $(call APP_WS_template,framework-res,framework))

# for release
ifeq ($(USE_ANDROID_OUT),true)
RELEASE_MIUI += $(RELEASE_PATH)/$(DENSITY)/system/framework/framework-ext-res.apk
$(RELEASE_PATH)/$(DENSITY)/system/framework/framework-ext-res.apk:
	mkdir -p $$(dirname $@)
	cp $(OUT_JAR_PATH)/framework-ext-res.apk $@
RELEASE_MIUI += $(RELEASE_PATH)/$(DENSITY)/system/framework/framework-res.apk
$(RELEASE_PATH)/$(DENSITY)/system/framework/framework-res.apk:
	mkdir -p $$(dirname $@)
	cp $(OUT_JAR_PATH)/framework-res.apk $@
endif

#< TARGET EXPANSION END

#> TARGET FOR ZIPFILE START
$(TMP_DIR):
	$(hide) mkdir -p $(TMP_DIR)

$(ZIP_DIR): $(TMP_DIR)
	mkdir -p $@
	cp -rf $(STOCKROM_DIR)/* $@
ifneq ($(strip $(local-phone-apps)),)
	$(hide) mv $(ZIP_DIR)/system/app $(ZIP_DIR)/system/app.original
	$(hide) mkdir $(ZIP_DIR)/system/app
	$(hide) for apk in $(local-phone-apps); do\
		cp $(ZIP_DIR)/system/app.original/$$apk.apk $(ZIP_DIR)/system/app; \
	done
	$(hide) rm -rf $(ZIP_DIR)/system/app.original
endif
ifneq ($(strip $(local-phone-priv-apps)),)
	$(hide) mv $(ZIP_DIR)/system/priv-app $(ZIP_DIR)/system/priv-app.original
	$(hide) mkdir $(ZIP_DIR)/system/priv-app
	$(hide) for apk in $(local-phone-priv-apps); do\
		cp $(ZIP_DIR)/system/priv-app.original/$$apk.apk $(ZIP_DIR)/system/priv-app; \
	done
	$(hide) rm -rf $(ZIP_DIR)/system/priv-app.original
endif

remove-rund-apks:
	@echo ">>> remove all unnecessary apks from original ZIP file..."
	$(hide) rm -f $(addprefix $(ZIP_DIR)/system/app/, $(addsuffix .apk, $(RUNDAPKS)))
	@echo "<<< remove done!"

pre-zip-misc: set-build-prop add-device-feature

set-build-prop: OVERLAY_PROP := $(TMP_DIR)/overlay.prop
set-build-prop:
	@echo "Overlay build prop"
	$(hide) cp $(MIUI_PROP) $(OVERLAY_PROP)
	$(hide) echo "ro.build.version.incremental=$(BUILD_NUMBER)" >> $(OVERLAY_PROP)
	$(hide) echo "ro.product.mod_device=$(PORT_PRODUCT)" >> $(OVERLAY_PROP)
	$(SETPROP) $(BUILD_PROP) $(OVERLAY_PROP)

add-device-feature: FEATURE_DIR := $(ZIP_DIR)/system/etc/device_features
add-device-feature:
	$(hide) mkdir -p $(FEATURE_DIR); \
	device_name=$$(grep "ro.product.device=" $(BUILD_PROP) | cut -d '=' -f2); \
	echo "Add device feature: $$device_name.xml"; \
	cp -rf $(PORT_BUILD)/device_features.xml $(FEATURE_DIR)/$$device_name.xml


rewrite-lib:
	$(hide) if [ $(REWRITE_SKIA_LIB) = "true" ]; then \
		$(REWRITE) $(SKIA_FILE) ANDROID_ROOT ANDROID_DATA; \
	fi

ifeq ($(USE_ANDROID_OUT),true)
RELEASE_MIUI += release-miui-prebuilt
endif
	
target_files: $(STOCKROM_DIR) | $(ZIP_DIR) 
target_files: $(TMP_DIR)/framework-ext-res.apk $(ZIP_BLDJARS) $(TOZIP_APKS) add-miui-prebuilt $(ACT_PRE_ZIP)

# Target to make zipfile which is all signed by testkey. convenient for developement and debug
zipfile: BUILD_NUMBER := 01.$(ROM_BUILD_NUMBER)
zipfile: target_files $(TMP_DIR)/sign-zipfile-dir
	$(BUILD_TARGET_FILES) $(INCLUDE_THIRDPART_APP) -n $(OUT_ZIP_FILE)
	@echo The output zip file is: $(OUT_ZIP)

#TODO add all depend sign..
$(TMP_DIR)/sign-zipfile-dir:
	$(SIGN) sign.zip $(ZIP_DIR)
	#@touch $@

# Target to test if full ota package will be generate
fullota: BUILD_NUMBER := 02.$(ROM_BUILD_NUMBER)
fullota: target_files
	@echo ">>> To build out target file: fullota.zip ..."
	$(BUILD_TARGET_FILES) $(INCLUDE_THIRDPART_APP) $(CERTIFICATE_DIR) fullota.zip
	@echo "<<< build target file completed!"

#< TARGET FOR ZIPFILE END

include $(PORT_BUILD)/util.mk
include $(PORT_BUILD)/prebuilt.mk
