add-prebuilt-binaries:
	@echo To add prebuilt binaries
	$(hide) cp -f $(SYSOUT_DIR)/xbin/shelld $(ZIP_DIR)/system/xbin
	$(hide) cp -f $(SYSOUT_DIR)/xbin/busybox $(ZIP_DIR)/system/xbin
	$(hide) cp -f $(SYSOUT_DIR)/xbin/su $(ZIP_DIR)/system/xbin
	$(hide) cp -f $(SYSOUT_DIR)/bin/servicemanager $(ZIP_DIR)/system/bin
	$(hide) cp -f $(SYSOUT_DIR)/bin/app_process_miui $(ZIP_DIR)/system/bin/app_process
	$(hide) cp -f $(STOCKROM_DIR)/system/bin/debuggerd $(ZIP_DIR)/system/bin/debuggerd_vendor
	$(hide) cp -f $(SYSOUT_DIR)/bin/debuggerd_miui $(ZIP_DIR)/system/bin/debuggerd
	$(hide) cp -f $(STOCKROM_DIR)/system/bin/dexopt $(ZIP_DIR)/system/bin/dexopt_vendor
	$(hide) cp -f $(SYSOUT_DIR)/bin/dexopt_miui $(ZIP_DIR)/system/bin/dexopt


add-prebuilt-libraries:
	@echo To add prebuilt libraries
ifeq ($(USE_ANDROID_OUT),true)
	$(hide) for file in `find $(SYSOUT_DIR)/lib -type f`; do \
		file=`echo $$file | sed "s#$(SYSOUT_DIR)\/##g"`; \
		match=`grep $$file $(PORT_ROOT)/build/filelist.txt`; \
		if [ $$? -eq 1 ];then \
			mkdir -p $(ZIP_DIR)/system/`dirname $$file`; \
			cp -f $(SYSOUT_DIR)/$$file $(ZIP_DIR)/system/$$file; \
		fi \
	done
else
	$(hide) cp -rf $(SYSOUT_DIR)/lib $(ZIP_DIR)/system
endif
	$(hide) cp $(STOCKROM_DIR)/system/lib/libselinux.so $(ZIP_DIR)/system/lib/libselinux_orig.so
	$(hide) mv -f $(ZIP_DIR)/system/lib/libselinux_mod.so $(ZIP_DIR)/system/lib/libselinux.so

add-prebuilt-jars:
	$(hide) cp -rf $(SYSOUT_DIR)/framework/cloud-common.jar $(ZIP_DIR)/system/framework/
	$(hide) cp -rf $(SYSOUT_DIR)/framework/yellowpage-common.jar $(ZIP_DIR)/system/framework/
	$(hide) cp -rf $(SYSOUT_DIR)/framework/mms-common.jar $(ZIP_DIR)/system/framework/

add-prebuilt-media:
	@echo To add prebuilt media files
	$(hide) cp -rf $(SYSOUT_DIR)/media $(ZIP_DIR)/system

add-prebuilt-fonts:
	$(hide) cp -f $(SYSOUT_DIR)/fonts/Miui*.ttf $(ZIP_DIR)/system/fonts/

add-prebuilt-etc-files:
	@echo To add prebuilt files under etc
ifeq ($(USE_ANDROID_OUT),true)
	$(hide) for file in `find $(SYSOUT_DIR)/etc -type f`; do \
		file=`echo $$file | sed "s#$(SYSOUT_DIR)\/##g"`; \
		match=`grep $$file $(PORT_ROOT)/build/filelist.txt`; \
		if [ $$? -eq 1 ];then \
			mkdir -p $(ZIP_DIR)/system/`dirname $$file`; \
			cp -f $(SYSOUT_DIR)/$$file $(ZIP_DIR)/system/$$file; \
		fi \
	done
else
	$(hide) cp -rf $(SYSOUT_DIR)/etc $(ZIP_DIR)/system
endif

add-preinstall-files:
	@echo To add preintall files
	$(hide) mkdir -p $(ZIP_DIR)/data/miui/app/customized
	$(hide) cp -rf $(OUT_DATA_PATH)/miui/gallery $(ZIP_DIR)/data/miui
	$(hide) cp -rf $(OUT_DATA_PATH)/miui/mms $(ZIP_DIR)/data/miui
	$(hide) cp -rf $(OUT_DATA_PATH)/miui/yellowpage $(ZIP_DIR)/data/miui
	$(hide) find $(OUT_DATA_PATH)/miui/app -name "ota-*.apk" -exec cp -rf {} $(ZIP_DIR)/data/miui/app/customized \;
	$(hide) mkdir -p $(ZIP_DIR)/data/miui/cust/cn
	$(hide) cp -rf $(OUT_CUST_PATH)/data/cn/customized_applist $(ZIP_DIR)/data/miui/cust/cn

add-skia-emoji:
	@echo To add Skia Emoji support
	$(hide) cp -f $(SYSOUT_DIR)/lib/libskia.so $(ZIP_DIR)/sysem/lib
	$(hide) cp -f $(SYSOUT_DIR)/lib/libhwui.so $(ZIP_DIR)/system/lib

release-prebuilt-binaries:
	@echo Release prebuilt binaries
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/xbin
	$(hide) cp -f $(SYSOUT_DIR)/xbin/shelld $(RELEASE_PATH)/$(DENSITY)/system/xbin/
	$(hide) cp -f $(SYSOUT_DIR)/xbin/busybox $(RELEASE_PATH)/$(DENSITY)/system/xbin/
	$(hide) cp -f $(SYSOUT_DIR)/xbin/su $(RELEASE_PATH)/$(DENSITY)/system/xbin/
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/bin
	$(hide) cp -f $(SYSOUT_DIR)/bin/debuggerd_miui $(RELEASE_PATH)/$(DENSITY)/system/bin/
	$(hide) cp -f $(SYSOUT_DIR)/bin/app_process_miui $(RELEASE_PATH)/$(DENSITY)/system/bin/
	$(hide) cp -f $(SYSOUT_DIR)/bin/dexopt_miui $(RELEASE_PATH)/$(DENSITY)/system/bin/
	$(hide) cp -f $(SYSOUT_DIR)/bin/servicemanager $(RELEASE_PATH)/$(DENSITY)/system/bin/


release-prebuilt-libraries:
	@echo Release prebuilt libraries
	$(hide) for dir in `find $(SYSOUT_DIR)/lib -type d`; do \
		path=`echo $$dir | sed "s#$(SYSOUT_DIR)\/##g"`; \
		mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/$$path; \
	done
	$(hide) for file in `find $(SYSOUT_DIR)/lib -type f`; do \
		file=`echo $$file | sed "s#$(SYSOUT_DIR)\/##g"`; \
		match=`grep $$file $(PORT_ROOT)/build/filelist.txt`; \
		if [ $$? -eq 1 ];then \
			cp -f $(SYSOUT_DIR)/$$file $(RELEASE_PATH)/$(DENSITY)/system/$$file; \
		fi \
	done

release-prebuilt-jars:
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/framework/
	$(hide) cp -rf $(SYSOUT_DIR)/framework/cloud-common.jar $(RELEASE_PATH)/$(DENSITY)/system/framework/
	$(hide) cp -rf $(SYSOUT_DIR)/framework/yellowpage-common.jar $(RELEASE_PATH)/$(DENSITY)/system/framework/
	$(hide) cp -rf $(SYSOUT_DIR)/framework/mms-common.jar $(RELEASE_PATH)/$(DENSITY)/system/framework/

release-prebuilt-media:
	@echo Release prebuilt media files
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/media
	$(hide) cp -rf $(SYSOUT_DIR)/media $(RELEASE_PATH)/$(DENSITY)/system

release-prebuilt-fonts:
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/fonts/
	$(hide) cp -f $(SYSOUT_DIR)/fonts/Miui*.ttf $(RELEASE_PATH)/$(DENSITY)/system/fonts/

release-prebuilt-etc-files:
	@echo Release prebuilt etc-files
	$(hide) for dir in `find $(SYSOUT_DIR)/etc -type d`; do \
		path=`echo $$dir | sed "s#$(SYSOUT_DIR)\/##g"`; \
		mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/$$path; \
	done
	$(hide) for file in `find $(SYSOUT_DIR)/etc -type f`; do \
		file=`echo $$file | sed "s#$(SYSOUT_DIR)\/##g"`; \
		match=`grep $$file $(PORT_ROOT)/build/filelist.txt`; \
		if [ $$? -eq 1 ];then \
			cp -f $(SYSOUT_DIR)/$$file $(RELEASE_PATH)/$(DENSITY)/system/$$file; \
		fi \
	done

release-preinstall-files:
	@echo Release preintall files
	$(hide) mkdir -p $(RELEASE_PATH)/data/miui/app/customized
	$(hide) cp -rf $(OUT_DATA_PATH)/miui/gallery $(RELEASE_PATH)/data/miui
	$(hide) cp -rf $(OUT_DATA_PATH)/miui/mms $(RELEASE_PATH)/data/miui
	$(hide) cp -rf $(OUT_DATA_PATH)/miui/yellowpage $(RELEASE_PATH)/data/miui
	$(hide) find $(OUT_DATA_PATH)/miui/app -name "ota-*.apk" -exec cp -rf {} $(RELEASE_PATH)/data/miui/app/customized/ \;
	$(hide) mkdir -p $(RELEASE_PATH)/cust/data/cn
	$(hide) cp -rf $(OUT_CUST_PATH)/data/cn/customized_applist $(RELEASE_PATH)/cust/data/cn

release-miui-resources:
	@echo Release miui resources
	$(hide) cd $(ANDROID_TOP)/miui; tar -cf $(RELEASE_PATH)/res.tar config-overlay/v6/common config-overlay/v6/platform I18N_res/v6/common I18N_res/v6/platform
	$(hide) cd $(RELEASE_PATH); tar -xf res.tar;rm res.tar

add-miui-prebuilt: add-prebuilt-binaries add-prebuilt-libraries add-prebuilt-jars add-prebuilt-media add-prebuilt-fonts add-prebuilt-etc-files add-preinstall-files
	@echo Add miui prebuilt completed!

release-miui-prebuilt: release-prebuilt-binaries release-prebuilt-libraries release-prebuilt-jars release-prebuilt-media release-prebuilt-fonts release-prebuilt-etc-files release-preinstall-files release-miui-resources 
	@echo Release MIUI prebuilt completed!
