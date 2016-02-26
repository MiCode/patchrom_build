#
# Currenly the following local variables are used for
# each product to define the behavior for porting
# 	local-stockrom-dir 		MUST be defined
# 	local-out-zip-file
# 	local-modified-apps
# 	local-modified-priv-apps
# 	local-modified-jars
# 	local-miui-removed-apps
#	local-miui-removed-priv-apps
# 	local-miui-apps (DEPRECATED)
# 	local-miui-modified-apps
# 	local-phone-apps
# 	local-remove-apps
# 	local-pre-zip
# 	local-after-zip
# 	local-density
# 	local-certificate-dir
# See nexus5/makefile as an example
#


# specify the density for apps, HDPI OR XHDPI, default is XHDPI
DENSITY := $(strip $(local-density))
ifeq ($(DENSITY),)
	DENSITY := XHDPI
endif

ifeq ($(strip $(USE_ANDROID_OUT)),true)
    ifeq ($(ANDROID_OUT),)
         ERR_REPORT += error-android-env
    else
         OUT_SYS_PATH := $(ANDROID_OUT)/system
         OUT_DATA_PATH := $(ANDROID_OUT)/data
         OUT_CUST_PATH := $(ANDROID_OUT)/cust_variants_intermedia
	 REALLY_CLEAN = $(CLEANJAR) $(CLEANMIUIAPP)
    endif
else
    USE_ANDROID_OUT := false
    OUT_SYS_PATH := $(PORT_ROOT)/miui/$(DENSITY)/system
    OUT_DATA_PATH := $(PORT_ROOT)/miui/data
    OUT_CUST_PATH := $(PORT_ROOT)/miui/cust
    REALLY_CLEAN :=
endif
OUT_JAR_PATH := $(OUT_SYS_PATH)/framework
OUT_APK_PATH := $(OUT_SYS_PATH)/app

include $(PORT_ROOT)/build/$(PATCHROM_BRANCH).mk

ERR_REPORT   :=
VERIFY_OTA   :=

STOCKROM_DIR     := $(strip $(local-stockrom-dir))
ifeq ($(STOCKROM_DIR),)
    ERR_REPORT += error-no-stockrom-dir
endif

OUT_ZIP_FILE := $(strip $(local-out-zip-file))
ifeq ($(OUT_ZIP_FILE),)
    OUT_ZIP_FILE:= update.zip
endif

APPS         := $(strip $(local-modified-apps))
ALL_MIUIAPPS := $(strip $(private-miui-apps))
ALL_PRIV_MIUIAPPS := $(strip $(private-miui-priv-apps))
MIUIAPPS_MOD := $(strip $(local-miui-modified-apps))
MIUIAPPS     := $(strip \
                    $(filter-out $(strip $(local-miui-modified-apps)), \
                                 $(filter-out $(strip $(local-miui-removed-apps)),$(strip $(private-miui-apps)))) \
			     )
PRIV_MIUIAPPS:= $(strip \
                    $(filter-out $(strip $(local-miui-modified-apps)), \
                                 $(filter-out $(strip $(local-miui-removed-apps)),$(strip $(private-miui-priv-apps)))) \
			     )

MIUI_JARS := $(strip $(private-miui-jars))
PHONE_JARS := $(strip $(local-modified-jars))


ACT_PRE_ZIP  := $(strip $(local-pre-zip))
ACT_PRE_ZIP  += pre-zip-misc

ifeq ($(strip $(local-rewrite-skia-lib)),false)
	REWRITE_SKIA_LIB := false
else
	REWRITE_SKIA_LIB := true
endif

# if local-phone-apps is set, local-remove-apps would not be used,
# and the apps could be removed at target $(ZIP_DIR)
ifeq ($(strip $(local-phone-apps)),)
	RUNDAPKS := $(strip $(local-remove-apps))
	ifneq ($(RUNDAPKS),)
		ACT_PRE_ZIP += remove-rund-apks
	endif
else
	local-remove-apps :=
	RUNDAPKS :=
endif

ACT_PRE_ZIP  += $(VERIFY_OTA)

ACT_AFTER_ZIP := $(strip $(local-after-zip))

#
# log could be set with 'make -e log=value target' and the value:
#	quiet  : print information about the make stage and the scripts
#	info   : print more information related to the running scripts
#	verbose: print all information from executed commands
# and the default value is 'info'
log  := info
PROG :=
APK_VERBOSE := --verbose
ifeq ($(strip $(log)),verbose)
	INFO :=
	VERBOSE :=
else
	VERBOSE := >/dev/null
	APK_VERBOSE := --quiet
	ifeq ($(strip $(log)),quiet)
		INFO := >/dev/null
	endif
endif
# use 'make -e showcommand=true' to print all executed commands, if not
# set, only the scripts are printed. To disable all commands (including
# those scripts), use 'make -s'
ifeq ($(strip $(showcommand)),true)
	hide :=
else
	hide := @
endif

# variable for local-ota
ifeq ($(strip $(otabase)),)
	OTA_BASE := $(shell adb shell getprop ro.build.version.incremental 2>/dev/null | tail -n 1 | sed -e "s/0.\.//" | sed -e "s/://g")
else
	OTA_BASE := $(strip $(otabase))
endif

ifeq ($(strip $(otatype)),fullota)
	OTA_TYPE := fullota
else
	OTA_TYPE := zipfile
endif

ifeq ($(strip $(OTA_BASE)),)
	OTA_BASE :=unknown
endif

ifeq ($(strip $(include_thirdpart_app)),true)
	INCLUDE_THIRDPART_APP := true
else
	INCLUDE_THIRDPART_APP := false
endif

ifeq ($(wildcard $(strip $(local-certificate-dir))),)
CERTIFICATE_DIR := $(PORT_ROOT)/build/security
else
CERTIFICATE_DIR := $(strip $(local-certificate-dir))
endif
