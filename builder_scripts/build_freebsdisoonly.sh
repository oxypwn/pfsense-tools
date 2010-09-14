#!/bin/sh
#
# Common functions to be used by build scripts
#
#  build_freebsdisoonly.sh
#  Copyright (C) 2004-2009 Scott Ullrich
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

# This should be run first
launch

# Make sure source directories are present.
ensure_source_directories_present

# Ensure binaries are present that builder system requires
install_required_builder_system_ports

# Allow old CVS_CO_DIR to be deleted later
if [ -d $CVS_CO_DIR ]; then 
	chflags -R noschg $CVS_CO_DIR
fi 

# Allow customized Kernel
if [ ! -z "${KERNELCONF:-}" ]; then
    echo ">>> Using ${KERNELCONF:-} ..."
    export KERNELCONF="${KERNELCONF:-}"
else
    export KERNELCONF="${BUILDER_SCRIPTS}/conf/FreeBSD.$FREEBSD_VERSION"
fi

# Define src.conf
export SRC_CONF="/dev/null"
export SRC_CONF_INSTALL="/dev/null"

# Add etcmfs and rootmfs to the EXTRA plugins used by freesbie2
export EXTRA="${EXTRA:-} rootmfs varmfs etcmfs"

# Clean up items that should be cleaned each run
freesbie_clean_each_run

# Output build flags
print_flags

# Clean up items that should be cleaned each run
freesbie_clean_each_run

# Prepare object directry
echo ">>> Preparing object directory..."
freesbie_make obj

# Check for freesbie builder issues
if [ -f ${MAKEOBJDIRPREFIX}/usr/home/pfsense/freesbie2/.tmp_buildworld ]; then
	echo "Something has gone wrong!  Press ENTER to view log file."
	read ans
	more ${MAKEOBJDIRPREFIX}/usr/home/pfsense/freesbie2/.tmp_buildworld
	exit
fi

if [ -f ${MAKEOBJDIRPREFIX}/usr/home/pfsense/freesbie2/.tmp_installworld ]; then
	echo "Something has gone wrong!  Press ENTER to view log file."
	read ans
	more ${MAKEOBJDIRPREFIX}/usr/home/pfsense/freesbie2/.tmp_installworld
	exit
fi

# Build world, kernel and install
echo ">>> Building world and kernels for ISO... $FREEBSD_VERSION  $FREEBSD_BRANCH ..."
make_world

# Build SMP, Embedded (wrap) and Developers edition kernels
echo ">>> Building FreeBSD kernel.. $FREEBSD_VERSION  $FREEBSD_BRANCH ..."
build_freebsd_only_kernel

# Check for freesbie builder issues
if [ -f ${MAKEOBJDIRPREFIX}/usr/home/pfsense/freesbie2/.tmp_kernelbuild ]; then
	echo "Something has gone wrong!  Press ENTER to view log file."
	read ans
	more ${MAKEOBJDIRPREFIX}/usr/home/pfsense/freesbie2/.tmp_kernelbuild 
	exit
fi

# Install BSDInstaller
rebuild_and_install_bsdinstaller

echo ">>> Searching for packages..."
set +e # grep could fail
rm -f $PFSPKGFILE
(cd /var/db/pkg && ls | grep bsdinstaller) > $PFSPKGFILE
(cd /var/db/pkg && ls | grep grub) >> $PFSPKGFILE
(cd /var/db/pkg && ls | grep lua) >> $PFSPKGFILE
set -e
freesbie_make pkginstall

# Install packages needed for livecd
echo ">>> Installing packages: $PKG_INSTALL_PORTSPFS" 
install_pkg_install_ports

rm -f $MAKEOBJDIRPREFIX/usr/home/pfsense/freesbie2/*pkginstall*

echo ">>> Installing packages: " 
cat $BUILDER_TOOLS/builder_scripts/conf/packages

# Add extra files such as buildtime of version, bsnmpd, etc.
echo ">>> Phase populate_extra..."
cust_populate_extra

# Overlay host binaries
cust_overlay_host_binaries

# Install BSDInstaller bits
cust_populate_installer_bits_freebsd_only

# Check to see if we have a healthy installer
ensure_healthy_installer

# Build custom ports and install in chroot if needed
install_pkg_install_ports

# Prepare /usr/local/pfsense-fs -> /usr/local/pfsense-clonefs clone
echo ">>> Cloning filesystem..."
freesbie_make clonefs

# Ensure /home exists
mkdir -p $CLONEDIR/home

# Finalize iso
echo ">>> Finalizing iso..."
freesbie_make iso

# Email that the operation has completed
email_operation_completed

# Run final finish routines
finish
