#!/bin/sh

# pfSense master builder script
# (C)2005-2006 Scott Ullrich and the pfSense project
# All rights reserved.
#
# $Id$

#set -e -u

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Make sure cvsup_current has been run first 
check_for_clog

# Allow old CVS_CO_DIR to be deleted later
chflags -R noschg $CVS_CO_DIR

# Use pfSense.6 as kernel configuration file
if [ $pfSense_version = "6" ]; then
	export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense.6}
fi
if [ $pfSense_version = "7" ]; then
	export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense.7}
fi

# Use normal make.conf
if [ $pfSense_version = "6" ]; then
	export MAKE_CONF="${PWD}/conf/make.conf"
	export SRC_CONF_INSTALL="${PWD}/conf/make.conf"	
fi
if [ $pfSense_version = "7" ]; then
	export MAKE_CONF="${PWD}/conf/make.conf.7"
	export SRC_CONF="${PWD}/conf/make.conf.7"
	export SRC_CONF_INSTALL="${PWD}/conf/make.conf.7.install"
fi

# Add etcmfs and rootmfs to the EXTRA plugins used by freesbie2
export EXTRA="${EXTRA:-} rootmfs etcmfs"

# Items that we will remove before creating final .tgz archive
if [ $pfSense_version = "6" ]; then
	export PRUNE_LIST="${PWD}/remove.list"
fi
if [ $pfSense_version = "7" ]; then
	export PRUNE_LIST="${PWD}/remove.list.7"
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

# Build if needed and install world and kernel
make_world_kernel

# Build SMP, Embedded (wrap) and Developers edition kernels
build_all_kernels

# Nuke the boot directory
[ -d "${CVS_CO_DIR}/boot" ] && rm -rf ${CVS_CO_DIR}/boot

rm -f conf/packages

set +e # grep could fail
(cd /var/db/pkg && ls | grep bsdinstaller) > conf/packages
(cd /var/db/pkg && ls | grep cpdup) >> conf/packages
(cd /var/db/pkg && ls | grep rrdtool) >> conf/packages
#(cd /var/db/pkg && ls | grep domtt) >> conf/packages
#(cd /var/db/pkg && ls | grep scriptaculous) >> conf/packages
set -e

# Invoke FreeSBIE2 toolchain
freesbie_make extra

# Add extra files such as buildtime of version, bsnmpd, etc.
echo ">>> Phase populate_extra"
( populate_extra )

fixup_updates

# Fixup library changes if needed
fixup_libmap

create_pfSense_Full_update_tarball
create_pfSense_Embedded_update_tarball

