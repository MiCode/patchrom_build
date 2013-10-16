# The currently supported products
PRODUCTS := honor i9100 sensation lt18i onex mx p1 gnote razr ones i9300 lt26i vivo x515m saga u970 d1 me865 lu6200 v8 note2 honor2 mx2 x909 i9500

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

