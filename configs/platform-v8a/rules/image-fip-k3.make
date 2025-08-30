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
IMAGE_PACKAGES-$(PTXCONF_IMAGE_FIP_K3) += image-fip-k3

#
# Paths and names
#
IMAGE_FIP_K3			:= image-fip-k3
IMAGE_FIP_K3_DIR		:= $(BUILDDIR)/$(IMAGE_FIP_K3)
IMAGE_FIP_K3_IMAGE	:= $(IMAGEDIR)/k3.fip
IMAGE_FIP_K3_CONFIG	:= image-fip-k3.config


IMAGE_FIP_K3_ENV := \
					FIP_K3_BL31=$(IMAGEDIR)/bl31.bin \
					FIP_K3_DM_FW=$(SYSROOT)/usr/lib/firmware/ti-dm/am62xx/ti-dm.bin \
					FIP_K3_BAREBOX=$(IMAGEDIR)/barebox-beagleplay.img

# ----------------------------------------------------------------------------
# Image
# ----------------------------------------------------------------------------

$(IMAGE_FIP_K3_IMAGE):
	@$(call targetinfo)
	@rm -f $(IMAGEDIR)/bl31.bin
	@cp $(IMAGEDIR)/k3-bl31.bin $(IMAGEDIR)/bl31.bin
	@$(call image/genimage, IMAGE_FIP_K3)
	@$(call finish)

# vim: syntax=make
