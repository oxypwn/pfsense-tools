#!/bin/sh

if [ $# -lt 1 ]; then
	echo 1>&2 Usage  : $0 ./set_version branch SUP_HOST ERROR_EMAIL_ADDRESS
	echo 1>&2 example: $0 ./set_version HEAD cvsup.livebsd.com myemail@emails.com
	exit 127
fi

# Default SUPHOST
if [ "$2" != "" ]; then 
	SUPHOST="$2"
else 
	SUPHOST="cvsup.livebsd.com"
fi

# Default EMAIL
if [ "$3" != "" ]; then
	FREESBIE_ERROR_MAIL="$3"
fi

if [ "$4" != "" ]; then
	FREESBIE_COMPLETED_MAIL="$3"
fi

HANDLED=false

# Ensure file exists
touch pfsense-build.conf

export BUILDER_SCRIPTS=`pwd`
export BUILDER_TOOLS=${BUILDER_SCRIPTS}/..
export BASE_DIR=${BUILDER_TOOLS}/..

# Source pfsense-build.conf variables
. ./pfsense_local.sh
. ./pfsense-build.conf

strip_pfsense_local() {
	# Strip dynamic values
	cat $BUILDER_SCRIPTS/pfsense-build.conf | \
		grep -v BASE_DIR | \
		grep -v BUILDER_TOOLS | \
		grep -v BUILDER_SCRIPTS | \
		grep -v FREEBSD_VERSION | \
		grep -v FREEBSD_BRANCH | \
		grep -v PFSENSETAG | \
		grep -v "set_version.sh" | \
		grep -v PFSPATCHFILE | \
		grep -v PFSENSE_VERSION | \
		grep -v SUPFILE | \
		grep -v PFSPATCHDIR | \
		grep -v PFSENSE_VERSION | \
		grep -v PFSPORTSFILE | \
		grep -v CUSTOM_COPY_LIST | \
		grep -v FREESBIE_ERROR_MAIL | \
		grep -v OVERRIDE_FREEBSD_CVSUP_HOST > /tmp/pfsense-build.conf
	mv /tmp/pfsense-build.conf $BUILDER_SCRIPTS/pfsense-build.conf
}

set_items() {
	strip_pfsense_local
	# Add our custom dynamic values
	echo "# set_version.sh generated defaults" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export PFSENSE_VERSION="${PFSENSE_VERSION}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export FREEBSD_VERSION="${FREEBSD_VERSION}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export FREEBSD_BRANCH="${FREEBSD_BRANCH}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export PFSENSETAG="${PFSENSETAG}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export PFSPATCHFILE="${PFSPATCHFILE}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export PFSPATCHDIR="${PFSPATCHDIR}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export SUPFILE="${SUPFILE}" >> $BUILDER_SCRIPTS/pfsense-build.conf		
	echo export CUSTOM_COPY_LIST="${CUSTOM_COPY_LIST}" >> $BUILDER_SCRIPTS/pfsense-build.conf	
	echo export OVERRIDE_FREEBSD_CVSUP_HOST="${SUPHOST}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export BASE_DIR="${BASE_DIR}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export BUILDER_TOOLS="${BUILDER_TOOLS}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export BUILDER_SCRIPTS="${BUILDER_SCRIPTS}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	if [ "$FREESBIE_ERROR_MAIL" != "" ]; then 
		echo "export FREESBIE_ERROR_MAIL=${FREESBIE_ERROR_MAIL}" >> $BUILDER_SCRIPTS/pfsense-build.conf		
	fi
	if [ "$FREESBIE_COMPLETED_MAIL" != "" ]; then 
		echo "export FREESBIE_COMPLETED_MAIL=${FREESBIE_COMPLETED_MAIL}" >> $BUILDER_SCRIPTS/pfsense-build.conf		
	fi
	if [ "$PFSPORTSFILE" != "" ]; then 
		echo "export PFSPORTSFILE=${PFSPORTSFILE}" >> $BUILDER_SCRIPTS/pfsense-build.conf		
	fi
	echo
	echo ">>> Custom pfsense-build.conf contains:"
	echo "---------------------------------------------------------------------------------------"
	cat pfsense-build.conf
	echo "---------------------------------------------------------------------------------------"
	echo
	echo "NOTE: pfsense-build.conf values updated.  These values override pfsense_local.sh !!"
	echo
	echo
	HANDLED=true
}

echo

case $1 in
HEAD)
	echo ">>> Setting builder environment to use HEAD ..."
	export FREEBSD_VERSION="7"
	export FREEBSD_BRANCH="RELENG_7_1"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/RELENG_7_1-supfile"
	export PFSENSE_VERSION=2.0-ALPHA-ALPHA
	export PFSENSETAG=HEAD
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_7_1
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/patches.RELENG_2_0
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/copy.list.RELENG_2"
	set_items
;;

RELENG_1_2)
	echo ">>> Setting builder environment to use RELENG_1_3-PRE ..."
	export FREEBSD_VERSION="7"
	export FREEBSD_BRANCH="RELENG_7_1"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/${FREEBSD_BRANCH}-supfile"
	export PFSENSE_VERSION=1.2.3
	export PFSENSETAG=RELENG_1_2
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_7_1
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/patches.RELENG_1_2
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/copy.list.RELENG_1_2"	
	set_items
;;

RELENG_2_0)
	echo ">>> Setting builder environment to use RELENG_2_0 ..."
	export FREEBSD_VERSION="7"
	export FREEBSD_BRANCH="RELENG_7_1"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/RELENG_7_1-supfile"
	export PFSENSE_VERSION=2.0-ALPHA-ALPHA
	export PFSENSETAG=RELENG_2_0
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_7_1
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/patches.RELENG_2_0
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/copy.list.RELENG_2"	
	set_items
;;

RELENG_7_2)
	echo ">>> Setting builder environment to use RELENG_1_3-PRE w/ FreeBSD 7.2 ..."
	export FREEBSD_VERSION="7"
	export FREEBSD_BRANCH="RELENG_7_2"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/${FREEBSD_BRANCH}-supfile"
	export PFSENSE_VERSION=1.2.3
	export PFSENSETAG=RELENG_1_2
	export PFSPORTSFILE=Makefile.RELENG_7_2
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/patches.RELENG_7_2
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/copy.list.RELENG_1_2"
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_7_2
	set_items
;;

RELENG_8_0)
	echo ">>> Setting builder environment to use RELENG_8_0 ..."
	export FREEBSD_VERSION="8"
	export FREEBSD_BRANCH="RELENG_8_0"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/RELENG_8-supfile"
	export PFSENSE_VERSION=2.0-ALPHA-ALPHA
	export PFSENSETAG=HEAD
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_8_0
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/patches.RELENG_8_0
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/copy.list.RELENG_8_0"	
	set_items
;;
esac

if [ "$HANDLED" = "false" ]; then 
	echo "Invalid verison."
fi
