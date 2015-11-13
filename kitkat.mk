
private-remove-apps := InputDevices MusicFX SharedStorageBackup OneTimeInitializer ProxyHandler GooglePinyinIME \
	Shell FusedLocation BackupRestoreConfirmation ExternalStorageProvider PhotoTable PrintSpooler \
	WAPPushManager MagicSmokeWallpapers VisualizationWallpapers BasicDreams PhaseBeam HoloSpiralWallpaper \
	Bluetooth Galaxy4 LiveWallpapers PicoTts CertInstaller KeyChain NoiseField PacProcessor Camera2 \
	TrafficControl


private-miui-priv-apps :=

$(foreach app, $(subst .apk,,$(shell find $(OUT_SYS_PATH)/priv-app -name "*.apk" -exec basename {} \;)), \
	    $(eval private-miui-priv-apps += $(app)))

private-miui-priv-apps := $(filter-out $(private-remove-apps),$(private-miui-priv-apps))


private-miui-apps:=

$(foreach app, $(subst .apk,,$(shell find $(OUT_SYS_PATH)/app -name "*.apk" -exec basename {} \;)), \
	        $(eval private-miui-apps += $(app)))

private-miui-apps := $(filter-out $(private-remove-apps),$(private-miui-apps))


private-miui-jars := services \
                     android.policy \
                     telephony-common \
                     framework \
                     framework2
