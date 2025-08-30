# -*-makefile-*-
#
# Copyright (C) 2024 by Alexander Dahl <ada@thorsis.com>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_FIRMWARE_SENTINEL) += firmware-sentinel

#
# Paths and names
#
FIRMWARE_SENTINEL_VERSION	:= 0.11
FIRMWARE_SENTINEL_MD5		:= 339011b6b199151d835c03089a3c2221
FIRMWARE_SENTINEL_SKIP		:= 47053
FIRMWARE_SENTINEL		:= firmware-sentinel-$(FIRMWARE_SENTINEL_VERSION)
FIRMWARE_SENTINEL_SUFFIX	:= bin
FIRMWARE_SENTINEL_URL		:= http://www.nxp.com/lgfiles/NMG/MAD/YOCTO/$(FIRMWARE_SENTINEL).$(FIRMWARE_SENTINEL_SUFFIX)
FIRMWARE_SENTINEL_SOURCE	:= $(SRCDIR)/$(FIRMWARE_SENTINEL).$(FIRMWARE_SENTINEL_SUFFIX)
FIRMWARE_SENTINEL_DIR		:= $(BUILDDIR)/$(FIRMWARE_SENTINEL)
FIRMWARE_SENTINEL_LICENSE	:= NXP-Software-License-Agreement
FIRMWARE_SENTINEL_LICENSE_FILES	:= \
	file://COPYING;md5=db4762b09b6bda63da103963e6e081de

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

$(STATEDIR)/firmware-sentinel.extract:
	@$(call targetinfo)
	@$(call clean, $(FIRMWARE_SENTINEL_DIR))
	@mkdir -p "$(FIRMWARE_SENTINEL_DIR)"
	@dd if="$(FIRMWARE_SENTINEL_SOURCE)" bs=$(FIRMWARE_SENTINEL_SKIP) skip=1 \
		| tar -xj --strip-components=2 -C "$(FIRMWARE_SENTINEL_DIR)"
	@$(call patchin, FIRMWARE_SENTINEL)
	@$(call touch)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

FIRMWARE_SENTINEL_CONF_TOOL	:= NO

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/firmware-sentinel.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/firmware-sentinel.install:
	@$(call targetinfo)

	@install -d -m755 $(FIRMWARE_SENTINEL_PKGDIR)/usr/lib/firmware
	@install -v -m644 $(FIRMWARE_SENTINEL_DIR)/mx93a1-ahab-container.img \
		$(FIRMWARE_SENTINEL_PKGDIR)/usr/lib/firmware/

	@$(call touch)

# vim: syntax=make
