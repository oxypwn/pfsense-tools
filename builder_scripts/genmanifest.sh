#!/bin/sh
#
# genmanifest.sh - a quick script to make mtree manifests for pfSense diff updates
#
# Colin Smith

make_manifest() {
	SUFFIX=`echo $1 | /usr/bin/sed 's/\//\./g' | cut -d '/' -f 1`
	/usr/sbin/mtree -X exclude.list -c -k cksum,md5digest -p $1 > manifest_$SUFFIX
}

echo -n "Deleting old manifests... "
rm manifest_*
echo "done."

echo -n "Creating manifest for /etc/*... "
make_manifest pfSense/etc
echo "done."

echo -n "Creating manifest for /usr/local/www/*... "
make_manifest pfSense/usr/local/www
echo "done."

echo -n "Adding manifests to tarfile... "
tar rf pfSense-Firmware-Manifest-$1.tar manifest_*
gzip pfSense-Firmware-Manifest-$1.tar
mv pfSense-Firmware-Manifest-$1.tar.gz pfSense-Firmware-Manifest-$1.tgz
echo "done."
