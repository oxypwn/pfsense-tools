#!/bin/sh

# Ensure directories exist
mkdir -p /usr/local/www/data/updates
mkdir -p /usr/local/www/data/iso
mkdir -p /usr/local/www/data/embedded
mkdir -p /usr/local/www/data/head/updates
mkdir -p /usr/local/www/data/head/iso
mkdir -p /usr/local/www/data/head/embedded

rm -rf /usr/obj*

set_source() {
	echo $1 > /usr/local/www/CURRENTLY_BUILDING_PLATFORM.txt
}

update_sources() {
		CURRENTLY_BUILDING=`cat /usr/local/www/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Updating sources and building $CURRENTLY_BUILDING ISO..."
		cd /home/pfsense/tools/builder_scripts/
		./cvsup_current
		gzip /usr/obj.pfSense/pfSense.iso
}

build_embedded() {
		CURRENTLY_BUILDING=`cat /usr/local/www/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Building embedded $CURRENTLY_BUILDING ..."
		cd /home/pfsense/tools/builder_scripts/
		./build_embedded.sh
		setstatus "Gzipping embedded $CURRENTLY_BUILDING ..."
		rm /usr/obj.pfSense/pfSense.img.gz
		gzip /usr/obj.pfSense/pfSense.img		
}

build_updates() {
		CURRENTLY_BUILDING=`cat /usr/local/www/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Building updates..."
		cd /home/pfsense/tools/builder_scripts/
		./build_updates.sh
}

build_iso() {
		CURRENTLY_BUILDING=`cat /usr/local/www/CURRENTLY_BUILDING_PLATFORM.txt`
		setstatus "Building ISO..."
		cd /home/pfsense/tools/builder_scripts/
		./build_iso.sh
}

setstatus() {
		CURRENTLY_BUILDING=`cat /usr/local/www/CURRENTLY_BUILDING_PLATFORM.txt`
		STATUS=$1
		echo $1
		echo "Currently building $CURRENTLY_BUILDING" > /usr/local/www/status.txt
		uptime  >> /usr/local/www/status.txt
		date    >> /usr/local/www/status.txt
		echo $1 >> /usr/local/www/status.txt
}

while [ /bin/true ]; do

		# -- RELENG_1
		setstatus "Setting build to -RELENG_1..."
		set_source "-RELENG_1"
		CURRENTLY_BUILDING=`cat /usr/local/www/CURRENTLY_BUILDING_PLATFORM.txt`
		cp /root/pfsense_local_releng_1.sh \
			/home/pfsense/tools//builder_scripts/pfsense_local.sh

		update_sources
		build_updates
		cp /usr/obj.pfSense/pfSense.iso.gz /usr/local/www/data/iso/

		build_embedded
		cp /usr/obj.pfSense/pfSense.img.gz /usr/local/www/data/embedded/

		setstatus "Copying files for -RELENG_1 build..."
		cp /home/pfsense/updates/* /usr/local/www/data/updates/

		setstatus "Cleaning up..."
		rm -rf /usr/obj*

		setstatus "Cooling down..."
		sleep 500

		# -- HEAD
		setstatus "Setting build to -HEAD..."
		set_source "-HEAD"
		CURRENTLY_BUILDING=`cat /usr/local/www/CURRENTLY_BUILDING_PLATFORM.txt`
		cp /root/pfsense_local_releng_1_head.sh \
			/home/pfsense/tools/builder_scripts/pfsense_local.sh

		cd /home/pfsense/tools/builder_scripts/

		update_sources
		build_updates
		cp /usr/obj.pfSense/pfSense.iso.gz /usr/local/www/data/head/iso/
		cp /home/pfsense/updates/* /usr/local/www/data/head/updates/

		build_embedded
		cp /usr/obj.pfSense/pfSense.img.gz /usr/local/www/data/head/embedded/

		setstatus "Cleaning up..."
		rm -rf /usr/obj*

		setstatus "Cooling down..."
		sleep 500

done
