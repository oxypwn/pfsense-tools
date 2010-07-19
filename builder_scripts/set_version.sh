#!/bin/sh

if [ $# -lt 1 ]; then
	echo 1>&2 Usage  : $0 branch SUP_HOST ERROR_EMAIL_ADDRESS
	echo 1>&2 example: $0 HEAD cvsup.livebsd.org myemail@emails.com
	exit 127
fi

# Default SUPHOST
if [ "$2" != "" ]; then 
	SUPHOST="$2"
else 
	if [ -f /usr/local/bin/fastest_cvsup ]; then
		echo "One moment please, finding the best cvsup server to use"
		SUPHOST=`fastest_cvsup -c tld -q`
	else 
		echo "WARNING:  Setting CVSUP host to cvsup.livebsd.org.  You must have firewall access for this to work on pfSense.org!"
		SUPHOST="cvsup.livebsd.org"	
		sleep 2
	fi
fi

# Default EMAIL
if [ "$3" != "" ]; then
	FREESBIE_ERROR_MAIL="$3"
fi

if [ "$4" != "" ]; then
	FREESBIE_COMPLETED_MAIL="$4"
fi

if [ "$5" != "" ]; then
	TWITTER_USERNAME="$5"
fi

if [ "$6" != "" ]; then
	TWITTER_PASSWORD="$6"
fi

if [ "$7" != "" ]; then
	TWITTER_PASSWORD="$6"
fi

if [ "$8" != "" ]; then
	REMOVE_PHP="$6"
fi

HANDLED=false

# Ensure file exists
rm -f pfsense-build.conf
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
		grep -v TWITTER_USERNAME | \
		grep -v TWITTER_PASSWORD | \
		grep -v PFSENSE_VERSION | \
		grep -v FREESBIE_COMPLETED_MAIL | \
		grep -v PFSPORTSFILE | \
		grep -v CUSTOM_COPY_LIST | \
		grep -v FREESBIE_ERROR_MAIL | \
		grep -v REMOVE_PHP | \
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
	echo "# Comment out the following line if you would like to automatically select an update server."
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
	if [ "$TWITTER_USERNAME" != "" ]; then 
		echo "export TWITTER_USERNAME=${TWITTER_USERNAME}" >> $BUILDER_SCRIPTS/pfsense-build.conf		
		echo "export TWITTER_PASSWORD=${TWITTER_PASSWORD}" >> $BUILDER_SCRIPTS/pfsense-build.conf		
	fi	
	if [ "$REMOVE_PHP" != "" ]; then 
		echo "export REMOVE_PHP=true" >> $BUILDER_SCRIPTS/pfsense-build.conf
	fi
	UNAME=`uname -m`
	if [ "$UNAME" = "amd64" ]; then
		echo "export ARCH=amd64" >> $BUILDER_SCRIPTS/pfsense-build.conf
		echo "export TARGETARCH=amd64" >> $BUILDER_SCRIPTS/pfsense-build.conf
	fi
	if [ "$UNAME" = "mips" ]; then
		echo "export ARCH=mips" >> $BUILDER_SCRIPTS/pfsense-build.conf
		echo "export TARGETARCH=mips" >> $BUILDER_SCRIPTS/pfsense-build.conf
	fi

	echo
	echo ">>> Custom pfsense-build.conf contains:"
	echo "---------------------------------------------------------------------------------------"
	cat pfsense-build.conf
	echo "---------------------------------------------------------------------------------------"
	echo
	echo "NOTE: pfsense-build.conf values updated.  These values override pfsense_local.sh !!"
	echo
	echo "NOTE2: pfPorts will be rebuilt!"
	echo
	HANDLED=true
	touch /tmp/pfPorts_forced_build_required
}

echo

case $1 in
HEAD)
	echo ">>> Setting builder environment to use HEAD ..."
	export FREEBSD_VERSION="8"
	export FREEBSD_BRANCH="RELENG_8_0"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/RELENG_8-supfile"
	export PFSENSE_VERSION=2.0-BETA1
	export PFSENSETAG=HEAD
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_8_0
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/patches.RELENG_8_0
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/copy.list.RELENG_8_0"	
	export PFSPORTSFILE=buildports.RELENG_2_0
	set_items
;;

RELENG_1_2)
	echo ">>> Setting builder environment to use RELENG_1_3-REL ..."
	export FREEBSD_VERSION="7"
	export FREEBSD_BRANCH="RELENG_7_2"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/${FREEBSD_BRANCH}-supfile"
	export PFSENSE_VERSION=1.2.3
	export PFSENSETAG=RELENG_1_2
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_7_2
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/patches.RELENG_7_2
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/copy.list.RELENG_1_2"	
	export PFSPORTSFILE=buildports.RELENG_1_2
	set_items
;;

RELENG_2_0)
	echo ">>> Setting builder environment to use RELENG_8_1 ..."
	export FREEBSD_VERSION="8"
	export FREEBSD_BRANCH="RELENG_8_1"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/RELENG_8_1-supfile"
	export PFSENSE_VERSION=2.0-BETA3
	export PFSENSETAG=HEAD
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_8_1
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/patches.RELENG_8_1
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/copy.list.RELENG_8_0"	
	export PFSPORTSFILE=buildports.RELENG_2_0
	set_items
;;

RELENG_7_2)
	echo ">>> Setting builder environment to use RELENG_1.2.3-REL w/ FreeBSD 7.2 ..."
	export FREEBSD_VERSION="7"
	export FREEBSD_BRANCH="RELENG_7_2"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/${FREEBSD_BRANCH}-supfile"
	export PFSENSE_VERSION=1.2.3
	export PFSENSETAG=RELENG_1_2
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/patches.RELENG_7_2
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/copy.list.RELENG_1_2"
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_7_2
	export PFSPORTSFILE=buildports.RELENG_1_2
	set_items
;;

RELENG_7_3)
	echo ">>> Setting builder environment to use RELENG_1.2.3-REL w/ FreeBSD 7.3 ..."
	export FREEBSD_VERSION="7"
	export FREEBSD_BRANCH="RELENG_7_3"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/${FREEBSD_BRANCH}-supfile"
	export PFSENSE_VERSION=1.2.3
	export PFSENSETAG=RELENG_1_2
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/patches.RELENG_7_3
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/copy.list.RELENG_1_2"
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_7_3
	export PFSPORTSFILE=buildports.RELENG_1_2
	set_items
;;

RELENG_8_1)
	echo ">>> Setting builder environment to use RELENG_8_1 ..."
	export FREEBSD_VERSION="8"
	export FREEBSD_BRANCH="RELENG_8_1"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/RELENG_8-supfile"
	export PFSENSE_VERSION=2.0-BETA3
	export PFSENSETAG=HEAD
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_8_1
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/patches.RELENG_8_1
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/copy.list.RELENG_8_0"	
	export PFSPORTSFILE=buildports.RELENG_2_0
	set_items
;;
esac

if [ "$HANDLED" = "false" ]; then 
	echo "Invalid verison."
fi
