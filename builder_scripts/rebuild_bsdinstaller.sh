#!/bin/sh

echo ">>> Rebuilding BSDInstaller..."

. ./pfsense_local.sh

mkdir -p $BUILDER_TOOLS/builder_scripts/conf

PREVIOUSDIR=`pwd`

cd $BASE_DIR/installer/installer/scripts/build 

# Backup old make.conf
if [ -f /etc/make.conf ]; then
	mv /etc/make.conf /tmp/
	echo "WITHOUT_X11=yo" >> /etc/make.conf
	echo "CFLAGS=-O2" >> /etc/make.conf
	MKCNF="pfPorts"
fi

export CVSDIR=${CVSDIR:-"$BUILDER_SCRIPTS"}

echo ">>> Creating installer tarballs..."
(cd $BASE_DIR/installer/installer/scripts/build  && ./create_installer_tarballs.sh) 2>&1 | egrep -wi '(warning|error)'
echo ">>> Copying ports to the ports directory..."
(cd $BASE_DIR/installer/installer/scripts/build  && ./copy_ports_to_portsdir.sh) 2>&1 | egrep -wi '(warning|error)'
echo ">>> Rebuilding..."
(cd $BASE_DIR/installer/installer/scripts/build  && ./build_installer_packages.sh) 2>&1 | egrep -wi '(error)'

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
