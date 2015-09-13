#!/usr/bin/make -f

# if no option is given then we'll just run "make build"
all: build

# get the location where our script actually exists
SCM?=$(realpath $(firstword $(MAKEFILE_LIST)))
SCMDIR?=$(dir $(SCM))

# include configuration
include $(SCMDIR)/bin/config
include $(SCMDIR)/bin/servers

# include the build scripts
MODULES=$(sort $(wildcard modules/scm.*))
include $(MODULES)

# move everything under /bin to be under the root of the deployed project and
# move everything in /modules to be under /modules in the deployed project. if
# the config and servers files exist then they will be copied, too, because
# .gitignore tells rsync to not copy them
.PHONY: post_build_hook
post_build_hook::
	mkdir -p $(RELEASE_DIR)/scm
	$(RSYNC) $(RSYNC_FLAGS) --exclude="*.example" $(BUILD_DIR)/bin/ $(RELEASE_DIR)/scm/
	$(RSYNC) $(RSYNC_FLAGS) --exclude="*.example" $(BUILD_DIR)/modules/ $(RELEASE_DIR)/scm/modules/
	$(RSYNC) $(RSYNC_FLAGS) --exclude="*.example" $(BUILD_DIR)/plugins/ $(RELEASE_DIR)/scm/plugins/
	$(RSYNC) $(RSYNC_FLAGS) --exclude="*.example" $(BUILD_DIR)/actions/ $(RELEASE_DIR)/scm/actions/
	if test -e $(CURDIR)/bin/config; then \
		cp -pf $(CURDIR)/bin/config $(BUILD_DIR)/bin/config; \
		cp -pf $(CURDIR)/bin/config $(RELEASE_DIR)/scm/config; \
	fi
	if test -e $(CURDIR)/bin/servers; then \
		cp -pf $(CURDIR)/bin/servers $(BUILD_DIR)/bin/servers; \
		cp -pf $(CURDIR)/bin/servers $(RELEASE_DIR)/scm/servers; \
	fi
