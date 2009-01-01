#!/bin/sh

echo "Rebuilding BSDInstaller..."

mkdir -p /home/pfsense/tools/builder_scripts/conf

PREVIOUSDIR=`pwd`

cd /home/pfsense/installer/installer/scripts/build 

# Backup old make.conf
if [ -f /etc/make.conf ]; then
	mv /etc/make.conf /tmp/
	echo "WITHOUT_X11=yo" >> /etc/make.conf
	echo "CFLAGS=-O" >> /etc/make.conf
	MKCNF="pfPorts"
fi

./create_installer_tarballs.sh | egrep -B3  -wi '(warning|error)'
./copy_ports_to_portsdir.sh | egrep -B3  -wi '(warning|error)'
./build_installer_packages.sh | egrep -B3  -wi '(warning|error)'

if [ -f /usr/home/pfsense/tools/builder_scripts/conf/packages.tbz ]; then
	echo "Moving BSDInstaller package into place..."
	mv /usr/home/pfsense/tools/builder_scripts/conf/packages.tbz \
		/usr/ports/packages/All/bsdinstaller-2.0.2008.0405.tbz
fi

# Restore previous make.conf
if [ -f /tmp/make.conf ]; then
	mv /tmp/make.conf /etc/
fi

cd $PREVIOUSDIR
