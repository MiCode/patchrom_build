include $(PORT_BUILD)/config.mk
include $(PORT_BUILD)/definitions.mk
include $(PORT_BUILD)/release.mk
include $(PORT_BUILD)/prebuilt.mk

#> Start of global variable
# The global variable could be used in local makefile, and the name
# would not be changed in future
SHELL       := /bin/bash
TOOL_DIR    := $(PORT_ROOT)/tools
STOCKROM_DIR := $(basename $(ZIP_FILE))
ZIP_DIR  := $(TARGET_OUT_DIR)/ZIP
OUT_ZIP  := $(TARGET_OUT_DIR)/$(OUT_ZIP_FILE)

# Tool alias used in the makefile
SIGN        := $(TOOL_DIR)/sign.sh $(VERBOSE)
ADDMIUI     := $(TOOL_DIR)/add_miui_smail.sh
ADDMIUIRES  := $(TOOL_DIR)/add_miui_res.sh $(VERBOSE)
PATCH_MIUI_APP  := $(TOOL_DIR)/patch_miui_app.sh $(VERBOSE)
FIX_9PATCH_PNG  := $(TOOL_DIR)/fix_9patch_png.sh $(VERBOSE)
SETPROP     := $(TOOL_DIR)/post_process_props.py
INSERTKEYS  := $(TOOL_DIR)/insertkeys.py
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

PLATFORM_OVERLAY := $(strip $(shell grep "OVERLAY" $(PORT_ROOT)/android/README | cut -d'=' -f2))

MIUI_OVERLAY_RES := $(MIUI_SRC_DIR)/miui/device/xiaomi/patchrom/overlay/frameworks/base/core/res/res
MIUI_OVERLAY_RES += $(addsuffix /frameworks/base/core/res/res, $(addprefix $(MIUI_SRC_DIR)/config-overlay/v6/platform/, $(PLATFORM_OVERLAY))) $(MIUI_SRC_DIR)/config-overlay/v6/common/frameworks/base/core/res/res
MIUI_OVERLAY_RES +=$(addsuffix /frameworks/base/core/res/res, $(addprefix $(MIUI_SRC_DIR)/I18N_res/v6/platform/, $(PLATFORM_OVERLAY))) $(MIUI_SRC_DIR)/I18N_res/v6/common/frameworks/base/core/res/res
OVERLAY_RES := overlay/framework-res/res $(MIUI_OVERLAY_RES)

MIUI_RES := overlay/framework-ext-res/res \
	$(MIUI_SRC_DIR)/miui/device/xiaomi/patchrom/overlay/miui/frameworks/base/core/res/res \
	$(addsuffix /miui/frameworks/base/core/res/res, $(addprefix $(MIUI_SRC_DIR)/I18N_res/v6/platform/, $(PLATFORM_OVERLAY))) \
	$(MIUI_SRC_DIR)/I18N_res/v6/common/miui/frameworks/base/core/res/res \
	$(MIUI_SRC_DIR)/frameworks/base/core/res/res \
	$(MIUI_SRC_DIR)/frameworks/opt/ToggleManager/res

JARS        := $(MIUI_JARS) $(PHONE_JARS)
BLDAPKS     := $(addprefix $(TARGET_OUT_DIR)/,$(addsuffix .apk,$(APPS)))
JARS_OUTDIR := $(addsuffix .jar.out,$(MIUI_JARS))
APPS_OUTDIR := $(APPS)
BLDJARS     := $(addprefix $(TARGET_OUT_DIR)/,$(addsuffix .jar,$(JARS)))
PHN_BLDJARS := $(addsuffix -phone,$(BLDJARS))
ZIP_BLDJARS := $(addsuffix -tozip,$(BLDJARS))

SIGNAPKS    := 
TOZIP_APKS  :=
CLEANJAR    :=
CLEANMIUIAPP:=
RELEASE_MIUI:=
MAKE_ATTOP  := make -C $(ANDROID_TOP)

#
# Extract the jar file from ZIP file and replaced the modified smails
# with MIUI features, and these smali files are stored in xxxx.jar.out
# $1: the jar name, such as services
# $2: the dir under build for apktool-decoded files, such as .build/services
define JAR_template
$(TARGET_OUT_DIR)/$(1).jar-phone:$(TARGET_OUT_DIR)/$(1).jar
	$(ADB) remount
	$(ADB) shell stop
	$(ADB) push $$< /system/framework/$(1).jar
	$(ADB) shell start

$(TARGET_OUT_DIR)/$(1).jar-tozip:$(TARGET_OUT_DIR)/$(1).jar
	$(hide) cp $$< $(TARGET_FRAMEWORK_DIR)/$(1).jar
	@touch $$@

source-files-for-$(1) := $$(call all-files-under-dir,$(1).jar.out)
$(TARGET_OUT_DIR)/$(1).jar: $(2)_miui $$(source-files-for-$(1)) 
	@echo ">>> build $$@..."
	$(hide) rm -rf $(2)
	$(hide) cp -r $(1).jar.out/ $(2)
	$(ADDMIUI) $(PORT_ROOT)/android/$(1).jar.out $(2)_miui $(2)
	$(APKTOOL) b $(2) -o $$@
	@echo "<<< build $$@ completed!"

$(2)_miui: $(PREBUILT_JAR_DIR)/$(1).jar
	$(APKTOOL) d -f $$< -o $$@

ifeq ($(USE_ANDROID_OUT),true)
RELEASE_MIUI += $(RELEASE_JAR_DIR)/$(1).jar
$(RELEASE_JAR_DIR)/$(1).jar: $(PREBUILT_JAR_DIR)/$(1).jar
	$(hide) mkdir -p $(RELEASE_JAR_DIR)
	$(hide) cp $$< $$@
endif

# targets for initial workspace
$(1).jar.out:  $(ZIP_FILE)
	$(UNZIP) $(ZIP_FILE) system/framework/$(1).jar -d $(TARGET_OUT_DIR)
	$(APKTOOL) d -f $(TARGET_OUT_DIR)/system/framework/$(1).jar -o $$@
	$(hide) rm $(TARGET_OUT_DIR)/system/framework/$(1).jar

endef

#
# Template to apktool-build the jar-file that is from phone(i.e, not MIUI)
# the decoded smali files are located at JARNAME.jar.out
# $1: the jar name, such as framework2
define JAR_PHONE_template
$(TARGET_OUT_DIR)/$(1).jar-phone:$(TARGET_OUT_DIR)/$(1).jar
	$(ADB) push $$< /system/framework/$(1).jar

$(TARGET_OUT_DIR)/$(1).jar-tozip:$(TARGET_OUT_DIR)/$(1).jar
	$(hide) cp $$< $(ZIP_DIR)/system/framework/$(1).jar
	@touch $$@

source-files-for-$(1) := $$(call all-files-under-dir,$(1).jar.out)
$(TARGET_OUT_DIR)/$(1).jar: $$(source-files-for-$(1)) | $(TARGET_OUT_DIR)
	@echo ">>> build $$@..."
	#$(hide) rm -rf $(TARGET_OUT_DIR)/$(1).jar.out
	$(hide) cp -r $(1).jar.out $(TARGET_OUT_DIR)/
	$(APKTOOL) b $(TARGET_OUT_DIR)/$(1).jar.out -o $$@
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
$(TARGET_OUT_DIR)/$(1).apk: $$(source-files-for-$(2)) $(3) | $(TARGET_OUT_DIR)
	@echo ">>> build $$@..."
ifneq ($(wildcard $(2)),)
	$(hide) cp -r $(2) $(TARGET_OUT_DIR)
	$(hide) find $(TARGET_OUT_DIR)/$(2) -name "*.part" -exec rm {} \;
	$(hide) find $(TARGET_OUT_DIR)/$(2) -name "*.smali.method" -exec rm {} \;
endif
	$(APKTOOL) b -p $(TARGET_OUT_DIR)/apktool -a $(AAPT) $(TARGET_OUT_DIR)/$(2) -o $$@
	#@echo "9Patch png fix $$@..."
#ifeq ($(3),)
#	$(FIX_9PATCH_PNG) $(1) $(STOCKROM_DIR)/system/$(4) $(TARGET_OUT_DIR)
#else
#	$(FIX_9PATCH_PNG) $(1) $(OUT_APK_PATH:app=$(4)) $(TARGET_OUT_DIR) $(1)/res
#endif
	@echo "fix $$@ completed!"
	@echo "<<< build $$@ completed!"

$(3): $(OUT_APK_PATH:app=$(4))/$(1)/$(1).apk $(TARGET_OUT_DIR)/apktool
	$(hide) rm -rf $(3)
	$(APKTOOL) d -p $(TARGET_OUT_DIR)/apktool -t miui -f $$< -o $(3)
	$(hide) sed -i "/tag:/d" $(3)/apktool.yml
	$(hide) sed -i "s/isFrameworkApk: true/isFrameworkApk: false/g" $(3)/apktool.yml
	$(hide) sed -i "s/package=\"com.miui.core\"/package=\"miui\"/g" $(3)/AndroidManifest.xml
	$(PATCH_MIUI_APP) $(2) $(3)

endef

# Target to build framework-res.apk
# copy the framework-res, add the miui overlay then build
#TODO need to add changed files for all related, and re-install framework-res.apk make sense?
framework-res-overlay-files:= $(call all-files-under-dir,$(OVERLAY_RES))

$(TARGET_OUT_DIR)/framework-res.apk: $(STOCKROM_DIR)/system/framework/framework-res.apk $(framework-res-overlay-files)
	@echo ">>> build $@..."
	$(APKTOOL) d -f $(STOCKROM_DIR)/system/framework/framework-res.apk -o $(TARGET_OUT_DIR)/framework-res
	$(AAPT) p -f -x --auto-add-overlay --wlan-replace Wi-Fi --wlan-replace WiFi \
		--min-sdk-version $(ANDROID_PLATFORM) --target-sdk-version $(ANDROID_PLATFORM) \
		$(addprefix -S ,$(wildcard $(OVERLAY_RES))) \
		-S $(TARGET_OUT_DIR)/framework-res/res -A $(TARGET_OUT_DIR)/framework-res/assets \
		-M $(TARGET_OUT_DIR)/framework-res/AndroidManifest.xml -F $@
	#@echo "9Patch png fix $@..."
	#$(FIX_9PATCH_PNG) framework-res $(STOCKROM_DIR)/system/framework $(TARGET_OUT_DIR) $(MIUI_OVERLAY_RES_DIR) $(OVERLAY_RES_DIR)
	$(APKTOOL) if -p $(APKTOOL_INCLUDE_RES_DIR) $@
	@echo "<<< build $@ completed!"

$(TARGET_OUT_DIR)/framework-ext-res.apk: $(TARGET_OUT_DIR)/framework-res.apk $(APKTOOL_INCLUDE_MIUI_RES)
	$(AAPT) p -f -u --package-id 0x11 --rename-manifest-package com.miui.rom --auto-add-overlay -z --wlan-replace Wi-Fi --wlan-replace WiFi \
		--min-sdk-version $(ANDROID_PLATFORM) --target-sdk-version $(ANDROID_PLATFORM) \
		$(addprefix -S ,$(wildcard $(MIUI_RES))) -M $(MIUI_SRC_DIR)/frameworks/base/core/res/AndroidManifest.xml \
		-I $(APKTOOL_INCLUDE_RES_DIR)/1.apk -I $(APKTOOL_INCLUDE_RES_DIR)/16.apk -I $(PORT_ROOT)/build/empty-res/17.apk -F $@
	$(APKTOOL) if -p $(APKTOOL_INCLUDE_RES_DIR) $@
	@echo "<<< build $@ completed!"

#
# To prepare the workspace to modify the APKs from zip file
# $1 the apk name, also the dir name to save the smali files
# $2 the apk location under system, such as app or framework
define APP_WS_template
$(1): $(ZIP_FILE)
	if $(UNZIP) $(ZIP_FILE) system/$(2)/$(1).apk -d $(TARGET_OUT_DIR) 2>/dev/null; then \
	$(APKTOOL) d -f $(TARGET_OUT_DIR)/system/$(2)/$(1).apk -o $$@ ; else \
	echo system/$(2)/$(1).apk does not exist, ignored!;  fi
	$(hide) rm -f $(TARGET_OUT_DIR)/system/$(2)/$(1).apk
endef

# To decide dir of the apk
# $1 the apk name
define MOD_DIR_template
ifeq ($(USE_ANDROID_OUT),true)
ifeq ($(wildcard $(ANDROID_OUT)/system/priv-app/$(1).apk),$(wildcard $(STOCKROM_DIR)/system/priv-app/$(1).apk))
	$(call SIGN_template,$(TARGET_OUT_DIR)/$(1).apk,/system/app/$(1).apk)
else
	$(call SIGN_template,$(TARGET_OUT_DIR)/$(1).apk,/system/priv-app/$(1).apk)
endif
else
ifeq ($(wildcard $(RELEASE_DIR)/$(DENSITY)/system/priv-app/$(1).apk),$(wildcard $(STOCKROM_DIR)/system/priv-app/$(1).apk))
	$(call SIGN_template,$(TARGET_OUT_DIR)/$(1).apk,/system/app/$(1).apk)
else
	$(call SIGN_template,$(TARGET_OUT_DIR)/$(1).apk,/system/priv-app/$(1).apk)
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
ifeq ($(wildcard $(RELEASE_DIR)/$(DENSITY)/system/priv-app/$(1).apk),)
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

mark-tozip-for-$(1) := $(TARGET_OUT_DIR)/$$(shell basename $(1))-tozip
TOZIP_APKS += $$(mark-tozip-for-$(1))
$$(mark-tozip-for-$(1)) : $(1)
	$(hide) mkdir -p $(shell dirname $(ZIP_DIR)$(2))
	$(hide) cp $(1) $(ZIP_DIR)$(2)
	@touch $$@
endef

zipone: zipfile $(ACT_AFTER_ZIP)

otapackage: metadata target_files
	$(BUILD_TARGET_FILES) $(INCLUDE_THIRDPART_APP)

#> TARGETS EXPANSION START
$(foreach jar, $(MIUI_JARS), \
	$(eval $(call JAR_template,$(jar),$(TARGET_OUT_DIR)/$(jar))))
$(foreach jar, $(PHONE_JARS), \
	$(eval $(call JAR_PHONE_template,$(jar))))

#$(foreach app, $(APPS), \
	$(eval $(call APP_DIR_template,$(app),)))

#$(foreach app, $(MIUI_APPS) , \
	$(eval $(call APP_DIR_template,$(app),$(TARGET_OUT_DIR)/$(app))))

#$(foreach app, $(APPS) $(MIUI_APPS_MOD), \
	$(eval $(call MOD_DIR_template,$(app))))

$(call copy-apks-to-target, $(MIUI_APPS), $(PREBUILT_APP_APK_DIR), $(TARGET_APP_DIR))
$(call copy-apks-to-target, $(MIUI_PRIV_APPS), $(PREBUILT_PRIV_APP_APK_DIR), $(TARGET_PRIV_APP_DIR))
$(eval $(call copy-one-file,$(TARGET_OUT_DIR)/framework-ext-res.apk,$(TARGET_FRAMEWORK_DIR)/framework-ext-res/framework-ext-res.apk))
$(eval $(call copy-one-file,$(TARGET_OUT_DIR)/framework-res.apk,$(TARGET_FRAMEWORK_DIR)/framework-res.apk))

#$(foreach app, $(APPS), \
	$(eval $(call APP_WS_template,$(app),app)))

#$(foreach app, $(APPS), \
	$(eval $(call APP_WS_template,$(app),priv-app)))

$(eval $(call APP_WS_template,framework-res,framework))

#< TARGET EXPANSION END

#> TARGET FOR ZIPFILE START
$(TARGET_OUT_DIR):
	$(hide) mkdir -p $(TARGET_OUT_DIR)

# if the zip file does not exist, would try to generate the zip
# file from the stockrom dirctory if exist
$(ZIP_FILE):
	$(hide) cd $(STOCKROM_DIR) && $(ZIP) -r ../$(ZIP_FILE) ./
	$(hide) touch .delete-zip-file-when-clean

# if the zip dir does not exist, would try to unzip stockrom.zip
$(STOCKROM_DIR): $(ZIP_FILE) | $(TARGET_OUT_DIR)
	$(UNZIP) -n $(ZIP_FILE) -d $@

$(ZIP_DIR): $(ZIP_FILE)
	$(UNZIP) $(ZIP_FILE) -d $@
ifneq ($(strip $(local-phone-apps)),)
	$(hide) mv $(ZIP_DIR)/system/app $(ZIP_DIR)/system/app.original
	$(hide) mkdir $(ZIP_DIR)/system/app
	$(hide) for apk in $(local-phone-apps); do\
		cp -rf $(ZIP_DIR)/system/app.original/$$apk $(ZIP_DIR)/system/app; \
	done
	$(hide) rm -rf $(ZIP_DIR)/system/app.original
endif
ifneq ($(strip $(local-phone-priv-apps)),)
	$(hide) mv $(ZIP_DIR)/system/priv-app $(ZIP_DIR)/system/priv-app.original
	$(hide) mkdir $(ZIP_DIR)/system/priv-app
	$(hide) for apk in $(local-phone-priv-apps); do\
		cp -rf $(ZIP_DIR)/system/priv-app.original/$$apk $(ZIP_DIR)/system/priv-app; \
	done
	$(hide) rm -rf $(ZIP_DIR)/system/priv-app.original
endif

$(APKTOOL_INCLUDE_VENDOR_RES): $(ZIP_FILE) | $(TARGET_OUT_DIR)
	@echo ">>> Install vendor resources for apktool..."
	$(UNZIP) $(ZIP_FILE) "system/framework/*.apk" -d $(TARGET_OUT_DIR)
	$(hide) for res_file in `find $(TARGET_OUT_DIR)/system/framework/ -name "*.apk"`; \
			do \
				echo install $$res_file ; \
				$(APKTOOL) if -p $(TARGET_OUT_DIR)/apktool $$res_file; \
			done
	$(hide) rm -r $(TARGET_OUT_DIR)/system/framework


$(APKTOOL_INCLUDE_MIUI_RES): $(PREBUILT_RES_DIR)/framework-res.apk $(MIUI_EXT_RES_APKS)
	@echo ">>> Install framework resources for apktool..."
	$(APKTOOL) if -p $(TARGET_OUT_DIR)/apktool $(PREBUILT_RES_DIR)/framework-res.apk -t miui
	$(hide) for res_file in $(MIUI_EXT_RES_APKS); \
			do\
				echo install $$res_file ; \
				$(APKTOOL) if -p $(TARGET_OUT_DIR)/apktool $$res_file; \
			done

remove-rund-apks:
	@echo ">>> remove all unnecessary apks from original ZIP file..."
	$(hide) rm -rf $(addprefix $(ZIP_DIR)/system/app/, $(RUNDAPKS))
	$(hide) rm -rf $(addprefix $(ZIP_DIR)/system/priv-app/, $(RUNDAPKS))
	@echo "<<< remove done!"

pre-zip-misc: set-build-prop add-device-feature
pre-zip-misc: merge-preloaded-classes insertkeys-mac_permissions
pre-zip-misc: patch-bootimg

set-build-prop: OVERLAY_PROP := $(TARGET_OUT_DIR)/overlay.prop
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
	cp -rf $(PORT_BUILD)/device_features.xml $(FEATURE_DIR)/$$device_name.xml; \

insertkeys-mac_permissions: MAC_PERMS_FILE := system/etc/security/mac_permissions.xml
insertkeys-mac_permissions: | $(ZIP_DIR)
	@echo "Replace keys in mac_permissions.xml"
	$(hide) cp -f $(STOCKROM_DIR)/$(MAC_PERMS_FILE) $(TARGET_OUT_DIR)/mac_permissions.xml
	$(hide) -sed -i "s/$(call get-key-in-mac-perms,$(STOCKROM_DIR)/$(MAC_PERMS_FILE),platform)/@PLATFORM/" $(TARGET_OUT_DIR)/mac_permissions.xml
	$(hide) -sed -i "s/$(call get-key-in-mac-perms,$(STOCKROM_DIR)/$(MAC_PERMS_FILE),media)/@MEDIA/" $(TARGET_OUT_DIR)/mac_permissions.xml
	$(hide) -sed -i "s/$(call get-key-in-mac-perms,$(STOCKROM_DIR)/$(MAC_PERMS_FILE),shared)/@SHARED/" $(TARGET_OUT_DIR)/mac_permissions.xml
	$(hide) DEFAULT_SYSTEM_DEV_CERTIFICATE="$(CERTIFICATE_DIR)" \
		$(INSERTKEYS) -o $(ZIP_DIR)/$(MAC_PERMS_FILE) $(KEYS_CONF) $(TARGET_OUT_DIR)/mac_permissions.xml

merge-preloaded-classes: | $(ZIP_DIR)
	@echo "Merge preload classes"
	$(hide) cat $(STOCKROM_DIR)/system/etc/preloaded-classes >> $(TARGET_ETC_DIR)/preloaded-classes
	$(hide) mv $(TARGET_ETC_DIR)/preloaded-classes $(TARGET_ETC_DIR)/preloaded-classes.tmp
	$(hide) sort $(TARGET_ETC_DIR)/preloaded-classes.tmp | uniq > $(TARGET_ETC_DIR)/preloaded-classes
	$(hide) rm $(TARGET_ETC_DIR)/preloaded-classes.tmp

patch-bootimg: $(PATCH_BOOTIMG_SH) $(UNPACKBOOTIMG) $(MKBOOTFS) $(MKBOOTIMG) $(TARGET_OUT_DIR)/ZIP/boot.img
	@echo "Patching bootimg"
	$(hide) TARGET_BOOT_DIR=$(TARGET_BOOT_DIR) PREBUILT_BOOT_DIR=$(PREBUILT_BOOT_DIR) \
			$(if $(filter $(USE_ANDROID_OUT),true) ,,TARGET_BIT=$(PREBUILT_BIT)) \
			UNPACKBOOTIMG=$(UNPACKBOOTIMG) MKBOOTFS=$(MKBOOTFS) MKBOOTIMG=$(MKBOOTIMG) \
			bash $(PATCH_BOOTIMG_SH) $(TARGET_OUT_DIR)/ZIP/boot.img 
	

target_files: $(STOCKROM_DIR) | $(ZIP_DIR) 
target_files: add-miui-prebuilt
target_files: $(foreach app_name, $(MIUI_APPS),$(TARGET_APP_DIR)/$(app_name)/$(app_name).apk)
target_files: $(foreach app_name, $(MIUI_PRIV_APPS),$(TARGET_PRIV_APP_DIR)/$(app_name)/$(app_name).apk)
target_files: $(TARGET_FRAMEWORK_DIR)/framework-res.apk $(TARGET_FRAMEWORK_DIR)/framework-ext-res/framework-ext-res.apk
target_files: $(ZIP_BLDJARS) $(ACT_PRE_ZIP)

# Target to make zipfile which is all signed by testkey. convenient for developement and debug
zipfile: BUILD_NUMBER := 01.$(ROM_BUILD_NUMBER)
zipfile: target_files $(TARGET_OUT_DIR)/sign-zipfile-dir
	$(BUILD_TARGET_FILES) $(INCLUDE_THIRDPART_APP) -n $(OUT_ZIP_FILE)
	@echo The output zip file is: $(OUT_ZIP)

#TODO add all depend sign..
$(TARGET_OUT_DIR)/sign-zipfile-dir:
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
