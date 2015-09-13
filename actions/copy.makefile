#!/usr/bin/make -f
#
# Copies bin, lib, and etc directories. Could easily be extended to install
# additional directories as necessary. Usage should look like this:
#
#   #!/usr/bin/make -f
#   CLONEDIR=scm/common
#   include $(SCMDIR)/actions/copy.makefile
#

# to add support for a new directroy, just add the DEPLOY here
# and add it to the list of SUBDIRS
DEPLOY_etc?=$(RELEASE_DIR)/etc
DEPLOY_bin?=$(RELEASE_DIR)/bin
DEPLOY_lib?=$(RELEASE_DIR)/lib
SUBDIRS?=etc bin lib
