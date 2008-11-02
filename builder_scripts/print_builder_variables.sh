#!/bin/sh

CURRENTDIR=`pwd`
[ -r "${CURRENTDIR}/pfsense_local.sh" ] && . ${CURRENTDIR}/pfsense_local.sh

print_flags
