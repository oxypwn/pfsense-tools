#!/bin/sh

mkdir -p /usr/local/www/data/updates
mkdir -p /usr/local/www/data/iso
mkdir -p /usr/local/www/data/embedded
mkdir -p /usr/local/www/data/head/updates
mkdir -p /usr/local/www/data/head/iso
mkdir -p /usr/local/www/data/head/embedded

rm -rf /usr/obj*

setstatus() {
		STATUS=$1
		echo $1
		uptime >   /usr/local/www/data/status.txt
		date >>    /usr/local/www/data/status.txt
		echo $1 >> /usr/local/www/data/status.txt
}

while [ /bin/true ]; do

		# -- RELENG_1 -- TODO, MAKE THIS A FUNCTION!

		cp /root/pfsense_local_releng_1.sh /home/pfsense/tools/pfsense_local.sh
		cd /home/pfsense/tools/builder_scripts/

		setstatus "Updating sources and building -RELENG_1 ISO..."
		./cvsup_current
		setstatus "Building updates..."
		./build_updates.sh

		setstatus "Copying files for -RELENG_1 build..."
		cp /home/pfsense/updates/* /usr/local/www/data/updates/
		setstatus "Gzipping embedded image -RELENG_1..."
		gzip /usr/obj.pfSense/pfSense.iso
		cp /usr/obj.pfSense/pfSense.iso.gz /usr/local/www/data/iso/

		setstatus "Building embedded -RELENG_1..."
		./build_embedded.sh
		setstatus "Gzipping embedded -RELENG_1..."
		gzip /usr/obj.pfSense/pfSense.img
		cp /usr/obj.pfSense/pfSense.img.gz /usr/local/www/data/embedded/

		setstatus "Cleaning up..."
		rm -rf /usr/obj.pfSense

		setstatus "Cooling down... (before -RELENG_1 build)"
		sleep 500

		# ---- HEAD!!!!!!

		setstatus "Setting build to -HEAD"
		cp /root/pfsense_local_releng_1_head.sh \
			/home/pfsense/tools/pfsense_local.sh

		cd /home/pfsense/tools/builder_scripts/

		setstatus "Updating sources and building -HEAD ISO..."
		./cvsup_current
		setstatus "Building updates..."
		./build_updates.sh

		setstatus "Copying files..."
		cp /home/pfsense/updates/* /usr/local/www/data/head/updates/
		setstatus "Gzipping embedded -HEAD image..."
		gzip /usr/obj.pfSense/pfSense.iso
		cp /usr/obj.pfSense/pfSense.iso.gz /usr/local/www/data/head/iso/

		setstatus "Building embedded..."
		./build_embedded.sh
		setstatus "Gzipping embedded..."
		gzip /usr/obj.pfSense/pfSense.img
		cp /usr/obj.pfSense/pfSense.img.gz /usr/local/www/data/head/embedded/

		setstatus "Cleaning up..."
		rm -rf /usr/obj.pfSense

		setstatus "Cooling down..."
		sleep 500

done
