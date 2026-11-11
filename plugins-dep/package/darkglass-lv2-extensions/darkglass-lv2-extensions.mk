######################################
#
# darkglass-lv2-extensions
#
######################################

DARKGLASS_LV2_EXTENSIONS_VERSION = 12be8a11099d8471a4534dfad0347a81e8e21098
DARKGLASS_LV2_EXTENSIONS_SITE = $(call github,Darkglass-Electronics,LV2-Extensions,$(DARKGLASS_LV2_EXTENSIONS_VERSION))

DARKGLASS_LV2_EXTENSIONS_TARGET_MAKE = $(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) PREFIX=/usr

define DARKGLASS_LV2_EXTENSIONS_INSTALL_TARGET_CMDS
	$(DARKGLASS_LV2_EXTENSIONS_TARGET_MAKE) install DESTDIR=$(TARGET_DIR)
endef

$(eval $(generic-package))
