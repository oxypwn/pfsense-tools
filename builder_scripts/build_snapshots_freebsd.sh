#!/bin/sh
#
# FreeBSD snapshot building system
# (C)2007, 2008, 2009 Scott Ullrich
# All rights reserved
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#

if [ ! -f ./pfsense-build.conf ]; then
	echo "You must first run ./set_version.sh !"
	exit 1
fi

# Set verbose
#set -x

# Set debug
#set -e 

# Local variables that are used by builder scripts
RSYNCIP="172.29.29.181"
FREEBSDOBJDIR=/usr/obj.FreeBSD
MAKEOBJDIRPREFIX=/usr/obj.FreeBSD
STAGINGAREA=/tmp/staging
FREEBSDHOMEDIR=/home/pfsense
TOOLDIR=${FREEBSDHOMEDIR}/tools
BUILDERSCRIPTS=${TOOLDIR}/builder_scripts

# Source pfSense / FreeSBIE variables
# *** DO NOT SOURCE BUILDER_COMMON.SH!
# *** IT WILL BREAK EVERYTHING FOR 
# *** SOME UNKNOWN REASON.
# ***                       04/07/2008
. $BUILDERSCRIPTS/pfsense_local.sh

# Ensure directories exist
mkdir -p $STAGINGAREA

build_freebsdiso() {
	cd $BUILDERSCRIPTS
	echo ">> Copying FreeBSD overlay information..."
	cp $BUILDERSCRIPTS/builder_profiles/freebsd_only/pfsense* $BUILDERSCRIPTS/
	./clean_build.sh
	./build_freebsdisoonly.sh
}

dobuilds() {
	cd $BUILDERSCRIPTS
	build_freebsdiso	
	scp_files
}

copy_to_staging_deviso_updates() {
	DATESTRING=`date "+%Y%m%d-%H%M"`
	mv $FREEBSDOBJDIR/FreeBSD.iso $STAGINGAREA/FreeBSD-${DATESTRING}-8.0-CURRENT.iso
	gzip $STAGINGAREA/$STAGINGAREA/FreeBSD-${DATESTRING}-8.0-CURRENT.iso
	md5 $STAGINGAREA/FreeBSD-${DATESTRING}-8.0-CURRENT.iso > $STAGINGAREA/FreeBSD-${DATESTRING}-8.0-CURRENT.iso.md5	
}

scp_files() {
	date >$STAGINGAREA/version
	echo ">>> Copying files to snapshots.pfsense.org"
	if [ ! -f /usr/local/bin/rsync ]; then
		echo ">>> Could not find rsync, installing from ports..."
		(cd /usr/ports/net/rsync && make install clean)
	fi
	rm -f /tmp/ssh-snapshots*
	set +e
	# Ensure directory(s) are available
	ssh snapshots@${RSYNCIP} mkdir -p /usr/local/www/snapshots/FreeBSD_8_0
	rsync -ave ssh --bwlimit=50 --timeout=60 $STAGINGAREA/* snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_8_0/
	set -e
}

cleanup_builds() {
	# Remove prior builds
	echo ">>> Cleaning up after prior builds..."
	rm -rf /usr/obj*
	rm -f $STAGINGAREA/*
	if [ -d /home/pfsense/pfSense ]; then
		echo "Clearing out previous pfSense checkout directory..."
		chflags -R noschg /home/pfsense/pfSense
		rm -rf /home/pfsense/pfSense
	fi
	./clean_build.sh
}

build_loop_operations() {
	echo ">>> Starting build loop operations"
	dobuilds
	scp_files
}

# Main builder loop - if you want to loop a build invoke build_snapshots_looped.sh
echo ">>> Execing pfsense-build.conf"
. $BUILDERSCRIPTS/pfsense-build.conf

while [ /bin/true ]; do
	build_loop_operations
	sleep 65535
done

