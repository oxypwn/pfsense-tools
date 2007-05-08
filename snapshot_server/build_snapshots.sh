#!/bin/sh

# pfSense snapshot building system
# (C)2007 Scott Ullrich
# All rights reserved
#
# This file is placed under the BSD License, 2 clause.
#
# $Id$
#

set -e -x

# Local variables that are used by builder scripts
WEBDATAROOT=/usr/local/www/data
WEBROOT=/usr/local/www
TOOLDIR=/home/pfsense/tools
BUILDERSCRIPTS=/home/pfsense/tools/builder_scripts
SNAPSHOTSCRIPTSDIR=/root/
PFSENSEUPDATESDIR=/home/pfsense/updates/
PFSENSEOBJDIR=/usr/obj.pfSense/
STAGINGAREA=/tmp/staging
CVSROOT=/home/pfsense/cvsroot

# Ensure directories exist
mkdir -p $CVSROOT

mkdir -p $WEBDATAROOT/FreeBSD6/RELENG_1_2/updates \
		 $WEBDATAROOT/FreeBSD6/RELENG_1_2/iso \
		 $WEBDATAROOT/FreeBSD6/RELENG_1_2/embedded \
		 $WEBDATAROOT/FreeBSD6/head/updates \
		 $WEBDATAROOT/FreeBSD6/head/iso \
		 $WEBDATAROOT/FreeBSD6/head/embedded

mkdir -p $WEBDATAROOT/FreeBSD7/RELENG_1_2/iso/ \
		 $WEBDATAROOT/FreeBSD7/RELENG_1_2/embedded/ \
		 $WEBDATAROOT/FreeBSD7/RELENG_1_2/updates/ \
		 $WEBDATAROOT/FreeBSD7/head/iso/ \
		 $WEBDATAROOT/FreeBSD7/head/embedded/ \
		 $WEBDATAROOT/FreeBSD7/head/updates/

touch $WEBROOT/RELENG_1_2ISOSTATUS.txt \
	  $WEBROOT/RELENG_1_2UPDATESSTATUS.txt \
	  $WEBROOT/RELENG_1_2EMBEDDEDSTATUS.txt \
	  $WEBROOT/RELENG_1_2STATUS.txt \
	  $WEBROOT/HEADISOSTATUS.txt \
	  $WEBROOT/HEADUPDATESSTATUS.txt \
	  $WEBROOT/HEADEMBEDDEDSTATUS.txt \
	  $WEBROOT/HEADSTATUS.txt \

mkdir -p /tmp/staging

set_pfsense_source() {
	echo $1 > $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt
	install_pfsense_local_sh
}

set_freebsd_source() {
	echo $1 > $WEBROOT/FREEBSD_PLATFORM.txt
	install_pfsense_local_sh
}

install_pfsense_local_sh() {
	if [ -f $WEBROOT/FREEBSD_PLATFORM.txt ]; then 
		FREEBSD_PLATFORM=`cat $WEBROOT/FREEBSD_PLATFORM.txt`
	else 
		FREEBSD_PLATFORM="RELENG_6_2"
	fi
	if [ -f $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt ]; then
		PFSENSE_PLATFORM=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`		
	fi 
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

# pfSense cvs tag to build
export PFSENSETAG="${PFSENSE_PLATFORM}"

# FreeSBIE 2 toolkit path
export FREESBIE_PATH=\${FREESBIE_PATH:-/home/pfsense/freesbie2}

# export variables used by freesbie2
export FREESBIE_CONF=\${FREESBIE_CONF:-/dev/null}
export SRCDIR=\${SRCDIR:-/usr/src}
export BASEDIR=\${PFSENSEBASEDIR:-/usr/local/pfsense-fs}
export CLONEDIR=\${PFSENSEISODIR:-/usr/local/pfsense-clone}
export MAKEOBJDIRPREFIX=\${MAKEOBJDIRPREFIX:-/usr/obj.pfSense}
export ISOPATH=\${ISOPATH:-\${MAKEOBJDIRPREFIX}/pfSense.iso}
export IMGPATH=\${IMGPATH:-\${MAKEOBJDIRPREFIX}/pfSense.img}
export PKGFILE=\${PKGFILE:-\$PWD/conf/packages}
export FREESBIE_LABEL=pfSense
export EXTRA="\${EXTRA:-"customroot buildmodules"}"
export BUILDMODULES="netgraph acpi ndis if_ndis padlock ipfw dummynet fdescfs"

MAKEJ=" "

# FreeBSD version.  6 or 7
export pfSense_version="6"
export freebsd_branch="${FREEBSD_PLATFORM}"

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

EOF

}

update_sources() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Updating sources and building $CURRENTLY_BUILDING ISO..."
		cd $BUILDERSCRIPTS
		./cvsup_current
		gzip $PFSENSEOBJDIR/pfSense.iso
		md5 $PFSENSEOBJDIR/pfSense.iso.gz > $PFSENSEOBJDIR/pfSense.iso.gz.md5
		echo "Sources updated for $CURRENTLY_BUILDING last completed at `date`" \
			> $WEBROOT/${CURRENTLY_BUILDING}STATUS.txt
}

build_embedded() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Building embedded $CURRENTLY_BUILDING ..."
		cd $BUILDERSCRIPTS
		./build_embedded.sh
		setstatus "GZipping embedded $CURRENTLY_BUILDING ..."
		rm -f $PFSENSEOBJDIR/pfSense.img.gz
		gzip $PFSENSEOBJDIR/pfSense.img
		md5 $PFSENSEOBJDIR/pfSense.img.gz > $PFSENSEOBJDIR/pfSense.img.gz.md5
		echo "Embedded for $CURRENTLY_BUILDING last completed at `date`" \
			> $WEBROOT/${CURRENTLY_BUILDING}EMBEDDEDSTATUS.txt
}

build_embedded_updates() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Building embedded updates $CURRENTLY_BUILDING ..."
		cd $BUILDERSCRIPTS
		./build_updates_embedded.sh
		echo "Embedded update for $CURRENTLY_BUILDING last completed at `date`" \
			> $WEBROOT/${CURRENTLY_BUILDING}EMBEDDEDUPDATESTATUS.txt
}

build_updates() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Building updates..."
		cd $BUILDERSCRIPTS
		./build_updates.sh
		for filename in $PFSENSEUPDATESDIR/*.tgz
		do
			md5  $filename > $filename.md5
		done
		echo "Updates for $CURRENTLY_BUILDING last completed at `date`" \
			> $WEBROOT/${CURRENTLY_BUILDING}UPDATESSTATUS.txt
}

build_iso() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Building ISO..."
		cd $BUILDERSCRIPTS
		./build_iso.sh
		echo "FULL ISO for $CURRENTLY_BUILDING last completed at `date`" \
			> $WEBROOT/${CURRENTLY_BUILDING}ISOSTATUS.txt
}

setstatus() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		STATUS=$1
		echo "$1" > $WEBDATAROOT/status.txt
		uptime  >> $WEBDATAROOT/status.txt
		echo    >> $WEBDATAROOT/status.txt
		iostat  >> $WEBDATAROOT/status.txt
		echo    >> $WEBDATAROOT/status.txt
		date    >> $WEBDATAROOT/status.txt
		echo    >> $WEBDATAROOT/status.txt
		echo $1 >> $WEBDATAROOT/status.txt
		echo    >> $WEBDATAROOT/status.txt
		echo "-RELENG_1_2 last known build status" \
				>> $WEBDATAROOT/status.txt
		echo \
				>> $WEBDATAROOT/status.txt
		cat $WEBROOT/RELENG_1_2ISOSTATUS.txt \
			    >> $WEBDATAROOT/status.txt
		cat $WEBROOT/RELENG_1_2UPDATESSTATUS.txt \
			    >> $WEBDATAROOT/status.txt
		cat $WEBROOT/RELENG_1_2EMBEDDEDSTATUS.txt \
			    >> $WEBDATAROOT/status.txt
		cat $WEBROOT/RELENG_1_2EMBEDDEDUPDATESTATUS.txt \
			    >> $WEBDATAROOT/status.txt
		cat $WEBROOT/RELENG_1_2STATUS.txt \
			    >> $WEBDATAROOT/status.txt
		echo \
				>> $WEBDATAROOT/status.txt
		echo "-HEAD last known build status" \
				>> $WEBDATAROOT/status.txt
		echo \
				>> $WEBDATAROOT/status.txt
		cat $WEBROOT/HEADISOSTATUS.txt \
				>> $WEBDATAROOT/status.txt
		cat $WEBROOT/HEADUPDATESSTATUS.txt \
				>> $WEBDATAROOT/status.txt
		cat $WEBROOT/HEADEMBEDDEDSTATUS.txt \
				>> $WEBDATAROOT/status.txt
		cat $WEBROOT/HEADSTATUS.txt \
				>> $WEBDATAROOT/status.txt
}

dobuilds() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`

		cd $BUILDERSCRIPTS

		# Update sources and build iso
		update_sources

		# Build updates on same run as iso
		build_updates

		# Copy files before embedded, it wipes out usr.obj*
		cp $PFSENSEOBJDIR/pfSense.iso.* $STAGINGAREA/

		# Build embedded version
		build_embedded
		build_embedded_updates
		cp $PFSENSEOBJDIR/pfSense.img.* $STAGINGAREA/

		setstatus "Copying files for -RELENG_1_2 build..."
		cp $PFSENSEUPDATESDIR/*.tgz $STAGINGAREA/
		cp $PFSENSEUPDATESDIR/*.tgz.md5 $STAGINGAREA/

		setstatus "Cleaning up..."
		rm -rf /usr/obj*
		rm -f $PFSENSEUPDATESDIR/*  # Keep updates dir slimmed down
}

# Remove prior builds
rm -rf /usr/obj*

# Uncomment if builder problems appear
#  rm -rf /home/pfsense/cvsroot
#  rm -rf /home/pfsense/pfSense
#  mkdir -p /home/pfsense/cvsroot
#  cvsup $BUILDERSCRIPTS/pfSense-supfile

# Main builder loop
while [ /bin/true ]; do
		# -- pfSense RELENG_1_2 -- FreeBSD RELENG_6_2
		rm -f $WEBDATAROOT/FreeBSD6/RELENG_1_2/updates/*HEAD*
		setstatus "Setting build to -RELENG_1_2 FreeBSD RELENG_6_2..."
		set_pfsense_source "RELENG_1_2"
		set_freebsd_source "RELENG_6_2"
		rm -f $STAGINGAREA/*
		dobuilds
		cp $STAGINGAREA/pfSense.iso.* $WEBDATAROOT/FreeBSD6/RELENG_1_2/iso/
		cp $STAGINGAREA/pfSense.img.* $WEBDATAROOT/FreeBSD6/RELENG_1_2/embedded/
		cp $STAGINGAREA/*.tgz $WEBDATAROOT/FreeBSD6/RELENG_1_2/updates/
		cp $STAGINGAREA/*.tgz.md5 $WEBDATAROOT/FreeBSD6/RELENG_1_2/updates/
		rm -f $WEBDATAROOT/FreeBSD6/RELENG_1_2/updates/*HEAD*
		setstatus "Cleaning up..."
		rm -f $STAGINGAREA/*
		rm -rf /usr/obj*

		# -- pfSense RELENG_1 -- FreeBSD RELENG_6_2
		rm -f $WEBDATAROOT/FreeBSD6/RELENG_1/updates/*HEAD*
		setstatus "Setting build to -RELENG_1 FreeBSD RELENG_6_2..."
		set_pfsense_source "RELENG_1"
		set_freebsd_source "RELENG_6_2"
		rm -f $STAGINGAREA/*
		dobuilds
		cp $STAGINGAREA/pfSense.iso.* $WEBDATAROOT/FreeBSD6/RELENG_1/iso/
		cp $STAGINGAREA/pfSense.img.* $WEBDATAROOT/FreeBSD6/RELENG_1/embedded/
		cp $STAGINGAREA/*.tgz $WEBDATAROOT/FreeBSD6/RELENG_1/updates/
		cp $STAGINGAREA/*.tgz.md5 $WEBDATAROOT/FreeBSD6/RELENG_1/updates/
		rm -f $WEBDATAROOT/FreeBSD6/RELENG_1/updates/*HEAD*
		setstatus "Cleaning up..."
		rm -f $STAGINGAREA/*
		rm -rf /usr/obj*

		# -- pfSense HEAD - FreeBSD RELENG_6_2
		setstatus "Setting build to -HEAD FreeBSD RELENG_6_2..."
		set_pfsense_source "HEAD"
		set_freebsd_source "RELENG_6_2"
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		rm -f $STAGINGAREA/*
		dobuilds
		cp $STAGINGAREA/pfSense.iso.* $WEBDATAROOT/FreeBSD6/head/iso/
		cp $STAGINGAREA/pfSense.img.* $WEBDATAROOT/FreeBSD6/head/embedded/
		cp $STAGINGAREA/*.tgz $WEBDATAROOT/FreeBSD6/head/updates/
		cp $STAGINGAREA/*.tgz.md5 $WEBDATAROOT/FreeBSD6/head/updates/
		setstatus "Cleaning up..."
		rm $STAGINGAREA/*
		rm -rf /usr/obj*
		setstatus "Cooling down..." # Let machine rest a moment
		sleep 500
done
