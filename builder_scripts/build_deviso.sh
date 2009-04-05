#!/bin/sh

# $Id$

#set -e -u

. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Output build flags
print_flags

# Set extra before pfsense_local.sh will do
# Add comconsole to the list
# export EXTRA="comconsole customroot"
export EXTRA="customroot"

export MAKE_CONF="${PWD}/conf/make.conf.developer.$FREEBSD_VERSION"
export SRC_CONF="${PWD}/conf/make.conf.developer.$FREEBSD_VERSION"

export IS_DEV_ISO=yo

export PRUNE_LIST=""

export DEVIMAGE=yo

# Suck in script helper functions
. ./builder_common.sh

# Make sure cvsup_current has been run first 
check_for_clog

# Allow old CVS_CO_DIR to be deleted later
chflags -R noschg $CVS_CO_DIR

# Add etcmfs and rootmfs to the EXTRA plugins used by freesbie2
export EXTRA="${EXTRA:-} rootmfs varmfs etcmfs"

unset NO_UNIONFS
export UNION_DIRS="usr"

# Clean out directories
freesbie_make cleandir

# Checkout a fresh copy from pfsense cvs depot
update_cvs_depot

# Calculate versions
export version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
export version_base=`cat $CVS_CO_DIR/etc/version_base`
export version=`cat $CVS_CO_DIR/etc/version`

# Build world, kernel and install
echo ">>> Building world and kernels for DevISO... $FREEBSD_VERSION  $FREEBSD_BRANCH ..."
make_world

# Build SMP, Embedded (wrap) and Developers edition kernels
echo ">>> Building all extra kernels... $FREEBSD_VERSION  $FREEBSD_BRANCH ..."
build_all_kernels

# Add extra pfSense packages
echo ">>> Phase install_custom_packages"
install_custom_packages
echo ">>> Phase set_image_as_cdrom"
set_image_as_cdrom

# Fixup library changes if needed
fixup_libmap

rm -f $BASE_DIR/tools/builder_scripts/conf/packages

echo ">>> Searching for packages..."
set +e # grep could fail
(cd /var/db/pkg && ls | grep bsdinstaller) > $BASE_DIR/tools/builder_scripts/conf/packages
(cd /var/db/pkg && ls | grep lighttpd) >> $BASE_DIR/tools/builder_scripts/conf/packages
(cd /var/db/pkg && ls | grep lua) >> $BASE_DIR/tools/builder_scripts/conf/packages
(cd /var/db/pkg && ls | grep grub) >> $BASE_DIR/tools/builder_scripts/conf/packages
set -e

echo ">>> Installing packages: " 
cat $BASE_DIR/tools/builder_scripts/conf/packages

rm -f $MAKEOBJDIRPREFIX/usr/home/pfsense/freesbie2/*pkginstall*

# Install custom packages
echo ">>> Installing custom packageas..."
freesbie_make pkginstall

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

# Ensure config.xml exists
copy_config_xml_from_conf_default

# Prepare /usr/local/pfsense-clonefs
echo ">>> Cloning filesystem..."
freesbie_make clonefs

# Ensure /home exists
mkdir -p $CLONEDIR/home

# Finalize iso
echo ">>> Finalizing iso..."
freesbie_make iso

report_zero_sized_files

email_operation_completed
