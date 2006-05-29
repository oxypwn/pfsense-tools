#!/bin/sh

# pfSense build all master script.
# (C)2006 Scott Ullrich

# NOTE: this script will set SKIP_RSYNC=yo (yes)
export SKIP_RSYNC=yo

# Suck in pfSense specific information
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Update source against freebsd.org and pfsense.com
# and build a iso
sh -x ./cvsup_current

# Build general updates
sh -x ./build_updates.sh

# Build developer ISO
sh -x ./build_deviso.sh

# Build embedded image
sh -x ./build_embedded.sh

# Build embedded updates
sh -x #./build_updates_embedded.sh

