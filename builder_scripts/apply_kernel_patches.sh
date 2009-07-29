#!/bin/sh

# This script is for testing only!
# It will build a kernel for each patch line item and
# then output the kernels to $KERNELOUTPUTDIR

#set -e -x

CURRENTDIR=`pwd`
[ -r "${CURRENTDIR}/pfsense_local.sh" ] && . ${CURRENTDIR}/pfsense_local.sh
[ -r "${CURRENTDIR}/builder_common.sh" ] && . ${CURRENTDIR}/builder_common.sh

if [ -f $MAKEOBJDIRPREFIX/.done_buildworld ]; then
	echo ">>> Removing $MAKEOBJDIRPREFIX/.done_buildworld"
	rm $MAKEOBJDIRPREFIX/.done_buildworld
fi
update_freebsd_sources_and_apply_patches
