#!/bin/sh

# $Id$

set -e -u

. ./pfsense_local.sh

# Set extra before pfsense_local.sh will do
# Add comconsole to the list
#export EXTRA="comconsole customroot"
export EXTRA="customroot"

export MAKE_CONF="${PWD}/conf/make.conf.developer"

export PRUNE_LIST="/dev/null"

# Use pfSense.6 as kernel configuration file
export KERNELCONF=${KERNELCONF:-"${PWD}/conf/pfSense.6"}

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
    rm -f ${objdir}/${build_id_w}.world.done
    rm -rf /usr/obj*
fi

sh -x ./build_iso.sh

# Re-remove lockfiles after build
rm -f ${objdir}/${build_id_w}.world.done ${objdir}/${build_id_k}.kernel.done
