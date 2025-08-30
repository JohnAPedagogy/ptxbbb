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
IMAGE_PACKAGES-$(PTXCONF_IMAGE_STM32MP135F_DK) += image-stm32mp135f-dk

IMAGE_STM32MP135F_DK_ENV := STM32MP_BOARD=stm32mp135f-dk

#
# Paths and names
#
IMAGE_STM32MP135F_DK		:= image-stm32mp135f-dk
IMAGE_STM32MP135F_DK_DIR	:= $(BUILDDIR)/$(IMAGE_STM32MP135F_DK)
IMAGE_STM32MP135F_DK_IMAGE	:= $(IMAGEDIR)/stm32mp135f-dk.hdimg
IMAGE_STM32MP135F_DK_FILES	:= $(IMAGEDIR)/root.tgz
IMAGE_STM32MP135F_DK_CONFIG	:= stm32mp-optee.config

# ----------------------------------------------------------------------------
# Image
# ----------------------------------------------------------------------------

$(IMAGE_STM32MP135F_DK_IMAGE):
	@$(call targetinfo)
	@$(call image/genimage, IMAGE_STM32MP135F_DK)
	@$(call finish)

# vim: syntax=make
