#!/bin/sh
#
# Usage: qemu.sh instance-id
set -u

ISO_IMAGE="/usr/obj.pfSense/pfSense.iso"
IMG_PREFIX="harddisk-"

DD_ARG_SIZE="bs=1k count=10k"

INSTANCE_ID="$1"

#Calculate mac address based on INSTANCE ID
macaddr=`printf ${INSTANCE_ID} | md5 | awk '{for(i=0;i<6;i++){ a=a "" substr($1,2*i,2); if(i!=5) a=a ":" }}END{print a;}'`

[ ! -f "${IMG_PREFIX}${INSTANCE_ID}" ] && \
  dd if=/dev/zero of=${IMG_PREFIX}${INSTANCE_ID} ${DD_ARG_SIZE}

qemu -hda ${IMG_PREFIX}${INSTANCE_ID} -cdrom ${ISO_IMAGE} \
  -boot d -nics 2 -n launch-bridge.sh -macaddr ${macaddr} \
  -localtime -parallel pty -nographic 
