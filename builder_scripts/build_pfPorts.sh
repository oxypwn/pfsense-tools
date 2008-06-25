#!/bin/sh

# pfSense master builder script
# (C)2005-2006 Scott Ullrich and the pfSense project
# All rights reserved.
#
# $Id$

# Crank up error reporting, debugging.
#set -e 
#set -x

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

MAKEJ_PORTS=""

# Make sure cvsup_current has been run first 
check_for_clog

(cd ${pfSPORTS_BASE_DIR} && make deinstall)
(cd ${pfSPORTS_BASE_DIR} && make clean distclean)


	
# Backup host pkg db
if [ -d /var/db/pkg ]; then 
	echo "===> Backing up host pkg DB..."
	(cd /var/db/pkg && tar czf /tmp/vardbpkg.tgz .)
fi

# Zero out DB
rm -rf /var/db/pkg/*
	
echo "===> Compiling pfPorts..."
if [ -f /etc/make.conf ]; then
	mv /etc/make.conf /tmp/
	echo "WITHOUT_X11=yo" >> /etc/make.conf
	MKCNF="pfPorts"
fi
export FORCE_PKG_REGISTER=yo

echo ">>> Special building rrdtool from recompile_pfPorts()..."
(cd /usr/ports/databases/rrdtool && make ${MAKEJ_PORTS} BATCH=yo && make install FORCE_PKG_REGISTER=yo)
echo ">>> Special building grub from recompile_pfPorts()..."
(cd /usr/ports/sysutils/grub && make ${MAKEJ_PORTS} BATCH=yo && make install FORCE_PKG_REGISTER=yo)

echo "===> Operating on $pfSPORT..."
( cd ${pfSPORTS_BASE_DIR} && make ${MAKEJ_PORTS} FORCE_PKG_REGISTER=yo BATCH=yo )
echo "===> Installing new port..."
( cd ${pfSPORTS_BASE_DIR} && make install FORCE_PKG_REGISTER=yo BATCH=yo )

if [ "${MKCNF}x" = "pfPortsx" ]; then
	mv /tmp/make.conf /etc/
fi

if [ -d /tmp/vardbpkg/pkg ]; then 
	echo "===> Restoring parent pkg DB..."
	rm -rf /var/db/pkg/*
	(cd /var/db/pkg/ && tar xzf /tmp/vardbpkg.tgz)
fi
echo "===> End of pfPorts..."


