#!/bin/sh

# pfSense master builder script
# (C)2005-2006 Scott Ullrich and the pfSense project
# All rights reserved.
#
# $Id$

# Crank up error reporting, debugging.
#set -e 
#set -x

# If a full build has been performed we need to nuke
# /usr/obj.pfSense/ since embedded uses a different
# make.conf
if [ -f /usr/obj.pfSense/pfSense.$FREEBSD_VERSION.world.done ]; then
	echo -n "Removing /usr/obj* since full build performed prior..."
	rm -rf /usr/obj*
	echo "done."
fi

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Make sure cvsup_current has been run first 
check_for_clog

# Output build flags
print_flags

# Allow old CVS_CO_DIR to be deleted later
chflags -R noschg $CVS_CO_DIR

export NO_COMPRESSEDFS=yes

if [ ! -z "${CUSTOM_REMOVE_LIST:-}" ]; then
	echo ">>> Using ${CUSTOM_REMOVE_LIST:-} ..."
	export PRUNE_LIST="${CUSTOM_REMOVE_LIST:-}"
else
	echo ">>> Using ${PWD}/remove.list.iso.$FREEBSD_VERSION ..."
	export PRUNE_LIST="${PWD}/remove.list.iso.$FREEBSD_VERSION"
fi

# Use embedded make.conf
export MAKE_CONF="${PWD}/conf/make.conf.embedded.$FREEBSD_VERSION"
export SRC_CONF="${PWD}/conf/make.conf.embedded.$FREEBSD_VERSION"
export SRC_CONF_INSTALL="${PWD}/conf/make.conf.embedded.$FREEBSD_VERSION.install"

# Clean out directories
freesbie_make cleandir

# Checkout a fresh copy from pfsense cvs depot
update_cvs_depot

# Calculate versions
version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
version_base=`cat $CVS_CO_DIR/etc/version_base`
version=`cat $CVS_CO_DIR/etc/version`

# Build if needed and install world and kernel
echo ">>> Building world and kernels for Embedded... $FREEBSD_VERSION  $FREEBSD_BRANCH ..."
make_world

# Build embedded kernel
build_embedded_kernel

# Add extra files such as buildtime of version, bsnmpd, etc.
cust_populate_extra

# Add extra pfSense packages
install_custom_packages

# Only include Lighty in packages list
(cd /var/db/pkg && ls | grep lighttpd) > conf/packages

# Add extra files such as buildtime of version, bsnmpd, etc.
echo ">>> Phase populate_extra..."
cust_populate_extra

# Overlay pfsense checkout on top of FreeSBIE image
# using the customroot plugin
echo ">>> Merging extra items..."
freesbie_make extra

# Overlay host binaries
cust_overlay_host_binaries

# Must be run after overlay_host_binaries and freesbie_make extra
cust_fixup_wrap

# Check for custom config.xml
cust_install_config_xml

# Install custom pfSense-XML packages from a chroot
pfsense_install_custom_packages_exec

# Overlay final files
install_custom_overlay_final

# Ensure config.xml exists
copy_config_xml_from_conf_default

# Invoke FreeSBIE2 toolchain
check_for_zero_size_files
freesbie_make clonefs

# Ensure /home exists
mkdir -p $CLONEDIR/home

# Fixup library changes if needed
fixup_libmap

echo "#### Building bootable UFS image ####"

UFS_LABEL=${FREESBIE_LABEL:-"pfSense"} # UFS label
CONF_LABEL=${CONF_LABEL:-"pfSenseCfg"} # UFS label

###############################################################################
#		59 megabyte image.
#		ROOTSIZE=${ROOTSIZE:-"116740"}  # Total number of sectors - 59 megs
#		CONFSIZE=${CONFSIZE:-"4096"}
###############################################################################
#		128 megabyte image.
#		ROOTSIZE=${ROOTSIZE:-"235048"}  # Total number of sectors - 128 megs
#		CONFSIZE=${CONFSIZE:-"4096"}
###############################################################################
#		500 megabyte image.  Will be used later.
#		ROOTSIZE=${ROOTSIZE:-"1019990"}  # Total number of sectors - 500 megs
#		CONFSIZE=${CONFSIZE:-"4096"}
###############################################################################

unset ROOTSIZE
unset CONFSIZE
ROOTSIZE=${ROOTSIZE:-"235048"}  # Total number of sectors - 128 megabytes
CONFSIZE=${CONFSIZE:-"10240"}

SECTS=$((${ROOTSIZE} + ${CONFSIZE}))
# Temp file and directory to be used later
TMPFILE=`mktemp -t freesbie`
TMPDIR=`mktemp -d -t freesbie`

echo "Initializing image..."
dd if=/dev/zero of=${IMGPATH} count=${SECTS}

# Attach the md device
DEVICE=`mdconfig -a -t vnode -f ${IMGPATH}`

cat > ${TMPFILE} <<EOF
a:	*			0	4.2BSD	1024	8192	99
c:	${SECTS}	0	unused	0		0
d:	${CONFSIZE}	*	4.2BSD	1024	8192	99
EOF

bsdlabel -BR ${DEVICE} ${TMPFILE}

newfs -L ${UFS_LABEL} -O2 /dev/${DEVICE}a
newfs -L ${CONF_LABEL} -O2 /dev/${DEVICE}d

mount /dev/${DEVICE}a ${TMPDIR}
mkdir ${TMPDIR}/cf
mount /dev/${DEVICE}d ${TMPDIR}/cf

echo "Currently mounted Embedded partitions:"
df -h | grep ${DEVICE}

echo "Writing files..."

cd ${CLONEDIR}
find . -print -depth | cpio -dump ${TMPDIR}

echo -n ">>> Creating md5 summary of files present..."
rm -f ./etc/pfSense_md5.txt
chroot $CLONEDIR /usr/bin/find / -type f | /usr/bin/xargs /sbin/md5 >> ./etc/pfSense_md5.txt
echo "Done."

echo "/dev/ufs/${UFS_LABEL} / ufs ro 1 1" > ${TMPDIR}/etc/fstab
echo "/dev/ufs/${CONF_LABEL} /cf ufs ro 1 1" >> ${TMPDIR}/etc/fstab

umount ${TMPDIR}/cf
umount ${TMPDIR}

mdconfig -d -u ${DEVICE}
rm -f ${TMPFILE}
rm -rf ${TMPDIR}

ls -lh ${IMGPATH}

report_zero_sized_files

email_operation_completed