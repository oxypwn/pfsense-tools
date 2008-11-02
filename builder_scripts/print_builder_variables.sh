#!/bin/sh

CURRENTDIR=`pwd`
[ -r "${CURRENTDIR}/pfsense_local.sh" ] && . ${CURRENTDIR}/pfsense_local.sh
[ -r "${CURRENTDIR}/builder_common.sh" ] && . ${CURRENTDIR}/builder_common.sh

print_flags

