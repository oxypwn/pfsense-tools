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

if [ ! -f ./pfsense-build.conf ]; then
	echo "You must first run ./set_version.sh !"
	exit 1
fi

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

if [ -f /tmp/pfSense_do_not_build_pfPorts ]; then
	echo "--> Removing /tmp/pfSense_do_not_build_pfPorts..."
	rm /tmp/pfSense_do_not_build_pfPorts
fi

sync_cvs() {
	# Sync with pfsense.org
	echo ">>> Syncing with pfSense.org"
	/usr/bin/csup -b $CVS_CO_DIR $BUILDERSCRIPTS/pfSense-supfile
	/usr/bin/csup -b $FREESBIE_PATH $BUILDERSCRIPTS/freesbie2-supfile
	cd $BUILDERSCRIPTS && cvs up -d
}

create_webdata_structure() {
	mkdir -p $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/updates
	mkdir -p $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/iso 
	mkdir -p $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/embedded 
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
	./cvsup_current
	touch /tmp/pfSense_do_not_build_pfPorts
	gzip $PFSENSEOBJDIR/pfSense.iso
	mv $PFSENSEOBJDIR/pfSense.iso.gz $PFSENSEOBJDIR/pfSense-${PFSENSE_VERSION}-`date "+%Y%m%d-%H%M"`.iso.gz
	md5 $PFSENSEOBJDIR/pfSense-${PFSENSE_VERSION}-`date "+%Y%m%d-%H%M"`.iso.gz > $PFSENSEOBJDIR/pfSense-${PFSENSE_VERSION}-`date "+%Y%m%d-%H%M"`.iso.gz.md5
	sha256 $PFSENSEOBJDIR/pfSense-${PFSENSE_VERSION}-`date "+%Y%m%d-%H%M"`.iso.gz > ${PFSENSEOBJDIR}/pfSense-${PFSENSE_VERSION}-`date "+%Y%m%d-%H%M"`.iso.gz.sha256
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
	cp $PFSENSEUPDATESDIR/*.tgz.sha256 $STAGINGAREA/
}

copy_to_staging_embedded() {
	cp $PFSENSEOBJDIR/pfSense.img $STAGINGAREA/ 
	DATESTRING=`date "+%Y%m%d-%H%M"`
	rm -f $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${DATESTRING}.img.gz
	mv $STAGINGAREA/pfSense.img $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${DATESTRING}.img
	gzip $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${DATESTRING}.img
	md5 $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${DATESTRING}.img.gz > $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${DATESTRING}.img.gz.md5
	sha256 $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${DATESTRING}.img.gz > $STAGINGAREA/pfSense-${PFSENSE_VERSION}-${DATESTRING}.img.gz.sha256
}

cp_files() {
	cp $STAGINGAREA/pfSense-*.iso* $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/
	cp $STAGINGAREA/pfSense-*.img* $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/
	cp $STAGINGAREA/*.gz $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/
	cp $STAGINGAREA/*.tgz $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/
	cp $STAGINGAREA/*.tgz.md5 $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/
	cp $STAGINGAREA/*.tgz.sha256 $WEBDATAROOT/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/
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
	rsync -ave ssh --timeout=60 $STAGINGAREA/pfSense-*.tgz snapshots@172.29.29.181:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/
	rsync -ave ssh --timeout=60 $STAGINGAREA/pfSense-*.gz snapshots@172.29.29.181:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/
	rsync -ave ssh --timeout=60 $STAGINGAREA/*.md5 snapshots@172.29.29.181:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/
	rsync -ave ssh --timeout=60 $STAGINGAREA/*.sha256 snapshots@172.29.29.181:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/
	rsync -ave ssh --timeout=60 $STAGINGAREA/latest* snapshots@172.29.29.181:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/_updaters
	rsync -ave ssh --timeout=60 $STAGINGAREA/version snapshots@172.29.29.181:/usr/local/www/snapshots/FreeBSD_${FREEBSD_BRANCH}/pfSense_${PFSENSETAG}/_updaters/version
	set -e
}

cleanup_builds() {
	# Remove prior builds
	echo ">>> Cleaning up after prior builds..."
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
	echo ">>> Starting build loop operations"
	# --- Items we need to run for a complete build run ---
	# Create extra structures
	create_webdata_structure
	# Cleanup prior builds
	cleanup_builds
	# Do the builds
	dobuilds
	# Copy/SCP images
	cp_files
	scp_files
}

# Main builder loop - lets do this forever until the cows come home.
while [ /bin/true ]; do
	echo ">>> Execing pfsense-build.conf"
	. $BUILDERSCRIPTS/pfsense-build.conf
	build_loop_operations
	sleep 18600 # 5 hours
done

rm -f /tmp/pfSense_do_not_build_pfPorts
