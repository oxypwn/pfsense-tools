#!/bin/sh
#
# Common functions to be used by build scripts
#
#  build_iso.sh
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

# Ensure needed builder binaries are present
install_required_builder_system_ports

echo ">>> Cleaning up old directories..."
freesbie_make cleandir

# Allow old CVS_CO_DIR to be deleted later
if [ -d $CVS_CO_DIR ]; then 
	chflags -R noschg $CVS_CO_DIR
fi 

export KERNELCONF="${PWD}/conf/pfSense.$FREEBSD_VERSION"

# If a embedded build has been performed we need to nuke
# /usr/obj.pfSense/ since full uses a different
# src.conf
if [ -f /usr/obj.pfSense/pfSense_wrap.$FREEBSD_VERSION.world.done ]; then
	echo -n "Removing /usr/obj* since embedded build performed prior..."
	rm -rf /usr/obj.pfSense/*
	echo "done."
fi

# Define src.conf
export SRC_CONF="${PWD}/conf/src.conf.$FREEBSD_VERSION"
export SRC_CONF_INSTALL="${PWD}/conf/src.conf.$FREEBSD_VERSION.install"

# Add etcmfs and rootmfs to the EXTRA plugins used by freesbie2
export EXTRA="${EXTRA:-} rootmfs varmfs etcmfs"

if [ ! -z "${CUSTOM_REMOVE_LIST:-}" ]; then
	echo ">>> Using ${CUSTOM_REMOVE_LIST:-} ..."
	export PRUNE_LIST="${CUSTOM_REMOVE_LIST:-}"
else
	echo ">>> Using ${PWD}/remove.list.iso.$FREEBSD_VERSION ..."
	export PRUNE_LIST="${PWD}/remove.list.iso.$FREEBSD_VERSION"
fi

# Output build flags
print_flags

# Install BSDInstaller
rebuild_and_install_bsdinstaller

# Update FreeBSD sources and install custom patches
update_freebsd_sources_and_apply_patches

# Checkout a fresh copy from pfsense cvs depot
echo ">>> Updating pfSense CVS depot..."
update_cvs_depot

# Calculate versions
export version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
export version_base=`cat $CVS_CO_DIR/etc/version_base`
export version=`cat $CVS_CO_DIR/etc/version`

# Invoke FreeSBIE2 toolchain

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

# Fixup library changes if needed
fixup_libmap

# Nuke the boot directory
# [ -d "${CVS_CO_DIR}/boot" ] && rm -rf ${CVS_CO_DIR}/boot

rm -f $BUILDER_TOOLS/builder_scripts/conf/packages

echo ">>> Searching for packages..."
set +e # grep could fail
(cd /var/db/pkg && ls | grep bsdinstaller) > $BUILDER_TOOLS/builder_scripts/conf/packages
(cd /var/db/pkg && ls | grep grub) >> $BUILDER_TOOLS/builder_scripts/conf/packages
(cd /var/db/pkg && ls | grep lua) >> $BUILDER_TOOLS/builder_scripts/conf/packages
set -e

echo ">>> Installing packages: " 
cat $BUILDER_TOOLS/builder_scripts/conf/packages

rm -f $MAKEOBJDIRPREFIX/usr/home/pfsense/freesbie2/*pkginstall*

# Install custom packages
echo ">>> Installing custom packageas..."
freesbie_make pkginstall

# Add extra files such as buildtime of version, bsnmpd, etc.
echo ">>> Phase populate_extra..."
cust_populate_extra

# Add installer bits
cust_populate_installer_bits

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

# See if php configuration script is available
if [ -f $PFSENSEBASEDIR/etc/rc.php_ini_setup ]; then
	echo ">>> chroot'ing and running /etc/rc.php_ini_setup"
	chroot $PFSENSEBASEDIR /etc/rc.php_ini_setup
fi

# Overlay final files
install_custom_overlay_final

# Ensure config.xml exists
copy_config_xml_from_conf_default

echo -n ">>> Creating md5 summary of files present..."
rm -f $BASEDIR/etc/pfSense_md5.txt
echo "#!/bin/sh" > $BASEDIR/chroot.sh
echo "find / -type f | /usr/bin/xargs /sbin/md5 >> /etc/pfSense_md5.txt" >> $BASEDIR/chroot.sh
chmod a+rx $BASEDIR/chroot.sh
chroot $BASEDIR /chroot.sh
rm $BASEDIR/chroot.sh
echo "Done."

# Ensure installer bits are present
cust_populate_installer_bits

# Test PHP installation
test_php_install

# Check to see if we have a healthy installer
ensure_healthy_installer

# Prepare /usr/local/pfsense-clonefs
echo ">>> Cloning filesystem..."
freesbie_make clonefs

# Ensure /home exists
mkdir -p $CLONEDIR/home

# Finalize iso
echo ">>> Finalizing iso..."
freesbie_make iso

# Check for zero sized files.  loader.conf is one of the culprits.
check_for_zero_size_files
report_zero_sized_files

# Email that the operation is done
email_operation_completed
