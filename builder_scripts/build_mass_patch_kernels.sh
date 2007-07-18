#!/bin/sh

# This script is for testing only!
# It will build a kernel for each patch line item and
# then output the kernels to $KERNELOUTPUTDIR

#set -e -x

CURRENTDIR=`pwd`
[ -r "${CURRENTDIR}/pfsense_local.sh" ] && . ${CURRENTDIR}/pfsense_local.sh

PATCHDIR=${PATCHDIR:-${BASE_DIR}/tools/patches/${freebsd_branch}}
SRCDIR=${SRCDIR:-/usr/src}

# Set these two options
FBSDBRANCH="RELENG_6_2"
KERNCONFCONFIG="pfSense_wrap.6"
KERNELOUTPUTDIR="/usr/local/www/data/kernels/"
PATHTOTESTKERNEL="/root/pfSense_wrap.6"
CVSUPHOST="cvsup.livebsd.com"

cp $PATHTOTESTKERNEL /usr/src/sys/i386/conf/

for LINE in `cat /root/patches.$FBSDBRANCH` 
do
	cd $CURRENTDIR
	# Loop through and patch files
	PATCH_DEPTH=`echo $LINE | cut -d~ -f1`
	PATCH_DIRECTORY=`echo $LINE | cut -d~ -f2`
	PATCH_FILE=`echo $LINE | cut -d~ -f3`
	PATCH_FILE_LEN=`echo $PATCH_FILE | wc -c`
	MOVE_FILE=`echo $LINE | cut -d~ -f4`
	MOVE_FILE_LEN=`echo $MOVE_FILE | wc -c`
	
	cvsup -h cvsup.livebsd.com /home/pfsense/tools/builder_scripts/$FBSDBRANCH-supfile
	echo "Building kernel with patch $PATCH_FILE"

	if [ $PATCH_FILE_LEN -gt "2" ]; then
		echo "Patching ${PATCH_FILE}"
		(cd ${SRCDIR}/${PATCH_DIRECTORY} && patch -f ${PATCH_DEPTH} < ${PATCHDIR}/${PATCH_FILE})
	fi

	cd /usr/src/ && make buildkernel KERNCONF=$KERNCONFCONFIG && make installkernel KERNCONF=$KERNCONFCONFIG
	gzip /boot/kernel/kernel
	mv /boot/kernel/kernel.gz $KERNELOUTPUTDIR/kernel.gz-$PATCH_FILE
done

# Build a kernel without any patches at all
cvsup -h $CVSUPHOST /home/pfsense/tools/builder_scripts/$FBSDBRANCH-supfile
cd /usr/src/ && make buildkernel KERNCONF=$KERNCONFCONFIG && make installkernel KERNCONF=$KERNCONFCONFIG
gzip /boot/kernel/kernel
mv /boot/kernel/kernel.gz $KERNELOUTPUTDIR/kernel.gz-NOPATCHES

# Copy kernel building file over
cp $PATHTOTESTKERNEL $KERNELOUTPUTDIR/
cp /root/patches.$FBSDBRANCH $KERNELOUTPUTDIR/

