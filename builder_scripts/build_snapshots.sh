#!/bin/sh
#
# ${PRODUCT_NAME} snapshot building system
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
# ${PRODUCT_NAME} builder system and will build each style image: ISO, NanoBSD,
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
PFSENSEOBJDIR=/usr/obj.${PRODUCT_NAME}
MAKEOBJDIRPREFIX=/usr/obj.${PRODUCT_NAME}
WEBDATAROOT=/usr/local/www/data
WEBROOT=/usr/local/www
SNAPSHOTSCRIPTSDIR=/root
STAGINGAREA=/tmp/staging
PFSENSEHOMEDIR=/home/pfsense
PFSENSECVSROOT=${PFSENSEHOMEDIR}/cvsroot
PFSENSECHECKOUTDIR=${PFSENSEHOMEDIR}/${PRODUCT_NAME}
PFSENSEUPDATESDIR=${MAKEOBJDIRPREFIXFINAL}/updates
TOOLDIR=${PFSENSEHOMEDIR}/tools
BUILDERSCRIPTS=${TOOLDIR}/builder_scripts
RSYNCIP="snapshots.pfsense.org"
RSYNCKBYTELIMIT="480"
PINGTIME="999"
PINGMAX="40"
PINGIP="snapshots.pfsense.org"

# Source ${PRODUCT_NAME} / FreeSBIE variables
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

create_webdata_structure() {
	mkdir -p $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/${PRODUCT_NAME}_${PFSENSETAG}/livecd_installer
	mkdir -p $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/${PRODUCT_NAME}_${PFSENSETAG}/embedded
	mkdir -p $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/${PRODUCT_NAME}_${PFSENSETAG}/updates 
	mkdir -p $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/${PRODUCT_NAME}_${PFSENSETAG}/nanobsd
	mkdir -p $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/${PRODUCT_NAME}_${PFSENSETAG}/virtualization
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
	if [ "${DATESTRING}" = "" ]; then
		if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
			BUILDTIME=`cat $PFSENSEBASEDIR/etc/version.buildtime`
			DATESTRING=`date -j -f "%a %b %e %T %Z %Y" "$BUILDTIME" "+%Y%m%d-%H%M"`
		else
			DATESTRING=`date "+%Y%m%d-%H%M"`
		fi
	fi

	# Ensure the images are compressed.
	if [ -f ${ISOPATH} ]; then
		gzip ${ISOPATH}
	fi
	if [ -f ${ISOPATH}.gz ]; then
		ISOPATH=${ISOPATH}.gz
	fi
	md5 ${ISOPATH} > ${ISOPATH}.md5
	sha256 ${ISOPATH} > ${ISOPATH}.sha256

	if [ -f ${MEMSTICKPATH} ]; then
		gzip ${MEMSTICKPATH}
	fi
	if [ -f ${MEMSTICKPATH}.gz ]; then
		MEMSTICKPATH=${MEMSTICKPATH}.gz
	fi
	md5 ${MEMSTICKPATH} > ${MEMSTICKPATH}.md5
	sha256 ${MEMSTICKPATH} > ${MEMSTICKPATH}.sha256

	if [ -f ${MEMSTICKSERIALPATH} ]; then
		gzip ${MEMSTICKSERIALPATH}
	fi
	if [ -f ${MEMSTICKSERIALPATH}.gz ]; then
		MEMSTICKSERIALPATH=${MEMSTICKSERIALPATH}.gz
	fi
	md5 ${MEMSTICKSERIALPATH} > ${MEMSTICKSERIALPATH}.md5
	sha256 ${MEMSTICKSERIALPATH} > ${MEMSTICKSERIALPATH}.sha256
}

build_ova() {
	cd $BUILDERSCRIPTS
	./clean_build.sh
	./build_ova.sh
	copy_staging_ova
}

build_deviso() {
	cd $BUILDERSCRIPTS
	./clean_build.sh
	./build_deviso.sh
}

build_embedded() {
	cd $BUILDERSCRIPTS 
	rm -rf /usr/obj*
	if [ "${DATESTRING}" = "" ]; then
		if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
			BUILDTIME=`cat $PFSENSEBASEDIR/etc/version.buildtime`
			DATESTRING=`date -j -f "%a %b %e %T %Z %Y" "$BUILDTIME" "+%Y%m%d-%H%M"`
		else
			DATESTRING=`date "+%Y%m%d-%H%M"`
		fi
	fi
	rm -f $MAKEOBJDIRPREFIXFINAL/${PRODUCT_NAME}-${DATESTRING}.img.gz
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
	if [ -z "${NANO_WITH_VGA}" ]; then
		./build_nano.sh
	else
		./build_nano.sh -g
	fi
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
	# Set a common DATESTRING for the build.
	if [ "${DATESTRING}" = "" ]; then
		if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
			BUILDTIME=`cat $PFSENSEBASEDIR/etc/version.buildtime`
			export DATESTRING=`date -j -f "%a %b %e %T %Z %Y" "$BUILDTIME" "+%Y%m%d-%H%M"`
		else
			export DATESTRING=`date "+%Y%m%d-%H%M"`
		fi
	fi
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
	# Do the NanoBSD+VGA builds too
	export NANO_WITH_VGA=yes
	donanobuilds
	# build ova
	build_ova
}

copy_staging_ova() {
	if [ "${DATESTRING}" = "" ]; then
		if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
			BUILDTIME=`cat $PFSENSEBASEDIR/etc/version.buildtime`
			DATESTRING=`date -j -f "%a %b %e %T %Z %Y" "$BUILDTIME" "+%Y%m%d-%H%M"`
		else
			DATESTRING=`date "+%Y%m%d-%H%M"`
		fi
	fi
	FILENAMEFULL="${PRODUCT_NAME}-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.ova"
	mkdir -p $STAGINGAREA/virtualization
	mv $MAKEOBJDIRPREFIXFINAL/${PRODUCT_NAME}.ova $MAKEOBJDIRPREFIXFINAL/$FILENAMEFULL 2>/dev/null
	cp $MAKEOBJDIRPREFIXFINAL/$FILENAMEFULL $STAGINGAREA/virtualization/
	if [ -f $STAGINGAREA/virtualization/$FILENAMEFULL ]; then
		chmod a+r $STAGINGAREA/virtualization/$FILENAMEFULL
		sha256 $STAGINGAREA/virtualization/$FILENAMEFULL > $STAGINGAREA/virtualization/$FILENAMEFULL.sha256 2>/dev/null
	fi
}

copy_to_staging_nanobsd() {
	cd $BUILDERSCRIPTS
	if [ "${DATESTRING}" = "" ]; then
		if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
			BUILDTIME=`cat $PFSENSEBASEDIR/etc/version.buildtime`
			DATESTRING=`date -j -f "%a %b %e %T %Z %Y" "$BUILDTIME" "+%Y%m%d-%H%M"`
		else
			DATESTRING=`date "+%Y%m%d-%H%M"`
		fi
	fi
	if [ ! -f /tmp/nanosize.txt ]; then
		echo "1g" > /tmp/nanosize.txt
	fi
	FILESIZE=`cat /tmp/nanosize.txt`

	if [ -n "${NANO_WITH_VGA}" ]; then
		_VGA="_vga"
	fi

	FILENAMEFULL="${PRODUCT_NAME}-${PFSENSE_VERSION}-${FILESIZE}-${ARCH}-nanobsd${_VGA}-${DATESTRING}.img"
	FILENAMEUPGRADE="${PRODUCT_NAME}-${PFSENSE_VERSION}-${FILESIZE}-${ARCH}-nanobsd${_VGA}-upgrade-${DATESTRING}.img"
	mkdir -p $STAGINGAREA/nanobsd
	mkdir -p $STAGINGAREA/nanobsdupdates

	mv $MAKEOBJDIRPREFIXFINAL/nanobsd${_VGA}.full.img $MAKEOBJDIRPREFIXFINAL/$FILENAMEFULL 2>/dev/null
	mv $MAKEOBJDIRPREFIXFINAL/nanobsd${_VGA}.upgrade.img $MAKEOBJDIRPREFIXFINAL/$FILENAMEUPGRADE 2>/dev/null
	gzip $MAKEOBJDIRPREFIXFINAL/$FILENAMEFULL 2>/dev/null
	gzip $MAKEOBJDIRPREFIXFINAL/$FILENAMEUPGRADE 2>/dev/null

	# Fix names now that they're actually compressed.
	FILENAMEFULL=${FILENAMEFULL}.gz
	FILENAMEUPGRADE=${FILENAMEUPGRADE}.gz

	cp $MAKEOBJDIRPREFIXFINAL/$FILENAMEFULL $STAGINGAREA/nanobsd/ 2>/dev/null
	cp $MAKEOBJDIRPREFIXFINAL/$FILENAMEUPGRADE $STAGINGAREA/nanobsdupdates 2>/dev/null

	if [ -f $STAGINGAREA/nanobsd/$FILENAMEFULL ]; then
		md5 $STAGINGAREA/nanobsd/$FILENAMEFULL > $STAGINGAREA/nanobsd/$FILENAMEFULL.md5 2>/dev/null
		sha256 $STAGINGAREA/nanobsd/$FILENAMEFULL > $STAGINGAREA/nanobsd/$FILENAMEFULL.sha256 2>/dev/null
	fi
	if [ -f $STAGINGAREA/nanobsdupdates/$FILENAMEUPGRADE ]; then
		md5 $STAGINGAREA/nanobsdupdates/$FILENAMEUPGRADE > $STAGINGAREA/nanobsdupdates/$FILENAMEUPGRADE.md5 2>/dev/null
		sha256 $STAGINGAREA/nanobsdupdates/$FILENAMEUPGRADE > $STAGINGAREA/nanobsdupdates/$FILENAMEUPGRADE.sha256 2>/dev/null
	fi

	# Copy NanoBSD auto update:
	if [ -f $STAGINGAREA/nanobsdupdates/$FILENAMEUPGRADE ]; then
		if [ -n "${_VGA}" ]; then
			_VGA="-vga"
		fi
		cp $STAGINGAREA/nanobsdupdates/$FILENAMEUPGRADE $STAGINGAREA/latest-nanobsd${_VGA}-$FILESIZE.img.gz 2>/dev/null
		sha256 $STAGINGAREA/latest-nanobsd${_VGA}-$FILESIZE.img.gz > $STAGINGAREA/latest-nanobsd${_VGA}-$FILESIZE.img.gz.sha256 2>/dev/null
		cp $PFSENSEBASEDIR/etc/version.buildtime $STAGINGAREA/version-nanobsd${_VGA}-$FILESIZE
	fi
}

copy_to_staging_nanobsd_updates() {
	cd $BUILDERSCRIPTS	
}

copy_to_staging_deviso_updates() {
	cd $BUILDERSCRIPTS	
	if [ "${DATESTRING}" = "" ]; then
		if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
			BUILDTIME=`cat $PFSENSEBASEDIR/etc/version.buildtime`
			DATESTRING=`date -j -f "%a %b %e %T %Z %Y" "$BUILDTIME" "+%Y%m%d-%H%M"`
		else
			DATESTRING=`date "+%Y%m%d-%H%M"`
		fi
	fi
	mv $MAKEOBJDIRPREFIXFINAL/${PRODUCT_NAME}.iso $STAGINGAREA/${PRODUCT_NAME}-Developers-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.iso 2>/dev/null
	gzip $STAGINGAREA/${PRODUCT_NAME}-Developers-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.iso 2>/dev/null
	md5 $STAGINGAREA/${PRODUCT_NAME}-Developers-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.iso.gz > $STAGINGAREA/${PRODUCT_NAME}-Developers.iso.gz.md5 2>/dev/null
}

copy_to_staging_iso_updates() {
	cd $BUILDERSCRIPTS
	# Copy ISOs
	cp $MAKEOBJDIRPREFIXFINAL/${PRODUCT_NAME}-*.iso $STAGINGAREA/ 2>/dev/null
	cp $MAKEOBJDIRPREFIXFINAL/${PRODUCT_NAME}-*.iso.* $STAGINGAREA/ 2>/dev/null
	# Copy memstick items
	cp $MAKEOBJDIRPREFIXFINAL/${PRODUCT_NAME}-memstick*.img $STAGINGAREA/ 2>/dev/null
	cp $MAKEOBJDIRPREFIXFINAL/${PRODUCT_NAME}-memstick*.img* $STAGINGAREA/ 2>/dev/null
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
	cp $MAKEOBJDIRPREFIXFINAL/${PRODUCT_NAME}.img $STAGINGAREA/ 
	if [ "${DATESTRING}" = "" ]; then
		if [ -f $PFSENSEBASEDIR/etc/version.buildtime ]; then
			BUILDTIME=`cat $PFSENSEBASEDIR/etc/version.buildtime`
			DATESTRING=`date -j -f "%a %b %e %T %Z %Y" "$BUILDTIME" "+%Y%m%d-%H%M"`
		else
			DATESTRING=`date "+%Y%m%d-%H%M"`
		fi
	fi
	rm -f $STAGINGAREA/${PRODUCT_NAME}-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz 2>/dev/null
	mv $STAGINGAREA/${PRODUCT_NAME}.img $STAGINGAREA/${PRODUCT_NAME}-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img 2>/dev/null
	gzip $STAGINGAREA/${PRODUCT_NAME}-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img 2>/dev/null
	md5 $STAGINGAREA/${PRODUCT_NAME}-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz > $STAGINGAREA/${PRODUCT_NAME}-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz.md5 2>/dev/null
	sha256 $STAGINGAREA/${PRODUCT_NAME}-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz > $STAGINGAREA/${PRODUCT_NAME}-${PFSENSE_VERSION}-${ARCH}-${DATESTRING}.img.gz.sha256 2>/dev/null
}

cp_files() {
	cd $BUILDERSCRIPTS
	cp $STAGINGAREA/${PRODUCT_NAME}-*iso* $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/${PRODUCT_NAME}_${PFSENSETAG}/livecd_installer 2>/dev/null
	cp $STAGINGAREA/${PRODUCT_NAME}-*img* $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/${PRODUCT_NAME}_${PFSENSETAG}/embedded 2>/dev/null
	cp $STAGINGAREA/${PRODUCT_NAME}-*Update* $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/${PRODUCT_NAME}_${PFSENSETAG}/updates 2>/dev/null
}

check_for_congestion() {
	cd $BUILDERSCRIPTS
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
	if [ -z "${RSYNC_COPY_ARGUMENTS:-}" ]; then
		RSYNC_COPY_ARGUMENTS="-ave ssh --timeout=60 --bwlimit=${RSYNCKBYTELIMIT}" #--bwlimit=50
	fi
	echo ">>> Copying files to snapshots.pfsense.org"
	if [ ! -f /usr/local/bin/rsync ]; then
		echo ">>> Could not find rsync, installing from ports..."
		(cd /usr/ports/net/rsync && make install clean)
	fi
	rm -f /tmp/ssh-snapshots*
	set +e
	# Ensure directory(s) are available
	ssh snapshots@${RSYNCIP} "mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/livecd_installer"
	ssh snapshots@${RSYNCIP} "mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/embedded"
	ssh snapshots@${RSYNCIP} "mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/updates"
	ssh snapshots@${RSYNCIP} "mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/nanobsd"
	ssh snapshots@${RSYNCIP} "mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/virtualization"
	ssh snapshots@${RSYNCIP} "mkdir -p /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/.updaters"
	# ensure permissions are correct for r+w
	ssh snapshots@${RSYNCIP} "chmod -R ug+rw /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/."
	ssh snapshots@${RSYNCIP} "chmod -R ug+rw /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/."
	ssh snapshots@${RSYNCIP} "chmod -R ug+rw /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/*/."
	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/${PRODUCT_NAME}-*iso* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/livecd_installer/
	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/${PRODUCT_NAME}-memstick* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/livecd_installer/
	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/${PRODUCT_NAME}-*Update* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/updates/
	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/nanobsd/* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/nanobsd/
	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/nanobsdupdates/* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/updates/
	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/virtualization/* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/virtualization/
	check_for_congestion

	# Rather than copy these twice, use ln to link to the latest one.

	ssh snapshots@${RSYNCIP} "rm -f /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/.updaters/latest.tgz"
	ssh snapshots@${RSYNCIP} "rm -f /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/.updaters/latest.tgz.sha256"

	LATESTFILENAME="`ls $PFSENSEUPDATESDIR/*.tgz | grep Full | grep -v md5 | grep -v sha256 | tail -n1`"
	LATESTFILENAME=`basename ${LATESTFILENAME}`
	ssh snapshots@${RSYNCIP} "ln -s /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/updates/${LATESTFILENAME} \
		/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/.updaters/latest.tgz"
	ssh snapshots@${RSYNCIP} "ln -s /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/updates/${LATESTFILENAME}.sha256 \
		/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/.updaters/latest.tgz.sha256"

	for i in 512mb 1g 2g 4g
	do
		ssh snapshots@${RSYNCIP} "rm -f /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/.updaters/latest-nanobsd-${i}.img.gz"
		ssh snapshots@${RSYNCIP} "rm -f /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/.updaters/latest-nanobsd-${i}.img.gz.sha256"
		ssh snapshots@${RSYNCIP} "rm -f /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/.updaters/latest-nanobsd-vga-${i}.img.gz"
		ssh snapshots@${RSYNCIP} "rm -f /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/.updaters/latest-nanobsd-vga-${i}.img.gz.sha256"

		FILENAMEUPGRADE="${PRODUCT_NAME}-${PFSENSE_VERSION}-${i}-${ARCH}-nanobsd-upgrade-${DATESTRING}.img.gz"
		ssh snapshots@${RSYNCIP} "ln -s /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/updates/${FILENAMEUPGRADE} \
			/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/.updaters/latest-nanobsd-${i}.img.gz"
		ssh snapshots@${RSYNCIP} "ln -s /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/updates/${FILENAMEUPGRADE}.sha256 \
			/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/.updaters/latest-nanobsd-${i}.img.gz.sha256"

		FILENAMEUPGRADE="${PRODUCT_NAME}-${PFSENSE_VERSION}-${i}-${ARCH}-nanobsd-vga-upgrade-${DATESTRING}.img.gz"
		ssh snapshots@${RSYNCIP} "ln -s /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/updates/${FILENAMEUPGRADE} \
			/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/.updaters/latest-nanobsd-vga-${i}.img.gz"
		ssh snapshots@${RSYNCIP} "ln -s /usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/updates/${FILENAMEUPGRADE}.sha256 \
			/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/.updaters/latest-nanobsd-vga-${i}.img.gz.sha256"
	done

	check_for_congestion
	rsync $RSYNC_COPY_ARGUMENTS $STAGINGAREA/version* \
		snapshots@${RSYNCIP}:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/.updaters
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
	if [ -d /home/pfsense/${PRODUCT_NAME} ]; then
		echo -n ">>> Clearing out previous ${PRODUCT_NAME} checkout directory..."
		chflags -R noschg /home/pfsense/${PRODUCT_NAME}
		rm -rf /home/pfsense/${PRODUCT_NAME}
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
	post_tweet "Snapshots for FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}-${PFSENSETAG} have been copied http://snapshots.pfsense.org/FreeBSD_${FREEBSD_BRANCH}/${ARCH}/${PRODUCT_NAME}_${PFSENSETAG}/"
}

# Main builder loop - if you want to loop a build invoke build_snapshots_looped.sh
echo ">>> Execing pfsense-build.conf"
. $BUILDERSCRIPTS/pfsense-build.conf
build_loop_operations

