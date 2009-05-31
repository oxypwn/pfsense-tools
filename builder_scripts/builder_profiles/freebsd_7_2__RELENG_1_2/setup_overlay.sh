#!/bin/sh

TOOLSDIR=/home/pfsense/tools/builder_scripts/

cp pfsense-build.conf  $TOOLSDIR

cd $TOOLSDIR
./clean_build.sh
./apply_kernel_patches.sh
./build_freebsdisoonly.sh
