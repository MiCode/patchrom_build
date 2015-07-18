
# $(1): The dir of the files
# $(2): The target root dir
define copy_prebuilt_files
$(hide) for file in `find $(1) -type f`; do \
	file=`echo $$file | sed "s#$$(dirname $(1))\/##g"`; \
	match=`grep $$file $(PORT_ROOT)/build/filelist.txt`; \
	if [ $$? -eq 1 ];then \
		mkdir -p $(2)/system/`dirname $$file`; \
		cp -f $$(dirname $(1))/$$file $(2)/system/$$file; \
	fi \
done
endef


add-prebuilt-files:
	@echo To add prebuilt files
	$(call copy_prebuilt_files, $(subst /$(DENSITY)/,/,$(SYSOUT_DIR)/lib), $(ZIP_DIR))
	$(call copy_prebuilt_files, $(subst /$(DENSITY)/,/,$(SYSOUT_DIR)/framework), $(ZIP_DIR))
	$(call copy_prebuilt_files, $(subst /$(DENSITY)/,/,$(SYSOUT_DIR)/etc), $(ZIP_DIR))
	$(call copy_prebuilt_files, $(subst /$(DENSITY)/,/,$(SYSOUT_DIR)/bin), $(ZIP_DIR))
	$(call copy_prebuilt_files, $(subst /$(DENSITY)/,/,$(SYSOUT_DIR)/xbin), $(ZIP_DIR))
	$(hide) cp $(STOCKROM_DIR)/system/lib/libselinux.so $(ZIP_DIR)/system/lib/libselinux_orig.so
	$(hide) mv -f $(ZIP_DIR)/system/lib/libselinux_mod.so $(ZIP_DIR)/system/lib/libselinux.so
	$(hide) cp -f $(STOCKROM_DIR)/system/bin/app_process $(ZIP_DIR)/system/bin/app_process_vendor
	$(hide) mv -f $(ZIP_DIR)/system/bin/app_process_miui $(ZIP_DIR)/system/bin/app_process
	$(hide) cp -f $(STOCKROM_DIR)/system/bin/debuggerd $(ZIP_DIR)/system/bin/debuggerd_vendor
	$(hide) mv -f $(ZIP_DIR)/system/bin/debuggerd_miui $(ZIP_DIR)/system/bin/debuggerd
	$(hide) cp -f $(STOCKROM_DIR)/system/bin/dexopt $(ZIP_DIR)/system/bin/dexopt_vendor
	$(hide) mv -f $(ZIP_DIR)/system/bin/dexopt_miui $(ZIP_DIR)/system/bin/dexopt

add-prebuilt-media:
	@echo To add prebuilt media files
	$(hide) cp -rf $(SYSOUT_DIR)/media $(ZIP_DIR)/system

add-prebuilt-fonts:
	$(hide) cp -f $(SYSOUT_DIR)/fonts/Miui*.ttf $(ZIP_DIR)/system/fonts/


add-preinstall-files:
	@echo To add preintall files
	$(hide) mkdir -p $(ZIP_DIR)/data/miui
	$(hide) cp -rf $(OUT_DATA_PATH)/miui/* $(ZIP_DIR)/data/miui
	$(hide) find $(OUT_DATA_PATH)/miui/app -name "cta-*_CTA.apk" -exec rm -rf {} \;
	$(hide) mkdir -p $(ZIP_DIR)/data/miui/cust/cn
	$(hide) cp -rf $(OUT_CUST_PATH)/data/cn/* $(ZIP_DIR)/data/miui/cust/cn



release-prebuilt-files:
	@echo Release prebuilt files
	$(call copy_prebuilt_files, $(SYSOUT_DIR)/lib, $(RELEASE_PATH))
	$(call copy_prebuilt_files, $(SYSOUT_DIR)/framework, $(RELEASE_PATH))
	$(call copy_prebuilt_files, $(SYSOUT_DIR)/etc, $(RELEASE_PATH))
	$(call copy_prebuilt_files, $(SYSOUT_DIR)/bin, $(RELEASE_PATH))
	$(call copy_prebuilt_files, $(SYSOUT_DIR)/xbin, $(RELEASE_PATH))

release-prebuilt-media:
	@echo Release prebuilt media files
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/media
	$(hide) cp -rf $(SYSOUT_DIR)/media $(RELEASE_PATH)/$(DENSITY)/system

release-prebuilt-fonts:
	$(hide) mkdir -p $(RELEASE_PATH)/$(DENSITY)/system/fonts/
	$(hide) cp -f $(SYSOUT_DIR)/fonts/Miui*.ttf $(RELEASE_PATH)/$(DENSITY)/system/fonts/

release-preinstall-files:
	@echo Release preintall files
	$(hide) mkdir -p $(RELEASE_PATH)/data/miui
	$(hide) cp -rf $(OUT_DATA_PATH)/miui/* $(RELEASE_PATH)/data/miui
	$(hide) find $(OUT_DATA_PATH)/miui/app -name "cta-*_CTA.apk" -exec rm -rf {} \;
	$(hide) mkdir -p $(RELEASE_PATH)/cust/data/cn
	$(hide) cp -rf $(OUT_CUST_PATH)/data/cn/* $(RELEASE_PATH)/cust/data/cn
	$(hide) rm -rf $(RELEASE_PATH)/data/miui/apps
	$(hide) rm -rf $(RELEASE_PATH)/data/miui/app/noncustomized/*


release-miui-resources:
	@echo Release miui resources
	$(hide) rm -rf $(RELEASE_PATH)/src
	$(hide) mkdir -p $(RELEASE_PATH)/src
	$(hide) cd $(ANDROID_TOP)/miui; tar -cf $(RELEASE_PATH)/src/res.tar config-overlay/v6/common config-overlay/v6/platform I18N_res/v6/common I18N_res/v6/platform frameworks/base/core/res/res frameworks/opt/ToggleManager/res
	$(hide) cd $(RELEASE_PATH)/src; tar -xf res.tar;rm res.tar
	$(hide) find $(RELEASE_PATH)/src -name "packages" | xargs rm -rf
	$(hide) cp $(ANDROID_TOP)/miui/frameworks/base/core/res/AndroidManifest.xml $(RELEASE_PATH)/src/frameworks/base/core/res/AndroidManifest.xml

release-apkcert:
	@echo Release apkcert
	$(hide) rm -rf $(RELEASE_PATH)/metadata/apkcert.txt
	$(hide) mkdir -p $(RELEASE_PATH)/metadata
	$(hide) for apk in `find $(RELEASE_PATH) -name "*.apk"`;do \
				line=`grep -r "\"$$(basename $$apk)\"" $(ANDROID_OUT)/obj/PACKAGING/apkcerts_intermediates/ \
						| cut -d ':' -f2`; \
				echo $$line >> $(RELEASE_PATH)/metadata/apkcert.txt; \
				cat $(RELEASE_PATH)/metadata/apkcert.txt | sort | uniq > $(RELEASE_PATH)/metadata/tmp; \
				mv $(RELEASE_PATH)/metadata/tmp $(RELEASE_PATH)/metadata/apkcert.txt; \
			done

add-miui-prebuilt: add-prebuilt-files add-prebuilt-media add-prebuilt-fonts add-preinstall-files
	@echo Add miui prebuilt completed!

release-miui-prebuilt: release-prebuilt-files release-prebuilt-media release-prebuilt-fonts release-preinstall-files
	@echo Release MIUI prebuilt completed!
