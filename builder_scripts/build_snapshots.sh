#!/bin/sh
#
# pfSense snapshot building system
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
# *** DO NOT SOURCE BUILDER_COMMON.SH!
# *** IT WILL BREAK EVERYTHING FOR 
# *** SOME UNKNOWN REASON.
# ***                       04/07/2008
. $BUILDERSCRIPTS/pfsense_local.sh
	
# Ensure a fresh environment, please.
# rm -rf $PFSENSECVSROOT
# rm -rf $PFSENSECHECKOUTDIR

# Ensure directories exist
mkdir -p $PFSENSECVSROOT
mkdir -p $PFSENSECHECKOUTDIR
mkdir -p $STAGINGAREA
mkdir -p $WEBROOT

post_tweet() {
	TWEET_MESSAGE="$1"
	if [ "$TWITTER_USERNAME" = "" ]; then
		echo ">>> ERROR: Could not find TWITTER_USERNAME -- tweet cancelled."
		return
	fi
	if [ "$TWITTER_PASSWORD" = "" ]; then
		echo ">>> ERROR: Could not find TWITTER_PASSWORD -- tweet cancelled."
		return
	fi
	if [ ! -f "/usr/local/bin/curl" ]; then 
		echo ">>> ERROR: Could not find /usr/local/bin/curl -- tweet cancelled."
		return
	fi
	echo ">>> Tweet:"
	echo ">>> ${TWEET_MESSAGE}"
	echo -n ">>> Posting tweet..."
	`/usr/local/bin/curl --basic --user "$TWITTER_USERNAME:$TWITTER_PASSWORD" --data status="$TWEET_MESSAGE" http://twitter.com/statuses/update.xml` >/tmp/tweet_diag.txt 2>&1
	echo "Done!"
}

sync_cvs() {
	# Sync with pfsense.org
	echo ">>> Syncing with pfSense.org"
	/usr/bin/csup -b $CVS_CO_DIR $BUILDERSCRIPTS/pfSense-supfile
	/usr/bin/csup -b $FREESBIE_PATH $BUILDERSCRIPTS/freesbie2-supfile
	cd $BUILDERSCRIPTS && cvs up -d
}

create_webdata_structure() {
	mkdir -p $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/livecd_installer
	mkdir -p $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/embedded
	mkdir -p $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/updates 
}

set_pfsense_source() {
	echo $1 > $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt
	install_pfsense_local_sh
}

set_freebsd_source() {
	echo $1 > $WEBROOT/FREEBSD_PLATFORM.txt
	install_pfsense_local_sh
}

set_FREEBSD_VERSION() {
	echo $1 > $WEBROOT/FREEBSD_VERSION.txt
	install_pfsense_local_sh
}

set_freebsd_patches() {
	echo $1 > $WEBROOT/FREEBSD_PATCHFILE.txt
	install_pfsense_local_sh
}

set_patches_dir() {
	echo $1 > $WEBROOT/FREEBSD_PATCHDIR.txt
	install_pfsense_local_sh
}

set_pfsense_version() {
	echo $1 > $WEBROOT/PFSENSE_VERSION.txt
	install_pfsense_local_sh
}

set_pfsense_supfile() {
	echo $1 > $WEBROOT/FREEBSD_SUPFILE.txt
	install_pfsense_local_sh
}

install_pfsense_local_sh() {
	# Customizes pfsense-build.conf
	touch $WEBROOT/FREEBSD_PLATFORM.txt
	touch $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt
	touch $WEBROOT/FREEBSD_VERSION.txt
	touch $WEBROOT/FREEBSD_PATCHFILE.txt
	touch $WEBROOT/FREEBSD_PATCHDIR.txt	
	touch $WEBROOT/PFSENSE_VERSION.txt
	touch $WEBROOT/FREEBSD_SUPFILE.txt
	FREEBSD_PLATFORM=`cat $WEBROOT/FREEBSD_PLATFORM.txt`
	PFSENSE_PLATFORM=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
	FREEBSD_VERSION=`cat $WEBROOT/FREEBSD_VERSION.txt`
	FREEBSD_PATCHFILE=`cat $WEBROOT/FREEBSD_PATCHFILE.txt`
	FREEBSD_PATCHDIR=`cat $WEBROOT/FREEBSD_PATCHDIR.txt`
	PFSENSE_VERSION=`cat $WEBROOT/PFSENSE_VERSION.txt`
	FREEBSD_SUPFILE=`cat $WEBROOT/FREEBSD_SUPFILE.txt`
	# Strip dynamic values
	cat $BUILDERSCRIPTS/pfsense-build.conf | \
		grep -v FREEBSD_VERSION | \
		grep -v FREEBSD_BRANCH | \
		grep -v PFSENSETAG | \
		grep -v PATCHFILE | \
		grep -v SUPFILE | \
		grep -v PATCHDIR | \
		grep -v PFSENSE_VERSION | \
		grep -v OVERRIDE_FREEBSD_CVSUP_HOST > /tmp/pfsense-build.conf
	mv /tmp/pfsense-build.conf $BUILDERSCRIPTS/pfsense-build.conf
	# Add our custom dynamic values
	echo export FREEBSD_VERSION="${FREEBSD_VERSION}" >> $BUILDERSCRIPTS/pfsense-build.conf
	echo export FREEBSD_BRANCH="${FREEBSD_PLATFORM}" >> $BUILDERSCRIPTS/pfsense-build.conf
	echo export PFSENSETAG="${PFSENSE_PLATFORM}" >> $BUILDERSCRIPTS/pfsense-build.conf
	echo export PFSPATCHFILE="${FREEBSD_PATCHFILE}" >> $BUILDERSCRIPTS/pfsense-build.conf
	echo export PFSPATCHDIR="${FREEBSD_PATCHDIR}" >> $BUILDERSCRIPTS/pfsense-build.conf
	echo export PFSENSE_VERSION="${PFSENSE_VERSION}" >> $BUILDERSCRIPTS/pfsense-build.conf
	echo export SUPFILE="${FREEBSD_SUPFILE}" >> $BUILDERSCRIPTS/pfsense-build.conf	
	echo export OVERRIDE_FREEBSD_CVSUP_HOST="cvsup.livebsd.com" >> $BUILDERSCRIPTS/pfsense-build.conf
}

update_sources() {
	cd $BUILDERSCRIPTS 
	./update_git_repos.sh
	# Cleanup after each build run
	./clean_build.sh
	./cvsup_current
	DATESTRING=`date "+%Y%m%d-%H%M"`
	gzip $PFSENSEOBJDIR/pfSense.iso
	mv $PFSENSEOBJDIR/pfSense.iso.gz $PFSENSEOBJDIR/pfSense-${PFSENSE_VERSION}-${DATESTRING}.iso.gz
	md5 $PFSENSEOBJDIR/pfSense-${PFSENSE_VERSION}-${DATESTRING}.iso.gz > $PFSENSEOBJDIR/pfSense-${PFSENSE_VERSION}-${DATESTRING}.iso.gz.md5
	sha256 $PFSENSEOBJDIR/pfSense-${PFSENSE_VERSION}-${DATESTRING}.iso.gz > ${PFSENSEOBJDIR}/pfSense-${PFSENSE_VERSION}-${DATESTRING}.iso.gz.sha256
}

build_embedded() {
	rm -rf /usr/obj*
	DATESTRING=`date "+%Y%m%d-%H%M"`
	rm -f $PFSENSEOBJDIR/pfSense-${DATESTRING}.img.gz
	cd $BUILDERSCRIPTS 
	./build_embedded.sh
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
			sha256 $filename > $filename.sha256
		fi
	done
	LATESTFILENAME="`ls $PFSENSEUPDATESDIR/*.tgz | grep Full | grep -v md5 | grep -v sha256 | tail -n1`"
	cp $LATESTFILENAME $PFSENSEUPDATESDIR/latest.tgz
	sha256 $PFSENSEUPDATESDIR/latest.tgz > $PFSENSEUPDATESDIR/latest.tgz.sha256
}

build_deviso() {
	cd $BUILDERSCRIPTS
	./clean_build.sh
	./build_deviso.sh
}

build_nano() {
	cd $BUILDERSCRIPTS
	./clean_build.sh
	./build_nano.sh
}

dobuilds() {
	cd $BUILDERSCRIPTS
	# Update sources and build iso
	update_sources
	# Build updates on same run as iso
	build_updates
	# Copy files before embedded, it wipes out usr.obj*
	copy_to_staging_iso_updates
	# Copy what we can 
	scp_files
	# Build DevISO
	build_deviso	
	# Copy deviso to staging area
	copy_to_staging_deviso_updates
	# Copy what we can 
	scp_files
	# Build embedded version
	build_embedded
	# Copy to staging
	copy_to_staging_embedded
	# Copy what we can
	scp_files
	# Build nanobsd
	build_nano
	# Copy nanobsd to staging areas
	copy_to_staging_nanobsd
	# Copy what we can 
	scp_files
}

copy_to_staging_nanobsd() {
	DATESTRING=`date "+%Y%m%d-%H%M"`
	FILENAMEFULL="pfSense-${PFSENSE_VERSION}-${DATESTRING}-nanobsd.img"
	FILENAMEUPGRADE="pfSense-${PFSENSE_VERSION}-${DATESTRING}-nanobsd-upgrade.img"
	mkdir $STAGINGAREA/nanobsd
	mkdir $STAGINGAREA/nanobsd/updates
	cp $PFSENSEOBJDIR/nanobsd.full.img $STAGINGAREA/nanobsd/ 2>/dev/null
	cp $PFSENSEOBJDIR/nanobsd.upgrade.img $STAGINGAREA/nanobsd/updates 2>/dev/null
	mv $STAGINGAREA/nanobsd/nanobsd.full.img $STAGINGAREA/nanobsd/$FILENAMEFULL 2>/dev/null
	mv $STAGINGAREA/nanobsd/updates/nanobsd.upgrade.img $STAGINGAREA/nanobsd/updates/$FILENAMEUPGRADE 2>/dev/null
	gzip $STAGINGAREA/nanobsd/$FILENAMEFULL 2>/dev/null
	gzip $STAGINGAREA/nanobsd/updates/$FILENAMEUPGRADE 2>/dev/null
	md5 $STAGINGAREA/nanobsd/$FILENAMEFULL.gz > $STAGINGAREA/nanobsd/$FILENAMEFULL.gz.md5 2>/dev/null
	md5 $STAGINGAREA/nanobsd/updates/$FILENAMEUPGRADE.gz > $STAGINGAREA/nanobsd/updates/$FILENAMEUPGRADE.gz.md5 2>/dev/null
	sha256 $STAGINGAREA/nanobsd/$FILENAMEFULL.gz > $STAGINGAREA/nanobsd/$FILENAMEFULL.gz.sha256 2>/dev/null
	sha256 $STAGINGAREA/nanobsd/updates/$FILENAMEUPGRADE.gz > $STAGINGAREA/nanobsd/updates/$FILENAMEUPGRADE.gz.sha256 2>/dev/null
}

copy_to_staging_nanobsd_updates() {
}

copy_to_staging_deviso_updates() {
	DATESTRING=`date "+%Y%m%d-%H%M"`
	mv $PFSENSEOBJDIR/pfSense.iso $STAGINGAREA/pfSense-Developers-${PFSENSE_VERSION}-${DATESTRING}.iso 2>/dev/null
	gzip $STAGINGAREA/pfSense-Developers-${PFSENSE_VERSION}-${DATESTRING}.iso 2>/dev/null
	md5 $STAGINGAREA/pfSense-Developers-${PFSENSE_VERSION}-${DATESTRING}.iso.gz > $STAGINGAREA/pfSense-Developers.iso.gz.md5 2>/dev/null
}

copy_to_staging_iso_updates() {
	cp $PFSENSEOBJDIR/pfSense-*.iso.* $STAGINGAREA/ 2>/dev/null
	cp $PFSENSEUPDATESDIR/*.tgz $STAGINGAREA/ 2>/dev/null
	cp $PFSENSEUPDATESDIR/*.tgz.md5 $STAGINGAREA/ 2>/dev/null
	cp $PFSENSEUPDATESDIR/*.tgz.sha256 $STAGINGAREA/ 2>/dev/null
}

copy_to_staging_embedded() {
	cp $PFSENSEOBJDIR/pfSense.img $STAGINGAREA/ 
	DATESTRING=`date "+%Y%m%d-%H%M"`
	rm -f $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${DATESTRING}.img.gz 2>/dev/null
	mv $STAGINGAREA/pfSense.img $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${DATESTRING}.img 2>/dev/null
	gzip $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${DATESTRING}.img 2>/dev/null
	md5 $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${DATESTRING}.img.gz > $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${DATESTRING}.img.gz.md5 2>/dev/null
	sha256 $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${DATESTRING}.img.gz > $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${DATESTRING}.img.gz.sha256 2>/dev/null
}

cp_files() {
	cp $STAGINGAREA/pfSense-*iso* $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/livecd_installer 2>/dev/null
	cp $STAGINGAREA/pfSense-*img* $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/embedded 2>/dev/null
	cp $STAGINGAREA/pfSense-*Update* $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/updates 2>/dev/null
}

check_for_congestion() {
	PINGTIME="999"
	PINGMAX="40"
	PINGIP="172.29.29.1"
	echo -n ">>> Waiting for Internet congestion to die down before rsync operations: $PINGTIME "
	while [ "$PINGTIME" -gt "$PINGMAX" ]; do
		PINGTIME=`ping -c1 $PINGIP | grep time | cut -d"=" -f4 | cut -d" " -f1 | cut -d"." -f1`
		echo -n " $PINGTIME"
		sleep 10
	done
	echo ""
}

scp_files() {
	RSYNCIP="172.29.29.181"
	RSYNCARGUMENTS="-ave ssh --bwlimit=50 --timeout=60 "
	date >$STAGINGAREA/version
	echo ">>> Copying files to snapshots.pfsense.org"
	if [ ! -f /usr/local/bin/rsync ]; then
		echo ">>> Could not find rsync, installing from ports..."
		(cd /usr/ports/net/rsync && make install clean)
	fi
	rm -f /tmp/ssh-snapshots*
	set +e
	# Ensure directory(s) are available
	ssh snapshots@${RSYNCIP} mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/livecd_installer
	ssh snapshots@${RSYNCIP} mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/embedded
	ssh snapshots@${RSYNCIP} mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/updates
	ssh snapshots@${RSYNCIP} mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/nanobsd	
	ssh snapshots@${RSYNCIP} rm -rf  /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/_updaters
	ssh snapshots@${RSYNCIP} mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/.updaters
	ssh snapshots@${RSYNCIP} chmod -R ug+rw /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/.
	check_for_congestion
	rsync $RSYNCARGUMENTS $STAGINGAREA/pfSense-*iso* snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/livecd_installer/
	check_for_congestion
	rsync $RSYNCARGUMENTS $STAGINGAREA/pfSense-*img* snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/embedded/
	check_for_congestion
	rsync $RSYNCARGUMENTS $STAGINGAREA/pfSense-*Update* snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/updates/
	check_for_congestion
	rsync $RSYNCARGUMENTS $STAGINGAREA/latest* snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/.updaters
	check_for_congestion
	rsync $RSYNCARGUMENTS $STAGINGAREA/version snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/.updaters/version
	check_for_congestion
	rsync $RSYNCARGUMENTS $STAGINGAREA/nanobsd/* snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/nanobsd/		
	rsync $RSYNCARGUMENTS $STAGINGAREA/nanobsd/updates/* snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/updates/			
	set -e
}

cleanup_builds() {
	# Remove prior builds
	echo ">>> Cleaning up after prior builds..."
	rm -rf /usr/obj*
	rm -rf $STAGINGAREA/*
	rm -f $PFSENSEUPDATESDIR/*  # Keep updates dir slimmed down
	if [ -d /home/pfsense/pfSense ]; then
		echo -n ">>> Clearing out previous pfSense checkout directory..."
		chflags -R noschg /home/pfsense/pfSense
		rm -rf /home/pfsense/pfSense
		echo "Done!"
	fi
	./clean_build.sh
}

build_loop_operations() {
	echo ">>> Starting build loop operations"
	# --- Items we need to run for a complete build run ---
	# Create extra structures
	create_webdata_structure
	# Cleanup prior builds
	cleanup_builds
	# Do the builds
	dobuilds
	# Make a local copy of the files.
	#cp_files
	# SCP files to snapshot web hosting area
	scp_files
	# Alert the world that we have some snapshots ready.
	post_tweet "Snapshots for FreeBSD_${FREEBSD_BRANCH}/pfSense-${PFSENSETAG} have been copied http://snapshots.pfsense.org/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/"
}

# Main builder loop - if you want to loop a build invoke build_snapshots_looped.sh
echo ">>> Execing pfsense-build.conf"
. $BUILDERSCRIPTS/pfsense-build.conf
build_loop_operations

