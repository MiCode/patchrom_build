add-prebuilt-app: $(ZIP_DIR)/system/xbin/busybox
	@echo To add prebuilt apps
	$(HIDEC) cp -f $(SYSOUT_DIR)/xbin/invoke-as $(ZIP_DIR)/system/xbin/

$(ZIP_DIR)/system/xbin/busybox:
	$(HIDEC) cp -f $(SYSOUT_DIR)/xbin/busybox $(ZIP_DIR)/system/xbin/

add-prebuilt-libraries:
	@echo To add prebuilt libraries
	$(HIDEC) cp -f $(SYSOUT_DIR)/lib/content-types.properties $(ZIP_DIR)/system/lib/

add-prebuilt-media:
	@echo To add prebuilt media files
	$(HIDEC) cp -rf $(SYSOUT_DIR)/media $(ZIP_DIR)/system

add-prebuilt-etc-files:
	@echo To add prebuilt files under etc
	$(HIDEC) cp -f $(SYSOUT_DIR)/etc/apns-conf.xml $(ZIP_DIR)/system/etc/
	$(HIDEC) cp -rf $(SYSOUT_DIR)/etc/license/ $(ZIP_DIR)/system/etc/
	$(HIDEC) cp -f $(SYSOUT_DIR)/etc/telocation.db $(ZIP_DIR)/system/etc/
	$(HIDEC) cp -f $(SYSOUT_DIR)/etc/yellowpage.db $(ZIP_DIR)/system/etc/

add-lbesec-miui:
	@echo To add LBESEC_MIUI
	$(HIDEC) cp -f $(SYSOUT_DIR)/lib/liblbesec.so $(ZIP_DIR)/system/lib/
	$(HIDEC) cp -f $(SYSOUT_DIR)/bin/installd $(ZIP_DIR)/system/bin
	$(HIDEC) cp -f $(SYSOUT_DIR)/app/LBESEC_MIUI.apk $(ZIP_DIR)/system/app
	$(HIDEC) cp -f $(SYSOUT_DIR)/xbin/su $(ZIP_DIR)/system/xbin/

add-skia-emoji:
	@echo To add Skia Emoji support
	$(HIDEC) cp -f $(SYSOUT_DIR)/lib/libskia.so $(ZIP_DIR)/sysem/lib
	$(HIDEC) cp -f $(SYSOUT_DIR)/lib/libhwui.so $(ZIP_DIR)/system/lib

release-prebuilt-app:
	@echo Release prebuilt apps
	$(HIDEC) mkdir -p $(RELEASE_PATH)/system/xbin
	$(HIDEC) cp $(SYSOUT_DIR)/xbin/invoke-as $(RELEASE_PATH)/system/xbin/
	$(HIDEC) cp $(SYSOUT_DIR)/xbin/busybox $(RELEASE_PATH)/system/xbin/
	$(HIDEC) mkdir -p $(RELEASE_PATH)/system/bin
	$(HIDEC) cp $(SYSOUT_DIR)/bin/installd $(RELEASE_PATH)/system/bin/

release-prebuilt-libraries:
	@echo Release prebuilt libraries
	$(HIDEC) mkdir -p $(RELEASE_PATH)/system/lib
	$(HIDEC) cp -f $(SYSOUT_DIR)/lib/liblbesec.so $(RELEASE_PATH)/system/lib/
	$(HIDEC) cp -f $(SYSOUT_DIR)/lib/libnativecache.so $(RELEASE_PATH)/system/lib/
	$(HIDEC) cp -f $(SYSOUT_DIR)/lib/libservice.so $(RELEASE_PATH)/system/lib/
	$(HIDEC) cp -f $(SYSOUT_DIR)/lib/libskia.so $(RELEASE_PATH)/system/lib/
	$(HIDEC) cp -f $(SYSOUT_DIR)/lib/libhwui.so $(RELEASE_PATH)/system/lib/
	$(HIDEC) cp -f $(SYSOUT_DIR)/lib/content-types.properties $(RELEASE_PATH)/system/lib/

release-prebuilt-media:
	@echo Release prebuilt media files
	$(HIDEC) mkdir -p $(RELEASE_PATH)/system/media
	$(HIDEC) cp -rf $(SYSOUT_DIR)/media $(RELEASE_PATH)/system

release-prebuilt-etc-files:
	@echo Release prebuilt etc-files
	$(HIDEC) mkdir -p $(RELEASE_PATH)/system/etc
	$(HIDEC) cp -rf $(SYSOUT_DIR)/etc/apns-conf.xml $(RELEASE_PATH)/system/etc/
	$(HIDEC) cp -rf $(SYSOUT_DIR)/etc/license/ $(RELEASE_PATH)/system/etc/
	$(HIDEC) cp -rf $(SYSOUT_DIR)/etc/telocation.db $(RELEASE_PATH)/system/etc/
	$(HIDEC) cp -rf $(SYSOUT_DIR)/etc/yellowpage.db $(RELEASE_PATH)/system/etc/

release-miui-resources:
	@echo release miui resources
	$(HIDEC) mkdir -p $(RELEASE_PATH)/src/frameworks/miui
	$(HIDEC) cp -r $(ANDROID_TOP)/frameworks/miui/overlay $(RELEASE_PATH)/src/frameworks/miui
	$(HIDEC) mkdir -p $(RELEASE_PATH)/src/frameworks/miui/core/res
	$(HIDEC) cp -r $(ANDROID_TOP)/frameworks/miui/core/res/res $(RELEASE_PATH)/src/frameworks/miui/core/res

add-miui-prebuilt: add-prebuilt-app add-prebuilt-libraries add-prebuilt-media add-prebuilt-etc-files
	@echo Add miui prebuilt completed!

release-miui-prebuilt: release-prebuilt-app release-prebuilt-libraries release-prebuilt-media release-prebuilt-etc-files release-miui-resources
	@echo Release MIUI prebuilt completed!
