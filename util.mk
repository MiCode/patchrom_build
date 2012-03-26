usage:
	@echo ">>> The main target for porting:"
	@echo "	make zipfile    - to create the full ZIP file, all apks are signed using testkey"
	@echo "	make zipone     - zipfile, plus the customized actions, such as zip2sd"
	@echo "	make zip2sd     - to push the ZIP file to phone in recovery mode"
	@echo "	make clean      - clear everything for output of this makefile"
	@echo "	make reallyclean- clear everything of related."
	@echo "	make workspace  - prepare the initial workspace for porting"
	@echo "	make firstpatch - add the miui hook into target framework smali code first time for a device"
	@echo "	make patchmiui  - incrementaly add the miui hook into target framework smali code"
	@echo "	make fullota    - generate full ota package, all apks are signed using apkcerts.txt"
	@echo ">>> Other helper targets:"
	@echo "	make apktool-if            - install the framework for apktool"
	@echo "	make verify                - to check if any error in the makefile"
	@echo "	make verify-ota            - to generate an ota for ota verification"
	@echo "	make out/xxxx.jar-phone - to make out a single jar file and push to phone"
	@echo "	make xxxx.apk.sign         - to generate a xxxx.apk and sign/push to phone"
	@echo "	make clean-xxxx/make xxxx  - just as make under android-build-top"
	@echo "	make sign                  - Sign all generated apks by this makefile and push to phone"
	@echo ">>> Environment overrides:"
	@echo "	make -e showcommand=true   - to show all executed commands"
	@echo "	make -e log=quiet|info|verbose - to control the output from make command"

# Target to prepare porting workspace
workspace: apktool-if $(JARS_OUTDIR) $(APPS_OUTDIR) fix-framework-res
	@echo Prepare workspace completed!

# Target to install apktool framework 
apktool-if: $(SYSOUT_DIR)/framework/framework.jar $(ZIP_FILE)
	@echo ">>> Install framework resources for apktool..."
	@echo install framework-miui-res.apk
	$(APKTOOL) if $(SYSOUT_DIR)/framework/framework-miui-res.apk
	$(UNZIP) $(ZIP_FILE) "system/framework/*.apk" -d $(TMP_DIR)
	$(hide) for res_file in `find $(TMP_DIR)/system/framework/ -name "*.apk"`; do\
		echo install $$res_file ; \
		$(APKTOOL) if $$res_file; \
	done
	$(hide) rm -r $(TMP_DIR)/system/framework/*.apk
	@echo "<<< install framework resources completed!"

fix-framework-res:
	@echo fix the apktool multiple position substitution bug
	$(FIX_PLURALS) framework-res

# Target to add miui hook into target framework first time
firstpatch:
	$(PATCH_MIUI_FRAMEWORK) $(PORT_ROOT)/android/google-framework $(PORT_ROOT)/android `pwd`

# Target to add miui hook into target framework - custom
custompatch:
	$(PATCH_MIUI_FRAMEWORK) `pwd`/DONE/original `pwd`/DONE/patched `pwd`

# Target to incrementaly add miui hook into target framework
patchmiui:
	$(PATCH_MIUI_FRAMEWORK) $(PORT_ROOT)/android/last-framework $(PORT_ROOT)/android `pwd`
	@echo Patchmiui completed!

# Target to release MIUI jar and apks
release: $(RELEASE_MIUI) release-framework-base-src

ifeq ($(strip $(ANDROID_BRANCH)),)
release-framework-base-src:
	$(error To release source code for framework base, run envsetup -b to specify branch)
else
release-framework-base-src: release-miui-resources
	@echo "To release source code for framework base..."
	$(RLZ_SOURCE) $(ANDROID_BRANCH) $(ANDROID_TOP) $(RELEASE_PATH)
endif


# Target to sign apks in the connected phone
sign: $(SIGNAPKS)
	@echo Sign competed!

# Target to clean the .build
clean:
	$(hide) rm -rf $(TMP_DIR)
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
	@echo "----------------------"
	@echo ">>>>> GLOBAL VARIABLE:"
	@echo "TMP_DIR    = $(TMP_DIR)"
	@echo "ZIP_DIR    = $(ZIP_DIR)"
	@echo "OUT_ZIP    = $(OUT_ZIP)"
	@echo "TOOL_DIR   = $(TOOL_DIR)"
	@echo "APKTOOL    = $(APKTOOL)"
	@echo "SIGN       = $(SIGN)"
	@echo "ADDMIUI    = $(ADDMIUI)"
	@echo "SYSOUT_DIR = $(SYSOUT_DIR)"
	@echo "----------------------"
	@echo ">>>>> LOCAL VARIABLE:"
	@echo "local-use-android-out = $(local-use-android-out)"
	@echo "local-zip-file        = $(local-zip-file)"
	@echo "local-out-zip-file    = $(local-out-zip-file)"
	@echo "local-modified-apps   = $(local-modified-apps)"
	@echo "local-miui-apps       = $(local-miui-apps)"
	@echo "local-remove-apps     = $(local-remove-apps)"
	@echo "local-pre-zip         = $(local-pre-zip)"
	@echo "local-after-zip       = $(local-after-zip)"
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
	@echo "MIUIAPPS_MOD    = $(MIUIAPPS_MOD)"
	@echo "miui-apps       = $(private-miui-apps)"
	@echo "MIUIAPPS        = $(MIUIAPPS)"
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
	cp $(TMP_DIR)/target_files.zip last_target_files.zip
	cp $(TMP_DIR)/testota.zip last_fullota.zip
	make clean

verify-ota: last_target_files.zip fullota
	$(TOOL_DIR)/releasetools/ota_from_target_files -k ../build/security/testkey -i last_target_files.zip out/target_files.zip $(TMP_DIR)/ota_update.zip
	@mv last_target_files.zip $(TMP_DIR)
	@mv last_fullota.zip $(TMP_DIR)

miui-apps-included:
	@echo $(addsuffix .apk,$(private-miui-apps) framework-miui-res)

