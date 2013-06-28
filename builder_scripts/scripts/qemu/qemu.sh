#!/bin/sh
#
# Usage: qemu.sh instance-id
set -u

ISO_IMAGE="/usr/obj.pfSense/pfSense.iso"
IMG_PREFIX="harddisk-"

IMG_SIZE="10M"

INSTANCE_ID="$1"

#Calculate mac address based on INSTANCE ID
macaddr=`printf ${INSTANCE_ID} | md5 | awk '{for(i=0;i<6;i++){ a=a "" substr($1,2*i,2); if(i!=5) a=a ":" }}END{print a;}'`

[ ! -f "${IMG_PREFIX}${INSTANCE_ID}" ] && \
  qemu-img create ${IMG_PREFIX}${INSTANCE_ID} ${IMG_SIZE}

qemu -hda ${IMG_PREFIX}${INSTANCE_ID} -cdrom ${ISO_IMAGE} \
  -boot d -nics 2 -n launch-bridge.sh -macaddr ${macaddr} \
  -localtime -parallel pty -nographic 
