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
#
# This script glues together the various FreeSBIE style pieces of the 
# pfSense builder system and will build each style image: ISO, NanoBSD,
# DevISO, full update and NanoBSD updates and then copy the results of
# all the builds to the public facing WWW server.  This script will 
# invoke the scripts directly such as build_iso.sh and build_nano.sh, 
# etc.
#
# Crank up error reporting, debugging.
#  set -e
#  set -x

if [ ! -f ./pfsense-build.conf ]; then
	echo "You must first run ./set_version.sh !"
	exit 1
fi

# Local variables that are used by builder scripts
MAKEOBJDIRPREFIXFINAL=/tmp/builder/
PFSENSEOBJDIR=/usr/obj.pfSense
MAKEOBJDIRPREFIX=/usr/obj.pfSense
WEBDATAROOT=/usr/local/www/data
WEBROOT=/usr/local/www
SNAPSHOTSCRIPTSDIR=/root
STAGINGAREA=/tmp/staging
PFSENSEHOMEDIR=/home/pfsense
PFSENSECVSROOT=${PFSENSEHOMEDIR}/cvsroot
PFSENSECHECKOUTDIR=${PFSENSEHOMEDIR}/pfSense
PFSENSEUPDATESDIR=${MAKEOBJDIRPREFIXFINAL}/updates
TOOLDIR=${PFSENSEHOMEDIR}/tools
BUILDERSCRIPTS=${TOOLDIR}/builder_scripts

# Source pfSense / FreeSBIE variables
# *** DO NOT SOURCE BUILDER_COMMON.SH!
# *** IT WILL BREAK EVERYTHING FOR 
# *** SOME UNKNOWN LAYERING REASON.
# *** 04/07/2008, 11/04/2009                      
. $BUILDERSCRIPTS/pfsense_local.sh

# Ensure a fresh environment, please.
# rm -rf $PFSENSECVSROOT
# rm -rf $PFSENSECHECKOUTDIR

# Ensure directories exist
mkdir -p $PFSENSECVSROOT
mkdir -p $PFSENSECHECKOUTDIR
mkdir -p $STAGINGAREA
mkdir -p $WEBROOT

if [ -f /tmp/pfPorts_forced_build_required ]; then
	rm /tmp/pfPorts_forced_build_required
fi

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
	`/usr/local/bin/curl --silent --basic --user "$TWITTER_USERNAME:$TWITTER_PASSWORD" --data status="$TWEET_MESSAGE" http://twitter.com/statuses/update.xml` >/tmp/tweet_diag.txt 2>&1
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
	mkdir -p $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/nanobsd
	mkdir -p $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/virtualization
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
}

build_iso() {
	if [ "$DO_NOT_BUILD_ISO" != "" ]; then
		echo ">>> DO_NOT_BUILD_ISO is set, skipping."
		return
	fi
	# Ensures sane nevironment
	# and invokes build_iso.sh
	cd $BUILDERSCRIPTS
	./clean_build.sh
	./build_iso.sh
	if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
		BUILDTIME=`cat $PFSENSEBASEDIR/etc/version.buildtime`
		DATESTRING=`date -j -f "%a %b %e %T %Z %Y" "$BUILDTIME" "+%Y%m%d-%H%M"`
	else
		DATESTRING=`date "+%Y%m%d-%H%M"`
	fi
	gzip $MAKEOBJDIRPREFIXFINAL/pfSense.iso
	gzip $MAKEOBJDIRPREFIXFINAL/pfSense-memstick.img
	mv $MAKEOBJDIRPREFIXFINAL/pfSense.iso.gz $MAKEOBJDIRPREFIXFINAL/pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.iso.gz
	mv $MAKEOBJDIRPREFIXFINAL/pfSense-memstick.img.gz $MAKEOBJDIRPREFIXFINAL/pfSense-memstick-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz
	md5 $MAKEOBJDIRPREFIXFINAL/pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.iso.gz > $MAKEOBJDIRPREFIXFINAL/pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.iso.gz.md5
	md5 $MAKEOBJDIRPREFIXFINAL/pfSense-memstick-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz > $MAKEOBJDIRPREFIXFINAL/pfSense-memstick-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz.md5
	sha256 $MAKEOBJDIRPREFIXFINAL/pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.iso.gz > ${MAKEOBJDIRPREFIXFINAL}/pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.iso.gz.sha256	
	sha256 $MAKEOBJDIRPREFIXFINAL/pfSense-memstick-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz > ${MAKEOBJDIRPREFIXFINAL}/pfSense-memstick-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz.sha256	

	sha256 $MAKEOBJDIRPREFIXFINAL/pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.ova > ${MAKEOBJDIRPREFIXFINAL}/pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.ova.sha256	
	
}

build_ova() {
	cd $BUILDERSCRIPTS
	./clean_build.sh
	./build_ova.sh
}

build_deviso() {
	cd $BUILDERSCRIPTS
	./clean_build.sh
	./build_deviso.sh
}

build_embedded() {
	cd $BUILDERSCRIPTS 
	rm -rf /usr/obj*
	if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
		BUILDTIME=`cat $PFSENSEBASEDIR/etc/version.buildtime`
		DATESTRING=`date -j -f "%a %b %e %T %Z %Y" "$BUILDTIME" "+%Y%m%d-%H%M"`
	else
		DATESTRING=`date "+%Y%m%d-%H%M"`
	fi
	rm -f $MAKEOBJDIRPREFIXFINAL/pfSense-${DATESTRING}.img.gz
	./build_embedded.sh
}

build_embedded_updates() {
	cd $BUILDERSCRIPTS
	./build_updates_embedded.sh
}

build_updates() {
	if [ "$DO_NOT_BUILD_UPDATES" != "" ]; then
		echo ">>> DO_NOT_BUILD_UPDATES is set, skipping."
		return
	fi
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

	if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
		cp $PFSENSEBASEDIR/etc/version.buildtime $PFSENSEUPDATESDIR/version
	else
		date "+%a %b %d %T %Z %Y" > $PFSENSEUPDATESDIR/version
	fi
}

build_nano() {
	if [ "$DO_NOT_BUILD_NANOBSD" != "" ]; then
		echo ">>> DO_NOT_BUILD_NANOBSD is set, skipping."
		return
	fi
	cd $BUILDERSCRIPTS
	./clean_build.sh
	./build_nano.sh
}

rebuild_nano() {
	if [ "$DO_NOT_BUILD_NANOBSD" != "" ]; then
		echo ">>> DO_NOT_BUILD_NANOBSD is set, skipping."
		return
	fi
	cd $BUILDERSCRIPTS
	./build_resized_nano.sh $1
}

build_pfPorts() {
	if [ "$DO_NOT_BUILD_PFPORTS" != "" ]; then
		echo ">>> DO_NOT_BUILD_PFPORTS is set, skipping."
		return
	fi
	./build_pfPorts.sh
}

donanobuilds() {
	if [ "$DO_NOT_BUILD_NANOBSD" != "" ]; then
		echo ">>> DO_NOT_BUILD_NANOBSD is set, skipping."
		return
	fi
	# Build nanobsd
	build_nano
	copy_to_staging_nanobsd

	# Build all other sizes except the one just built.
	OLDSIZE=`cat /tmp/nanosize.txt`
	if [ "$OLDSIZE" != "512mb" ]; then
		rebuild_nano 512mb
		copy_to_staging_nanobsd
	fi

	if [ "$OLDSIZE" != "1g" ]; then
		rebuild_nano 1g
		copy_to_staging_nanobsd
	fi

	if [ "$OLDSIZE" != "2g" ]; then
		rebuild_nano 2g
		copy_to_staging_nanobsd
	fi

	if [ "$OLDSIZE" != "4g" ]; then
		rebuild_nano 4g
		copy_to_staging_nanobsd
	fi

#	Don't really build these yet for normal snaps, but leave the code here in case we need it.
#	if [ "$OLDSIZE" != "8g" ]; then
#		rebuild_nano 8g
#		copy_to_staging_nanobsd
#	fi
#
#	if [ "$OLDSIZE" != "16g" ]; then
#		rebuild_nano 16g
#		copy_to_staging_nanobsd
#	fi
}

dobuilds() {
	cd $BUILDERSCRIPTS
	# Update sources and build iso
	update_sources
	# Rebuild pfPorts if needed
	build_pfPorts
	# Build ISO
	build_iso
	# Update sources
	build_updates
	# Copy files before embedded, it wipes out usr.obj*
	copy_to_staging_iso_updates
	# Build nanobsd
	donanobuilds	
}

copy_staging_ova() {
	if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
		BUILDTIME=`cat $PFSENSEBASEDIR/etc/version.buildtime`
		DATESTRING=`date -j -f "%a %b %e %T %Z %Y" "$BUILDTIME" "+%Y%m%d-%H%M"`
	else
		DATESTRING=`date "+%Y%m%d-%H%M"`
	fi
	FILENAMEFULL="pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.ova"
	mkdir -p $STAGINGAREA/virtualization
	mv $MAKEOBJDIRPREFIXFINAL/pfSense.ova $MAKEOBJDIRPREFIXFINAL/$FILENAMEFULL 2>/dev/null
	cp $MAKEOBJDIRPREFIXFINAL/$FILENAMEFULL $STAGINGAREA/virtualization/
	if [ -f $STAGINGAREA/nanobsd/$FILENAMEFULL.gz ]; then
		sha256 $STAGINGAREA/virtualization/$FILENAMEFULL > $STAGINGAREA/virtualization/$FILENAMEFULL.sha256 2>/dev/null
	fi
}

copy_to_staging_nanobsd() {
	cd $BUILDERSCRIPTS
	if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
		BUILDTIME=`cat $PFSENSEBASEDIR/etc/version.buildtime`
		DATESTRING=`date -j -f "%a %b %e %T %Z %Y" "$BUILDTIME" "+%Y%m%d-%H%M"`
	else
		DATESTRING=`date "+%Y%m%d-%H%M"`
	fi
	if [ ! -f /tmp/nanosize.txt ]; then
		echo "1g" > /tmp/nanosize.txt
	fi
	FILESIZE=`cat /tmp/nanosize.txt`
	FILENAMEFULL="pfSense-${PFSENSE_VERSION}-${FILESIZE}-${ARCH}-${DATESTRING}-nanobsd.img"
	FILENAMEUPGRADE="pfSense-${PFSENSE_VERSION}-${FILESIZE}-${ARCH}-${DATESTRING}-nanobsd-upgrade.img"
	mkdir -p $STAGINGAREA/nanobsd
	mkdir -p $STAGINGAREA/nanobsdupdates

	mv $MAKEOBJDIRPREFIXFINAL/nanobsd.full.img $MAKEOBJDIRPREFIXFINAL/$FILENAMEFULL 2>/dev/null
	mv $MAKEOBJDIRPREFIXFINAL/nanobsd.upgrade.img $MAKEOBJDIRPREFIXFINAL/$FILENAMEUPGRADE 2>/dev/null
	gzip $MAKEOBJDIRPREFIXFINAL/$FILENAMEFULL 2>/dev/null
	gzip $MAKEOBJDIRPREFIXFINAL/$FILENAMEUPGRADE 2>/dev/null
	cp $MAKEOBJDIRPREFIXFINAL/$FILENAMEFULL.gz $STAGINGAREA/nanobsd/ 2>/dev/null
	cp $MAKEOBJDIRPREFIXFINAL/$FILENAMEUPGRADE.gz $STAGINGAREA/nanobsdupdates 2>/dev/null

	if [ -f $STAGINGAREA/nanobsd/$FILENAMEFULL.gz ]; then
		md5 $STAGINGAREA/nanobsd/$FILENAMEFULL.gz > $STAGINGAREA/nanobsd/$FILENAMEFULL.gz.md5 2>/dev/null
		sha256 $STAGINGAREA/nanobsd/$FILENAMEFULL.gz > $STAGINGAREA/nanobsd/$FILENAMEFULL.gz.sha256 2>/dev/null
	fi
	if [ -f $STAGINGAREA/nanobsdupdates/$FILENAMEUPGRADE.gz ]; then
		md5 $STAGINGAREA/nanobsdupdates/$FILENAMEUPGRADE.gz > $STAGINGAREA/nanobsdupdates/$FILENAMEUPGRADE.gz.md5 2>/dev/null
		sha256 $STAGINGAREA/nanobsdupdates/$FILENAMEUPGRADE.gz > $STAGINGAREA/nanobsdupdates/$FILENAMEUPGRADE.gz.sha256 2>/dev/null
	fi

	# Copy NanoBSD auto update:
	if [ -f $STAGINGAREA/nanobsdupdates/$FILENAMEUPGRADE.gz ]; then
		cp $STAGINGAREA/nanobsdupdates/$FILENAMEUPGRADE.gz $STAGINGAREA/latest-nanobsd-$FILESIZE.img.gz 2>/dev/null
		sha256 $STAGINGAREA/latest-nanobsd-$FILESIZE.img.gz > $STAGINGAREA/latest-nanobsd-$FILESIZE.img.gz.sha256 2>/dev/null
		cp $PFSENSEBASEDIR/etc/version.buildtime $STAGINGAREA/version-nanobsd-$FILESIZE
	fi
}

copy_to_staging_nanobsd_updates() {
	cd $BUILDERSCRIPTS	
}

copy_to_staging_deviso_updates() {
	cd $BUILDERSCRIPTS	
	if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
		BUILDTIME=`cat $PFSENSEBASEDIR/etc/version.buildtime`
		DATESTRING=`date -j -f "%a %b %e %T %Z %Y" "$BUILDTIME" "+%Y%m%d-%H%M"`
	else
		DATESTRING=`date "+%Y%m%d-%H%M"`
	fi
	mv $MAKEOBJDIRPREFIXFINAL/pfSense.iso $STAGINGAREA/pfSense-Developers-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.iso 2>/dev/null
	gzip $STAGINGAREA/pfSense-Developers-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.iso 2>/dev/null
	md5 $STAGINGAREA/pfSense-Developers-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.iso.gz > $STAGINGAREA/pfSense-Developers.iso.gz.md5 2>/dev/null
}

copy_to_staging_iso_updates() {
	cd $BUILDERSCRIPTS
	# Copy ISOs
	cp $MAKEOBJDIRPREFIXFINAL/pfSense-*.iso $STAGINGAREA/ 2>/dev/null
	cp $MAKEOBJDIRPREFIXFINAL/pfSense-*.iso.* $STAGINGAREA/ 2>/dev/null
	# Copy memstick items
	cp $MAKEOBJDIRPREFIXFINAL/pfSense-memstick*.img $STAGINGAREA/ 2>/dev/null
	cp $MAKEOBJDIRPREFIXFINAL/pfSense-memstick*.img* $STAGINGAREA/ 2>/dev/null
	# Old updates, might be able to remove this.
	cp $MAKEOBJDIRPREFIXFINAL/*.tgz $STAGINGAREA/ 2>/dev/null
	cp $MAKEOBJDIRPREFIXFINAL/*.tgz.md5 $STAGINGAREA/ 2>/dev/null
	cp $MAKEOBJDIRPREFIXFINAL/*.tgz.sha256 $STAGINGAREA/ 2>/dev/null
	# Copy updates
	cp $PFSENSEUPDATESDIR/version $STAGINGAREA/ 2>/dev/null
	cp $PFSENSEUPDATESDIR/*.tgz $STAGINGAREA/ 2>/dev/null
	cp $PFSENSEUPDATESDIR/*.tgz.md5 $STAGINGAREA/ 2>/dev/null
	cp $PFSENSEUPDATESDIR/*.tgz.sha256 $STAGINGAREA/ 2>/dev/null
}

copy_to_staging_embedded() {
	cd $BUILDERSCRIPTS
	cp $MAKEOBJDIRPREFIXFINAL/pfSense.img $STAGINGAREA/ 
	if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
		BUILDTIME=`cat $PFSENSEBASEDIR/etc/version.buildtime`
		DATESTRING=`date -j -f "%a %b %e %T %Z %Y" "$BUILDTIME" "+%Y%m%d-%H%M"`
	else
		DATESTRING=`date "+%Y%m%d-%H%M"`
	fi
	rm -f $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz 2>/dev/null
	mv $STAGINGAREA/pfSense.img $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img 2>/dev/null
	gzip $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img 2>/dev/null
	md5 $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz > $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz.md5 2>/dev/null
	sha256 $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz > $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz.sha256 2>/dev/null
}

cp_files() {
	cd $BUILDERSCRIPTS
	cp $STAGINGAREA/pfSense-*iso* $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/livecd_installer 2>/dev/null
	cp $STAGINGAREA/pfSense-*img* $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/embedded 2>/dev/null
	cp $STAGINGAREA/pfSense-*Update* $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/updates 2>/dev/null
}

check_for_congestion() {
	cd $BUILDERSCRIPTS
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
	cd $BUILDERSCRIPTS
	RSYNCIP="172.29.29.249"
	if [ -z "${RSYNC_COPY_ARGUMENTS:-}" ]; then
		RSYNC_COPY_ARGUMENTS="-ave ssh --timeout=60" #--bwlimit=50
	fi
	echo ">>> Copying files to snapshots.pfsense.org"
	if [ ! -f /usr/local/bin/rsync ]; then
		echo ">>> Could not find rsync, installing from ports..."
		(cd /usr/ports/net/rsync && make install clean)
	fi
	rm -f /tmp/ssh-snapshots*
	set +e
	# Ensure directory(s) are available
	ssh snapshots@${RSYNCIP} "mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/livecd_installer"
	ssh snapshots@${RSYNCIP} "mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/embedded"
	ssh snapshots@${RSYNCIP} "mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/updates"
	ssh snapshots@${RSYNCIP} "mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/nanobsd"
	ssh snapshots@${RSYNCIP} "mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/virtualization"
	ssh snapshots@${RSYNCIP} "mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/.updaters"
	ssh snapshots@${RSYNCIP} "chmod -R ug+rw /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/."
	ssh snapshots@${RSYNCIP} "chmod -R ug+rw /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/."
	ssh snapshots@${RSYNCIP} "chmod -R ug+rw /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/*/."
	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/pfSense-*iso* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/livecd_installer/
	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/pfSense-memstick* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/livecd_installer/
	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/pfSense-*Update* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/updates/
	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/latest* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/.updaters
	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/version* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/.updaters
	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/nanobsd/* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/nanobsd/
	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/nanobsdupdates/* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/updates/
	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/virtualization/* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/virtualization/
	set -e
}

cleanup_builds() {
	cd $BUILDERSCRIPTS
	# Remove prior builds
	echo ">>> Cleaning up after prior builds..."
	rm -rf /usr/obj*
	rm -rf $STAGINGAREA/*
	rm -f $PFSENSEUPDATESDIR/*  # Keep updates dir slimmed down
	rm -rf $MAKEOBJDIRPREFIXFINAL/*
	if [ -d /home/pfsense/pfSense ]; then
		echo -n ">>> Clearing out previous pfSense checkout directory..."
		chflags -R noschg /home/pfsense/pfSense
		rm -rf /home/pfsense/pfSense
		echo "Done!"
	fi
	rm -f /tmp/version.buildtime
	./clean_build.sh
}

build_loop_operations() {
	cd $BUILDERSCRIPTS
	echo ">>> Starting build loop operations"
	# --- Items we need to run for a complete build run ---
	# Create extra structures
	create_webdata_structure
	# Cleanup prior builds
	cleanup_builds
	# Do the builds
	dobuilds
	# SCP files to snapshot web hosting area
	scp_files
	# Alert the world that we have some snapshots ready.
	post_tweet "Snapshots for FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense-${PFSENSETAG} have been copied http://snapshots.pfsense.org/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/pfSense_${PFSENSETAG}/"
}

# Main builder loop - if you want to loop a build invoke build_snapshots_looped.sh
echo ">>> Execing pfsense-build.conf"
. $BUILDERSCRIPTS/pfsense-build.conf
build_loop_operations

