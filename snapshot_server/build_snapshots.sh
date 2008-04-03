#!/bin/sh

# pfSense snapshot building system
# (C)2007 Scott Ullrich
# All rights reserved
#
# This file is placed under the BSD License, 2 clause.
#
# $Id$
#

# Set verbose + debug
set -e -x

# Local variables that are used by builder scripts
PFSENSEOBJDIR=/usr/obj.pfSense/
MAKEOBJDIRPREFIX=/usr/obj.pfSense/
WEBDATAROOT=/usr/local/www/data
WEBROOT=/usr/local/www
TOOLDIR=/home/pfsense/tools
BUILDERSCRIPTS=/home/pfsense/tools/builder_scripts
SNAPSHOTSCRIPTSDIR=/root/
PFSENSEUPDATESDIR=/home/pfsense/updates/
STAGINGAREA=/tmp/staging
CVSROOT=/home/pfsense/cvsroot
PFSENSEHOMEDIR=/home/pfsense
PFSENSECVSROOT=${PFSENSEHOMEDIR}/cvsroot
PFSENSECHECKOUTDIR=${PFSENSEHOMEDIR}/pfSense

# Ensure directories exist
mkdir -p $CVSROOT
mkdir -p $STAGINGAREA
mkdir -p $WEBROOT

# Create extra structures
create_webdata_structure

# Source pfSense / FreeSBIE variables
. $BUILDERSCRIPTS/builder_common.sh
. $BUILDERSCRIPTS/pfsense_local.sh

# Ensure a fresh environment, please.
rm -rf $PFSENSECVSROOT
rm -rf $PFSENSECHECKOUTDIR
mkdir -p $PFSENSECVSROOT

# Sync with pfsense.org
cvsup $BUILDERSCRIPTS/pfSense-supfile

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
	FREEBSD_PLATFORM=`cat $WEBROOT/FREEBSD_PLATFORM.txt`
	PFSENSE_PLATFORM=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
	FREEBSD_VERSION=`cat $WEBROOT/FREEBSD_VERSION.txt`

	cat <<EOF >$BUILDERSCRIPTS/pfsense_local.sh

#!/bin/sh

# This is the base working directory for all builder
# operations
export BASE_DIR=\${BASE_DIR:-/home/pfsense}

# This is the directory where the latest pfSense cvs co
# is checked out to.
export CVS_CO_DIR=\${CVS_CO_DIR:-\${BASE_DIR}/pfSense}

export CUSTOMROOT=\${CUSTOMROOT:-\${CVS_CO_DIR}}

# This is the user that has access to the pfSense repo
export CVS_USER=\${CVS_USER:-sullrich}

# pfSense repo IP address. Typically cvs.pfsense.org,
# but somebody could use a ssh tunnel and specify
# a different one
export CVS_IP=\${CVS_IP:-cvs.pfsense.org}

export UPDATESDIR=\${UPDATESDIR:-\$BASE_DIR/updates}

export PFSENSEBASEDIR=\${PFSENSEBASEDIR:-/usr/local/pfsense-fs}

export PFSENSEISODIR=\${PFSENSEISODIR:-/usr/local/pfsense-clone}

# FreeSBIE 2 toolkit path
export FREESBIE_PATH=\${FREESBIE_PATH:-/home/pfsense/freesbie2}

# export variables used by freesbie2
export FREESBIE_CONF=\${FREESBIE_CONF:-/dev/null}
export SRCDIR=\${SRCDIR:-/usr/src}
export BASEDIR=\${PFSENSEBASEDIR:-/usr/local/pfsense-fs}
export CLONEDIR=\${PFSENSEISODIR:-/usr/local/pfsense-clone}
export ISOPATH=\${ISOPATH:-\${MAKEOBJDIRPREFIX}/pfSense.iso}
export IMGPATH=\${IMGPATH:-\${MAKEOBJDIRPREFIX}/pfSense.img}
export PKGFILE=\${PKGFILE:-\$PWD/conf/packages}
export FREESBIE_LABEL=pfSense
export EXTRA="\${EXTRA:-"customroot buildmodules"}"
export BUILDMODULES="netgraph acpi ndis if_ndis padlock ipfw dummynet fdescfs"

MAKEJ=" "

# Used by non pfSense developers
export SKIP_RSYNC=yes

# Custom overlay for people building or extending pfSense images.
# The custom overlay tar gzipped file will be extracted over the root
# of the prepared image allowing for customization.
#
# Note: It is also possible to specify a directory instead of a
#       gezipped tarball.
# export custom_overlay="/home/pfsense/custom_overlay.tgz"

export OVERRIDE_FREEBSD_CVSUP_HOST="cvsup.livebsd.com"

export INSTALL_PORTS="pfPorts/isc-dhcp3-server pfPorts/php4-pfsense pfPorts/libevent pfPorts/beep pfPorts/lighttpd pfPorts/check_reload_status pfPorts/minicron pfPorts/libart_lgpl pfPorts/rrdtool pfPorts/choparp pfPorts/mpd pfPorts/slbd pfPorts/olsrd pfPorts/dnsmasq pfPorts/openntpd pfPorts/sshlockout_pf pfPorts/expiretable pfPorts/lzo2 pfPorts/openvpn pfPorts/pecl-APC pfPorts/ipsec-tools pfPorts/pftop pfPorts/vtsh pfPorts/isc-dhcp3-relay pfPorts/libevent pfPorts/pftpx pfPorts/clog pfPorts/fping"
export STATIC_INSTALL_PORTS="pfPorts/ipsec-tools"

# FreeBSD version.  6 or 7
export pfSense_version="${FREEBSD_VERSION}"
export freebsd_branch="${FREEBSD_PLATFORM}"

# pfSense cvs tag to build
export PFSENSETAG="${PFSENSE_PLATFORM}"

EOF

}

update_sources() {
	CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
	cd $BUILDERSCRIPTS 
	./cvsup_current
	gzip $PFSENSEOBJDIR/pfSense.iso
	mv $PFSENSEOBJDIR/pfSense.iso.gz $PFSENSEOBJDIR/pfSense-`date "+%Y%m%d-%H%M"`.iso.gz
	md5 pfSense-`date "+%Y%m%d-%H%M"`.iso.gz > $PFSENSEOBJDIR/pfSense-`date "+%Y%m%d-%H%M"`.iso.gz.md5
}

build_embedded() {
	CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
	cd $BUILDERSCRIPTS 
	./build_embedded.sh
	rm -f $PFSENSEOBJDIR/pfSense-`date "+%Y%m%d-%H%M"`.img.gz
	gzip $PFSENSEOBJDIR/pfSense-`date "+%Y%m%d-%H%M"`.img
	md5 $PFSENSEOBJDIR/pfSense-`date "+%Y%m%d-%H%M"`.img.gz > $PFSENSEOBJDIR/pfSense-`date "+%Y%m%d-%H%M"`.img.gz.md5
}

build_embedded_updates() {
	CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
	cd $BUILDERSCRIPTS
	./build_updates_embedded.sh
}

build_updates() {
	CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
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
	CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
	cd $BUILDERSCRIPTS && ./build_iso.sh
}

dobuilds() {
	CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`

	cd $BUILDERSCRIPTS

	# Update sources and build iso
	update_sources

	# Build updates on same run as iso
	build_updates

	# Copy files before embedded, it wipes out usr.obj*
	cp $PFSENSEOBJDIR/pfSense-*.iso.* $STAGINGAREA/

	# Build embedded version
	build_embedded
	cp $PFSENSEOBJDIR/pfSense.img.* $STAGINGAREA/

	cp $PFSENSEUPDATESDIR/*.tgz $STAGINGAREA/
	cp $PFSENSEUPDATESDIR/*.tgz.md5 $STAGINGAREA/

	rm -rf /usr/obj*
	rm -f $PFSENSEUPDATESDIR/*  # Keep updates dir slimmed down
}

cp_files() {
	cp $STAGINGAREA/pfSense.iso.* $WEBDATAROOT/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/iso/
	cp $STAGINGAREA/pfSense.img.* $WEBDATAROOT/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/embedded/
	cp $STAGINGAREA/*.tgz $WEBDATAROOT/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/updates/
	cp $STAGINGAREA/*.tgz.md5 $WEBDATAROOT/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/updates/
}

scp_files() {
	echo "scp $STAGINGAREA/pfSense.iso* snapshots@172.29.29.181:/usr/local/www/snapshots/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/"
	scp $STAGINGAREA/pfSense.iso* snapshots@172.29.29.181:/usr/local/www/snapshots/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/
	scp $STAGINGAREA/pfSense.img* snapshots@172.29.29.181:/usr/local/www/snapshots/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/
	scp $STAGINGAREA/*.md5 snapshots@172.29.29.181:/usr/local/www/snapshots/FreeBSD${FREEBSD_VERSION}/${PFSENSE_PLATFORM}/
}

cleanup_builds() {
	# Remove prior builds
	echo "Cleaning up after prior builds..."
	rm -rf /usr/obj*
	rm -f $STAGINGAREA/*
	if [ -d /home/pfsense/pfSense ]; then
		echo "Clearing out previous pfSense checkout directory..."
		chflags -R noschg /home/pfsense/pfSense
		rm -rf /home/pfsense/pfSense
	fi
}

build_loop_operations() {
	# --- Items we need to run for a complete build run ---
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

	# --- begin pfSense RELENG_1_2 -- FreeBSD RELENG_6_3
	set_pfsense_source "RELENG_1_2"
	set_freebsd_source "RELENG_6_3"
	set_freebsd_version "6"
	build_loop_operations	
	# --- end pfSense RELENG_1_2 -- FreeBSD RELENG_6_3

	sleep 500	# give the box a break.
done
