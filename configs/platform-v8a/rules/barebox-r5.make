# -*-makefile-*-
#
# Copyright (C) 2025 by Lars Schmidt <l.schmidt@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_BAREBOX_R5) += barebox-r5

#
# Paths and names
#
BAREBOX_R5_VERSION		:= $(call ptx/config-version, PTXCONF_BAREBOX)
BAREBOX_R5_MD5			:= $(call ptx/config-md5, PTXCONF_BAREBOX)
BAREBOX_R5				:= barebox-r5-$(BAREBOX_R5_VERSION)
BAREBOX_R5_SUFFIX			:= tar.bz2
BAREBOX_R5_URL			:= $(call barebox-url, BAREBOX_R5)
BAREBOX_R5_PATCHES		:= barebox-$(BAREBOX_R5_VERSION)
BAREBOX_R5_SOURCE			:= $(SRCDIR)/$(BAREBOX_R5_PATCHES).$(BAREBOX_R5_SUFFIX)
BAREBOX_R5_DIR			:= $(BUILDDIR)/$(BAREBOX_R5)
BAREBOX_R5_BUILD_DIR		:= $(BAREBOX_R5_DIR)-build
BAREBOX_R5_CONFIG			:= $(call ptx/in-platformconfigdir, barebox-r5.config)
BAREBOX_R5_LICENSE		:= GPL-2.0-only
BAREBOX_R5_LICENSE_FILES	:=
BAREBOX_R5_BUILD_OOT		:= KEEP

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

# use host pkg-config for host tools
BAREBOX_R5_PATH			:= PATH=$(HOST_PATH)
BAREBOX_R5_INJECT_PATH 	:= $(PTXDIST_SYSROOT_TARGET)/usr/lib/firmware

BAREBOX_R5_WRAPPER_BLACKLIST := \
	$(PTXDIST_LOWLEVEL_WRAPPER_BLACKLIST)

BAREBOX_R5_CONF_TOOL	:= kconfig
BAREBOX_R5_CONF_OPT	:= \
	-C $(BAREBOX_R5_DIR) \
	O=$(BAREBOX_R5_BUILD_DIR) \
	$(filter-out CROSS_COMPILE%, $(call barebox-opts, BAREBOX_R5)) \
	CROSS_COMPILE=$(PTXDIST_WORKSPACE)/selected_toolchain_r5/$(PTXCONF_COMPILERPREFIX_R5)

BAREBOX_R5_MAKE_OPT	:= $(BAREBOX_R5_CONF_OPT)

BAREBOX_R5_IMAGES := images/barebox-beagleplay-r5.img
BAREBOX_R5_IMAGES := $(addprefix $(BAREBOX_R5_BUILD_DIR)/,$(BAREBOX_R5_IMAGES))

ifdef PTXCONF_BAREBOX_R5
$(BAREBOX_R5_CONFIG):
	@echo
	@echo "****************************************************************************"
	@echo " Please generate a bareboxconfig with 'ptxdist menuconfig barebox-r5'"
	@echo "****************************************************************************"
	@echo
	@echo
	@exit 1
endif

$(STATEDIR)/barebox-r5.prepare:
	@$(call targetinfo)
	@$(call world/inject,BAREBOX_R5)
	@$(call world/prepare,BAREBOX_R5)
	@$(call touch)


# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/barebox-r5.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/barebox-r5.targetinstall:
	@$(call targetinfo)
	@$(foreach image, $(BAREBOX_R5_IMAGES), \
		$(call ptx/image-install, BAREBOX_R5, $(image), \
			$(notdir $(image)))$(ptx/nl))
	@$(call touch)


# ----------------------------------------------------------------------------
# oldconfig / menuconfig
# ----------------------------------------------------------------------------

$(call ptx/kconfig-targets, barebox-r5): $(STATEDIR)/barebox-r5.extract
	@$(call world/kconfig, BAREBOX_R5, $(subst barebox-r5_,,$@))

# vim: syntax=make
