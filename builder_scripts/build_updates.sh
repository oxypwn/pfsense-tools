#!/bin/sh
#
# Common functions to be used by build scripts
#
#  build_updates.sh
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

# If a embedded build has been performed we need to nuke
# /usr/obj.pfSense/ since full uses a different
# src.conf
if [ -f $MAKEOBJDIRPREFIX/pfSense_wrap.$FREEBSD_VERSION.world.done ]; then
	echo -n "Removing $MAKEOBJDIRPREFIX since embedded build performed prior..."
	rm -rf $MAKEOBJDIRPREFIX
	echo "done."
fi

# This should be run first
launch

# Show flags
print_flags

# Allow old CVS_CO_DIR to be deleted later
if [ -d $CVS_CO_DIR ]; then
	chflags -R noschg $CVS_CO_DIR
fi

# Use normal src.conf
export SRC_CONF="${BUILDER_SCRIPTS}/conf/src/src.conf.$FREEBSD_VERSION"
export SRC_CONF_INSTALL="${BUILDER_SCRIPTS}/conf/src/src.conf.$FREEBSD_VERSION.install"

# Add etcmfs and rootmfs to the EXTRAPLUGINS plugins used by freesbie2
export EXTRAPLUGINS="${EXTRAPLUGINS:-} rootmfs etcmfs"

if [ ! -z "${CUSTOM_REMOVE_LIST:-}" ]; then
	echo ">>> Using ${CUSTOM_REMOVE_LIST:-} ..."
	export PRUNE_LIST="${CUSTOM_REMOVE_LIST:-}"
else
	echo ">>> Using ${BUILDER_SCRIPTS}/conf/rmlist/remove.list.iso.$FREEBSD_VERSION ..."
	export PRUNE_LIST="${BUILDER_SCRIPTS}/conf/rmlist/remove.list.iso.$FREEBSD_VERSION"
fi

# Clean up items that should be cleaned each run
freesbie_clean_each_run

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

rm -f $PFSPKGFILE

set +e # grep could fail
mkdir -p conf
(cd /var/db/pkg && ls | grep bsdinstaller) > $PFSPKGFILE
(cd /var/db/pkg && ls | grep rrdtool) >> $PFSPKGFILE
set -e

# Install packages needed for livecd
install_pkg_install_ports

echo ">>> Installing packages: "
cat $PFSPKGFILE

# Add extra files such as buildtime of version, bsnmpd, etc.
echo ">>> Phase populate_extra"
cust_populate_extra

# Invoke FreeSBIE2 toolchain, populate /usr/local/pfsense-fs
freesbie_make extra

# Remove stuff that could have been modified on installation
# such as /etc/ttys, /conf/config.xml, etc
fixup_updates

# Overlay host binaries
cust_overlay_host_binaries

# Make sure loader.conf is nuked
find $BASE_DIR -name loader.conf -exec rm {} \;

# Install custom pfSense-XML packages from a chroot
pfsense_install_custom_packages_exec

# Overlay any loader.conf customziations
install_extra_loader_conf_options

create_pfSense_Full_update_tarball
#create_pfSense_Embedded_update_tarball

# Email that the operation has completed
email_operation_completed

# Run final finish routines
finish
