#!/bin/sh

echo "Rebuilding BSDInstaller..."

. ./pfsense_local.sh

mkdir -p $BUILDER_TOOLS/builder_scripts/conf

PREVIOUSDIR=`pwd`

cd $BASE_DIR/installer/installer/scripts/build 

# Backup old make.conf
if [ -f /etc/make.conf ]; then
	mv /etc/make.conf /tmp/
	echo "WITHOUT_X11=yo" >> /etc/make.conf
	echo "CFLAGS=-O" >> /etc/make.conf
	MKCNF="pfPorts"
fi

export CVSDIR=${CVSDIR:-"$BUILDER_SCRIPTS"}
./create_installer_tarballs.sh | egrep -B3  -wi "(warning|error)"
./copy_ports_to_portsdir.sh | egrep -B3  -wi "(warning|error)"
./build_installer_packages.sh | egrep -B3  -wi "(warning|error)"

if [ -f $BUILDER_TOOLS/builder_scripts/conf/packages.tbz ]; then
	echo "Moving BSDInstaller package into place..."
	mv $BUILDER_TOOLS/builder_scripts/conf/packages.tbz \
		/usr/ports/packages/All/bsdinstaller-2.0.2008.0405.tbz
fi

# Restore previous make.conf
if [ -f /tmp/make.conf ]; then
	mv /tmp/make.conf /etc/
fi

cd $PREVIOUSDIR
