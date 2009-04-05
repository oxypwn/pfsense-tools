#!/bin/sh

# pfSense master builder script
# (C)2005-2006 Scott Ullrich and the pfSense project
# All rights reserved.
#
# $Id$

# Crank up error reporting, debugging.
#set -e 
#set -x

# If a full build has been performed we need to nuke
# /usr/obj.pfSense/ since embedded uses a different
# make.conf
if [ -f /usr/obj.pfSense/pfSense.6.world.done ]; then
	echo -n "Removing /usr/obj* since full build performed prior..."
	rm -rf /usr/obj*
	echo "done."
fi

# Suck in local vars
. ./pfsense_local.sh

# Optional Per build config file.
# Specify a file with build parameters to override the default.
if [ "$1" != "" ]; then
	[ -r "$1" ] && . $1
fi

# Suck in script helper functions
. ./builder_common.sh

# Make sure cvsup_current has been run first 
check_for_clog

# Output build flags
print_flags

# Allow old CVS_CO_DIR to be deleted later
chflags -R noschg $CVS_CO_DIR

export IS_NANO_BUILD=yes

export NO_COMPRESSEDFS=yes

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

# Use embedded make.conf
if [ $FREEBSD_VERSION = "6" ]; then
	export MAKE_CONF="${PWD}/conf/make.conf.embedded"
	export SRC_CONF="${PWD}/conf/make.conf.embedded"
	export SRC_CONF_INSTALL="${PWD}/conf/make.conf.embedded"	
fi
if [ $FREEBSD_VERSION = "7" ]; then
	export MAKE_CONF="${PWD}/conf/make.conf.embedded.7"
	export SRC_CONF="${PWD}/conf/make.conf.embedded.7"
	export SRC_CONF_INSTALL="${PWD}/conf/make.conf.embedded.7.install"
fi

# Clean out directories
freesbie_make cleandir

# Checkout a fresh copy from pfsense cvs depot
update_cvs_depot

# Calculate versions
version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
version_base=`cat $CVS_CO_DIR/etc/version_base`
version=`cat $CVS_CO_DIR/etc/version`

# Build if needed and install world and kernel
echo ">>> Building world and kernels for Embedded... $FREEBSD_VERSION  $FREEBSD_BRANCH ..."
make_world

# Build embedded kernel
build_embedded_kernel

# Add extra files such as buildtime of version, bsnmpd, etc.
cust_populate_extra

# Add extra pfSense packages
install_custom_packages

# Only include Lighty in packages list
(cd /var/db/pkg && ls | grep lighttpd) > conf/packages

# Add extra files such as buildtime of version, bsnmpd, etc.
echo ">>> Phase populate_extra..."
cust_populate_extra

# Overlay pfsense checkout on top of FreeSBIE image
# using the customroot plugin
echo ">>> Merging extra items..."
freesbie_make extra

# Overlay host binaries
cust_overlay_host_binaries

# Must be run after overlay_host_binaries and freesbie_make extra
cust_fixup_wrap

# Check for custom config.xml
cust_install_config_xml

# Invoke FreeSBIE2 toolchain
check_for_zero_size_files
freesbie_make clonefs

# Fixup library changes if needed
fixup_libmap

echo "#### Building bootable UFS image ####"
FlashDevice $FLASH_MODEL $FLASH_SIZE
setup_nanobsd_etc

setup_nanobsd
prune_usr
create_i386_diskimage

echo "Image completed."
echo "$MAKEOBJDIRPREFIX/"
ls -lah $MAKEOBJDIRPREFIX/nanobsd*

email_operation_completed

