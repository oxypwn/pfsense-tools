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
if [ -z "${MSDOS_CONF:-}" ]; then
	CONF_LABEL=${CONF_LABEL:-"pfSenseCfg"} # UFS label
else
	CONF_LABEL=${CONF_LABEL:-"PFSENSECFG"} # FAT label
fi

# Default parameters for the image, use diskinfo(1) to obtain yours
SECTS=${SECTS:-111072}  # Total number of sectors
SECTT=${SECTT:-32}      # Sectors/track
HEADS=${HEADS:-16}      # Heads

# Sectors reserved to /cf partition
if [ -z "${MSDOS_CONF:-}" ]; then
	CONFSIZE=${CONFSIZE:-"4096"}
else
	# Size must be >= 8 Mbytes for FAT16 partitions
	CONFSIZE=${CONFSIZE:-"16980"}
fi

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

if [ -z "${MSDOS_CONF:-}" ]; then
	rootoffset=${SECTT}
	rootsize=$((${SECTS} - ${CONFSIZE} - ${SECTT}))
	confoffset=$((${SECTS} - ${CONFSIZE}))
	confsize=${CONFSIZE}

	echo "g c${CYLINDERS} h${HEADS} s${SECTT}" > ${TMPFILE}
	echo "p 1 165 ${rootoffset} ${rootsize}" >> ${TMPFILE}
	echo "p 2 165 ${confoffset} ${confsize}" >> ${TMPFILE}
	echo "a 1" >> ${TMPFILE}
else
	rootoffset=$((${SECTT} + ${CONFSIZE}))
	rootsize=$((${SECTS} - ${CONFSIZE} - ${SECTT}))
	confsize=${CONFSIZE}
	confoffset=${SECTT}

	echo "g c${CYLINDERS} h${HEADS} s${SECTT}" > ${TMPFILE}
	echo "p 1 4 ${confoffset} ${confsize}" >> ${TMPFILE}
	echo "p 2 165 ${rootoffset} ${rootsize}" >> ${TMPFILE}
	echo "a 1" >> ${TMPFILE}
fi

cat ${TMPFILE}
fdisk -BI ${DEVICE}
fdisk -i -v -f ${TMPFILE} ${DEVICE}

if [ -z "${MSDOS_CONF:-}" ]; then
	bsdlabel -w -B ${DEVICE}s1
	newfs -b 4096 -f 512 -i 8192 -L ${UFS_LABEL} -O1 ${DEVICE}s1a
	bsdlabel -w -B ${DEVICE}s2
	newfs -b 4096 -f 512 -i 8192 -L ${CONF_LABEL} -O1 ${DEVICE}s2a
	mount /dev/${DEVICE}s1a ${TMPDIR}
else
	newfs_msdos -F 16 -L ${CONF_LABEL} ${DEVICE}s1
	bsdlabel -w -B ${DEVICE}s2
	newfs -b 4096 -f 512 -i 8192 -L ${UFS_LABEL} -O1 ${DEVICE}s2a
	mount /dev/${DEVICE}s2a ${TMPDIR}
fi


mkdir ${TMPDIR}/cf
if [ -z "${MSDOS_CONF:-}" ]; then
	mount /dev/${DEVICE}s2a ${TMPDIR}/cf
else
	mount_msdosfs -l /dev/${DEVICE}s1 ${TMPDIR}/cf
fi


echo "Writing files..."

cd ${CLONEDIR}
find . -print -depth | cpio -dump ${TMPDIR}
echo "/dev/ufs/${UFS_LABEL} / ufs ro 1 1" > ${TMPDIR}/etc/fstab
if [ -z "${MSDOS_CONF:-}" ]; then
	echo "/dev/ufs/${CONF_LABEL} /cf ufs ro 1 1" >> ${TMPDIR}/etc/fstab
else
	echo "/dev/msdosfs/${CONF_LABEL} /cf msdosfs rw,-l 1 1" >> ${TMPDIR}/etc/fstab
fi

umount ${TMPDIR}/cf
umount ${TMPDIR}

if [ ! -z "${MSDOS_CONF:-}" ]; then
	# Install the boot loader in MBR, if we are using msdos partition
	boot0cfg -B -b ${CLONEDIR}/boot/boot0sio -o packet -s 2 -t 1 ${DEVICE}
fi

echo "Dumping image to ${IMGPATH}..."

dd if=/dev/${DEVICE} of=${IMGPATH} bs=64k

mdconfig -d -u ${DEVICE}
rm -f ${TMPFILE}
rm -rf ${TMPDIR}

ls -lh ${IMGPATH}

