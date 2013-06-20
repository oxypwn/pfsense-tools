#!/bin/sh
#
# Common functions to be used by build scripts
#
#  build_mass_patch_kernels.sh
#  Copyright (C) 2004-2009 Scott Ullrich
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  
#  1. Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#  
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  
#  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
#  AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#  AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
#  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
#
# Crank up error reporting, debugging.
#  set -e 
#  set -x

CURRENTDIR=`pwd`
[ -r "${CURRENTDIR}/pfsense_local.sh" ] && . ${CURRENTDIR}/pfsense_local.sh

PFSPATCHDIR=${PFSPATCHDIR:-${BUILDER_TOOLS}/patches/${FREEBSD_BRANCH}}
SRCDIR=${SRCDIR:-/usr/pfSensesrc/src}

# Set these two options
FBSDBRANCH="RELENG_6_2"
KERNCONFCONFIG="pfSense_wrap.6"
KERNELOUTPUTDIR="/usr/local/www/data/kernels/"
PATHTOTESTKERNEL="/root/pfSense_wrap.6"
CVSUPHOST="cvsup.livebsd.com"

cp $PATHTOTESTKERNEL $SRCDIR/sys/${TARGET_ARCH}/conf/

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
	
	/usr/bin/csup -h cvsup.livebsd.com ${SUPFILE}
	echo "Building kernel with patch $PATCH_FILE"

	if [ $PATCH_FILE_LEN -gt "2" ]; then
		echo "Patching ${PATCH_FILE}"
		(cd ${SRCDIR}/${PATCH_DIRECTORY} && patch -f ${PATCH_DEPTH} < ${PFSPATCHDIR}/${PATCH_FILE})
	fi

	cd $SRCDIR && make buildkernel KERNCONF=$KERNCONFCONFIG && make installkernel KERNCONF=$KERNCONFCONFIG
	gzip /boot/kernel/kernel
	mv /boot/kernel/kernel.gz $KERNELOUTPUTDIR/kernel.gz-$PATCH_FILE
done

# Build a kernel without any patches at all
/usr/bin/csup -h $CVSUPHOST $BUILDER_TOOLS/builder_scripts/$FBSDBRANCH-supfile
cd $SRCDIR && make buildkernel KERNCONF=$KERNCONFCONFIG && make installkernel KERNCONF=$KERNCONFCONFIG
gzip /boot/kernel/kernel
mv /boot/kernel/kernel.gz $KERNELOUTPUTDIR/kernel.gz-NOPATCHES

# Copy kernel building file over
cp $PATHTOTESTKERNEL $KERNELOUTPUTDIR/
cp /root/patches.$FBSDBRANCH $KERNELOUTPUTDIR/

