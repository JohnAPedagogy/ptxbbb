# -*-makefile-*-
#
# Copyright (C) 2017 by Robert Schwebel <r.schwebel@pengutronix.de>
# Copyright (C) 2020 by Oleksij Rempel <o.rempel@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_BAREBOX_MALTA) += barebox-malta

#
# Paths and names
#
BAREBOX_MALTA_VERSION		:= $(call remove_quotes,$(PTXCONF_BAREBOX_VERSION))
BAREBOX_MALTA_MD5		:= $(call remove_quotes,$(PTXCONF_BAREBOX_MD5))
BAREBOX_MALTA			:= barebox-malta-$(BAREBOX_MALTA_VERSION)
BAREBOX_MALTA_SUFFIX		:= tar.bz2
BAREBOX_MALTA_URL		:= $(call barebox-url, BAREBOX_MALTA)
BAREBOX_MALTA_PATCHES		:= barebox-$(BAREBOX_MALTA_VERSION)
BAREBOX_MALTA_SOURCE		:= $(SRCDIR)/$(BAREBOX_MALTA_PATCHES).$(BAREBOX_MALTA_SUFFIX)
BAREBOX_MALTA_DIR		:= $(BUILDDIR)/$(BAREBOX_MALTA)
BAREBOX_MALTA_BUILD_DIR		:= $(BAREBOX_MALTA_DIR)-build
BAREBOX_MALTA_CONFIG		:= $(call ptx/in-platformconfigdir, barebox-malta.config)
BAREBOX_MALTA_REF_CONFIG	:= $(call ptx/in-platformconfigdir, barebox.config)
BAREBOX_MALTA_LICENSE		:= GPL-2.0-only
BAREBOX_MALTA_LICENSE_FILES	:= $(BAREBOX_LICENSE_FILES)
BAREBOX_MALTA_BUILD_OOT		:= KEEP

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

# use host pkg-config for host tools
BAREBOX_MALTA_PATH		:= PATH=$(HOST_PATH)

BAREBOX_MALTA_WRAPPER_BLACKLIST := \
	$(PTXDIST_LOWLEVEL_WRAPPER_BLACKLIST)

BAREBOX_MALTA_CONF_TOOL	:= kconfig
BAREBOX_MALTA_CONF_OPT	:= \
	-C $(BAREBOX_MALTA_DIR) \
	O=$(BAREBOX_MALTA_BUILD_DIR) \
	$(call barebox-opts, BAREBOX_MALTA)

BAREBOX_MALTA_MAKE_OPT	:= $(BAREBOX_MALTA_CONF_OPT)

BAREBOX_MALTA_IMAGES := images/barebox-qemu-malta.img.swapped
BAREBOX_MALTA_IMAGES := $(addprefix $(BAREBOX_MALTA_BUILD_DIR)/,$(BAREBOX_MALTA_IMAGES))

ifdef PTXCONF_BAREBOX_MALTA
$(BAREBOX_MALTA_CONFIG):
	@echo
	@echo "****************************************************************************"
	@echo " Please generate a bareboxconfig with 'ptxdist menuconfig barebox-malta'"
	@echo "****************************************************************************"
	@echo
	@echo
	@exit 1
endif

$(STATEDIR)/barebox-malta.prepare: $(BAREBOX_MALTA_CONFIG)
	@$(call targetinfo)
	@$(call world/prepare, BAREBOX_MALTA)
	@rm -f "$(BAREBOX_MALTA_BUILD_DIR)/.ptxdist-defaultenv"
	@ln -s "$(call ptx/in-platformconfigdir, barebox-malta-defaultenv)" \
		"$(BAREBOX_MALTA_BUILD_DIR)/.ptxdist-defaultenv"
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/barebox-malta.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/barebox-malta.targetinstall:
	@$(call targetinfo)
	@$(foreach image, $(BAREBOX_MALTA_IMAGES), \
		$(call ptx/image-install, BAREBOX_MALTA, $(image), \
			$(notdir $(image))-malta)$(ptx/nl))
	@$(call ptx/image-install, BAREBOX_MALTA, \
		$(BAREBOX_MALTA_BUILD_DIR)/defaultenv/barebox_zero_env, \
		barebox-zero-env-malta)
	@$(call ptx/image-install, BAREBOX_MALTA, \
		$(BAREBOX_MALTA_BUILD_DIR)/arch/mips/dts/qemu-malta.dtb, \
		qemu-malta.dtb-bb)

	@$(call touch)

# ----------------------------------------------------------------------------
# oldconfig / menuconfig
# ----------------------------------------------------------------------------

$(call ptx/kconfig-targets, barebox-malta): $(STATEDIR)/barebox-malta.extract
	@$(call world/kconfig, BAREBOX_MALTA, $(subst barebox-malta_,,$@))

# vim: syntax=make
