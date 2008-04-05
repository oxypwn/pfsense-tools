#!/bin/sh

echo "Rebuilding BSDInstaller..."

mkdir -p conf

PREVIOUSDIR=`pwd`

cd /home/pfsense/installer/installer/scripts/build 

./create_installer_tarballs.sh 
./copy_ports_to_portsdir.sh 
./build_installer_packages.sh 

if [ -f /usr/home/pfsense/tools/builder_scripts/conf/packages.tbz ]; then
	echo "Moving BSDInstaller package into place..."
	mv /usr/home/pfsense/tools/builder_scripts/conf/packages.tbz \
		/usr/ports/packages/All/bsdinstaller-2.0.2008.0405.tbz
fi

cd $PREVIOUSDIR
