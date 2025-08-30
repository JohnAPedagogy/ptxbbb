# -*-makefile-*-
#
# Copyright (C) 2016 by Robert Schwebel <r.schwebel@pengutronix.de>
# Copyright (C) 2023 Roland Hieber, Pengutronix <rhi@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_REPART_CONFIG) += repart-config

REPART_CONFIG_VERSION	:= 1
REPART_CONFIG_LICENSE	:= ignore

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/repart-config.targetinstall:
	@$(call targetinfo)

	@$(call install_init, repart-config)
	@$(call install_fixup,repart-config,PRIORITY,optional)
	@$(call install_fixup,repart-config,SECTION,base)
	@$(call install_fixup,repart-config,AUTHOR,"Robert Schwebel <r.schwebel@pengutronix.de>")
	@$(call install_fixup,repart-config,DESCRIPTION,missing)

	@$(call install_copy, repart-config, 0, 0, 0755, /mnt/data)
	@$(call install_alternative, repart-config, 0, 0, 0644, \
		/usr/lib/systemd/system/mnt-data.mount)

	@# Note: we only want to call systemd-repart in rc-once, so don't
	@# install the configs to any path picked up by systemd-repart.service
	@$(call install_alternative_tree, repart-config, 0, 0, \
		/etc/repart.rc-once.d/)
	@$(call install_alternative, repart-config, 0, 0, 0755, \
		/etc/rc.once.d/repart)

	@$(call install_finish,repart-config)

	@$(call touch)

# vim: syntax=make
