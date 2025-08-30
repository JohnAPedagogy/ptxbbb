# -*-makefile-*-
#
# Copyright (C) 2016 by Philipp Zabel <p.zabel@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_FIRMWARE_IMX) += firmware-imx

#
# Paths and names
#
FIRMWARE_IMX_VERSION	:= 8.23
FIRMWARE_IMX_MD5	:= eb03efb3a8fb98d99ed1df88537e72f4
FIRMWARE_IMX_SKIP	:= 48479
FIRMWARE_IMX		:= firmware-imx-$(FIRMWARE_IMX_VERSION)
FIRMWARE_IMX_SUFFIX	:= bin
FIRMWARE_IMX_URL	:= http://www.nxp.com/lgfiles/NMG/MAD/YOCTO/$(FIRMWARE_IMX).$(FIRMWARE_IMX_SUFFIX)
FIRMWARE_IMX_SOURCE	:= $(SRCDIR)/$(FIRMWARE_IMX).$(FIRMWARE_IMX_SUFFIX)
FIRMWARE_IMX_DIR	:= $(BUILDDIR)/$(FIRMWARE_IMX)
FIRMWARE_IMX_LICENSE	:= NXP-Software-License-Agreement
FIRMWARE_IMX_LICENSE_FILES := \
	file://COPYING;md5=44a8052c384584ba09077e85a3d1654f

#
# Firmware blobs for barebox
#
ifdef PTXCONF_FIRMWARE_IMX_BOOTIMAGE_IMX8
BAREBOX_INJECT_FILES	+= ddr/synopsys/lpddr4_pmu_train_1d_dmem.bin:firmware/lpddr4_pmu_train_1d_dmem.bin
BAREBOX_INJECT_FILES	+= ddr/synopsys/lpddr4_pmu_train_1d_imem.bin:firmware/lpddr4_pmu_train_1d_imem.bin
BAREBOX_INJECT_FILES	+= ddr/synopsys/lpddr4_pmu_train_2d_dmem.bin:firmware/lpddr4_pmu_train_2d_dmem.bin
BAREBOX_INJECT_FILES	+= ddr/synopsys/lpddr4_pmu_train_2d_imem.bin:firmware/lpddr4_pmu_train_2d_imem.bin
BAREBOX_INJECT_FILES	+= ddr/synopsys/ddr4_dmem_1d.bin:firmware/ddr4_dmem_1d.bin
BAREBOX_INJECT_FILES	+= ddr/synopsys/ddr4_dmem_2d.bin:firmware/ddr4_dmem_2d.bin
BAREBOX_INJECT_FILES	+= ddr/synopsys/ddr4_imem_1d.bin:firmware/ddr4_imem_1d.bin
BAREBOX_INJECT_FILES	+= ddr/synopsys/ddr4_imem_2d.bin:firmware/ddr4_imem_2d.bin
endif

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

$(STATEDIR)/firmware-imx.extract:
	@$(call targetinfo)
	@$(call clean, $(FIRMWARE_IMX_DIR))
	@mkdir -p "$(FIRMWARE_IMX_DIR)"
	@dd if="$(FIRMWARE_IMX_SOURCE)" bs=$(FIRMWARE_IMX_SKIP) skip=1 \
		| tar -xj --strip-components=2 -C "$(FIRMWARE_IMX_DIR)"
	@$(call patchin, FIRMWARE_IMX)
	@$(call touch)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

FIRMWARE_IMX_CONF_TOOL	:= NO

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/firmware-imx.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

FIRMWARE_IMX_INSTALL-y					:=
FIRMWARE_IMX_INSTALL-$(PTXCONF_FIRMWARE_IMX_VPU_IMX27)	+= vpu_fw_imx27_TO2.bin
FIRMWARE_IMX_INSTALL-$(PTXCONF_FIRMWARE_IMX_VPU_IMX6Q)	+= vpu_fw_imx6q.bin
FIRMWARE_IMX_INSTALL-$(PTXCONF_FIRMWARE_IMX_VPU_IMX6DL)	+= vpu_fw_imx6d.bin
FIRMWARE_IMX_INSTALL-$(PTXCONF_FIRMWARE_IMX_VPU_IMX53)	+= vpu_fw_imx53.bin
FIRMWARE_IMX_INSTALL-$(PTXCONF_FIRMWARE_IMX_VPU_IMX51)	+= vpu_fw_imx51.bin

$(STATEDIR)/firmware-imx.install:
	@$(call targetinfo)

	@$(foreach f,$(FIRMWARE_IMX_INSTALL-y), \
		install -v -D -m644 $(FIRMWARE_IMX_DIR)/firmware/vpu/$(f) \
		$(FIRMWARE_IMX_PKGDIR)/usr/lib/firmware/vpu/$(f)$(ptx/nl))

ifdef PTXCONF_FIRMWARE_IMX_BOOTIMAGE_IMX8
	@$(foreach f, lpddr4_pmu_train_1d_imem_202006.bin lpddr4_pmu_train_1d_dmem_202006.bin \
	              lpddr4_pmu_train_2d_imem_202006.bin lpddr4_pmu_train_2d_dmem_202006.bin, \
		install -v -D -m644 $(FIRMWARE_IMX_DIR)/firmware/ddr/synopsys/$(f) \
		$(FIRMWARE_IMX_PKGDIR)/usr/lib/firmware/ddr/synopsys/$(f)$(ptx/nl))

	@$(foreach f, lpddr4_pmu_train_1d_dmem.bin lpddr4_pmu_train_1d_imem.bin \
	              lpddr4_pmu_train_2d_dmem.bin lpddr4_pmu_train_2d_imem.bin, \
		install -v -D -m644 $(FIRMWARE_IMX_DIR)/firmware/ddr/synopsys/$(f) \
		$(FIRMWARE_IMX_PKGDIR)/usr/lib/firmware/ddr/synopsys/$(f)$(ptx/nl))

	@$(foreach f, ddr4_dmem_1d.bin ddr4_dmem_2d.bin \
	              ddr4_imem_1d.bin ddr4_imem_2d.bin, \
		install -v -D -m644 $(FIRMWARE_IMX_DIR)/firmware/ddr/synopsys/$(f) \
		$(FIRMWARE_IMX_PKGDIR)/usr/lib/firmware/ddr/synopsys/$(f)$(ptx/nl))

	@$(foreach f, signed_dp_imx8m.bin signed_hdmi_imx8m.bin, \
		install -v -D -m644 $(FIRMWARE_IMX_DIR)/firmware/hdmi/cadence/$(f) \
		$(FIRMWARE_IMX_PKGDIR)/usr/lib/firmware/hdmi/cadence/$(f)$(ptx/nl))
endif

ifdef PTXCONF_FIRMWARE_IMX_BOOTIMAGE_IMX9
	@$(foreach f, lpddr4_imem_1d_v202201.bin lpddr4_dmem_1d_v202201.bin \
	              lpddr4_imem_2d_v202201.bin lpddr4_dmem_2d_v202201.bin, \
		install -v -D -m644 $(FIRMWARE_IMX_DIR)/firmware/ddr/synopsys/$(f) \
		$(FIRMWARE_IMX_PKGDIR)/usr/lib/firmware/ddr/synopsys/$(f)$(ptx/nl))
endif

	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/firmware-imx.targetinstall:
	@$(call targetinfo)

	@$(call install_init, firmware-imx)
	@$(call install_fixup, firmware-imx,PRIORITY,optional)
	@$(call install_fixup, firmware-imx,SECTION,base)
	@$(call install_fixup, firmware-imx,AUTHOR,"Philipp Zabel <p.zabel@pengutronix.de>")
	@$(call install_fixup, firmware-imx,DESCRIPTION,missing)
	@$(foreach f,$(FIRMWARE_IMX_INSTALL-y), \
		$(call install_copy, firmware-imx, 0, 0, 0644, \
			$(FIRMWARE_IMX_PKGDIR)/usr/lib/firmware/vpu/$(f), \
			/usr/lib/firmware/$(f))$(ptx/nl))
	@$(call install_finish, firmware-imx)

	@$(call touch)

# vim: syntax=make
