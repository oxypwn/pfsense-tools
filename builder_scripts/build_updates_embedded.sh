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

# Allow old CVS_CO_DIR to be deleted later
chflags -R noschg $CVS_CO_DIR

# If a full build has been performed we need to nuke
# /usr/obj.pfSense/ since embedded uses a different
# make.conf
if [ -f /usr/obj.pfSense/pfSense.6.world.done ]; then
	echo -n "Removing /usr/obj* since full build performed prior..."
	rm -rf /usr/obj*
	echo "done."
fi

# Checkout a fresh copy from pfsense cvs depot
update_cvs_depot

# Calculate versions
export version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
version_base=`cat $CVS_CO_DIR/etc/version_base`
version=`cat $CVS_CO_DIR/etc/version`

# Use pfSense_wrap.6 as kernel configuration file
if [ $pfSense_version = "6" ]; then
	export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense_wrap.6}
fi
if [ $pfSense_version = "7" ]; then
	export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense_wrap.7}
fi

# Do not compress FS
export NO_COMPRESSEDFS=yes

if [ $pfSense_version = "6" ]; then
	export PRUNE_LIST="${PWD}/remove.list"
fi
if [ $pfSense_version = "7" ]; then
	export PRUNE_LIST="${PWD}/remove.list.7"
fi

cd $CVS_CO_DIR

# Nuke the boot directory
[ -d "${CVS_CO_DIR}/boot" ] && rm -rf ${CVS_CO_DIR}/boot

rm -f conf/packages

set +e # grep could fail
(cd /var/db/pkg && ls | grep bsdinstaller) > conf/packages
(cd /var/db/pkg && ls | grep cpdup) >> conf/packages
set -e

# Fixup library changes if needed
fixup_libmap

cd $CVS_CO_DIR
create_pfSense_Small_update_tarball

