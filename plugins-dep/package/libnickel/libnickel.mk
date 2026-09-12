######################################
#
# libnickel
#
######################################

LIBNICKEL_VERSION = 1
LIBNICKEL_SOURCE = .
LIBNICKEL_SITE = .
LIBNICKEL_SITE_METHOD = file
LIBNICKEL_INSTALL_STAGING = YES

define LIBNICKEL_EXTRACT_CMDS
endef

ifeq ($(BR2_TOOLCHAIN_EXTERNAL_GCC_15),y)
LIBNICKEL_EXTRA_SUFFIX = -gcc15
else ifeq ($(BR2_TOOLCHAIN_EXTERNAL_GCC_9),y)
LIBNICKEL_EXTRA_SUFFIX = -gcc9
endif

define LIBNICKEL_INSTALL_STAGING_CMDS
	$(INSTALL) -d $(STAGING_DIR)/usr/include
	$(INSTALL) -d $(STAGING_DIR)/usr/lib
	$(INSTALL) -m 644 $($(PKG)_PKGDIR)/dg-license.h $(STAGING_DIR)/usr/include/
	$(INSTALL) -m 644 $($(PKG)_PKGDIR)/libnickel.h $(STAGING_DIR)/usr/include/
	$(INSTALL) -m 644 $($(PKG)_PKGDIR)/libnickel$(LIBNICKEL_EXTRA_SUFFIX).a $(STAGING_DIR)/usr/lib/
endef

$(eval $(generic-package))
