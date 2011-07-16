#!/bin/sh

FILELIST=`cd /tmp/pkg && ls -Utr`
for FILE in $FILELIST; do
	pkg_add $FILE || true
done
