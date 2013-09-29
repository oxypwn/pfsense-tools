#!/bin/sh

if [ -f /usr/sbin/pkg_add ]; then
	PKG_ADD=pkg_add
else
	PKG_ADD="pkg add"
fi

/usr/sbin/pwd_mkdb -d /etc/ /etc/master.passwd
FILELIST=`cd /tmp/pkg && ls -Utr`
for FILE in $FILELIST; do
	cd /tmp/pkg && ${PKG_ADD} -f $FILE || true
done
