#!/bin/sh
#
# Common functions to be used by build scripts
#
#  build_updates_embedded.sh
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

# Output build flags
print_flags

# Allow old CVS_CO_DIR to be deleted later
chflags -R noschg $CVS_CO_DIR
rm -rf $CVS_CO_DIR

# If a full build has been performed we need to nuke
# /usr/obj.pfSense/ since embedded uses a different
# src.conf
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
if [ $FREEBSD_VERSION = "6" ]; then
	export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense_wrap.6}
fi
if [ $FREEBSD_VERSION = "7" ]; then
	export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense_wrap.7}
	export SRC_CONF="${PWD}/conf/src.conf.developer.7"	
fi
if [ $FREEBSD_VERSION = "8" ]; then
	export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense_wrap.8}
	export SRC_CONF="${PWD}/conf/src.conf.developer.8"
fi


# Do not compress FS
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
	if [ $FREEBSD_VERSION = "8" ]; then
		echo ">>> Using ${PWD}/remove.list.iso.8 ..."
		export PRUNE_LIST="${PWD}/remove.list.iso.8"
	fi
fi

cd $CVS_CO_DIR

# Nuke the boot directory
[ -d "${CVS_CO_DIR}/boot" ] && rm -rf ${CVS_CO_DIR}/boot

rm -f conf/packages

set +e # grep could fail
(cd /var/db/pkg && ls | grep bsdinstaller) > conf/packages
set -e

# Fixup library changes if needed
fixup_libmap

# Install custom pfSense-XML packages from a chroot
pfsense_install_custom_packages_exec

cd $CVS_CO_DIR
create_pfSense_Small_update_tarball

email_operation_completed
