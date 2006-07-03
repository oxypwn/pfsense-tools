#!/bin/sh

# pfSense master builder script
# (C)2005-2006 Scott Ullrich and the pfSense project
# All rights reserved.
#
# $Id$

set -e -u

# If a full build has been performed we need to nuke
# /usr/obj.pfSense/ since embedded uses a different
# make.conf
if [ -f /usr/obj.pfSense/pfSense.6.world.done ]; then
	echo -n "Removing /usr/obj* since full build performed prior..."
	rm -rf /usr/obj*
	echo "done."
fi

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Use pfSense_wrap.6 as kernel configuration file
export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense_wrap.6}
export NO_COMPRESSEDFS=yes
export PRUNE_LIST="${PWD}/remove.list"
if [ $pfSense_version = "7" ]; then
	export PRUNE_LIST="${PWD}/remove.list.7"
fi

# Use embedded make.conf
export MAKE_CONF="${PWD}/conf/make.conf.embedded.install"
if [ $pfSense_version = "7" ]; then
	export MAKE_CONF="${PWD}/conf/make.conf.embedded.7.install"
fi

# Clean out directories
freesbie_make cleandir

# Checkout a fresh copy from pfsense cvs depot
update_cvs_depot

# Calculate versions
version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
version_base=`cat $CVS_CO_DIR/etc/version_base`
version=`cat $CVS_CO_DIR/etc/version`

# Build if needed and install world and kernel
make_world_kernel

export MAKE_CONF="${PWD}/conf/make.conf.embedded.install"
if [ $pfSense_version = "7" ]; then
        export MAKE_CONF="${PWD}/conf/make.conf.embedded.7.install"
fi

# Add extra files such as buildtime of version, bsnmpd, etc.
populate_extra

# Only include Lighty in packages list
(cd /var/db/pkg && ls | grep lighttpd) > conf/packages

fixup_wrap

# Invoke FreeSBIE2 toolchain
freesbie_make clonefs

echo "#### Building bootable UFS image ####"

UFS_LABEL=${FREESBIE_LABEL:-"pfSense"} # UFS label
CONF_LABEL=${CONF_LABEL:-"pfSenseCfg"} # UFS label

# Root partition size
# ROOTSIZE=${ROOTSIZE:-"116740"}  # Total number of sectors - 59 megs
if [ $pfSense_version = "7" ]; then
	# 128 megs 
	ROOTSIZE=${ROOTSIZE:-"218048"}  # Total number of sectors
	CONFSIZE=${CONFSIZE:-"4096"}
fi
if [ $pfSense_version = "6" ]; then
	# 64 megs
	ROOTSIZE=${ROOTSIZE:-"119990"}  # Total number of sectors - 61 megs
	CONFSIZE=${CONFSIZE:-"4096"}
fi

SECTS=$((${ROOTSIZE} + ${CONFSIZE}))
# Temp file and directory to be used later
TMPFILE=`mktemp -t freesbie`
TMPDIR=`mktemp -d -t freesbie`

echo "Initializing image..."
dd if=/dev/zero of=${IMGPATH} count=${SECTS}

# Attach the md device
DEVICE=`mdconfig -a -t vnode -f ${IMGPATH}`

cat > ${TMPFILE} <<EOF
a:	*	0	4.2BSD	1024	8192	99
c:	${SECTS}	0	unused	0	0
d:	${CONFSIZE}	*	4.2BSD	1024	8192	99
EOF

bsdlabel -BR ${DEVICE} ${TMPFILE}

newfs -L ${UFS_LABEL} -O1 /dev/${DEVICE}a
newfs -L ${CONF_LABEL} -O1 /dev/${DEVICE}d


mount /dev/${DEVICE}a ${TMPDIR}
mkdir ${TMPDIR}/cf
mount /dev/${DEVICE}d ${TMPDIR}/cf

echo "Writing files..."

cd ${CLONEDIR}
find . -print -depth | cpio -dump ${TMPDIR}

echo "/dev/ufs/${UFS_LABEL} / ufs ro 1 1" > ${TMPDIR}/etc/fstab
echo "/dev/ufs/${CONF_LABEL} /cf ufs ro 1 1" >> ${TMPDIR}/etc/fstab

umount ${TMPDIR}/cf
umount ${TMPDIR}

mdconfig -d -u ${DEVICE}
rm -f ${TMPFILE}
rm -rf ${TMPDIR}

ls -lh ${IMGPATH}
