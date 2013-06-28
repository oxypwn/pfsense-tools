#!/bin/sh
#
# makepatch.sh - a quick script to make mtree manifests and patches for pfSense diff updates
#
# Colin Smith

CATEGORY="Firmware"
DIFFTIME=`cvs -d /cvsroot/ log pfSense/etc/version | grep 'date:' | cut -d ';' -f 1 | head -n 2 | awk '{ print $2, $3 }' | tail -n 1`
NEWVER=`cat pfSense/etc/version`

make_diff() {
	echo -n "Diffing /$3*... "
        cvs -d /cvsroot/ diff -u -D "$1 $2" $CVS_CO_DIR/$3 2> /dev/null >> pfsense_update.patch
	echo "done."
}

make_manifest() {
	echo -n "Creating manifest for /$1*... "
	/usr/sbin/mtree -X exclude.list -c -k cksum,md5digest -p $CVS_CO_DIR/$1 > $2
	echo "done."
}

echo -n "Deleting old files... "
rm pfsense_update.patch manifest_* 2> /dev/null
echo "done."

make_diff $DIFFTIME etc/
make_manifest etc/ manifest_etc
make_diff $DIFFTIME usr/local/etc/
make_manifest usr/local/etc/ manifest_usr.local.etc
make_diff $DIFFTIME usr/local/www/
make_manifest usr/local/www manifest_usr.local.www

echo -n "Creating patch tgz... "
tar czf pfSense-Diff-$CATEGORY-Update-$NEWVER.tgz pfsense_update.patch manifest_*
echo "done."

echo -n "Cleaning up... "
rm pfsense_update.patch manifest_* 2> /dev/null
echo "done."

echo -n "Creating full patch... "
tar czf pfSense-Full-$CATEGORY-Update-$NEWVER.tgz $CVS_CO_DIR/etc/* $CVS_CO_DIR/usr/local/www/* $CVS_CO_DIR/usr/local/etc/* 2> /dev/null
echo "done."
