#
# Copyright (C) 2016 The Miui Patchrom
#
ifeq ($(USE_ANDROID_OUT),true)
# Release apps
$(call copy-apks-to-target, $(ALL_MIUI_APPS), $(PREBUILT_APP_DIR), $(RELEASE_APP_APK_DIR))
RELEASE_MIUI += $(foreach app_name, $(MIUI_APPS),$(RELEASE_APP_APK_DIR)/$(app_name)/$(app_name).apk)

# Release priv apps
$(call copy-apks-to-target, $(ALL_MIUI_PRIV_APPS), $(PREBUILT_PRIV_APP_DIR), $(RELEASE_PRIV_APP_APK_DIR))
RELEASE_MIUI += $(foreach app_name, $(ALL_MIUI_PRIV_APPS),$(RELEASE_PRIV_APP_APK_DIR)/$(app_name)/$(app_name).apk)

# Release res apk
$(eval $(call copy-one-file,$(PREBUILT_RES_DIR)/framework-ext-res/framework-ext-res.apk,$(RELEASE_RES_DIR)/framework-ext-res/framework-ext-res.apk))
RELEASE_MIUI += $(RELEASE_RES_DIR)/framework-ext-res/framework-ext-res.apk
$(eval $(call copy-one-file,$(PREBUILT_RES_DIR)/framework-res.apk,$(RELEASE_RES_DIR)/framework-res.apk))
RELEASE_MIUI += $(RELEASE_RES_DIR)/framework-res.apk

# Release jar
RELEASE_MIUI += $(foreach jar_name,$(MIUI_JARS),$(RELEASE_JAR_DIR)/$(jar_name).jar)


release-prebuilt-files:
	@echo Release prebuilt files
	$(call copy-apks-lib,$(MIUI_APPS),$(PREBUILT_APP_LIB_DIR),$(RELEASE_APP_LIB_DIR))
	$(call copy-apks-lib,$(MIUI_PRIV_APPS),$(PREBUILT_PRIV_APP_LIB_DIR),$(RELEASE_PRIV_APP_LIB_DIR))
	$(call copy-prebuilt-files,$(PREBUILT_LIB_DIR),$(RELEASE_LIB_DIR),lib)
	$(call copy-prebuilt-files,$(PREBUILT_LIB64_DIR),$(RELEASE_LIB64_DIR),lib64)
	$(call copy-prebuilt-files,$(PREBUILT_JAR_DIR),$(RELEASE_JAR_DIR),framework)
	$(call copy-prebuilt-files,$(PREBUILT_ETC_DIR),$(RELEASE_ETC_DIR),etc)
	$(call copy-prebuilt-files,$(PREBUILT_BIN_DIR),$(RELEASE_BIN_DIR),bin)
	$(call copy-prebuilt-files,$(PREBUILT_XBIN_DIR),$(RELEASE_XBIN_DIR),xbin)
	$(call copy-prebuilt-files,$(PREBUILT_MEDIA_DIR),$(RELEASE_MEDIA_DIR),media)
	$(hide) mkdir -p $(RELEASE_FONTS_DIR)
	$(hide) cp -fp $(PREBUILT_FONTS_DIR)/Miui*.ttf $(RELEASE_FONTS_DIR)/
	$(hide) mkdir -p $(RELEASE_BOOT_DIR)/$(RELEASE_BIT)
	$(hide) cp -fp $(PREBUILT_BOOT_DIR)/init $(RELEASE_BOOT_DIR)/$(RELEASE_BIT)/

release-preinstall-files:
	@echo Release preintall files
	$(hide) mkdir -p $(RELEASE_DIR)/cust/data/cn
	$(hide) cp -rf $(PREBUILT_CUST_DIR)/data/cn/* $(RELEASE_DIR)/cust/data/cn/
	$(hide) mkdir -p $(RELEASE_DIR)/data
	$(hide) cp -rf $(PREBUILT_DATA_DIR)/miui $(RELEASE_DIR)/data
	$(hide) find $(RELEASE_DIR)/data/miui/app -name "ota-*.apk" -prune -o -name "*.apk" -print \
		-exec rm -f {} \; > /dev/null

release-miui-resources:
	@echo Release miui resources
	$(hide) rm -rf $(RELEASE_DIR)/src
	$(foreach path,$(wildcard $(MIUI_OVERLAY_RES) $(MIUI_RES)),\
		mkdir -p $(patsubst $(MIUI_SRC_DIR)/%/res,$(RELEASE_DIR)/src/%,$(path));\
		cp -r $(path) $(patsubst $(MIUI_SRC_DIR)/%/res,$(RELEASE_DIR)/src/%,$(path));)
	cp $(MIUI_SRC_DIR)/frameworks/base/core/res/AndroidManifest.xml $(RELEASE_DIR)/src/frameworks/base/core/res/AndroidManifest.xml

release-apkcert:
	@echo Release apkcert
	$(hide) rm -rf $(RELEASE_DIR)/metadata/apkcert.txt
	$(hide) mkdir -p $(RELEASE_DIR)/metadata
	$(hide) for apk in `find $(RELEASE_DIR) -name "*.apk"`;do \
		line=`grep -r "\"$$(basename $$apk)\"" $(ANDROID_OUT)/obj/PACKAGING/apkcerts_intermediates/ \
		| cut -d ':' -f2`; \
		echo $$line >> $(RELEASE_DIR)/metadata/apkcert.txt; \
		cat $(RELEASE_DIR)/metadata/apkcert.txt | sort | uniq > $(RELEASE_DIR)/metadata/tmp; \
		mv $(RELEASE_DIR)/metadata/tmp $(RELEASE_DIR)/metadata/apkcert.txt; \
		done

release-filesystem-config:
	@echo Release filesystem config
	$(hide) mkdir -p $(RELEASE_DIR)/metadata
	$(hide) touch $(RELEASE_DIR)/metadata/filesystem_config.txt
	$(hide) python $(UNIQ_FIRST_PY) $(shell find $(ANDROID_OUT)/obj/PACKAGING/target_files_intermediates/ -name filesystem_config.txt) $(RELEASE_DIR)/metadata/filesystem_config.txt 

release: release-prebuilt-files release-preinstall-files
release: $(RELEASE_MIUI) release-miui-resources release-apkcert release-filesystem-config
	@echo Release MIUI prebuilt completed!
endif
