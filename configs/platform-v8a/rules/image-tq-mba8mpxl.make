# -*-makefile-*-
#
# Copyright (C) 2020 by Sascha Hauer <s.hauer@pengutronix.de>
# Copyright (C) 2024 by Leonard Göhrs <l.goehrs@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
IMAGE_PACKAGES-$(PTXCONF_IMAGE_TQ_MBA8MPXL) += image-tq-mba8mpxl

#
# Paths and names
#
IMAGE_TQ_MBA8MPXL		:= image-tq-mba8mpxl
IMAGE_TQ_MBA8MPXL_DIR	:= $(BUILDDIR)/$(IMAGE_TQ_MBA8MPXL)
IMAGE_TQ_MBA8MPXL_IMAGE	:= $(IMAGEDIR)/tq-mba8mpxl.img
IMAGE_TQ_MBA8MPXL_FILES	:= $(IMAGEDIR)/root.tgz
IMAGE_TQ_MBA8MPXL_CONFIG	:= imx8m.config

# ----------------------------------------------------------------------------
# Image
# ----------------------------------------------------------------------------

IMAGE_TQ_MBA8MPXL_ENV := \
        BAREBOX_IMAGE=barebox-tqma8mpxl.img

$(IMAGE_TQ_MBA8MPXL_IMAGE):
	@$(call targetinfo)
	@$(call image/genimage, IMAGE_TQ_MBA8MPXL)
	@$(call finish)

# vim: syntax=make
