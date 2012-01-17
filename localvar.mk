#
# Currenly the following local variables are used for
# each product to define the behavior for porting
# 	local-zip-file 		MUST be defined
# 	local-out-zip-file
# 	local-modified-apps
# 	local-miui-apps
# 	local-remove-apps
# 	local-pre-zip
# 	local-after-zip
# See i9100/makefile as an example
#

ZIP_FILE     := $(strip $(local-zip-file))
ifeq ($(ZIP_FILE),)
    ZIP_FILE := empty-zip-filename
endif

OUT_ZIP_FILE := $(strip $(local-out-zip-file))
ifeq ($(OUT_ZIP_FILE),)
    OUT_ZIP_FILE:= porting_miui.zip
endif

APPS         := $(strip $(local-modified-apps))
MIUIAPPS     := $(strip $(local-miui-apps))

ACT_PRE_ZIP  := $(strip $(local-pre-zip))

RUNDAPKS     := $(local-remove-apps)
ifneq ($(RUNDAPKS),)
    ACT_PRE_ZIP += remove-rund-apks
endif

ACT_AFTER_ZIP  := $(strip $(local-after-zip))
