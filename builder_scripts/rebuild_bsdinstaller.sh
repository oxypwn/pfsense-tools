#!/bin/sh

echo "Rebuilding BSDInstaller..."

PREVIOUSDIR=`pwd`

cd /home/pfsense/installer/installer/scripts/build 

./create_installer_tarballs.sh 
./copy_ports_to_portsdir.sh 
./build_installer_packages.sh 

cd $PREVIOUSDIR
