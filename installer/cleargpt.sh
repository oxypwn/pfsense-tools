#!/bin/sh

DISK=$1
for PART in `gpart show $DISK | grep -v '=>' | awk '{ print $3 }'`; do
	/sbin/gpart delete -i $PART $DISK >/dev/null
done
/sbin/gpart destroy $DISK >/dev/null

exit 0