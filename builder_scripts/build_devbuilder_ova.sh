#!/bin/sh
#
# Common functions to be used by build scripts
#
#  build_ova.sh
#  Copyright (C) 2004-2011 Scott Ullrich
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  
#  1. Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#  
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  
#  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
#  AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#  AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
#  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
#
# Crank up error reporting, debugging.
#  set -e 
#  set -x

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Override PRODUCT_NAME
#export PRODUCT_NAME="pfSenseDevBuilder"

# If a embedded build has been performed we need to nuke
# /usr/obj.$dir/ since full uses a different
# src.conf
if [ -f ${MAKEOBJDIRPREFIX}/pfSense_wrap.$FREEBSD_VERSION.world.done ]; then
	echo -n "Removing $MAKEOBJDIRPREFIX/* since embedded build performed prior..."
	rm -rf ${MAKEOBJDIRPREFIX}/*
	echo "done."
fi

# Define src.conf
if [ -z "${SRC_CONF:-}" ]; then
	export SRC_CONF="${BUILDER_SCRIPTS}/conf/src.conf.developer.$FREEBSD_VERSION"
fi

# Add etcmfs and rootmfs to the EXTRA plugins used by freesbie2
export EXTRA="${EXTRA:-} rootmfs varmfs etcmfs"

if [ ! -z "${CUSTOM_REMOVE_LIST:-}" ]; then
	echo ">>> Using ${CUSTOM_REMOVE_LIST:-} ..."
	export PRUNE_LIST="${CUSTOM_REMOVE_LIST:-}"
else
	echo ">>> Using ${BUILDER_SCRIPTS}/remove.list.iso.$FREEBSD_VERSION ..."
	export PRUNE_LIST="${BUILDER_SCRIPTS}/remove.list.iso.$FREEBSD_VERSION"
fi

# This should be run first
launch

if [ "$1" = "" ]; then

	# Make sure source directories are present.
	ensure_source_directories_present

	# Ensure binaries are present that builder system requires
	install_required_builder_system_ports

	# Check if we need to force a ports rebuild
	check_for_forced_pfPorts_build

	# Clean up items that should be cleaned each run
	freesbie_clean_each_run

fi

# Allow old CVS_CO_DIR to be deleted later
if [ -d $CVS_CO_DIR ]; then 
	chflags -R noschg $CVS_CO_DIR
fi 

# Output build flags
print_flags

if [ "$1" = "" ]; then

	# Update FreeBSD sources and install custom patches
	update_freebsd_sources_and_apply_patches

fi

# Checkout a fresh copy from pfsense cvs depot
echo ">>> Updating pfSense GIT repo..."
update_cvs_depot

# Calculate versions
export version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
export version_base=`cat $CVS_CO_DIR/etc/version_base`
export version=`cat $CVS_CO_DIR/etc/version`

if [ "$1" = "" ]; then

	# Prepare object directry
	echo ">>> Preparing object directory..."
	freesbie_make obj

	# Build world, kernel and install
	echo ">>> Building world and kernels for ISO... $FREEBSD_VERSION  $FREEBSD_BRANCH ..."
	make_world

	# Build SMP, Embedded (wrap) and Developers edition kernels
	echo ">>> Building all extra kernels... $FREEBSD_VERSION  $FREEBSD_BRANCH ..."
	build_all_kernels

	# Check for freesbie builder issues
	if [ -f ${MAKEOBJDIRPREFIX}/usr/home/pfsense/freesbie2/.tmp_kernelbuild ]; then
		echo "Something has gone wrong!  Press ENTER to view log file."
		read ans
		more ${MAKEOBJDIRPREFIX}/usr/home/pfsense/freesbie2/.tmp_kernelbuild 
		exit
	fi

	# Add extra pfSense packages
	echo ">>> Phase install_custom_packages"
	install_custom_packages
	echo ">>> Phase set_image_as_cdrom"
	set_image_as_cdrom

	echo ">>> Searching for packages..."
	set +e # grep could fail
	if [ "$PFSPKGFILE" = "" ]; then
		echo "PFSPKGFILE is not defined.  Setting."
		PFSPKGFILE=/tmp/pfspackages
	fi

	# Install packages needed for livecd
	echo ">>> Installing packages: $PKG_INSTALL_PORTSPFS" 
	install_pkg_install_ports

	echo ">>> Installing packages: " 
	cat $PFSPKGFILE

	# Add extra files such as buildtime of version, bsnmpd, etc.
	echo ">>> Phase populate_extra..."
	cust_populate_extra

	# Overlay pfsense checkout on top of FreeSBIE image
	# using the customroot plugin
	echo ">>> Merging extra items..."
	freesbie_make extra

	# Overlay host binaries
	cust_overlay_host_binaries
	check_for_zero_size_files

	# Check for custom config.xml
	cust_install_config_xml

	# Install custom pfSense-XML packages from a chroot
	pfsense_install_custom_packages_exec

fi

# See if php configuration script is available
if [ -f $PFSENSEBASEDIR/etc/rc.php_ini_setup ]; then
	echo ">>> chroot'ing and running /etc/rc.php_ini_setup"
	chroot $PFSENSEBASEDIR /etc/rc.php_ini_setup
fi

# Overlay final files
install_custom_overlay_final

if [ "$1" = "" ]; then

	# LiveCD specifics
	setup_livecd_specifics

	# Ensure config.xml exists
	copy_config_xml_from_conf_default

	# Test PHP installation
	test_php_install

	# Create md5 summary file listing checksums
	create_md5_summary_file

	# Setup custom tcshrc prompt
	setup_tcshrc_prompt

	# Setup serial port helper hints
	if [ "$FBSD_VERSION" = "8" ]; then
		setup_serial_hints
	fi
	if [ "$FBSD_VERSION" = "9" ]; then
		setup_serial_hints
	fi

	# Ensure /home and /etc exists
	mkdir -p $PFSENSEBASEDIR/home $PFSENSEBASEDIR/etc

fi

# Create OVA image (ovf + vmdk)
# This will be roughly a 80GB image
export OVADISKSIZE="85899345920"
# dd block size - used to speed up dd operation
export OVABLOCKSIZE="3276800"
# / partitino size
export OVA_FIRST_PART_SIZE="77G"
# Swap partition size
export OVA_SWAP_PART_SIZE="4193789"
# 85898035200 = 81919MB (Virtual box sizes)
export OVA_DISKSECTIONALLOCATIONUNITS="85898035200"
# Add the builder specifc scripts
create_ova_image_dev_addons
# Create the OVA image
create_ova_image

# Check for zero sized files.  loader.conf is one of the culprits.
check_for_zero_size_files
report_zero_sized_files

# Email that the operation has completed
email_operation_completed

echo ">>> $MAKEOBJDIRPREFIXFINAL now contains:"
ls -lah $MAKEOBJDIRPREFIXFINAL

# Run final finish routines
finish
