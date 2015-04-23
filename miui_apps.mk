
MIUI_APP_BLACKLIST += InputDevices MusicFX SharedStorageBackup OneTimeInitializer ProxyHandler GooglePinyinIME \
	Shell FusedLocation BackupRestoreConfirmation ExternalStorageProvider PhotoTable PrintSpooler \
	WAPPushManager MagicSmokeWallpapers VisualizationWallpapers BasicDreams PhaseBeam HoloSpiralWallpaper \
	Bluetooth Galaxy4 LiveWallpapers PicoTts CertInstaller KeyChain NoiseField PacProcessor Camera2 \
	TrafficControl


ALL_MIUI_PRIV_APPS :=
$(foreach app, $(subst .apk,,$(shell find $(PREBUILT_PRIV_APP_APK_DIR) -name "*.apk" -exec basename {} \;)), \
	    $(eval ALL_MIUI_PRIV_APPS += $(app)))

MIUI_PRIV_APPS := $(filter-out $(MIUI_APP_BLACKLIST),$(ALL_MIUI_PRIV_APPS))


ALL_MIUI_APPS :=
$(foreach app, $(subst .apk,,$(shell find $(PREBUILT_APP_APK_DIR) -name "*.apk" -exec basename {} \;)), \
	        $(eval ALL_MIUI_APPS += $(app)))

MIUI_APPS := $(filter-out $(MIUI_APP_BLACKLIST),$(ALL_MIUI_APPS))

