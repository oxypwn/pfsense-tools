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

# Make sure cvsup_current has been run first 
check_for_clog

# Allow old CVS_CO_DIR to be deleted later
chflags -R noschg $CVS_CO_DIR

chflags -R noschg /usr/local/pfsense*
rm -rf /usr/local/pfsense*

# Use pfSense_wrap.6 as kernel configuration file
if [ $FREEBSD_VERSION = "6" ]; then
	export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense_wrap.6}
fi
if [ $FREEBSD_VERSION = "7" ]; then
	export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense_wrap.7}
fi
if [ $FREEBSD_VERSION = "8" ]; then
	export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense_wrap.8}
fi

# Do not compress FS
export NO_COMPRESSEDFS=yes

# Use normal src.conf
if [ $FREEBSD_VERSION = "6" ]; then
	export SRC_CONF="${PWD}/conf/src.conf"
	export SRC_CONF_INSTALL="${PWD}/conf/src.conf"	
	export SRC_CONF_INSTALL="${PWD}/conf/src.conf"
fi
if [ $FREEBSD_VERSION = "7" ]; then
	export SRC_CONF="${PWD}/conf/src.conf.7"
	export SRC_CONF="${PWD}/conf/src.conf.7"
	export SRC_CONF_INSTALL="${PWD}/conf/src.conf.7.install"
fi
if [ $FREEBSD_VERSION = "8" ]; then
	export SRC_CONF="${PWD}/conf/src.conf.8"
	export SRC_CONF="${PWD}/conf/src.conf.8"
	export SRC_CONF_INSTALL="${PWD}/conf/src.conf.8.install"
fi

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

export EXTRA=""

# Clean out directories
freesbie_make cleandir

# Checkout a fresh copy from pfsense cvs depot
#update_cvs_depot

# Calculate versions
version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
version_base=`cat $CVS_CO_DIR/etc/version_base`
version=`cat $CVS_CO_DIR/etc/version`

# Build if needed and install world and kernel
make_world


if [ $FREEBSD_VERSION = "7" ]; then
        export SRC_CONF="${PWD}/conf/src.conf.embedded.7.install"
fi
if [ $FREEBSD_VERSION = "8" ]; then
        export SRC_CONF="${PWD}/conf/src.conf.embedded.8.install"
fi

echo ">>> Building all extra kernels... $FREEBSD_VERSION  $FREEBSD_BRANCH ..."
build_all_kernels

# Add extra files such as buildtime of version, bsnmpd, etc.
#cust_populate_extra

# No need for packages
rm -f conf/packages

#fixup_wrap

check_for_zero_size_files

# Invoke FreeSBIE2 toolchain
freesbie_make clonefs

# Fixup library changes if needed
fixup_libmap

echo ${CLONEDIR}

create_FreeBSD_system_update

email_operation_completed
