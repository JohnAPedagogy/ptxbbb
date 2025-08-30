# -*-makefile-*-
#
# Copyright (C) 2025 by Michael Olbrich <m.olbrich@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_FIRMWARE_TI) += firmware-ti

#
# Paths and names
#
FIRMWARE_TI_VERSION		:= 11.00.07
FIRMWARE_TI_MD5			:= 65377f3f8ada7f6276e088e1b87cc5c6
FIRMWARE_TI				:= ti-linux-firmware-$(FIRMWARE_TI_VERSION)
FIRMWARE_TI_SUFFIX		:= tar.gz
FIRMWARE_TI_URL			:= https://git.ti.com/cgit/processor-firmware/ti-linux-firmware/snapshot/$(FIRMWARE_TI).$(FIRMWARE_TI_SUFFIX)
FIRMWARE_TI_SOURCE		:= $(SRCDIR)/$(FIRMWARE_TI).$(FIRMWARE_TI_SUFFIX)
FIRMWARE_TI_DIR			:= $(BUILDDIR)/$(FIRMWARE_TI)
FIRMWARE_TI_LICENSE		:= unknown
FIRMWARE_TI_LICENSE_FILES	:=

FIRMWARE_TI_FIRMWARE_FILES	:= \
	ti-fs-firmware-am62x-gp.bin \
	ti-fs-firmware-am62x-hs-fs-cert.bin \
	ti-fs-firmware-am62x-hs-fs-enc.bin

#
# Firmware blobs for barebox
#
ifdef PTXCONF_FIRMWARE_TI
BAREBOX_R5_INJECT_FILES		+= \
	$(foreach f,$(FIRMWARE_TI_FIRMWARE_FILES),ti-sysfw/$(f):firmware/ti-linux-firmware/ti-sysfw/$(f))
endif

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

FIRMWARE_TI_CONF_TOOL	:= NO

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/firmware-ti.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/firmware-ti.install:
	@$(call targetinfo)
	@$(foreach f,$(FIRMWARE_TI_FIRMWARE_FILES), \
		install -v -D -m644 $(FIRMWARE_TI_DIR)/ti-sysfw/$(f) \
		$(FIRMWARE_TI_PKGDIR)/usr/lib/firmware/ti-sysfw/$(f)$(ptx/nl))
	@install -v -D -m644 $(FIRMWARE_TI_DIR)/ti-dm/am62xx/ipc_echo_testb_mcu1_0_release_strip.xer5f \
        $(FIRMWARE_TI_PKGDIR)/usr/lib/firmware/ti-dm/am62xx/ti-dm.bin
	@$(call touch)

# vim: syntax=make
