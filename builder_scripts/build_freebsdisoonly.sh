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

# Allow old CVS_CO_DIR to be deleted later
if [ -d $CVS_CO_DIR ]; then 
	chflags -R noschg $CVS_CO_DIR
fi 

# Set to stock FreeBSD kernel configration
export KERNELCONF="${PWD}/conf/FreeBSD.$FREEBSD_VERSION"

# Define src.conf
export SRC_CONF="/dev/null"
export SRC_CONF_INSTALL="/dev/null"

# Add etcmfs and rootmfs to the EXTRA plugins used by freesbie2
export EXTRA="${EXTRA:-} rootmfs varmfs etcmfs"

echo ">>> Cleaning up old directories..."
freesbie_make cleandir

# Output build flags
print_flags

# Clean out directories
echo ">>> Cleaning up old directories..."
freesbie_make cleandir

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

# Fixup library changes if needed
fixup_libmap

echo ">>> Searching for packages..."
(cd /var/db/pkg && ls | grep bsdinstaller) > $BUILDER_TOOLS/builder_scripts/conf/packages
(cd /var/db/pkg && ls | grep grub) >> $BUILDER_TOOLS/builder_scripts/conf/packages

echo ">>> Installing packages: " 
cat $BUILDER_TOOLS/builder_scripts/conf/packages

rm -f $MAKEOBJDIRPREFIX/usr/home/pfsense/freesbie2/*pkginstall*

# Install custom packages
echo ">>> Installing custom packageas..."
freesbie_make pkginstall

# Add extra files such as buildtime of version, bsnmpd, etc.
echo ">>> Phase populate_extra..."
cust_populate_extra

# Install BSDInstaller bits
cust_populate_installer_bits

# Prepare /usr/local/pfsense-fs -> /usr/local/pfsense-clonefs clone
echo ">>> Cloning filesystem..."
freesbie_make clonefs

# Ensure /home exists
mkdir -p $CLONEDIR/home

# Finalize iso
echo ">>> Finalizing iso..."
freesbie_make iso

# Email that the operation is completed
email_operation_completed
