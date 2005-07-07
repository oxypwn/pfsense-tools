#!/bin/sh
#
# genmanifest.sh - a quick script to make mtree manifests for pfSense diff updates
#
# Colin Smith

make_manifest() {
	SUFFIX=`echo $1 | /usr/bin/sed 's/\//\./g' | cut -d '/' -f 1`
	/usr/sbin/mtree -X exclude.list -c -k cksum,md5digest -p $1 > manifest_$SUFFIX
}

echo -n "Creating manifest for /etc/*... "
make_manifest pfSense/etc
echo "done."

echo -n "Creating manifest for /usr/local/www/*... "
make_manifest pfSense/usr/local/www
echo "done."
