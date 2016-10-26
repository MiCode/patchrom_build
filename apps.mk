
#
# Copyright (C) 2016 The Miui Patchrom
#

MIUI_APP_BLACKLIST += InputDevices MusicFX SharedStorageBackup OneTimeInitializer ProxyHandler GooglePinyinIME \
	Shell FusedLocation BackupRestoreConfirmation ExternalStorageProvider PhotoTable PrintSpooler \
	WAPPushManager MagicSmokeWallpapers VisualizationWallpapers BasicDreams PhaseBeam HoloSpiralWallpaper \
	Bluetooth Galaxy4 LiveWallpapers PicoTts CertInstaller KeyChain NoiseField PacProcessor Camera2 \
	TrafficControl


ALL_MIUI_PRIV_APPS :=
$(foreach app, $(subst .apk,,$(shell find $(PREBUILT_PRIV_APP_APK_DIR) -name "*.apk" -exec basename {} \;)), \
	    $(eval ALL_MIUI_PRIV_APPS += $(app)))

MIUI_PRIV_APPS := $(filter-out $(MIUI_APP_BLACKLIST),$(ALL_MIUI_PRIV_APPS))


ALL_MIUI_APPS :=
$(foreach app, $(subst .apk,,$(shell find $(PREBUILT_APP_APK_DIR) -name "*.apk" -exec basename {} \;)), \
	        $(eval ALL_MIUI_APPS += $(app)))

MIUI_APPS := $(filter-out $(MIUI_APP_BLACKLIST),$(ALL_MIUI_APPS))

TARGET_APPS := $(foreach app_name, $(MIUI_APPS),$(TARGET_APP_DIR)/$(app_name)/$(app_name).apk) \
	$(foreach app_name, $(MIUI_PRIV_APPS),$(TARGET_PRIV_APP_DIR)/$(app_name)/$(app_name).apk) \

# Define a rule to modify miui app.  For use via $(eval).
# $1: the apk name, such as LogsProvider
define miui_app_mod_template
ifeq ($(wildcard $(PREBUILT_APP_APK_DIR)/$(1)/$(1).apk),)
prebuilt-apk-path := $(PREBUILT_PRIV_APP_APK_DIR)/$(1)/$(1).apk
else
prebuilt-apk-path := $(PREBUILT_APP_APK_DIR)/$(1)/$(1).apk
endif
source-files-for-$(1) := $$(call all-files-under-dir,$(1))
apkcert := $$(shell $(GET_APK_CERT) $(1).apk $(MIUI_APK_CERT_TXT))

$(TARGET_OUT_DIR)/$(1): $$(prebuilt-apk-path) $$(source-files-for-$(1)) $(APKTOOL_INCLUDE_MIUI_RES) $(APKTOOL_INCLUDE_VENDOR_RES)
	$(APKTOOL) d -p $(TARGET_OUT_DIR)/apktool -t miui -f $$< -o $(TARGET_OUT_DIR)/$(1)
	$(hide) sed -i "/tag:/d" $$@/apktool.yml
	$(hide) sed -i "s/isFrameworkApk: true/isFrameworkApk: false/g" $$@/apktool.yml
	$(hide) sed -i "s/package=\"com.miui.core\"/package=\"miui\"/g" $$@/AndroidManifest.xml
	$(PATCH_MIUI_APP) $(1) $$@

$(TARGET_OUT_DIR)/$(1).apk: $(TARGET_OUT_DIR)/$(1)
	@echo ">>> build $$@..."
ifneq ($(wildcard $(1)),)
	$(hide) cp -r $(1) $(TARGET_OUT_DIR)
endif
	$(APKTOOL) b -p $(TARGET_OUT_DIR)/apktool -a $(AAPT) $(TARGET_OUT_DIR)/$(1) -o $$@
	@echo "9Patch png fix $$@..."
	$(FIX_9PATCH_PNG) $(1) $$(dir $$(prebuilt-apk-path)) $(TARGET_OUT_DIR) $(1)/res
	@echo "sign $$(apkcert) key for $$@..."
	$(hide) java -jar $(TOOLS_DIR)/signapk.jar $(CERTIFICATE_DIR)/$$(apkcert).x509.pem $(CERTIFICATE_DIR)/$$(apkcert).pk8 $$@ $$@.signed
	$(hide) mv $$@.signed $$@
	@echo "<<< build $$@ completed!"

TARGET_APPS += $(TARGET_OUT_DIR)/$(1).apk
endef

$(foreach app, $(MOD_MIUI_APPS) , \
	$(eval $(call miui_app_mod_template,$(app))))
