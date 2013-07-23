#!/bin/sh

PREVIOUSDIR=`pwd`

# Suck in local vars
if [ -f ./pfsense_local.sh ]; then
        . ./pfsense_local.sh
elif [ -f ../pfsense_local.sh ]; then
        . ../pfsense_local.sh
else
        echo "You are calling this script from wrong location"
        exit 1
fi

mkdir -p $BUILDER_TOOLS/builder_scripts/conf

cd $BASE_DIR/installer/scripts/build 

# Backup old make.conf
if [ -f /etc/make.conf ]; then
	mv /etc/make.conf /tmp/
	echo "WITHOUT_X11=yo" >> /etc/make.conf
	DCPUS=`sysctl kern.smp.cpus | cut -d' ' -f2`
	CPUS=`expr $DCPUS '*' 2`
	echo SUBTHREADS="${CPUS}" >> /etc/make.conf
	MKCNF="pfPorts"
fi

# Copy BSDInstaller build.conf
cp ${BUILDER_TOOLS}/installer/conf/build.conf \
       ${BASE_DIR}/installer/scripts/build/

echo -n ">>> Creating installer tarballs..."
(cd $BASE_DIR/installer/scripts/build  && ./create_installer_tarballs.sh) 2>&1 | egrep -B3 -A3 -wi '(warning|error)'
echo "Done!"

echo -n ">>> Copying ports to the ports directory..."
(cd $BASE_DIR/installer/scripts/build  && ./copy_ports_to_portsdir.sh) 2>&1 | egrep -B3 -A3 -wi '(warning|error)'
echo "Done!"

echo -n ">>> Rebuilding BSDInstaller..."
(cd $BASE_DIR/installer/scripts/build  && sh ./build_installer_packages.sh) 2>&1 | egrep -B3 -A3 -wi '(error)'
echo "Done!"

if [ -f $BUILDER_TOOLS/builder_scripts/conf/packages.tbz ]; then
	echo -n ">>> Moving BSDInstaller package into place..."
	mv $BUILDER_TOOLS/builder_scripts/conf/packages.tbz \
		/usr/ports/packages/All/bsdinstaller-2.0.2008.0405.tbz
	echo "Done!"
fi

# Restore previous make.conf
if [ -f /tmp/make.conf ]; then
	mv /tmp/make.conf /etc/
fi

cd $PREVIOUSDIR
