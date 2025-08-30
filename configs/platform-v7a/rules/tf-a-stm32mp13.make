# -*-makefile-*-
#
# Copyright (C) 2018 by Rouven Czerwinski <r.czerwinski@pengutronix.de>
#               2019 by Ahmad Fatoum <a.fatoum@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_TF_A_STM32MP13) += tf-a-stm32mp13

#
# Paths and names
#
TF_A_STM32MP13_VERSION		:= $(call ptx/config-version, PTXCONF_TF_A)
TF_A_STM32MP13_MD5		:= $(call ptx/config-md5, PTXCONF_TF_A)
TF_A_STM32MP13			:= tf-a-stm32mp13-$(TF_A_STM32MP13_VERSION)
TF_A_STM32MP13_SUFFIX		:= tar.gz
TF_A_STM32MP13_URL		 = $(TF_A_URL)
TF_A_STM32MP13_SOURCE		 = $(TF_A_SOURCE)
TF_A_STM32MP13_DIR		:= $(BUILDDIR)/$(TF_A_STM32MP13)
TF_A_STM32MP13_BUILD_DIR	:= $(TF_A_STM32MP13_DIR)/build
TF_A_STM32MP13_BUILD_OOT	:= YES
TF_A_STM32MP13_LICENSE		:= BSD-3-Clause AND BSD-2-Clause \
		   AND (GPL-2.0-or-later OR BSD-2-Clause) \
		   AND (NCSA OR MIT) \
		   AND Zlib \
		   AND (GPL-2.0-or-later OR BSD-3-Clause)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

TF_A_STM32MP13_PLATFORMS		:= stm32mp1
TF_A_STM32MP13_ARTIFACTS		:= tf-a-*.stm32 fdts/*-fw-config.dtb

TF_A_STM32MP13_WRAPPER_BLACKLIST	:= \
	$(PTXDIST_LOWLEVEL_WRAPPER_BLACKLIST)

TF_A_STM32MP13_PATH	:= PATH=$(CROSS_PATH)
TF_A_STM32MP13_MAKE_OPT	:= \
	-C $(TF_A_STM32MP13_DIR) \
	CROSS_COMPILE=$(BOOTLOADER_CROSS_COMPILE) \
	HOSTCC=$(HOSTCC) \
	ARCH=aarch32 \
	ARM_ARCH_MAJOR=7 \
	BUILD_STRING=$(TF_A_STM32MP13_VERSION) \
	DTB_FILE_NAME='stm32mp135f-dk.dtb' \
	STM32MP_EMMC=1 STM32MP_SDMMC=1 \
	STM32MP_RAW_NAND=1 STM32MP_SPI_NAND=1 STM32MP_SPI_NOR=1 \
	STM32MP_USB_PROGRAMMER=1 \
	AARCH32_SP=optee \
	all

TF_A_STM32MP13_CONF_TOOL	:= NO

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/tf-a-stm32mp13.compile:
	@$(call targetinfo)

	@$(foreach plat, $(TF_A_STM32MP13_PLATFORMS), \
		$(call compile, TF_A_STM32MP13, \
		$(TF_A_STM32MP13_MAKE_OPT) PLAT=$(plat))$(ptx/nl))

	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tf-a-stm32mp13/inst_plat = $(foreach artifact, \
	$(foreach pattern, $(TF_A_STM32MP13_ARTIFACTS), \
	$(wildcard $(TF_A_STM32MP13_BUILD_DIR)/$(1)/$(if $(filter DEBUG=1,TF_A_STM32MP13_MAKE_OPT),debug,release)/$(pattern))), \
	install -v -D -m 644 $(artifact) \
		$(2)/$(1)-$(notdir $(artifact))$(ptx/nl))

tf-a-stm32mp13/inst_bins = $(foreach plat, $(TF_A_STM32MP13_PLATFORMS), $(call tf-a-stm32mp13/inst_plat,$(plat),$(1)))

$(STATEDIR)/tf-a-stm32mp13.install:
	@$(call targetinfo)
	@$(call tf-a-stm32mp13/inst_bins,$(TF_A_STM32MP13_PKGDIR)/usr/lib/firmware)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/tf-a-stm32mp13.targetinstall:
	@$(call targetinfo)
	@$(call tf-a-stm32mp13/inst_bins,$(IMAGEDIR))
	@$(call touch)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

$(STATEDIR)/tf-a-stm32mp13.clean:
	@$(call targetinfo)
	@rm -vf $(addprefix $(IMAGEDIR)/, $(notdir $(TF_A_STM32MP13_ARTIFACTS_SRC)))
	@$(call clean_pkg, TF_A_STM32MP13)

# vim: syntax=make
