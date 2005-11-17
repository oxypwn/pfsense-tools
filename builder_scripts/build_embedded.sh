#!/bin/sh

# pfSense master builder script
# (C)2005 Scott Ullrich and the pfSense project
# All rights reserved.

set -e -u

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Use pfSense_wrap.6 as kernel configuration file
export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense_wrap.6}

# Clean out directories
freesbie_make cleandir


# Update cvs depot. If SKIP_RSYNC is defined, skip the RSYNC update.
# If also SKIP_CHECKOUT is defined, don't update the tree at all
if [ -z "${SKIP_RSYNC:-}" ]; then
	rm -rf $BASE_DIR/pfSense
	rsync -avz ${CVS_USER}@${CVS_IP}:/cvsroot /home/pfsense/
	(cd $BASE_DIR && cvs -d /home/pfsense/cvsroot co -r ${PFSENSETAG} pfSense)
elif [ -z "${SKIP_CHECKOUT:-}" ]; then
	rm -rf $BASE_DIR/pfSense
	(cd $BASE_DIR && cvs -d :ext:${CVS_USER}@${CVS_IP}:/cvsroot co -r ${PFSENSETAG} pfSense)
fi

# Calculate versions
version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
version_base=`cat $CVS_CO_DIR/etc/version_base`
version=`cat $CVS_CO_DIR/etc/version`

# Check if the world and kernel are already built and set
# the NO variables accordingly
objdir=${MAKEOBJDIRPREFIX:-/usr/obj}
build_id=`basename ${KERNELCONF}`
if [ -f "${objdir}/${build_id}.world.done" ]; then
	export NO_BUILDWORLD=yo
fi
if [ -f "${objdir}/${build_id}.kernel.done" ]; then
	export NO_BUILDKERNEL=yo
fi

# Make world
freesbie_make buildworld
touch ${objdir}/${build_id}.world.done

# Make kernel
freesbie_make buildkernel
touch ${objdir}/${build_id}.kernel.done

freesbie_make installkernel installworld

# Add extra files such as buildtime of version, bsnmpd, etc.
populate_extra

# Packages list should be empty
echo > conf/packages

 
fixup_wrap

# Invoke FreeSBIE2 toolchain
freesbie_make clonefs

echo "#### Building bootable UFS image ####"

UFS_LABEL=${FREESBIE_LABEL:-"pfSense"} # UFS label
CONF_LABEL=${CONF_LABEL:-"pfSenseConf"} # UFS label
# Default parameters for the image, use diskinfo(1) to obtain yours
SECTS=${SECTS:-111072}  # Total number of sectors
SECTT=${SECTT:-32}      # Sectors/track
HEADS=${HEADS:-16}      # Heads


# Temp file and directory to be used later
TMPFILE=`mktemp -t freesbie`
TMPDIR=`mktemp -d -t freesbie`

# Size of cylinder in sectors
CYLSIZE=$((${SECTT} * ${HEADS}))

# Number of cylinders
CYLINDERS=$((${SECTS} / ${CYLSIZE}))

# Recalculate number of available sectors
SECTS=$((${CYLINDERS} * ${CYLSIZE}))

echo "Initializing image..."
dd if=/dev/zero of=${IMGPATH} count=${SECTS}

# Attach the md device
DEVICE=`mdconfig -a -t vnode -f ${IMGPATH} -x ${SECTT} -y ${HEADS}`
rm -f ${IMGPATH}

echo "g c${CYLINDERS} h${HEADS} s${SECTT}" > ${TMPFILE}
echo "p 1 165 ${SECTT} $((${SECTS} - ${SECTT}))" >> ${TMPFILE}
echo "a 1" >> ${TMPFILE}

fdisk -BI ${DEVICE}
fdisk -i -v -f ${TMPFILE} ${DEVICE}

SLICESIZE=$(fdisk ${DEVICE} | grep ", size" | awk '{print $4}')

CONFSIZE=4096 # counted in 512-byte blocks

AVAILSIZE=$((${SLICESIZE} - ${CONFSIZE}))

printf "a:\t${AVAILSIZE}\t0\tunused\t0\t0\t0\n" > ${TMPFILE} 
printf "c:\t${SLICESIZE}\t0\tunused\t0\t0\t0\n" >> ${TMPFILE} 
printf "d:\t${CONFSIZE}\t${AVAILSIZE}\tunused\t0\t0\t0\n" >> ${TMPFILE} 


bsdlabel -RB ${DEVICE}s1 ${TMPFILE}

newfs -b 4096 -f 512 -i 8192 -L ${UFS_LABEL} -O1 ${DEVICE}s1a
newfs -b 4096 -f 512 -i 8192 -L ${CONF_LABEL} -O1 ${DEVICE}s1d
bsdlabel ${DEVICE}s1 > ${TMPFILE}
cat ${TMPFILE}

mount /dev/${DEVICE}s1a ${TMPDIR}
mkdir ${TMPDIR}/cf
mount /dev/${DEVICE}s1d ${TMPDIR}/cf

echo "Writing files..."

cd ${CLONEDIR}
find . -print -depth | cpio -dump -v ${TMPDIR}
echo "/dev/ufs/${UFS_LABEL} / ufs ro 1 1" > ${TMPDIR}/etc/fstab
echo "/dev/ufs/${CONF_LABEL} /cf ufs ro 1 1" >> ${TMPDIR}/etc/fstab

umount ${TMPDIR}/cf
umount ${TMPDIR}

echo "Dumping image to ${IMGPATH}..."

dd if=/dev/${DEVICE} of=${IMGPATH} bs=64k

mdconfig -d -u ${DEVICE}
rm -f ${TMPFILE}
rm -rf ${TMPDIR}

ls -lh ${IMGPATH}
