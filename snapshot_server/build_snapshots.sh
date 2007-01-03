#!/bin/sh

# pfSense snapshot building system
# (C)2007 Scott Ullrich
# All rights reserved
#
# This file is placed under the BSD License, 2 clause.

# Local variables that are used by builder scripts
WEBDATAROOT=/usr/local/www/data
WEBROOT=/usr/local/www
TOOLDIR=/home/pfsense/tools
BUILDERSCRIPTS=/home/pfsense/tools/builder_scripts
SNAPSHOTSCRIPTSDIR=/root/
PFSENSEUPDATESDIR=/home/pfsense/updates/
PFSENSEOBJDIR=/usr/obj.pfSense/
STAGINGAREA=/tmp/staging

# Ensure directories exist
mkdir -p $WEBDATAROOT/FreeBSD6/updates \
		 $WEBDATAROOT/FreeBSD6/iso \
		 $WEBDATAROOT/FreeBSD6/embedded \
		 $WEBDATAROOT/FreeBSD6/head/updates \
		 $WEBDATAROOT/FreeBSD6/data/head/iso \
		 $WEBDATAROOT/FreeBSD6/data/head/embedded \
		 /tmp/staging

mkdir -p $WEBDATAROOT/FreeBSD7/iso/ \
		 $WEBDATAROOT/FreeBSD7/embedded/ \
		 $WEBDATAROOT/FreeBSD7/updates/

mkdir -p $WEBDATAROOT/FreeBSD7/head/iso/ \
		 $WEBDATAROOT/FreeBSD7/head/embedded/ \
		 $WEBDATAROOT/FreeBSD7/head/updates/

rm -rf /usr/obj*

set_pfsense_source() {
	echo $1 > $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt
}

set_freebsd_source() {
	echo $1 > $WEBROOT/FREEBSD_PLATFORM.txt
}

install_pfsense_local_sh() {
	FREEBSD_PLATFORM=`cat $WEBROOT/FREEBSD_PLATFORM.txt`
	PFSENSE_PLATFORM=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
	cat <<<EOF >$BUILDERSCRIPTS/pfsense_local.sh

#!/bin/sh

# $Id$

#export DNO_ATM=yes

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
export FREESBIE_CONF=\${FREESBIE_CONF:-/dev/null} # No configuration file should
be override our variables
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

EOF

}

update_sources() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Updating sources and building $CURRENTLY_BUILDING ISO..."
		cd $BUILDERSCRIPTS
		./cvsup_current
		gzip $PFSENSEOBJDIR/pfSense.iso
		echo "Sources updated for $CURRENTLY_BUILDING last completed at `date`" > $WEBROOT/$CURRENTLY_BUILDINGSTATUS.txt
}

build_embedded() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Building embedded $CURRENTLY_BUILDING ..."
		cd $BUILDERSCRIPTS
		./build_embedded.sh
		setstatus "Gzipping embedded $CURRENTLY_BUILDING ..."
		rm -f $PFSENSEOBJDIR/pfSense.img.gz
		gzip $PFSENSEOBJDIR/pfSense.img
		echo "Embedded for $CURRENTLY_BUILDING last completed at `date`" > $WEBROOT/$CURRENTLY_BUILDINGEMBEDDEDSTATUS.txt
}

build_updates() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Building updates..."
		cd $BUILDERSCRIPTS
		./build_updates.sh
		echo "Updates for $CURRENTLY_BUILDING last completed at `date`" > $WEBROOT/$CURRENTLY_BUILDINGUPDATESSTATUS.txt
}

build_iso() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Building ISO..."
		cd $BUILDERSCRIPTS
		./build_iso.sh
		echo "FULL ISO for $CURRENTLY_BUILDING last completed at `date`" > $WEBROOT/$CURRENTLY_BUILDINGISOSTATUS.txt
}

setstatus() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		STATUS=$1
		echo "Currently building $CURRENTLY_BUILDING"
		echo "Currently building $CURRENTLY_BUILDING" > $WEBDATAROOT/status.txt
		uptime  >> $WEBDATAROOT/status.txt
		echo    >> $WEBDATAROOT/status.txt
		iostat  >> $WEBDATAROOT/status.txt
		echo    >> $WEBDATAROOT/status.txt
		date    >> $WEBDATAROOT/status.txt
		echo    >> $WEBDATAROOT/status.txt
		echo $1 >> $WEBDATAROOT/status.txt
		echo    >> $WEBDATAROOT/status.txt
		echo "-RELENG_1"   >> $WEBDATAROOT/status.txt
		echo    >> $WEBDATAROOT/status.txt
		cat $WEBROOT/-RELENG_1ISOSTATUS.txt \
			    >> $WEBDATAROOT/status.txt
		cat $WEBROOT/-RELENG_1UPDATESSTATUS.txt \
			    >> $WEBDATAROOT/status.txt
		cat $WEBROOT/-RELENG_1EMBEDDEDSTATUS.txt \
			    >> $WEBDATAROOT/status.txt
		cat $WEBROOT/-RELENG_1STATUS.txt \
			    >> $WEBDATAROOT/status.txt
		echo    >> $WEBDATAROOT/status.txt
		echo "-HEAD"   >> $WEBDATAROOT/status.txt
		echo    >> $WEBDATAROOT/status.txt
		cat $WEBROOT/-HEADISOSTATUS.txt \
			>> $WEBDATAROOT/status.txt
		cat $WEBROOT/-HEADUPDATESSTATUS.txt \
			>> $WEBDATAROOT/status.txt
		cat $WEBROOT/-HEADEMBEDDEDSTATUS.txt \
			>> $WEBDATAROOT/status.txt
		cat $WEBROOT/-HEADSTATUS.txt \
			>> $WEBDATAROOT/status.txt
}

dobuilds() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`

		cd $BUILDERSCRIPTS

		update_sources
		build_updates
		cp $PFSENSEOBJDIR/pfSense.iso.gz $STAGINGAREA

		build_embedded
		cp $PFSENSEOBJDIR/pfSense.img.gz $STAGINGAREA

		setstatus "Copying files for -RELENG_1 build..."
		cp $PFSENSEUPDATESDIR/*.tgz $STAGINGAREA

		setstatus "Cleaning up..."
		rm -rf /usr/obj*
		rm $PFSENSEUPDATESDIR/*  # Keep updates dir slimmed down

		setstatus "Cooling down..."
		sleep 500
}

# Main builder loop
while [ /bin/true ]; do
		# -- pfSense RELENG_1 -- FreeBSD RELENG_6_2
		setstatus "Setting build to -RELENG_1 FreeBSD RELENG_6_2..."
		set_pfsense_source "-RELENG_1"
		set_freebsd_source "RELENG_6_2"
		rm -f $STAGINGAREA/*
		dobuilds
		cp $STAGINGAREA/pfSense.iso.gz $WEBDATAROOT/FreeBSD6/iso/
		cp $STAGINGAREA/pfSense.img.gz $WEBDATAROOT/FreeBSD6/embedded/
		cp $STAGINGAREA/*.tgz $WEBDATAROOT/FreeBSD6/updates/
		setstatus "Cleaning up..."
		rm -f $STAGINGAREA/*
		rm -rf /usr/obj*

		# -- pfSense HEAD - FreeBSD RELENG_6_2
		setstatus "Setting build to -HEAD FreeBSD RELENG_6_2..."
		set_pfsense_source "-HEAD"
		set_freebsd_source "RELENG_6_2"
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		rm -f $STAGINGAREA/*
		dobuilds
		cp $STAGINGAREA/pfSense.iso.gz $WEBDATAROOT/FreeBSD6/head/iso/
		cp $STAGINGAREA/pfSense.img.gz $WEBDATAROOT/FreeBSD6/head/embedded/
		cp $STAGINGAREA/*.tgz $WEBDATAROOT/FreeBSD6/head/updates/
		setstatus "Cleaning up..."
		rm $STAGINGAREA/*
		rm -rf /usr/obj*
done
