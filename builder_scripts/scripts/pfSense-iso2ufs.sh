#!/bin/sh

# You can set some variables here. Edit them to fit your needs.

# Set serial variable to 0 if you don't want serial console at all,
# 1 if you want comconsole and 2 if you want comconsole and vidconsole
serial=1

# Set nowizard to 1 if you don't want to trigger the initial wizard
# on the web configurator. This option make sense only if you specify
# the custom config.xml argument
nowizard=0

set -u

if [ $# -lt 2 ]; then
    echo "Usage: $0 source-iso-path output-img-path [ custom-config-xml-path ]"
    exit 1
fi

isoimage=$1; shift
imgoutfile=$1; shift
if [ ! -z "${1:-}" ]; then
    customconfig=$1; shift
fi

export tmpdir=$(mktemp -d -t pfsmount)
# Temp file and directory to be used later
export tmpfile=$(mktemp -t pfsmount)

export isodev=$(mdconfig -a -t vnode -f ${isoimage})

echo "#### Building bootable UFS image ####"

UFS_LABEL="pfSense" # UFS label

# Root partition size
SECTS="120000"

echo "Initializing image..."
dd if=/dev/zero of=${imgoutfile} count=${SECTS}
ls -l ${imgoutfile}
export imgdev=$(mdconfig -a -t vnode -f ${imgoutfile})

bsdlabel -w -B ${imgdev}
newfs -L ${UFS_LABEL} -O1 /dev/${imgdev}a

mkdir -p ${tmpdir}/iso ${tmpdir}/img

mount -t cd9660 /dev/${isodev} ${tmpdir}/iso
mount /dev/${imgdev}a ${tmpdir}/img

echo "Copying files to the image..."
( cd ${tmpdir}/iso && find . -print -depth | cpio -dump ${tmpdir}/img )
bzcat ${tmpdir}/iso/dist/root.dist.bz2 | mtree -PUr -p ${tmpdir}/img 2>&1 > /dev/null

echo "/dev/ufs/${UFS_LABEL} / ufs ro 1 1" > ${tmpdir}/img/etc/fstab

if [ ${serial} -eq 2 ]; then
        echo "-D" > ${tmpdir}/img/boot.config
        echo 'console="comconsole, vidconsole"' >> ${tmpdir}/img/boot/loader.conf
elif [ ${serial} -eq 1 ]; then
        echo "-h" > ${tmpdir}/img/boot.config
        echo 'console="comconsole"' >> ${tmpdir}/img/boot/loader.conf
fi


if [ ! -z "${customconfig:-}" ]; then
    cp ${customconfig} ${tmpdir}/img/conf.default/config.xml
    if [ ${nowizard} -eq 1 ]; then
	rm ${tmpdir}/img/trigger_initial_wizard
    fi
fi

cleanup() {
    umount ${tmpdir}/iso
    mdconfig -d -u ${isodev}
    umount ${tmpdir}/img
    mdconfig -d -u ${imgdev}
    rm -rf ${tmpdir} ${tmpfile}
}

cleanup

ls -lh ${imgoutfile}