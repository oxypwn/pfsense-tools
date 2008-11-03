#!/bin/sh

if [ $# -ne 1 ]; then
	echo 1>&2 Usage  : $0 pfSense branch
	echo 1>&2 example: $0 RELENG_1
	exit 127
fi

. ./pfsense_local.sh

strip_pfsense_local() {
	# Strip dynamic values
	cat $BUILDER_SCRIPTS/pfsense_local.sh | \
		grep -v FreeBSD_version | \
		grep -v freebsd_branch | \
		grep -v PFSENSETAG | \
		grep -v PFSPATCHFILE | \
		grep -v SUPFILE | \
		grep -v PFSPATCHDIR | \
		grep -v PFSENSE_VERSION | \
		grep -v OVERRIDE_FREEBSD_CVSUP_HOST > /tmp/pfsense_local.sh
	mv /tmp/pfsense_local.sh $BUILDER_SCRIPTS/pfsense_local.sh
}

case $1 in
RELENG_1)
	echo ">>> Setting builder environment to use RELENG_1 ..."
	strip_pfsense_local
	export pfSense_version="7"
	export FreeBSD_version="7"
	export freebsd_branch="RELENG_7"
	export SUPFILE="${BASE_DIR}/tools/builder_scripts/RELENG_7-supfile"
	export PFSENSEVERSION=${PFSENSEVERSION:-1.3-ALPHA-ALPHA}
	export PFSENSETAG=${PFSENSETAG:-RELENG_1}
	export PFSPATCHDIR=${BASE_DIR}/tools/patches/RELENG_7
	export PFSPATCHFILE=${BASE_DIR}/tools/builder_scripts/patches.RELENG_2_0
;;

RELENG_1_2)
	echo ">>> Setting builder environment to use RELENG_1_2 ..."
	strip_pfsense_local
	export pfSense_version="7"
	export FreeBSD_version="7"
	export freebsd_branch="RELENG_7_0"
	export SUPFILE="${BASE_DIR}/tools/builder_scripts/${freebsd_branch}-supfile"
	export PFSENSEVERSION=${PFSENSEVERSION:-1.2.1-RC2}
	export PFSENSETAG=${PFSENSETAG:-RELENG_1_2}
	export PFSPATCHDIR=${BASE_DIR}/tools/patches/${freebsd_branch}
	export PFSPATCHFILE=${BASE_DIR}/tools/builder_scripts/patches.${PFSENSETAG}
;;

RELENG_2_0)
	echo ">>> Setting builder environment to use RELENG_2_0 ..."
	strip_pfsense_local
	export pfSense_version="7"
	export FreeBSD_version="7"
	export freebsd_branch="RELENG_7"
	export SUPFILE="${BASE_DIR}/tools/builder_scripts/RELENG_7-supfile"
	export PFSENSEVERSION=${PFSENSEVERSION:-1.3-ALPHA-ALPHA}
	export PFSENSETAG=${PFSENSETAG:-RELENG_1}
	export PFSPATCHDIR=${BASE_DIR}/tools/patches/RELENG_7
	export PFSPATCHFILE=${BASE_DIR}/tools/builder_scripts/patches.RELENG_2_0
;;

esac

# Add our custom dynamic values
echo export PFSENSEVERSION="${PFSENSEVERSION}" >> $BUILDER_SCRIPTS/pfsense_local.sh
echo export FreeBSD_version="${FREEBSD_VERSION}" >> $BUILDER_SCRIPTS/pfsense_local.sh
echo export freebsd_branch="${FREEBSD_PLATFORM}" >> $BUILDER_SCRIPTS/pfsense_local.sh
echo export PFSENSETAG="${PFSENSE_PLATFORM}" >> $BUILDER_SCRIPTS/pfsense_local.sh
echo export PATCHFILE="${FREEBSD_PATCHFILE}" >> $BUILDER_SCRIPTS/pfsense_local.sh
echo export PFSPATCHDIR="${FREEBSD_PATCHDIR}" >> $BUILDER_SCRIPTS/pfsense_local.sh
echo export PFSENSE_VERSION="${PFSENSE_VERSION}" >> $BUILDER_SCRIPTS/pfsense_local.sh
echo export SUPFILE="${FREEBSD_SUPFILE}" >> $BUILDER_SCRIPTS/pfsense_local.sh	
#echo export OVERRIDE_FREEBSD_CVSUP_HOST="cvsup.livebsd.com" >> $BUILDER_SCRIPTS/pfsense_local.sh


