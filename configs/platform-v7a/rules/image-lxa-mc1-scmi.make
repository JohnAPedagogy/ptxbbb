# -*-makefile-*-
#
# Copyright (C) 2024 by Ahmad Fatoum <a.fatoum@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
IMAGE_PACKAGES-$(PTXCONF_IMAGE_LXA_MC1_SCMI) += image-lxa-mc1-scmi

IMAGE_LXA_MC1_SCMI_ENV := STM32MP_BOARD=stm32mp157c-lxa-mc1 SCMI=-scmi

#
# Paths and names
#
IMAGE_LXA_MC1_SCMI		:= image-lxa-mc1-scmi
IMAGE_LXA_MC1_SCMI_DIR		:= $(BUILDDIR)/$(IMAGE_LXA_MC1_SCMI)
IMAGE_LXA_MC1_SCMI_IMAGE	:= $(IMAGEDIR)/lxa-mc1-scmi.hdimg
IMAGE_LXA_MC1_SCMI_FILES	:= $(IMAGEDIR)/root.tgz
IMAGE_LXA_MC1_SCMI_CONFIG	:= stm32mp.config

# ----------------------------------------------------------------------------
# Image
# ----------------------------------------------------------------------------

$(IMAGE_LXA_MC1_SCMI_IMAGE):
	@$(call targetinfo)
	@$(call image/genimage, IMAGE_LXA_MC1_SCMI)
	@$(call finish)

# vim: syntax=make
