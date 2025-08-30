# -*-makefile-*-
#
# Copyright (C) 2025 by Fabian Pflug <f.pflug@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
IMAGE_PACKAGES-$(PTXCONF_IMAGE_TQ_MBA93XXCA) += image-tq-mba93xxca

#
# Paths and names
#
IMAGE_TQ_MBA93XXCA		:= image-tq-mba93xxca
IMAGE_TQ_MBA93XXCA_DIR		:= $(BUILDDIR)/$(IMAGE_TQ_MBA93XXCA)
IMAGE_TQ_MBA93XXCA_IMAGE	:= $(IMAGEDIR)/tq-mba93xxca.img
IMAGE_TQ_MBA93XXCA_FILES	:= $(IMAGEDIR)/root.tgz
IMAGE_TQ_MBA93XXCA_CONFIG	:= imx93.config

# ----------------------------------------------------------------------------
# Image
# ----------------------------------------------------------------------------

IMAGE_TQ_MBA93XXCA_ENV := \
        BAREBOX_IMAGE=barebox-tqma93xx.img

$(IMAGE_TQ_MBA93XXCA_IMAGE):
	@$(call targetinfo)
	@$(call image/genimage, IMAGE_TQ_MBA93XXCA)
	@$(call finish)

# vim: syntax=make
