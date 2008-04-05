#!/bin/sh
#
# pfSense snapshot building system
# (C)2007, 2008 Scott Ullrich
# All rights reserved
#
# This file is placed under the BSD License, 2 clause.
#
# $Id$
#

# Set verbose
set -x

# Set debug
set -e 

# Local variables that are used by builder scripts
PFSENSEOBJDIR=/usr/obj.pfSense
MAKEOBJDIRPREFIX=/usr/obj.pfSense
WEBDATAROOT=/usr/local/www/data
WEBROOT=/usr/local/www
SNAPSHOTSCRIPTSDIR=/root
STAGINGAREA=/tmp/staging
PFSENSEHOMEDIR=/home/pfsense
PFSENSECVSROOT=${PFSENSEHOMEDIR}/cvsroot
PFSENSECHECKOUTDIR=${PFSENSEHOMEDIR}/pfSense
PFSENSEUPDATESDIR=${PFSENSEHOMEDIR}/updates
TOOLDIR=${PFSENSEHOMEDIR}/tools
BUILDERSCRIPTS=${TOOLDIR}/builder_scripts

# Source pfSense / FreeSBIE variables
. $BUILDERSCRIPTS/builder_common.sh
. $BUILDERSCRIPTS/pfsense_local.sh

# Ensure a fresh environment, please.
# rm -rf $PFSENSECVSROOT
# rm -rf $PFSENSECHECKOUTDIR

# Ensure directories exist
mkdir -p $PFSENSECVSROOT
mkdir -p $PFSENSECHECKOUTDIR
mkdir -p $STAGINGAREA
mkdir -p $WEBROOT

# Sync with pfsense.org
cvsup $BUILDERSCRIPTS/pfSense-supfile
cvsup $BUILDERSCRIPTS/freesbie2-supfile

rm $BUILDERSCRIPTS/pfsense_local.sh
cd $BUILDERSCRIPTS && cvs up -d

create_webdata_structure() {
	mkdir -p $WEBDATAROOT/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/updates
	mkdir -p $WEBDATAROOT/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/iso 
	mkdir -p $WEBDATAROOT/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/embedded 
}

set_pfsense_source() {
	echo $1 > $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt
	install_pfsense_local_sh
}

set_freebsd_source() {
	echo $1 > $WEBROOT/FREEBSD_PLATFORM.txt
	install_pfsense_local_sh
}

set_freebsd_version() {
	echo $1 > $WEBROOT/FREEBSD_VERSION.txt
	install_pfsense_local_sh
}

install_pfsense_local_sh() {
	# Customizes pfsense_local.sh
	touch $WEBROOT/FREEBSD_PLATFORM.txt
	touch $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt
	touch $WEBROOT/FREEBSD_VERSION.txt
	FREEBSD_PLATFORM=`cat $WEBROOT/FREEBSD_PLATFORM.txt`
	PFSENSE_PLATFORM=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
	FREEBSD_VERSION=`cat $WEBROOT/FREEBSD_VERSION.txt`
	# Strip dynamic values
	cat $BUILDERSCRIPTS/pfsense_local.sh | \
		grep -v pfSense_version | \
		grep -v freebsd_branch | \
		grep -v PFSENSETAG | \
		grep -v OVERRIDE_FREEBSD_CVSUP_HOST > /tmp/pfsense_local.sh
	mv /tmp/pfsense_local.sh $BUILDERSCRIPTS/pfsense_local.sh
	# Add our custom dynamic values
	echo export pfSense_version="${FREEBSD_VERSION}" >> $BUILDERSCRIPTS/pfsense_local.sh
	echo export freebsd_branch="${FREEBSD_PLATFORM}" >> $BUILDERSCRIPTS/pfsense_local.sh
	echo export PFSENSETAG="${PFSENSE_PLATFORM}" >> $BUILDERSCRIPTS/pfsense_local.sh
	echo export OVERRIDE_FREEBSD_CVSUP_HOST="cvsup.livebsd.com" >> $BUILDERSCRIPTS/pfsense_local.sh
}

update_sources() {
	cd $BUILDERSCRIPTS 
	./cvsup_current
	gzip $PFSENSEOBJDIR/pfSense.iso
	mv $PFSENSEOBJDIR/pfSense.iso.gz $PFSENSEOBJDIR/pfSense-`date "+%Y%m%d-%H%M"`.iso.gz
	md5 $PFSENSEOBJDIR/pfSense-`date "+%Y%m%d-%H%M"`.iso.gz > $PFSENSEOBJDIR/pfSense-`date "+%Y%m%d-%H%M"`.iso.gz.md5
}

build_embedded() {
	rm -rf /usr/obj*
	cd $BUILDERSCRIPTS 
	./build_embedded.sh
	rm -f $PFSENSEOBJDIR/pfSense-`date "+%Y%m%d-%H%M"`.img.gz
	gzip $PFSENSEOBJDIR/pfSense-`date "+%Y%m%d-%H%M"`.img
	md5 $PFSENSEOBJDIR/pfSense-`date "+%Y%m%d-%H%M"`.img.gz > $PFSENSEOBJDIR/pfSense-`date "+%Y%m%d-%H%M"`.img.gz.md5
}

build_embedded_updates() {
	cd $BUILDERSCRIPTS
	./build_updates_embedded.sh
}

build_updates() {
	cd $BUILDERSCRIPTS 
	./build_updates.sh
	for filename in $PFSENSEUPDATESDIR/*.tgz
	do
		if [ -f $filename ]; then 
			echo "Creating MD5 summary for $filename"
			md5 $filename > $filename.md5
		fi
	done
}

build_iso() {
	cd $BUILDERSCRIPTS
	./build_iso.sh
}

dobuilds() {
	cd $BUILDERSCRIPTS
	# Update sources and build iso
	update_sources
	# Build updates on same run as iso
	build_updates
	# Copy files before embedded, it wipes out usr.obj*
	copy_to_staging_iso_updates
	# Build embedded version
	build_embedded
	# Copy to staging
	copy_to_staging_embedded
}

copy_to_staging_iso_updates() {
	cp $PFSENSEOBJDIR/pfSense-*.iso.* $STAGINGAREA/
	cp $PFSENSEUPDATESDIR/*.tgz $STAGINGAREA/
	cp $PFSENSEUPDATESDIR/*.tgz.md5 $STAGINGAREA/
}

copy_to_staging_embedded() {
	cp $PFSENSEOBJDIR/pfSense.img.* $STAGINGAREA/
}

cp_files() {
	cp $STAGINGAREA/pfSense.iso.* $WEBDATAROOT/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/iso/
	cp $STAGINGAREA/pfSense.img.* $WEBDATAROOT/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/embedded/
	cp $STAGINGAREA/*.tgz $WEBDATAROOT/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/updates/
	cp $STAGINGAREA/*.tgz.md5 $WEBDATAROOT/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/updates/
}

scp_files() {
	scp $STAGINGAREA/pfSense.iso* snapshots@172.29.29.181:/usr/local/www/snapshots/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/
	scp $STAGINGAREA/pfSense.img* snapshots@172.29.29.181:/usr/local/www/snapshots/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/
	scp $STAGINGAREA/*.md5 snapshots@172.29.29.181:/usr/local/www/snapshots/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/
}

cleanup_builds() {
	# Remove prior builds
	echo "Cleaning up after prior builds..."
	rm -rf /usr/obj*
	rm -f $STAGINGAREA/*
	rm -f $PFSENSEUPDATESDIR/*  # Keep updates dir slimmed down
	if [ -d /home/pfsense/pfSense ]; then
		echo "Clearing out previous pfSense checkout directory..."
		chflags -R noschg /home/pfsense/pfSense
		rm -rf /home/pfsense/pfSense
	fi
}

build_loop_operations() {
	# --- Items we need to run for a complete build run ---
	# Create extra structures
	create_webdata_structure
	# Cleanup prior builds
	cleanup_builds
	# Output builder flags
	print_flags
	# Do the builds
	dobuilds
	# Copy/SCP images
	cp_files
	scp_files
}

# Main builder loop - lets do this forever until the cows come home.
while [ /bin/true ]; do

	# --- begin pfSense RELENG_1 -- FreeBSD RELENG_7
	set_pfsense_source "RELENG_1"
	set_freebsd_source "RELENG_7_0"
	set_freebsd_version "7"
	build_loop_operations	
	# --- end pfSense RELENG_1 -- FreeBSD RELENG_7

	sleep 500	# give the box a break.
done
