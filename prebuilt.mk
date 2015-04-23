#
# Copyright (C) 2012 The Miui Patchrom
#

add-prebuilt-files:
	@echo To add prebuilt files
	$(call copy-apks-lib,$(MIUI_APPS),$(PREBUILT_APP_LIB_DIR),$(TARGET_APP_DIR))
	$(call copy-apks-lib,$(MIUI_PRIV_APPS),$(PREBUILT_PRIV_APP_LIB_DIR),$(TARGET_PRIV_APP_DIR))
	$(call copy-prebuilt-files,$(PREBUILT_LIB_DIR),$(TARGET_LIB_DIR),lib)
	$(call copy-prebuilt-files,$(PREBUILT_LIB64_DIR),$(TARGET_LIB64_DIR),lib64)
	$(call copy-prebuilt-files,$(PREBUILT_JAR_DIR),$(TARGET_FRAMEWORK_DIR),framework)
	$(call copy-prebuilt-files,$(PREBUILT_ETC_DIR),$(TARGET_ETC_DIR),etc)
	$(call copy-prebuilt-files,$(PREBUILT_BIN_DIR),$(TARGET_BIN_DIR),bin)
	$(call copy-prebuilt-files,$(PREBUILT_XBIN_DIR),$(TARGET_XBIN_DIR),xbin)
	$(call copy-prebuilt-files,$(PREBUILT_MEDIA_DIR),$(TARGET_MEDIA_DIR),media)
	$(hide) cp -f $(PREBUILT_FONTS_DIR)/Miui*.ttf $(TARGET_FONTS_DIR)/
	$(hide) -cp -f $(STOCKROM_DIR)/system/bin/app_process64 $(TARGET_BIN_DIR)/app_process64_vendor
	$(hide) -mv -f $(TARGET_BIN_DIR)/app_process64_miui $(TARGET_BIN_DIR)/app_process64
	$(hide) -cp -f $(STOCKROM_DIR)/system/bin/app_process32 $(TARGET_BIN_DIR)/app_process32_vendor
	$(hide) -mv -f $(TARGET_BIN_DIR)/app_process32_miui $(TARGET_BIN_DIR)/app_process32

add-preinstall-files:
	@echo To add preintall files
	$(hide) mkdir -p $(ZIP_DIR)/data/miui/cust/cn
	$(hide) cp -rf $(PREBUILT_CUST_DIR)/data/cn/* $(TARGET_DATA_DIR)/miui/cust/cn/
	$(hide) cp -rf $(PREBUILT_DATA_DIR)/miui $(TARGET_DATA_DIR)/
	$(hide) find $(TARGET_DATA_DIR)/miui/app -name "ota-*.apk" -prune -o -name "*.apk" -print \
		-exec rm -f {} \; > /dev/null


add-miui-prebuilt: add-prebuilt-files add-preinstall-files
	@echo Add miui prebuilt completed!
