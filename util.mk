usage:
	@echo ">>> The main target for porting:"
	@echo "	make zipfile    - to create the full ZIP file, all apks are signed using testkey"
	@echo "	make zipone     - zipfile, plus the customized actions, such as zip2sd"
	@echo "	make zip2sd     - to push the ZIP file to phone in recovery mode"
	@echo "	make clean      - clear everything for output of this makefile"
	@echo "	make reallyclean- clear everything of related."
	@echo "	make workspace  - prepare the initial workspace for porting"
	@echo "	make firstpatch - add the miui primary patch into target framework smali code"
	@echo "	make secondpatch - add the miui secondary patch into target framework smali code"
	@echo "	make fullota    - generate full ota package, all apks are signed using apkcerts.txt"
	@echo ">>> Other helper targets:"
	@echo "	make apktool-if            - install the framework for apktool"
	@echo "	make verify                - to check if any error in the makefile"
	@echo "	make out/xxxx.jar-phone    - to make out a single jar file and push to phone"
	@echo "	make xxxx.apk.sign         - to generate a xxxx.apk and sign/push to phone"
	@echo "	make clean-xxxx/make xxxx  - just as make under android-build-top"
	@echo "	make sign                  - Sign all generated apks by this makefile and push to phone"
	@echo ">>> local ota targets:"
	@echo "	make zipfile-ota-base              - create the zipfile and the ota base with build-number"
	@echo "	make -e otabase=BN zipfile-and-ota - create the zipfile and the ota package based on BN"
	@echo "	make -e otabase=BN zipfile-ota     - create the ota package based on BN"
	@echo "	make -e otatype=fullota zipfile-ota- specify local ota for fullota"
	@echo ">>> Environment overrides:"
	@echo "	make -e showcommand=true   - to show all executed commands"
	@echo "	make -e log=quiet|info|verbose - to control the output from make command"

# Target to prepare porting workspace
workspace: $(APKTOOL_INCLUDE_VENDOR_RES) $(JARS_OUTDIR) $(APPS_OUTDIR)
	@echo Prepare workspace completed!

# Target to add miui primary patch into target framework
firstpatch:
	$(PATCH_MIUI_FRAMEWORK) $(PORT_ROOT)/android/base-framework $(PORT_ROOT)/android/primary-patch `pwd`


# Target to add miui secondary patch into target framework
secondpatch:
	$(PATCH_MIUI_FRAMEWORK) $(PORT_ROOT)/android/base-framework $(PORT_ROOT)/android/secondary-patch `pwd`


# Target to sign apks in the connected phone
sign: $(SIGNAPKS)
	@echo Sign competed!

# Target to clean the .build
clean:
	$(hide) if [ -f ".delete-zip-file-when-clean" ]; then rm $(ZIP_FILE); fi
	$(hide) rm -f .delete-zip-file-when-clean
	$(hide) rm -rf $(TARGET_OUT_DIR)
	$(hide) rm -f $(OUT_APK_PATH)/*.apk-tozip $(OUT_APK_PATH:app=priv-app)/*.apk-tozip $(OUT_JAR_PATH)/*-tozip
	$(hide) rm -f releasetools.pyc
	$(hide) rm -f $(TOOL_DIR)/releasetools/common.pyc $(TOOL_DIR)/releasetools/edify_generator.pyc
	@echo clean completed!

reallyclean: clean $(ERR_REPORT) $(REALLY_CLEAN)
	@echo "ALL CLEANED!"

# Target to verify env and debug info
verify: $(ERR_REPORT)
	@echo "-------------------"
	@echo ">>>>> ENV VARIABLE:"
	@echo "PORT_ROOT   = $(PORT_ROOT)"
	@echo "ANDROID_TOP = $(ANDROID_TOP)"
	@echo "ANDROID_OUT = $(ANDROID_OUT)"
	@echo "BUILD_NUMBER= $(BUILD_NUMBER)"
	@echo "----------------------"
	@echo ">>>>> GLOBAL VARIABLE:"
	@echo "TARGET_OUT_DIR    = $(TARGET_OUT_DIR)"
	@echo "ZIP_DIR    = $(ZIP_DIR)"
	@echo "OUT_ZIP    = $(OUT_ZIP)"
	@echo "TOOL_DIR   = $(TOOL_DIR)"
	@echo "APKTOOL    = $(APKTOOL)"
	@echo "SIGN       = $(SIGN)"
	@echo "ADDMIUI    = $(ADDMIUI)"
	@echo "----------------------"
	@echo ">>>>> LOCAL VARIABLE:"
	@echo "local-use-android-out = $(local-use-android-out)"
	@echo "local-zip-file        = $(local-zip-file)"
	@echo "local-out-zip-file    = $(local-out-zip-file)"
	@echo "local-modified-apps   = $(local-modified-apps)"
	@echo "local-miui-apps       = $(local-miui-apps)"
	@echo "local-remove-apps     = $(local-remove-apps)"
	@echo "local-phone-apps      = $(local-phone-apps)"
	@echo "local-pre-zip         = $(local-pre-zip)"
	@echo "local-after-zip       = $(local-after-zip)"
	@echo "local-density         = $(local-density)"
	@echo "----------------------"
	@echo ">>>>> INTERNAL VARIABLE:"
	@echo "ERR_REPORT= $(ERR_REPORT)"
	@echo "OUT_SYS_PATH    = $(OUT_SYS_PATH)"
	@echo "OUT_JAR_PATH    = $(OUT_JAR_PATH)"
	@echo "OUT_APK_PATH    = $(OUT_APK_PATH)"
	@echo "ACT_PRE_ZIP     = $(ACT_PRE_ZIP)"
	@echo "ACT_PRE_ZIP     = $(ACT_AFTER_ZIP)"
	@echo "USE_ANDROID_OUT = $(USE_ANDROID_OUT)"
	@echo "RELEASE_MIUI    = $(RELEASE_MIUI)"
	@echo "MIUI_APPS_MOD    = $(MIUI_APPS_MOD)"
	@echo "miui-apps       = $(private-miui-apps)"
	@echo "MIUI_APPS        = $(MIUI_APPS)"
	@echo "OTA_BASE        = $(OTA_BASE)"
	@echo "APKTOOL_IF_RESULT_FILE = $(APKTOOL_IF_RESULT_FILE)"
	@echo "DENSITY         = $(DENSITY)"
	@echo "----------------------"
	@echo ">>>>> OUTPUT VARIABLE:"
	@echo "PROG    = $(PROG)"
	@echo "INFO    = $(INFO)"
	@echo "VERBOSE = $(VERBOSE)"
	@echo "hide   = $(hide)"
	@echo ">>>>> MORE VARIABLE:"
	@echo "SIGNAPKS     = $(SIGNAPKS)"
	@echo "REALLY-CLEAN = $(REALLY_CLEAN)"

# Push the generated ZIP file to phone
zip2sd: $(OUT_ZIP)
	adb reboot recovery
	sleep 40
	adb shell mount sdcard
	sleep 5
	@echo push $(OUT_ZIP) to phone sdcard
	adb shell rm -f /sdcard/$(OUT_ZIP_FILE)
	adb push $(OUT_ZIP) /sdcard/$(OUT_ZIP_FILE)

error-no-zipfile:
	$(error local-zip-file must be defined to specify the ZIP file)

error-android-env:
	$(error local-use-android-out set as true, should run lunch for android first)

last_target_files.zip:
	make clean
	make -e VERIFY_OTA=local-ota-update fullota
	cp $(TARGET_OUT_DIR)/target_files.zip last_target_files.zip
	cp $(TARGET_OUT_DIR)/fullota.zip last_fullota.zip
	make clean

# target for local ota package for local debug
# 1. the previous target_file.zip is built from zipfile-ota-base and
# the location for target zip file should be specified by local-previous-target-dir
# 2. the ota is generated by make -e otabase=xxx zipfile-ota
previous-target-dir := $(local-previous-target-dir)/$(OTA_TYPE)
save_previous_target_file := $(previous-target-dir)/target_file.$(ROM_BUILD_NUMBER).zip
use_previous_target_file  := $(previous-target-dir)/target_file.$(OTA_BASE).zip
zipfile-ota: $(TARGET_OUT_DIR)/target_files.zip $(use_previous_target_file)
	$(TOOL_DIR)/releasetools/ota_from_target_files -k ../build/security/testkey -i $(use_previous_target_file) $(TARGET_OUT_DIR)/target_files.zip $(TARGET_OUT_DIR)/ota_update_$(OTA_BASE).zip
	@echo OTA package generated at: $(TARGET_OUT_DIR)/ota_update_$(OTA_BASE).zip

zipfile-and-ota: zipfile-ota-base zipfile-ota

$(use_previous_target_file):
	$(info Available target files for OTA base:)
	$(info $(shell ls -Fl $(previous-target-dir)))
	$(error need to specify the build number as ota base: make -e OTA_BASE=build-number zipfile-ota)

zipfile-ota-base: $(OTA_TYPE)
	@mkdir -p $(previous-target-dir)
	@cp $(TARGET_OUT_DIR)/target_files.zip $(save_previous_target_file)
	@echo "$(save_previous_target_file) is saved as OTA-BASE"

ota-base-restore: $(use_previous_target_file)
	unzip $(use_previous_target_file) SYSTEM/framework/*framework* -d /tmp/
	unzip $(use_previous_target_file) SYSTEM/framework/services.jar -d /tmp/
	unzip $(use_previous_target_file) SYSTEM/framework/android.policy.jar -d /tmp/
	for app in $(MIUIAPPS_MOD) $(APPS); do \
		unzip $(use_previous_target_file) SYSTEM/app/$$app.apk -d /tmp/; \
	done
	adb remount
	adb push /tmp/SYSTEM/framework/ system/framework
	adb push /tmp/SYSTEM/app/ system/app
	rm -rf /tmp/SYSTEM/framework
	rm -rf /tmp/SYSTEM/app

released_keys:
	mkdir -p security
	-$(TOOL_DIR)/make_key security/platform '/C=CN/ST=Beijing/L=Beijing/O=Patchrom/OU=Patchrom/CN=$(USER)/emailAddress=$(USER)@android.com'
	-$(TOOL_DIR)/make_key security/shared '/C=CN/ST=Beijing/L=Beijing/O=Patchrom/OU=Patchrom/CN=$(USER)/emailAddress=$(USER)@android.com'
	-$(TOOL_DIR)/make_key security/media '/C=CN/ST=Beijing/L=Beijing/O=Patchrom/OU=Patchrom/CN=$(USER)/emailAddress=$(USER)@android.com'
	-$(TOOL_DIR)/make_key security/testkey '/C=CN/ST=Beijing/L=Beijing/O=Patchrom/OU=Patchrom/CN=$(USER)/emailAddress=$(USER)@android.com'
