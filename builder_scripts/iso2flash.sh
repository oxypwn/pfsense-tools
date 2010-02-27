#!/bin/sh
# $Id$
# convert an ISO image to flash image
# The type of filesystem depends on the content, but can be forced
# manually.
#
# based on picobsd tricks.
# Requires makefs, bsdlabel, sed and dd
# The linux image uses mtools and syslinux, see
# 	http://info.iet.unipi.it/~luigi/FreeBSD/#syslinux-port
# see http://www.allbootdisks.com/download/iso.html

MAKEFS=makefs
MKLABEL=bsdlabel
BSDTAR=tar

# Create a linux disk starting from an ISO. Use a FAT media
# and syslinux to format it. Add some intelligence to figure
# out where the kernel is and what options it needs.

make_linux_image() {	# src_tree dest_image
    local tree=$1
    local img=$2
    local size=$(( $3 + 1000 ))		# size in kb
    local x=$(( 1 + $size / 128 ))	# 128k units, good for dd
    # if you have an old newfs_msdos...
    local OPTS=" -h 16 -u 64 -S 512 -s $(( 2 * ${size} )) -o 0"
    [ -f ${img} ] && { chmod u+w ${img}; rm ${img} ; }
    dd if=/dev/zero bs=128k count=$x of=${img}	# create blank file
    newfs_msdos ${OPTS} ${img}				# format msdos
    syslinux ${img}			# add linux bootcode

    # Try to identify where the kernel is
    local boot=`find $tree -name boot`
    if [ x"${boot}" != x -a -d "${boot}" ] ; then
	echo "moving boot code"
	chmod u+w ${boot} ${boot}/*
	mv ${boot}/* $tree
	[ -f ${tree}/syslinux.cfg ] || mv ${tree}/isolinux.cfg ${tree}/syslinux.cfg
    fi
    if [ -d ${tree}/isolinux ] ; then
	# systemrescuecd
	local sys=${tree}/syslinux
	echo moving files... 
	[ -d ${sys} ] || mkdir -p ${sys}
	chmod -R u+w ${tree}/isolinux
	mv ${tree}/isolinux/* ${sys}
	[ -f ${sys}/syslinux.cfg ] || mv ${sys}/isolinux.cfg ${sys}/syslinux.cfg
    fi
    if [ -f ${tree}/syslinux.cfg ] ; then
    elif [ -f ${tree}/syslinux/syslinux.cfg ] ; then
    elif [ -f ${tree}/linux ] ; then
    elif [ -f ${tree}/CE_BZ ] ; then
	# splashtop / expressgate
	echo "default ce_bz" > ${tree}/syslinux.cfg
    else
	boot=`cd ${tree}; find . -name boot.img`
	if [ x"${boot}" != x -a -f "${tree}/${boot}" ] ; then
	    cp -p /usr/local/share/syslinux/memdisk $tree
	    ( echo "default memdisk"; 
		echo "append initrd=${boot}" ) > $tree/syslinux.cfg
	fi
    fi
    mcopy -i ${img} -s ${tree}/* ::/		# copy the tree
    mdir -/ -i  ${img} ::			# show the results
}

# to add freedos code:
    #perl sys-freedos.pl --disk=${img} --heads=16 --sectors=64 --offset=0 # --lb
    #dd if=mbrfat.bin bs=90 iseek=1 oseek=1 of=${img} conv=notrunc

# Create a FreeBSD image.
make_freebsd_image() {	# tree imagefile size
    local tree=$1
    local imagefile=$2
    local boot1=${tree}/boot/boot1
    local boot2=${tree}/boot/boot2

    echo "convert tree $tree image $img"
    ${MAKEFS} -t ffs -o bsize=4096 -o fsize=512 \
        -f 50 ${imagefile} ${tree}
    ${MKLABEL} -w -f ${imagefile} auto # write a label
    # copy partition c: into a: with some sed magic
    ${MKLABEL} -f ${imagefile} | sed -e '/  c:/{p;s/c:/a:/;}' | \
        ${MKLABEL} -R -f ${imagefile} /dev/stdin

    # dump the primary and secondary boot (primary is 512 bytes)
    dd if=${boot1} of=${imagefile} conv=notrunc 2>/dev/null
    # XXX secondary starts after the 0x114 = dec 276 bytes of the label
    # so we skip 276 from the source, and 276+512=788 from dst
    # the old style blocks used 512 and 1024 respectively
    dd if=${boot2} iseek=1 ibs=276 2> /dev/null | \
        dd of=${imagefile} oseek=1 obs=788 conv=notrunc 2>/dev/null
}

extract_image() {	# extract image to a tree
    [ -f $1 ] || return
    local tmp="${tree}.tree"
    echo "Extract files from ${tree} into $tmp "
    (chmod -R +w $tmp; rm -rf $tmp )
    mkdir -p $tmp
    ls -la $tmp
    (cd $tmp && ${BSDTAR} xf $tree )
    ls -la $tmp
    tree=$tmp
}

guess_type() {
    echo guess type
    imgtype="error"	# default
    [ -f $tree/boot/loader -a -f $tree/boot/loader.rc ] && { imgtype="bsd"; return ; }
    local a=`find $tree -name isolinux`
    [ x"$a" != x -a -d $a ] && { imgtype="linux"; return ; }
}

# option processing
while [ x"$*" != x ] ; do
    case x"$1" in
    x-t )	# type
	shift
	imgtype=$1
	;;
    *)
	break
	;;
    esac
    shift
done

tree=`realpath $1`
image=`realpath $2`
echo "type <$imgtype> tree <$tree> image <$image>"

extract_image $tree
set `du -sk $tree`
size=$1
echo "image size is $size kb"

while true ; do
    case x"$imgtype" in
    *[Bb][Ss][Dd] )
	make_freebsd_image $tree $image $size
	;;
    *[Ll][Ii][Nn][Uu][Xx] )
	make_linux_image $tree $image $size
	;;
    xerror)
	echo "Image type not found, giving up"
	;;
    * )
	guess_type
	continue
	;;
    esac
    break
done
[ -d "$tmp" ] && (chmod -R u+w $tmp && rm -rf $tmp)
