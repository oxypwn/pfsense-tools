#!/bin/sh

# pfSense master builder script
# (C)2005 Scott Ullrich and the pfSense project
# All rights reserved.
#
# $Id$

set -e -u

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Use pfSense.6 as kernel configuration file
export KERNELCONF=${KERNELCONF:-"${PWD}/conf/pfSense.6"}

# Use normal make.conf
export MAKE_CONF="${PWD}/conf/make.conf"

# Add etcmfs and rootmfs to the EXTRA plugins used by freesbie2
export EXTRA="${EXTRA:-} rootmfs varmfs etcmfs" 

export PRUNE_LIST="${PWD}/remove.list.iso"

# If a embedded build has been performed we need to nuke
# /usr/obj.pfSense/ since full uses a different
# make.conf
if [ -f /usr/obj.pfSense/pfSense_wrap.6.world.done ]; then
	echo -n "Removing /usr/obj* since embedded build performed prior..."
	rm -rf /usr/obj*
	echo "done."
fi

# Clean out directories
freesbie_make cleandir

# Checkout a fresh copy from pfsense cvs depot
update_cvs_depot

# Calculate versions
export version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
export version_base=`cat $CVS_CO_DIR/etc/version_base`
export version=`cat $CVS_CO_DIR/etc/version`

# Build if needed and install world and kernel
make_world_kernel

# Add extra files such as buildtime of version, bsnmpd, etc.
echo ">>> Phase populate_extra"
( populate_extra )
echo ">>> Phase set_image_as_cdrom"
( set_image_as_cdrom )

# Nuke the boot directory
[ -d "${CVS_CO_DIR}/boot" ] && rm -rf ${CVS_CO_DIR}/boot

rm -f conf/packages

set +e # grep could fail
(cd /var/db/pkg && ls | grep bsdinstaller) > conf/packages
(cd /var/db/pkg && ls | grep lighttpd) >> conf/packages
(cd /var/db/pkg && ls | grep lua) >> conf/packages
(cd /var/db/pkg && ls | grep cpdup) >> conf/packages
set -e

# Invoke FreeSBIE2 toolchain
freesbie_make iso
