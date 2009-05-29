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
