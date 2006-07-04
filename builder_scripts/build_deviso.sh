#!/bin/sh

# $Id$

set -e -u

. ./pfsense_local.sh

# Set extra before pfsense_local.sh will do
# Add comconsole to the list
# export EXTRA="comconsole customroot"
export EXTRA="customroot"

export MAKE_CONF="${PWD}/conf/make.conf.developer"
if [ $pfSense_version = "7" ]; then
	export MAKE_CONF="${PWD}/conf/make.conf.developer.7"
fi

export PRUNE_LIST=""

# Use pfSense.6 as kernel configuration file
export DEVIMAGE=yo
if [ $pfSense_version = "6" ]; then
	export KERNELCONF=${KERNELCONF:-"${PWD}/conf/pfSense_Dev.6"}
fi
if [ $pfSense_version = "7" ]; then
	export KERNELCONF=${KERNELCONF:-"${PWD}/conf/pfSense_Dev.7"}
fi

# Check if the world and kernel are already built and remove
# lock files accordingly

objdir=${MAKEOBJDIRPREFIX:-/usr/obj}
build_id_w=`basename ${KERNELCONF}`
build_id_k=${build_id_w}

# If PFSENSE_DEBUG is set, remove the ${build_id_k}.DEBUG file
if [ ! -z "${PFSENSE_DEBUG:-}" -a -f ${KERNELCONF}.DEBUG ]; then
    build_id_k=${build_id_w}.DEBUG
fi

if [ -f "${objdir}/${build_id_w}.world.done" ]; then
    #rm -f ${objdir}/${build_id_w}.world.done
    #rm -rf /usr/obj*
fi

# Suck in script helper functions
. ./builder_common.sh

# Use pfSense.6 as kernel configuration file
if [ $pfSense_version = "6" ]; then
	export KERNELCONF=${KERNELCONF:-"${PWD}/conf/pfSense_Dev.6"}
fi
if [ $pfSense_version = "7" ]; then
	export KERNELCONF=${KERNELCONF:-"${PWD}/conf/pfSense_Dev.7"}
fi

# Add etcmfs and rootmfs to the EXTRA plugins used by freesbie2
export EXTRA="${EXTRA:-} rootmfs varmfs etcmfs"

# Clean out directories
freesbie_make cleandir

# Checkout a fresh copy from pfsense cvs depot
update_cvs_depot

# Calculate versions
export version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
export version_base=`cat $CVS_CO_DIR/etc/version_base`
export version=`cat $CVS_CO_DIR/etc/version`

# Build if needed and install world and kernel
make_world_kernel

# Add extra files such as buildtime of version, bsnmpd, etc.
echo ">>> Phase populate_extra"
( populate_extra )
echo ">>> Phase set_image_as_cdrom"
( set_image_as_cdrom )

# Fixup library changes if needed
fixup_libmap

# Nuke the boot directory
[ -d "${CVS_CO_DIR}/boot" ] && rm -rf ${CVS_CO_DIR}/boot

rm -f conf/packages

set +e # grep could fail
(cd /var/db/pkg && ls | grep bsdinstaller) > conf/packages
(cd /var/db/pkg && ls | grep lighttpd) >> conf/packages
(cd /var/db/pkg && ls | grep lua) >> conf/packages
(cd /var/db/pkg && ls | grep cpdup) >> conf/packages
set -e

# Invoke FreeSBIE2 toolchain
freesbie_make iso

# Re-remove lockfiles after build
#rm -f ${objdir}/${build_id_w}.world.done ${objdir}/${build_id_k}.kernel.done
