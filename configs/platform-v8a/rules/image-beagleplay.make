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
IMAGE_PACKAGES-$(PTXCONF_IMAGE_BEAGLEPLAY) += image-beagleplay

#
# Paths and names
#
IMAGE_BEAGLEPLAY		:= image-beagleplay
IMAGE_BEAGLEPLAY_DIR	:= $(BUILDDIR)/$(IMAGE_BEAGLEPLAY)
IMAGE_BEAGLEPLAY_IMAGE	:= $(IMAGEDIR)/image-beagleplay.hdimg
IMAGE_BEAGLEPLAY_FILES	:= $(IMAGEDIR)/root.tgz
IMAGE_BEAGLEPLAY_CONFIG	:= image-beagleplay.config

IMAGE_BEAGLEPLAY_ENV := \
					IMAGE_FIP_K3=$(IMAGEDIR)/k3.fip \
					IMAGE_BAREBOX_R5=$(IMAGEDIR)/barebox-beagleplay-r5.img \
					IMAGE_BAREBOX=$(IMAGEDIR)/barebox-beagleplay.img



# ----------------------------------------------------------------------------
# Image
# ----------------------------------------------------------------------------

$(IMAGE_BEAGLEPLAY_IMAGE):
	@$(call targetinfo)
	@$(call image/genimage, IMAGE_BEAGLEPLAY)
	@$(call finish)

# vim: syntax=make
