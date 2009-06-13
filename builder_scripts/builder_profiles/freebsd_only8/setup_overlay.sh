#!/bin/sh

TOOLSDIR=/home/pfsense/tools/builder_scripts/

cat $TOOLSDIR/RELENG_8-supfile | grep -v "date" > /tmp/RELENG_8-supfile
cp /tmp/RELENG_8-supfile $TOOLSDIR
rm /tmp/RELENG_8-supfile

cp pfsense_local.sh    $TOOLSDIR
cp pfsense-build.conf  $TOOLSDIR

cd $TOOLSDIR
./clean_build.sh
./apply_kernel_patches.sh
./build_freebsdisoonly.sh
