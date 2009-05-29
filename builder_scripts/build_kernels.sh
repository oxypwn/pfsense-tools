#!/bin/sh

# pfSense master builder script
# (C)2005-2006 Scott Ullrich and the pfSense project
# All rights reserved.
#
# $Id$

# Crank up error reporting, debugging.
#set -e 
#set -x

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Output build flags
print_flags

# Allow old CVS_CO_DIR to be deleted later
if [ -d $CVS_CO_DIR ]; then 
	chflags -R noschg $CVS_CO_DIR
fi 

# Use pfSense.6 as kernel configuration file
export KERNELCONF=${KERNELCONF:-"${PWD}/conf/pfSense.$FREEBSD_VERSION"}

# If a embedded build has been performed we need to nuke
# /usr/obj.pfSense/ since full uses a different
# src.conf
if [ -f /usr/obj.pfSense/pfSense_wrap.$FREEBSD_VERSION.world.done ]; then
	echo -n "Removing /usr/obj* since embedded build performed prior..."
	rm -rf /usr/obj.pfSense/*
	echo "done."
fi

# Use normal src.conf
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
