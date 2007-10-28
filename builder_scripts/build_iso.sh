#!/bin/sh

# pfSense master builder script
# (C)2005-2006 Scott Ullrich and the pfSense project
# All rights reserved.
#
# $Id$

#set -e -u -x

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Allow old CVS_CO_DIR to be deleted later
chflags -R noschg $CVS_CO_DIR

# Use pfSense.6 as kernel configuration file
if [ $pfSense_version = "6" ]; then
	export KERNELCONF=${KERNELCONF:-"${PWD}/conf/pfSense.6"}
fi
if [ $pfSense_version = "7" ]; then
	export KERNELCONF=${KERNELCONF:-"${PWD}/conf/pfSense.7"}
fi

# Use normal make.conf
if [ $pfSense_version = "6" ]; then
	export MAKE_CONF="${PWD}/conf/make.conf"
fi
if [ $pfSense_version = "7" ]; then
	export MAKE_CONF="${PWD}/conf/make.conf.7"
fi

# Add etcmfs and rootmfs to the EXTRA plugins used by freesbie2
export EXTRA="${EXTRA:-} rootmfs varmfs etcmfs"

if [ $pfSense_version = "6" ]; then
	export PRUNE_LIST="${PWD}/remove.list.iso"
fi
if [ $pfSense_version = "7" ]; then
	export PRUNE_LIST="${PWD}/remove.list.iso.7"
fi

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

if [ $pfSense_version = "7" ]; then
	recompile_pfPorts
fi

if [ $pfSense_version = "7" ]; then
	export MAKE_CONF="${PWD}/conf/make.conf.7.install" 
fi

# Build if needed and install world and kernel
make_world_kernel

# Build SMP, Embedded (wrap) and Developers edition kernels
build_all_kernels

# Add extra files such as buildtime of version, bsnmpd, etc.
echo ">>> Phase populate_extra"
( populate_extra )
# Add extra pfSense packages
echo ">>> Phase install_custom_packages"
( install_custom_packages )
echo ">>> Phase set_image_as_cdrom"
( set_image_as_cdrom )

# Fixup library changes if needed
fixup_libmap

# Nuke the boot directory
[ -d "${CVS_CO_DIR}/boot" ] && rm -rf ${CVS_CO_DIR}/boot

rm -f $BASE_DIR/tools/builder_scripts/conf/packages

set +e # grep could fail
(cd /var/db/pkg && ls | grep bsdinstaller) > $BASE_DIR/tools/builder_scripts/conf/packages
(cd /var/db/pkg && ls | grep lighttpd) >> $BASE_DIR/tools/builder_scripts/conf/packages
(cd /var/db/pkg && ls | grep lua) >> $BASE_DIR/tools/builder_scripts/conf/packages
(cd /var/db/pkg && ls | grep cpdup) >> $BASE_DIR/tools/builder_scripts/conf/packages
(cd /var/db/pkg && ls | grep grub) >> $BASE_DIR/tools/builder_scripts/conf/packages
(cd /var/db/pkg && ls | grep scriptaculous) >> $BASE_DIR/tools/builder_scripts/conf/packages
(cd /var/db/pkg && ls | grep domtt) >> $BASE_DIR/tools/builder_scripts/conf/packages
set -e

# Invoke FreeSBIE2 toolchain
freesbie_make iso

