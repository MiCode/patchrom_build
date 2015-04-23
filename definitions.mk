#
# Copyright (C) 2016 The Miui Patchrom
#

# $(1): app list
# $(2): source apps dir
# $(3): destination apps dir
define copy-apks-lib
$(foreach app_name, $(1), \
	$(shell rm -rf $(3)/$(app_name)/lib; \
		if [ -d $(2)/$(app_name)/lib ];then \
			mkdir -p $(3)/$(app_name); \
			cp -rfp $(2)/$(app_name)/lib $(3)/$(app_name)/; \
		fi \
	)\
)
endef

# $(1): app list
# $(2): source apps dir
# $(3): destination apps dir
define copy-apks-to-target
$(foreach app_name, $(1), \
		$(eval $(call copy-one-file,$(2)/$(app_name)/$(app_name).apk,$(3)/$(app_name)/$(app_name).apk)))
endef

# Define a rule to copy a file.  For use via $(eval).
# $(1): source file
# $(2): destination file
define copy-one-file
$(2): $(1)
	@echo "Copy: $$< to $$@"
	@mkdir -p $$(dir $$@)
	$(hide) cp -fp $$< $$@
endef


# $(1): source dir
# $(2): destination dir
# $(3): type
define copy-prebuilt-files
$(hide) for file in `find $(1) -type f`; do \
	path=$${file##$(1)}; \
	if [ "$${path:0:1}" == "/" ];then \
		grep "$(3)$$path" $(PORT_ROOT)/build/filelist.txt > /dev/null; \
	else \
		grep "$(3)/$$path" $(PORT_ROOT)/build/filelist.txt > /dev/null; \
	fi; \
	if [ $$? -eq 1 ];then \
		source_file="$(1)/$$path"; \
		target_file="$(2)/$$path"; \
		mkdir -p $$(dirname $$target_file); \
		cp -f $$source_file $$target_file; \
	fi \
done
endef


define all-files-under-dir
$(shell find $(1) -type f 2>/dev/null)
endef

define get-key-in-mac-perms
$(strip \
	$(foreach item,$(filter %"><seinfo value="$(2)"%,$(shell more $(1))),\
		$(if $(filter value="$(2)"%,$(item)),\
			$(patsubst signature="%"><seinfo,%,$(sig)),\
			$(eval sig := $(item))\
		 )\
	 )\
)
endef
