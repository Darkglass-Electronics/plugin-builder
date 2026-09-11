######################################
#
# darkglass-plugin-builder
#
######################################

DARKGLASS_PLUGIN_BUILDER_VERSION = 1
DARKGLASS_PLUGIN_BUILDER_SOURCE = .
DARKGLASS_PLUGIN_BUILDER_SITE = .
DARKGLASS_PLUGIN_BUILDER_SITE_METHOD = file
DARKGLASS_PLUGIN_BUILDER_DEPENDENCIES = host-cmake host-darkglass-plugin-builder

ifdef BR2_cortex_a7
DARKGLASS_PLUGIN_BUILDER_RUST_FLAGS = ["-Ctarget-cpu=cortex-a7","-Ctarget-feature=+a7,+neonfp,+vfp4sp","-Clink-args=--sysroot=$(STAGING_DIR)"]
DARKGLASS_PLUGIN_BUILDER_RUST_TARGET = armv7-unknown-linux-gnueabihf
else ifdef BR2_cortex_a35
DARKGLASS_PLUGIN_BUILDER_RUST_FLAGS = ["-Ctarget-cpu=cortex-a35","-Ctarget-feature=+a35,-fix-cortex-a53-835769,+neon,+fp-armv8","-Clink-args=--sysroot=$(STAGING_DIR)"]
DARKGLASS_PLUGIN_BUILDER_RUST_TARGET = aarch64-unknown-linux-gnu
else ifdef BR2_cortex_a76
DARKGLASS_PLUGIN_BUILDER_RUST_FLAGS = ["-Ctarget-cpu=cortex-a76","-Ctarget-feature=+neon,+fp-armv8","-Clink-args=--sysroot=$(STAGING_DIR)"]
DARKGLASS_PLUGIN_BUILDER_RUST_TARGET = aarch64-unknown-linux-gnu
else ifdef BR2_cortex_a76_a55
DARKGLASS_PLUGIN_BUILDER_RUST_FLAGS = ["-Ctarget-cpu=cortex-a76.cortex-a55","-Ctarget-feature=+neon,+fp-armv8","-Clink-args=--sysroot=$(STAGING_DIR)"]
DARKGLASS_PLUGIN_BUILDER_RUST_TARGET = aarch64-unknown-linux-gnu
else ifdef BR2_aarch64
DARKGLASS_PLUGIN_BUILDER_RUST_FLAGS = ["-Ctarget-cpu=cortex-a53","-Ctarget-feature=+a53,+fix-cortex-a53-835769,+neon,+fp-armv8","-Clink-args=--sysroot=$(STAGING_DIR)"]
DARKGLASS_PLUGIN_BUILDER_RUST_TARGET = aarch64-unknown-linux-gnu
else ifdef BR2_x86_64
DARKGLASS_PLUGIN_BUILDER_RUST_FLAGS = []
DARKGLASS_PLUGIN_BUILDER_RUST_TARGET = x86_64-unknown-linux-gnu
endif

DARKGLASS_PLUGIN_BUILDER_RUST_BUILD_FLAGS = --release \
	--target $(DARKGLASS_PLUGIN_BUILDER_RUST_TARGET) \
	--config 'target.$(DARKGLASS_PLUGIN_BUILDER_RUST_TARGET).rustflags=$(DARKGLASS_PLUGIN_BUILDER_RUST_FLAGS)' \
	--config 'target.$(DARKGLASS_PLUGIN_BUILDER_RUST_TARGET).linker="$(TARGET_CC)"'

define DARKGLASS_PLUGIN_BUILDER_EXTRACT_CMDS
endef

define HOST_DARKGLASS_PLUGIN_BUILDER_EXTRACT_CMDS
endef

define HOST_DARKGLASS_PLUGIN_BUILDER_INSTALL_CMDS
	$(INSTALL) -d $(HOST_DIR)/usr/share/darkglass-plugin-builder
	$(INSTALL) -m 644 $($(PKG)_PKGDIR)/toolchainfile.cmake $(HOST_DIR)/usr/share/darkglass-plugin-builder/
endef

$(eval $(generic-package))
$(eval $(host-generic-package))

# force flags for other packages here

LV2_CONF_OPTS += -Dplugins=disabled
