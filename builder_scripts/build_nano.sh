#!/bin/sh
#
#  build_nano.sh
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

# Read params
while getopts c opt; do
	case "${opt}" in
		c)      ALTCONFFILE="${OPTARG}";;
	esac
done

# Optional Per build config file.
# Specify a file with build parameters to override the default.
[ -n "${ALTCONFFILE}" -a -r "${ALTCONFFILE}" ] \
	&& . ${ALTCONFFILE}

# Suck in script helper functions
. ./builder_common.sh

# If a full build has been performed we need to nuke
# /usr/obj.pfSense/ since embedded uses a different
# src.conf
if [ -f ${MAKEOBJDIRPREFIX}/pfSense.$FREEBSD_VERSION.world.done ]; then
	echo -n "Removing $MAKEOBJDIRPREFIX since full build performed prior..."
	rm -rf $MAKEOBJDIRPREFIX
	echo "done."
fi

# Allow old CVS_CO_DIR to be deleted later
chflags -R noschg $CVS_CO_DIR

# Yep we are building nanobsd
export IS_NANO_BUILD=yes

# Do not compress this image which is used on the ISO
export NO_COMPRESSEDFS=yes

if [ ! -z "${CUSTOM_REMOVE_LIST:-}" ]; then
	echo ">>> Using ${CUSTOM_REMOVE_LIST:-} ..."
	export PRUNE_LIST="${CUSTOM_REMOVE_LIST:-}"
else
	echo ">>> Using ${BUILDER_SCRIPTS}/remove.list.iso.$FREEBSD_VERSION ..."
	export PRUNE_LIST="${BUILDER_SCRIPTS}/remove.list.iso.$FREEBSD_VERSION"
fi

# Use embedded src.conf
if [ -z "${SRC_CONF:-}" ]; then
	export SRC_CONF="${BUILDER_SCRIPTS}/conf/src/src.conf.embedded.$FREEBSD_VERSION"
	export SRC_CONF_INSTALL="${BUILDER_SCRIPTS}/conf/src/src.conf.embedded.$FREEBSD_VERSION.install"
fi

# This should be run first
launch

# Make sure source directories are present.
ensure_source_directories_present

# Ensure binaries are present that builder system requires
install_required_builder_system_ports

# Check if we need to force a ports rebuild
check_for_forced_pfPorts_build

# Output build flags
print_flags

# Clean up items that should be cleaned each run
freesbie_clean_each_run

# Checkout a fresh copy from pfsense cvs depot
update_cvs_depot

# Calculate versions
version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
version_base=`cat $CVS_CO_DIR/etc/version_base`
version=`cat $CVS_CO_DIR/etc/version`

# Build if needed and install world and kernel
echo ">>> Building world for Embedded... $FREEBSD_VERSION  $FREEBSD_BRANCH ..."
make_world

# Build kernels
echo ">>> Building kernel configs: $BUILD_KERNELS for FreeBSD: $FREEBSD_BRANCH ..."
build_all_kernels

if [ ! -z "${SPLIT_ARCH_BUILD:-}" ]; then
	echo ">>> SPLIT_ARCH_BUILD defined.  Now run ./build_nano.sh"
	echo "    on the netbooted $ARCH machine to finish the build."
	kill $$
fi

# Install ports on normal image
install_pkg_install_ports

echo ">>> Installing packages: "
cat $PFSPKGFILE

# Add extra files such as buildtime of version, bsnmpd, etc.
echo ">>> Phase populate_extra..."
cust_populate_extra

# Add extra pfSense packages
install_custom_packages

# Overlay pfsense checkout on top of FreeSBIE image
# using the customroot plugin
echo ">>> Merging extra items..."
freesbie_make extra

# Overlay custom binaries
cust_overlay_host_binaries

# Must be run after overlay_host_binaries and freesbie_make extra
cust_fixup_nanobsd

# Check for custom config.xml
cust_install_config_xml

echo -n ">>> Creating md5 summary of files present..."
rm -f $PFSENSEBASEDIR/etc/pfSense_md5.txt
echo "#!/bin/sh" > $PFSENSEBASEDIR/chroot.sh
echo "find / -type f | /usr/bin/xargs /sbin/md5 >> /etc/pfSense_md5.txt" >> $PFSENSEBASEDIR/chroot.sh
chmod a+rx $PFSENSEBASEDIR/chroot.sh
chroot $PFSENSEBASEDIR /chroot.sh 2>/dev/null
rm $PFSENSEBASEDIR/chroot.sh
echo "Done."

# Copy config.xml
copy_config_xml_from_conf_default

# Install custom pfSense-XML packages from a chroot
# and ensure php.ini is setup and ready to run.
# php.ini is auto generated on 2.0 from the list
# of php installed modules.
pfsense_install_custom_packages_exec

# Test PHP installation
test_php_install

# Invoke FreeSBIE2 toolchain
check_for_zero_size_files
freesbie_make clonefs

# Setup NanoBSD specific items
FlashDevice $FLASH_MODEL $FLASH_SIZE
echo "$FLASH_SIZE" > /tmp/nanosize.txt
setup_nanobsd_etc
setup_nanobsd

# Overlay any loader.conf customziations
install_extra_loader_conf_options

# Get rid of non-wanted files
prune_usr

# Create the NanoBSD disk image for i386
if [ "$ARCH" = "i386" -o "$ARCH" = "amd64" ]; then
	create_nanobsd_diskimage
fi
# Create the NanoBSD disk image for mips
if [ "$ARCH" = "mips" ]; then
	create_mips_diskimage
fi

# Wrap up the show, Johnny
echo "Image completed."
echo "$MAKEOBJDIRPREFIXFINAL/"

FILESIZE=`cat /tmp/nanosize.txt`
if [ "${DATESTRING}" = "" ]; then
	if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
		BUILDTIME=`cat $PFSENSEBASEDIR/etc/version.buildtime`
		DATESTRING=`date -j -f "%a %b %e %T %Z %Y" "$BUILDTIME" "+%Y%m%d-%H%M"`
	else
		DATESTRING=`date "+%Y%m%d-%H%M"`
	fi
fi

if [ -n "${NANO_WITH_VGA}" ]; then
	_VGA="_vga"
fi

gzip -f $MAKEOBJDIRPREFIXFINAL/nanobsd${_VGA}.full.img
gzip -f $MAKEOBJDIRPREFIXFINAL/nanobsd${_VGA}.upgrade.img

FILENAMEFULL="${PRODUCT_NAME}-${PFSENSE_VERSION}-${FILESIZE}-${ARCH}-nanobsd${_VGA}-${DATESTRING}.img.gz"
FILENAMEUPGRADE="${PRODUCT_NAME}-${PFSENSE_VERSION}-${FILESIZE}-${ARCH}-nanobsd${_VGA}-upgrade-${DATESTRING}.img.gz"

mv $MAKEOBJDIRPREFIXFINAL/nanobsd${_VGA}.full.img.gz $MAKEOBJDIRPREFIXFINAL/$FILENAMEFULL
mv $MAKEOBJDIRPREFIXFINAL/nanobsd${_VGA}.upgrade.img.gz $MAKEOBJDIRPREFIXFINAL/$FILENAMEUPGRADE



ls -lah $MAKEOBJDIRPREFIXFINAL

# E-Mail that we are done.
email_operation_completed

# Email that the operation has completed
email_operation_completed

# Run final finish routines
finish

