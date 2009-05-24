#!/bin/sh

TOOLSDIR=/home/pfsense/tools/builder_scripts/
cp pfsense_local.sh    $TOOLSDIR
cp pfsense-build.conf  $TOOLSDIR

cd $TOOLSDIR/builder_profiles

cd $TOOLSDIR
./clean_build.sh
./apply_kernel_patches.sh
./build_iso.sh
./build_embedded.sh


