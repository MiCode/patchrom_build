add-prebuilt-app: $(ZIP_DIR)/system/xbin/busybox
	@echo To add prebuilt apps
	$(hide) cp -f $(SYSOUT_DIR)/xbin/shelld $(ZIP_DIR)/system/xbin/
	$(hide) mkdir -p $(ZIP_DIR)/data/media
	$(hide) cp -rf $(DATAOUT_DIR)/media/preinstall_apps/ $(ZIP_DIR)/data/media/

$(ZIP_DIR)/system/xbin/busybox:
	$(hide) cp -f $(SYSOUT_DIR)/xbin/busybox $(ZIP_DIR)/system/xbin/

add-prebuilt-libraries:
	@echo To add prebuilt libraries
	$(hide) cp -f $(SYSOUT_DIR)/lib/content-types.properties $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libffmpeg_xm.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libffplayer_jni.so $(ZIP_DIR)/system/lib/
	#$(hide) cp -f $(SYSOUT_DIR)/framework/miui-framework.jar $(ZIP_DIR)/system/framework/
	#$(hide) cp -f $(SYSOUT_DIR)/lib/libjni_latinime.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/liblocSDK_*.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libjni_resource_drm.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libjni_resource_patcher.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libaudiofp.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libshell_jni.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libshell.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libshellservice.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libphotocli.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libimageutilities_jni.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libpatcher_jni.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/fonts/TobysHand.ttf $(ZIP_DIR)/system/fonts/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libmp3lame.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libFreqFilter.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libimageprocessor_jni.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libMiuiGalleryJNI.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libkeygen_jni.so $(ZIP_DIR)/system/lib/
ifneq ($(filter jellybean42, $(PATCHROM_BRANCH)),)
	$(hide) cp -f $(SYSOUT_DIR)/fonts/Miui-Bold.ttf $(ZIP_DIR)/system/fonts/
	$(hide) cp -f $(SYSOUT_DIR)/fonts/Miui-Regular.ttf $(ZIP_DIR)/system/fonts/
endif

add-prebuilt-media:
	@echo To add prebuilt media files
	$(hide) cp -rf $(SYSOUT_DIR)/media $(ZIP_DIR)/system

add-prebuilt-etc-files:
	@echo To add prebuilt files under etc
	$(hide) cp -f $(SYSOUT_DIR)/etc/apns-conf.xml $(ZIP_DIR)/system/etc/
	$(hide) cp -rf $(SYSOUT_DIR)/etc/license/ $(ZIP_DIR)/system/etc/
	$(hide) cp -f $(SYSOUT_DIR)/etc/yellowpage.db $(ZIP_DIR)/system/etc/
	$(hide) cp -f $(SYSOUT_DIR)/etc/telocation.idf $(ZIP_DIR)/system/etc/
	#$(hide) cp -f $(SYSOUT_DIR)/etc/permissions/miui-framework.xml $(ZIP_DIR)/system/etc/permissions/
	#$(hide) cp -f $(SYSOUT_DIR)/etc/unicode_py_index.td $(ZIP_DIR)/system/etc/
	$(hide) cp -f $(SYSOUT_DIR)/etc/pinyinindex.idf $(ZIP_DIR)/system/etc/
	$(hide) cp -f $(SYSOUT_DIR)/etc/weather_city.db $(ZIP_DIR)/system/etc/
	$(hide) cp -f $(SYSOUT_DIR)/etc/permission_config.json $(ZIP_DIR)/system/etc/

add-lbesec-miui:
	@echo To add LBESEC_MIUI
	$(hide) cp -f $(SYSOUT_DIR)/lib/liblbesec.so $(ZIP_DIR)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/bin/installd $(ZIP_DIR)/system/bin
	$(hide) cp -f $(SYSOUT_DIR)/app/LBESEC_MIUI.apk $(ZIP_DIR)/system/app
	$(hide) cp -f $(SYSOUT_DIR)/xbin/su $(ZIP_DIR)/system/xbin/

add-skia-emoji:
	@echo To add Skia Emoji support
	$(hide) cp -f $(SYSOUT_DIR)/lib/libskia.so $(ZIP_DIR)/sysem/lib
	$(hide) cp -f $(SYSOUT_DIR)/lib/libhwui.so $(ZIP_DIR)/system/lib

release-prebuilt-app:
	@echo Release prebuilt apps
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/xbin
	$(hide) cp $(SYSOUT_DIR)/xbin/shelld $(RELEASE_PATH)/$(DENSITY)/system/xbin/
	$(hide) cp $(SYSOUT_DIR)/xbin/busybox $(RELEASE_PATH)/$(DENSITY)/system/xbin/
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/bin
	$(hide) cp $(SYSOUT_DIR)/bin/installd $(RELEASE_PATH)/$(DENSITY)/system/bin/
	$(hide) cp -f $(SYSOUT_DIR)/app/LBESEC_MIUI.apk $(RELEASE_PATH)/$(DENSITY)/system/app
	$(hide) cp -f $(SYSOUT_DIR)/xbin/su $(RELEASE_PATH)/$(DENSITY)/system/xbin/
	$(hide) mkdir -p $(RELEASE_PATH)/data/media
	$(hide) cp -rf $(DATAOUT_DIR)/media/preinstall_apps/ $(RELEASE_PATH)/data/media/


release-prebuilt-libraries:
	@echo Release prebuilt libraries
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/lib
	$(hide) cp -f $(SYSOUT_DIR)/lib/liblbesec.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libskia.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libhwui.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/content-types.properties $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libffmpeg_xm.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libffplayer_jni.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	#$(hide) cp -f $(SYSOUT_DIR)/framework/miui-framework.jar $(RELEASE_PATH)/$(DENSITY)/system/framework/
	#$(hide) cp -f $(SYSOUT_DIR)/lib/libjni_latinime.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/liblocSDK_*.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libjni_resource_drm.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libjni_resource_patcher.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libaudiofp.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libshell_jni.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libshell.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libshellservice.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libphotocli.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libimageutilities_jni.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libpatcher_jni.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libmp3lame.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/fonts/
	$(hide) cp -f $(SYSOUT_DIR)/fonts/TobysHand.ttf $(RELEASE_PATH)/$(DENSITY)/system/fonts/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libFreqFilter.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libimageprocessor_jni.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libMiuiGalleryJNI.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
	$(hide) cp -f $(SYSOUT_DIR)/lib/libkeygen_jni.so $(RELEASE_PATH)/$(DENSITY)/system/lib/
ifneq ($(filter jellybean42, $(PATCHROM_BRANCH)),)
	$(hide) cp -f $(SYSOUT_DIR)/fonts/Miui-Bold.ttf $(RELEASE_PATH)/$(DENSITY)/system/fonts/
	$(hide) cp -f $(SYSOUT_DIR)/fonts/Miui-Regular.ttf $(RELEASE_PATH)/$(DENSITY)/system/fonts/
endif

release-prebuilt-media:
	@echo Release prebuilt media files
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/media
	$(hide) cp -rf $(SYSOUT_DIR)/media $(RELEASE_PATH)/$(DENSITY)/system

release-prebuilt-etc-files:
	@echo Release prebuilt etc-files
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/etc
	$(hide) cp -rf $(SYSOUT_DIR)/etc/apns-conf.xml $(RELEASE_PATH)/$(DENSITY)/system/etc/
	$(hide) cp -rf $(SYSOUT_DIR)/etc/license/ $(RELEASE_PATH)/$(DENSITY)/system/etc/
	$(hide) cp -rf $(SYSOUT_DIR)/etc/yellowpage.db $(RELEASE_PATH)/$(DENSITY)/system/etc/
	$(hide) cp -rf $(SYSOUT_DIR)/etc/telocation.idf $(RELEASE_PATH)/$(DENSITY)/system/etc/
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/etc/permissions/
	#$(hide) cp -rf $(SYSOUT_DIR)/etc/permissions/miui-framework.xml $(RELEASE_PATH)/$(DENSITY)/system/etc/permissions/
	#$(hide) cp -rf $(SYSOUT_DIR)/etc/unicode_py_index.td $(RELEASE_PATH)/$(DENSITY)/system/etc/
	$(hide) cp -rf $(SYSOUT_DIR)/etc/pinyinindex.idf $(RELEASE_PATH)/$(DENSITY)/system/etc/
	$(hide) cp -rf $(SYSOUT_DIR)/etc/weather_city.db $(RELEASE_PATH)/$(DENSITY)/system/etc/
	$(hide) cp -rf $(SYSOUT_DIR)/etc/permission_config.json $(RELEASE_PATH)/$(DENSITY)/system/etc/

release-miui-resources:
	@echo release miui resources
	$(hide) mkdir -p $(RELEASE_PATH)/src/frameworks/miui
	$(hide) cp -r $(ANDROID_TOP)/frameworks/miui/overlay $(RELEASE_PATH)/src/frameworks/miui
	$(hide) mkdir -p $(RELEASE_PATH)/src/frameworks/miui/core/res
	$(hide) cp -r $(ANDROID_TOP)/frameworks/miui/core/res/res $(RELEASE_PATH)/src/frameworks/miui/core/res
	$(hide) cd $(ANDROID_TOP); tar -cf $(RELEASE_PATH)/src/res.tar packages/apps/*/res
	$(hide) cd $(RELEASE_PATH)/src;tar -xf res.tar;rm res.tar

add-miui-prebuilt: add-prebuilt-app add-prebuilt-libraries add-prebuilt-media add-prebuilt-etc-files add-lbesec-miui
	@echo Add miui prebuilt completed!

release-miui-prebuilt: release-prebuilt-app release-prebuilt-libraries release-prebuilt-media release-prebuilt-etc-files release-miui-resources
	@echo Release MIUI prebuilt completed!
