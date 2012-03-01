add-prebuilt-app: $(ZIP_DIR)/system/xbin/busybox
	@echo Add prebuilt apps
	cp -f $(SYSOUT_DIR)/xbin/invoke-as $(ZIP_DIR)/system/xbin/

$(ZIP_DIR)/system/xbin/busybox:
	cp -f $(SYSOUT_DIR)/xbin/busybox $(ZIP_DIR)/system/xbin/

add-prebuilt-libraries:
	@echo Add prebuilt libraries
	cp -f $(SYSOUT_DIR)/lib/content-types.properties $(ZIP_DIR)/system/lib/

add-prebuilt-media:
	@echo Add prebuilt media files
	cp -rf $(SYSOUT_DIR)/media $(ZIP_DIR)/system

add-prebuilt-etc-files:
	@echo Add prebuilt files under etc
	cp -f $(SYSOUT_DIR)/etc/apns-conf.xml $(ZIP_DIR)/system/etc/
	cp -rf $(SYSOUT_DIR)/etc/license/ $(ZIP_DIR)/system/etc/
	cp -f $(SYSOUT_DIR)/etc/telocation.db $(ZIP_DIR)/system/etc/
	cp -f $(SYSOUT_DIR)/etc/yellowpage.db $(ZIP_DIR)/system/etc/

add-lbesec-miui:
	@echo Add LBESEC_MIUI
	cp -f $(SYSOUT_DIR)/lib/liblbesec.so $(ZIP_DIR)/system/lib/
	cp -f $(SYSOUT_DIR)/lib/libnativecache.so $(ZIP_DIR)/system/lib/
	cp -f $(SYSOUT_DIR)/lib/libservice.so $(ZIP_DIR)/system/lib/
	cp -f $(SYSOUT_DIR)/bin/installd $(ZIP_DIR)/system/bin
	cp -f $(SYSOUT_DIR)/app/LBESEC_MIUI.apk $(ZIP_DIR)/system/app

add-skia-emoji:
	@echo Add Skia Emoji support
	cp -f $(SYSOUT_DIR)/lib/libskia.so $(ZIP_DIR)/sysem/lib
	cp -f $(SYSOUT_DIR)/lib/libhwui.so $(ZIP_DIR)/system/lib

release-prebuilt-app:
	mkdir -p $(RELEASE_PATH)/system/xbin
	cp $(SYSOUT_DIR)/xbin/invoke-as $(RELEASE_PATH)/system/xbin/
	cp $(SYSOUT_DIR)/xbin/busybox $(RELEASE_PATH)/system/xbin/
	mkdir -p $(RELEASE_PATH)/system/bin
	cp $(SYSOUT_DIR)/bin/installd $(RELEASE_PATH)/system/bin/

release-prebuilt-libraries:
	mkdir -p $(RELEASE_PATH)/system/lib
	cp -f $(SYSOUT_DIR)/lib/liblbesec.so $(RELEASE_PATH)/system/lib/
	cp -f $(SYSOUT_DIR)/lib/libnativecache.so $(RELEASE_PATH)/system/lib/
	cp -f $(SYSOUT_DIR)/lib/libservice.so $(RELEASE_PATH)/system/lib/
	cp -f $(SYSOUT_DIR)/lib/libskia.so $(RELEASE_PATH)/system/lib/
	cp -f $(SYSOUT_DIR)/lib/libhwui.so $(RELEASE_PATH)/system/lib/
	cp -f $(SYSOUT_DIR)/lib/content-types.properties $(RELEASE_PATH)/system/lib/

release-prebuilt-media:
	mkdir -p $(RELEASE_PATH)/system/media
	cp -rf $(SYSOUT_DIR)/media $(RELEASE_PATH)/system

release-prebuilt-etc-files:
	mkdir -p $(RELEASE_PATH)/system/etc
	cp -rf $(SYSOUT_DIR)/etc/apns-conf.xml $(RELEASE_PATH)/system/etc/
	cp -rf $(SYSOUT_DIR)/etc/license/ $(RELEASE_PATH)/system/etc/
	cp -rf $(SYSOUT_DIR)/etc/telocation.db $(RELEASE_PATH)/system/etc/
	cp -rf $(SYSOUT_DIR)/etc/yellowpage.db $(RELEASE_PATH)/system/etc/

release-miui-resources:
	mkdir -p $(RELEASE_PATH)/src/frameworks/miui
	cp -r $(ANDROID_TOP)/frameworks/miui/overlay $(RELEASE_PATH)/src/frameworks/miui
	mkdir -p $(RELEASE_PATH)/src/frameworks/miui/core/res
	cp -r $(ANDROID_TOP)/frameworks/miui/core/res/res $(RELEASE_PATH)/src/frameworks/miui/core/res

add-miui-prebuilt: add-prebuilt-app add-prebuilt-libraries add-prebuilt-media add-prebuilt-etc-files

release-miui-prebuilt: release-prebuilt-app release-prebuilt-libraries release-prebuilt-media release-prebuilt-etc-files release-miui-resources
