# short-circuit the build since the recipe is only used to serve a REF_CONFIG
BAREBOX_MAKE_ENV=:

# don't error out when trying to copy the defaultenv in the targetinstall stage
$(STATEDIR)/barebox.targetinstall: $(BAREBOX_BUILD_DIR)/defaultenv/barebox_zero_env
$(BAREBOX_BUILD_DIR)/defaultenv/barebox_zero_env: $(STATEDIR)/barebox.compile
	mkdir -p "$(dir $@)" && touch $@
