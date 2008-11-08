#!/bin/sh

if [ $# -lt 1 ]; then
	echo 1>&2 Usage  : $0 pfSense branch
	echo 1>&2 example: $0 RELENG_1
	exit 127
fi

if [ $# -eq 2 ]; then
	SETLIVEBSD="true"
fi

HANDLED=false

# Ensure file exists
touch pfsense-build.conf

# Source pfsense-build.conf variables
. ./pfsense_local.sh
. ./pfsense-build.conf

strip_pfsense_local() {
	# Strip dynamic values
	cat $BUILDER_SCRIPTS/pfsense-build.conf | \
		grep -v FreeBSD_version | \
		grep -v freebsd_branch | \
		grep -v PFSENSETAG | \
		grep -v "set_version.sh" | \
		grep -v PFSPATCHFILE | \
		grep -v PFSENSEVERSION | \
		grep -v SUPFILE | \
		grep -v PFSPATCHDIR | \
		grep -v PFSENSE_VERSION | \
		grep -v OVERRIDE_FREEBSD_CVSUP_HOST > /tmp/pfsense-build.conf
	mv /tmp/pfsense-build.conf $BUILDER_SCRIPTS/pfsense-build.conf
}

set_items() {
	strip_pfsense_local
	# Add our custom dynamic values
	echo "# set_version.sh generated defaults" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export PFSENSEVERSION="${PFSENSEVERSION}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export FreeBSD_version="${FreeBSD_version}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export freebsd_branch="${freebsd_branch}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export PFSENSETAG="${PFSENSETAG}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export PFSPATCHFILE="${PFSPATCHFILE}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export PFSPATCHDIR="${PFSPATCHDIR}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export SUPFILE="${SUPFILE}" >> $BUILDER_SCRIPTS/pfsense-build.conf	
	if [ "$SETLIVEBSD" = "true" ]; then 
		echo "export OVERRIDE_FREEBSD_CVSUP_HOST=cvsup.livebsd.com" >> $BUILDER_SCRIPTS/pfsense-build.conf
	else 
		echo "#export OVERRIDE_FREEBSD_CVSUP_HOST=cvsup.livebsd.com" >> $BUILDER_SCRIPTS/pfsense-build.conf
	fi
	echo
	tail -n9 pfsense-build.conf
	echo
	HANDLED=true
}

echo

case $1 in
RELENG_1)
	echo ">>> Setting builder environment to use RELENG_1 ..."
	export pfSense_version="7"
	export FreeBSD_version="7"
	export freebsd_branch="RELENG_7"
	export SUPFILE="${BASE_DIR}/tools/builder_scripts/RELENG_7-supfile"
	export PFSENSEVERSION=2.0-ALPHA-ALPHA
	export PFSENSETAG=RELENG_1
	export PFSPATCHDIR=${BASE_DIR}/tools/patches/RELENG_7
	export PFSPATCHFILE=${BASE_DIR}/tools/builder_scripts/patches.RELENG_2_0
	set_items
;;

RELENG_1_2)
	echo ">>> Setting builder environment to use RELENG_1_2 ..."
	export pfSense_version="7"
	export FreeBSD_version="7"
	export freebsd_branch="RELENG_7_0"
	export SUPFILE="${BASE_DIR}/tools/builder_scripts/${freebsd_branch}-supfile"
	export PFSENSEVERSION=1.2.1-RC2
	export PFSENSETAG=RELENG_1_2
	export PFSPATCHDIR=${BASE_DIR}/tools/patches/${freebsd_branch}
	export PFSPATCHFILE=${BASE_DIR}/tools/builder_scripts/patches.${PFSENSETAG}
	set_items
;;

RELENG_2_0)
	echo ">>> Setting builder environment to use RELENG_2_0 ..."
	export pfSense_version="7"
	export FreeBSD_version="7"
	export freebsd_branch="RELENG_7"
	export SUPFILE="${BASE_DIR}/tools/builder_scripts/RELENG_7-supfile"
	export PFSENSEVERSION=2.0-ALPHA-ALPHA
	export PFSENSETAG=RELENG_1
	export PFSPATCHDIR=${BASE_DIR}/tools/patches/RELENG_7
	export PFSPATCHFILE=${BASE_DIR}/tools/builder_scripts/patches.RELENG_2_0
	set_items
;;
esac

if [ "$HANDLED" = "false" ]; then 
	echo "Invalid verison."
fi