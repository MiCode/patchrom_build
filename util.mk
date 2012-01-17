# Target to install apktool framework 
apktool-if: $(SYSOUT_DIR)/framework/framework.jar $(TMP_DIR)/framework-res.apk
	@echo install framework resources...
	$(APKTOOL) if $(TMP_DIR)/framework-res.apk
	$(APKTOOL) if $(SYSOUT_DIR)/framework/framework-miui-res.apk
	unzip $(ZIP_FILE) system/framework/twframework-res.apk -d $(TMP_DIR)
	$(APKTOOL) if $(TMP_DIR)/system/framework/twframework-res.apk

# Target to sign apks in the connected phone
sign: $(SIGNAPKS)
	@echo Sign competed!

# Target to clean the .build
clean:
	rm -rf $(TMP_DIR)

# Target to clean all related #TODO
reallyclean: clean $(CLEANJAR) $(CLEANMIUIAPP)
	@echo "ALL CLEANED!"

# Target to verify env and debug info
verify-env:
	@echo PORT_ROOT=$(PORT_ROOT)
	@echo ANDROID_TOP=$(ANDROID_TOP)
	@echo ANDROID_OUT=$(ANDROID_OUT)
	@echo ACT_PRE_ZIP=$(ACT_PRE_ZIP)
	@echo SIGNAPKS =$(SIGNAPKS)
	@echo REALLY-CLEAN =$(CLEANJAR) $(CLEANMIUIAPP)


# Push the generated ZIP file to phone
zip2sd: $(OUT_ZIP)
	adb reboot recovery
	sleep 40
	adb shell mount sdcard
	sleep 5
	@echo push $(OUT_ZIP) to phone sdcard
	adb shell rm -f /sdcard/$(OUT_ZIP_FILE)
	adb push $(OUT_ZIP) /sdcard/$(OUT_ZIP_FILE)

