#!/bin/sh

# pfSense master builder script
# (C)2005-2006 Scott Ullrich and the pfSense project
# All rights reserved.
#
# $Id$

# Crank up error reporting, debugging.
#set -e 
#set -x

# If a embedded build has been performed we need to nuke
# /usr/obj.pfSense/ since full uses a different
# make.conf
if [ -f /usr/obj.pfSense/pfSense_wrap.6.world.done ]; then
	echo -n "Removing /usr/obj* since embedded build performed prior..."
	rm -rf /usr/obj*
	echo "done."
fi

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Show flags
print_flags

# Make sure cvsup_current has been run first 
check_for_clog

# Allow old CVS_CO_DIR to be deleted later
if [ -d $CVS_CO_DIR ]; then
	chflags -R noschg $CVS_CO_DIR
fi

# Use pfSense.6 as kernel configuration file
if [ $FREEBSD_VERSION = "6" ]; then
	export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense.6}
fi
if [ $FREEBSD_VERSION = "7" ]; then
	export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense.7}
fi

# Use normal make.conf
if [ $FREEBSD_VERSION = "6" ]; then
	export MAKE_CONF="${PWD}/conf/make.conf"
	export SRC_CONF="${PWD}/conf/make.conf"
	export SRC_CONF_INSTALL="${PWD}/conf/make.conf"	
fi
if [ $FREEBSD_VERSION = "7" ]; then
	export MAKE_CONF="${PWD}/conf/make.conf.7"
	export SRC_CONF="${PWD}/conf/make.conf.7"
	export SRC_CONF_INSTALL="${PWD}/conf/make.conf.7.install"
fi

# Add etcmfs and rootmfs to the EXTRA plugins used by freesbie2
export EXTRA="${EXTRA:-} rootmfs etcmfs"

if [ ! -z "${CUSTOM_REMOVE_LIST:-}" ]; then
	echo ">>> Using ${CUSTOM_REMOVE_LIST:-} ..."
	export PRUNE_LIST="${CUSTOM_REMOVE_LIST:-}"
else
	if [ $FREEBSD_VERSION = "6" ]; then
		echo ">>> Using ${PWD}/remove.list.iso ..."	
		export PRUNE_LIST="${PWD}/remove.list.iso"
	fi
	if [ $FREEBSD_VERSION = "7" ]; then
		echo ">>> Using ${PWD}/remove.list.iso.7 ..."
		export PRUNE_LIST="${PWD}/remove.list.iso.7"
	fi
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
echo ">>> Building world and kernels for updates... $FREEBSD_VERSION  $FREEBSD_BRANCH ..."
make_world

# Build SMP, Embedded (wrap) and Developers edition kernels
echo ">>> Building all extra kernels... $FREEBSD_VERSION  $FREEBSD_BRANCH ..."
build_all_kernels

# Nuke the boot directory
[ -d "${CVS_CO_DIR}/boot" ] && rm -rf ${CVS_CO_DIR}/boot

rm -f conf/packages

set +e # grep could fail
(cd /var/db/pkg && ls | grep bsdinstaller) > conf/packages
(cd /var/db/pkg && ls | grep rrdtool) >> conf/packages
set -e

# Invoke FreeSBIE2 toolchain, populate /usr/local/pfsense-fs
freesbie_make extra

# Add extra files such as buildtime of version, bsnmpd, etc.
echo ">>> Phase populate_extra"
cust_populate_extra

# Remove stuff that could have been modified on installation
# such as /etc/ttys, /conf/config.xml, etc
fixup_updates

# Fixup library changes if needed
fixup_libmap

# Overlay host binaries
cust_overlay_host_binaries

# Make sure loader.conf is nuked
find $BASE_DIR -name loader.conf -exec rm {} \;
find $CLONEDIR -name loader.conf -exec rm {} \;

# Install custom pfSense-XML packages from a chroot
pfsense_install_custom_packages_exec

create_pfSense_Full_update_tarball
create_pfSense_Embedded_update_tarball

