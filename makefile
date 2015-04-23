# The currently supported products
PRODUCTS := i9500 note3 note2

PRODUCTS := $(strip $(PRODUCTS))
PRODUCT  := $(strip $(PORT_PRODUCT))

otapackage: check-product
	make -C $(PORT_ROOT)/$(PORT_PRODUCT) otapackage

clean reallyclean: check-product
	make -C $(PORT_ROOT)/$(PORT_PRODUCT) $@

check-product:
ifeq ($(PRODUCT),)
	$(error Need to specify the product type. (Use envsetup with -p))
endif
ifeq ($(findstring $(PRODUCT),$(PRODUCTS)),)
	$(error Product $(PRODUCT) does not exist. (Supported products: $(PRODUCTS)))
endif

