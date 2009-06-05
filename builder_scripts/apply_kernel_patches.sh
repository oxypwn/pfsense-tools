#!/bin/sh

# This script is for testing only!
# It will build a kernel for each patch line item and
# then output the kernels to $KERNELOUTPUTDIR

#set -e -x

CURRENTDIR=`pwd`
[ -r "${CURRENTDIR}/pfsense_local.sh" ] && . ${CURRENTDIR}/pfsense_local.sh

SRCDIR=${SRCDIR:-/usr/pfSensesrc/src}

echo ">>> Using patchfile ${PFSPATCHFILE} ..."
echo ">>> Using supfile   ${SUPFILE} ..."

# Loop through and remove files
for LINE in `cat ${PFSPATCHFILE}`
do
	PATCH_RM=`echo $LINE | cut -d~ -f4`
	PATCH_RM_LENGTH=`echo $PATCH_RM | wc -c`
	DIR_CREATE=`echo $LINE | cut -d~ -f5`
	if [ $PATCH_RM_LENGTH -gt "2" ]; then
		echo "Removing ${SRCDIR}${PATCH_RM}"
		rm -rf ${SRCDIR}${PATCH_RM}
	fi
	if [ "$DIR_CREATE" != "" ]; then
		echo "Creating ${SRCDIR}/${DIR_CREATE}"
		mkdir -p ${SRCDIR}/${DIR_CREATE}
	fi	
done

# If override is in place, use it otherwise
# locate fastest cvsup host
if [ ! -z ${OVERRIDE_FREEBSD_CVSUP_HOST:-} ]; then
	echo "Setting CVSUp host to ${OVERRIDE_FREEBSD_CVSUP_HOST}"
	echo $OVERRIDE_FREEBSD_CVSUP_HOST > /var/db/fastest_cvsup
else
	echo "Finding fastest CVSUp host... Please wait..."
	fastest_cvsup -c tld -q > /var/db/fastest_cvsup
fi

# CVSUp freebsd version
echo "Using FreeBSD ${pfSense_version} branch ${FREEBSD_BRANCH}"
/usr/bin/csup -b ${SRCDIR} -h `cat /var/db/fastest_cvsup` ${SUPFILE}

echo "Removing old patch rejects..."
find $SRCDIR -name "*.rej" -exec rm {} \;

# Loop through and patch files
for LINE in `cat ${PFSPATCHFILE}`
do
	PATCH_DEPTH=`echo $LINE | cut -d~ -f1`
	PATCH_DIRECTORY=`echo $LINE | cut -d~ -f2`
	PATCH_FILE=`echo $LINE | cut -d~ -f3`
	PATCH_FILE_LEN=`echo $PATCH_FILE | wc -c`
	MOVE_FILE=`echo $LINE | cut -d~ -f4`
	MOVE_FILE_LEN=`echo $MOVE_FILE | wc -c`
	IS_TGZ=`echo $LINE | grep -v grep | grep .tgz | wc -l`
	if [ $PATCH_FILE_LEN -gt "2" ]; then
		if [ $IS_TGZ -gt "0" ]; then 
			echo "Extracting ${PATCH_FILE} to ${PFSPATCHDIR}"
			(cd ${SRCDIR}/${PATCH_DIRECTORY} && tar xzvpf ${PFSPATCHDIR}/${PATCH_FILE}) 2>&1 \
			| egrep -wi '(warning|error)'
		else
			echo "Patching ${PATCH_FILE}"
			(cd ${SRCDIR}/${PATCH_DIRECTORY} && patch -f ${PATCH_DEPTH} < ${PFSPATCHDIR}/${PATCH_FILE}) 2>&1 \
			| egrep -wi '(patching\ file|warning|error)'
			if [ $? != 0 ]; then
				echo "Failed to apply patch ${PFSPATCHDIR}/${PATCH_FILE}"
				find $SRCDIR -name "*.rej"
			fi
		fi
	fi
	if [ $MOVE_FILE_LEN -gt "2" ]; then
		#cp ${SRCDIR}/${MOVE_FILE} ${SRCDIR}/${PATCH_DIRECTORY}
	fi
done

echo "Finding patch rejects..."
REJECTED_PATCHES=`find $SRCDIR -name "*.rej" | wc -l`
if [ $REJECTED_PATCHES -gt 0 ]; then
	echo
	echo "WARNING!  Rejected patches found!  Please fix before building!"
	echo 
	find $SRCDIR -name "*.rej" 
	echo
fi

