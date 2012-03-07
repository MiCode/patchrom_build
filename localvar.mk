#
# Currenly the following local variables are used for
# each product to define the behavior for porting
# 	local-zip-file 		MUST be defined
# 	local-out-zip-file
# 	local-modified-apps
# 	local-modified-jars
# 	local-miui-removed-apps
# 	local-miui-apps (DEPRECATED)
# 	local-miui-modified-apps
# 	local-remove-apps
# 	local-pre-zip
# 	local-after-zip
# See i9100/makefile as an example
#
include $(PORT_BUILD)/miuiapps.mk

ERR_REPORT   :=
VERIFY_OTA   :=

ZIP_FILE     := $(strip $(local-zip-file))
ifeq ($(ZIP_FILE),)
    ERR_REPORT += error-no-zipfile
endif

OUT_ZIP_FILE := $(strip $(local-out-zip-file))
ifeq ($(OUT_ZIP_FILE),)
    OUT_ZIP_FILE:= update.zip
endif

APPS         := $(strip $(local-modified-apps))
MIUIAPPS_MOD := $(strip $(local-miui-modified-apps))
MIUIAPPS     := $(strip \
                    $(filter-out $(strip $(local-miui-modified-apps)), \
                                 $(filter-out $(strip $(local-miui-removed-apps)),$(strip $(private-miui-apps)))) \
			     )

ACT_PRE_ZIP  := pre-zip-misc
ACT_PRE_ZIP  += $(strip $(local-pre-zip))

RUNDAPKS     := $(local-remove-apps)
ifneq ($(RUNDAPKS),)
    ACT_PRE_ZIP += remove-rund-apks
endif
ACT_PRE_ZIP  += $(VERIFY_OTA)

ACT_AFTER_ZIP := $(strip $(local-after-zip))

ifeq ($(strip $(USE_ANDROID_OUT)),true)
    ifeq ($(ANDROID_OUT),)
         ERR_REPORT += error-android-env
    else
         OUT_SYS_PATH := $(ANDROID_OUT)/system
	 REALLY_CLEAN = $(CLEANJAR) $(CLEANMIUIAPP)
    endif
else
    USE_ANDROID_OUT := false
    OUT_SYS_PATH := $(PORT_ROOT)/miui/system
    REALLY_CLEAN :=
endif
PHONE_JARS := $(strip $(local-modified-jars))
OUT_JAR_PATH := $(OUT_SYS_PATH)/framework
OUT_APK_PATH := $(OUT_SYS_PATH)/app

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

