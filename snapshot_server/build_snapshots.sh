#!/bin/sh

# Ensure directories exist
mkdir -p /usr/local/www/data/updates
mkdir -p /usr/local/www/data/iso
mkdir -p /usr/local/www/data/embedded
mkdir -p /usr/local/www/data/head/updates
mkdir -p /usr/local/www/data/head/iso
mkdir -p /usr/local/www/data/head/embedded

# Local variables that are used by builder scripts
WEBDATAROOT=/usr/local/www/data
WEBROOT=/usr/local/www
TOOLDIR=/home/pfsense/tools
BUILDERSCRIPTS=/home/pfsense/tools/builder_scripts
SNAPSHOTSCRIPTSDIR=/root/
PFSENSEUPDATESDIR=/home/pfsense/updates/
PFSENSEOBJDIR=/usr/obj.pfSense/

rm -rf /usr/obj*

set_source() {
	echo $1 > $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt
}

update_sources() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Updating sources and building $CURRENTLY_BUILDING ISO..."
		cd $BUILDERSCRIPTS
		./cvsup_current
		gzip $PFSENSEOBJDIR/pfSense.iso
}

build_embedded() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Building embedded $CURRENTLY_BUILDING ..."
		cd $BUILDERSCRIPTS
		./build_embedded.sh
		setstatus "Gzipping embedded $CURRENTLY_BUILDING ..."
		rm $PFSENSEOBJDIR/pfSense.img.gz
		gzip $PFSENSEOBJDIR/pfSense.img		
}

build_updates() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Building updates..."
		cd $BUILDERSCRIPTS
		./build_updates.sh
}

build_iso() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Building ISO..."
		cd $BUILDERSCRIPTS
		./build_iso.sh
}

setstatus() {
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		STATUS=$1
		echo $1
		echo "Currently building $CURRENTLY_BUILDING" > /usr/local/www/data/status.txt
		uptime  >> /usr/local/www/status.txt
		date    >> /usr/local/www/status.txt
		echo $1 >> /usr/local/www/status.txt
}

while [ /bin/true ]; do

		# -- RELENG_1
		setstatus "Setting build to -RELENG_1..."
		set_source "-RELENG_1"
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		cp $SNAPSHOTSCRIPTSDIR/pfsense_local_releng_1.sh \
			$BUILDERSCRIPTS/pfsense_local.sh

		cd $BUILDERSCRIPTS
		
		update_sources
		build_updates
		cp $PFSENSEOBJDIR/pfSense.iso.gz $WEBDATAROOT/iso/

		build_embedded
		cp $PFSENSEOBJDIR/pfSense.img.gz $WEBDATAROOT/embedded/

		setstatus "Copying files for -RELENG_1 build..."
		cp $PFSENSEUPDATESDIR/* $WEBDATAROOT/updates/

		setstatus "Cleaning up..."
		rm -rf /usr/obj*

		setstatus "Cooling down..."
		sleep 500

		# -- HEAD
		setstatus "Setting build to -HEAD..."
		set_source "-HEAD"
		CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
		cp $SNAPSHOTSCRIPTSDIR/pfsense_local_releng_1_head.sh \
			$BUILDERSCRIPTS/pfsense_local.sh

		cd $BUILDERSCRIPTS

		update_sources
		build_updates
		cp $PFSENSEOBJDIR/pfSense.iso.gz $WEBDATAROOT/head/iso/
		cp $PFSENSEUPDATESDIR/* $WEBDATAROOT/head/updates/

		build_embedded
		cp $PFSENSEOBJDIR/pfSense.img.gz $WEBDATAROOT/head/embedded/

		setstatus "Cleaning up..."
		rm -rf /usr/obj*

		setstatus "Cooling down..."
		sleep 500

done
