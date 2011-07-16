#!/bin/sh

FILELIST=`cd /tmp/pkg && ls -lUtr`
for FILE in \$FILELIST; do
	pkg_add \$FILE || true
done
