# -*-makefile-*-
#
# Copyright (C) 2017 by Sascha Hauer <s.hauer@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
IMAGE_PACKAGES-$(PTXCONF_IMAGE_RPI) += image-rpi

#
# Paths and names
#
IMAGE_RPI		:= image-rpi
IMAGE_RPI_DIR		:= $(BUILDDIR)/$(IMAGE_RPI)
IMAGE_RPI_IMAGE		:= $(IMAGEDIR)/rpi.hdimg
IMAGE_RPI_FILES		:= $(IMAGEDIR)/root.tgz
IMAGE_RPI_CONFIG	:= rpi.config
IMAGE_RPI_DATA_DIR	:= $(call ptx/in-path, PTXDIST_PATH, rpi-firmware)
IMAGE_RPI_DATA		:= \
	$(wildcard $(IMAGE_RPI_DATA_DIR)/*.bin) \
	$(wildcard $(IMAGE_RPI_DATA_DIR)/*.elf) \
	$(wildcard $(IMAGE_RPI_DATA_DIR)/*.dat) \
	$(wildcard $(IMAGE_RPI_DATA_DIR)/*.dtb) \
	$(wildcard $(IMAGE_RPI_DATA_DIR)/config.txt)

# ----------------------------------------------------------------------------
# Image
# ----------------------------------------------------------------------------

define squote_and_comma
$(subst $(ptx/def/space),$(comma) ,$(addsuffix $(ptx/def/squote),$(addprefix $(ptx/def/squote),$(1))))
endef

IMAGE_RPI_ENV := \
        FIRMWARE_RPI="$(call squote_and_comma,$(IMAGE_RPI_DATA))"

$(IMAGE_RPI_IMAGE):
	@$(call targetinfo)
	@$(call image/genimage, IMAGE_RPI)
	@$(call finish)

# vim: syntax=make
