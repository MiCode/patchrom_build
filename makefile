# The currently supported products
PRODUCTS := horner i9100 sensation

PRODUCTS := $(strip $(PRODUCTS))
PRODUCT  := $(strip $(PORT_PRODUCT))

clean reallyclean zipfile: check-product
	make -C $(PORT_ROOT)/$(PORT_PRODUCT) $@

defaut: check-product
	make -C $(PORT_ROOT)/$(PORT_PRODUCT) zipfile

check-product:
ifeq ($(PRODUCT),)
	$(error Need to specify the product type. (Use envsetup with -p))
endif
ifeq ($(findstring $(PRODUCT),$(PRODUCTS)),)
	$(error Product $(PRODUCT) does not exist. (Supported products: $(PRODUCTS)))
endif

