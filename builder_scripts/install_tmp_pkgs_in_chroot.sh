#!/bin/sh

FILELIST=`cd /tmp/pkg && ls -Utr`
for FILE in $FILELIST; do
	cd /tmp/pkg && pkg_add $FILE || true
done
