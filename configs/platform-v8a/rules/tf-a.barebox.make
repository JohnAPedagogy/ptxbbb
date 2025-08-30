ifdef PTXCONF_TF_A
# currently k3, imx8(mq/mm/mn/mp), imx93
BAREBOX_INJECT_FILES	+= $(foreach plat,$(TF_A_PLATFORMS), \
	$(plat)-bl31.bin:firmware/$(plat)-bl31.bin)
endif