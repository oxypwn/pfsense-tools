#!/bin/sh
#
#
# Copyright and rewritten by 2006 marcel stritzelberger / computing competence
# Heavily inspired but rewritten by http://www.hacom.net
# Contact: marcel AT stritzelberger.de
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

# This Skript takes an original pfSense image and turns
# it into a new and bigger one.
# You have to give the script the size and the sourcefile
# Example: /root/mkflash_new.sh 128 /root/pfSense.img

SIZE="$1"
ORIGINALCF="$2"
FLASHTMP=`pwd`

case "$SIZE" in
128)
	    echo "`date '+%b %e %T'`: Creating 128MB Compact Flash"
	    flash_MB=122
	    conf_MB=2
	    root_MB=$(( $flash_MB - $conf_MB ))
	    heads=64
	    sectors=32
	    ;;
256)
	    echo "`date '+%b %e %T'`: Creating 256MB Compact Flash"
	    flash_MB=222
	    conf_MB=4
	    root_MB=$(( $flash_MB - $conf_MB ))
	    heads=16
	    sectors=32
	    ;;
512)
	    echo "`date '+%b %e %T'`: Creating 512MB Compact Flash"
	    flash_MB=485
	    conf_MB=4
	    root_MB=$(( $flash_MB - $conf_MB ))
	    heads=16
	    sectors=32
	    ;;
1024)
	    echo "`date '+%b %e %T'`: Creating 1 Gigabyte Compact Flash"
	    flash_MB=978
	    conf_MB=4
	    root_MB=$(( $flash_MB - $conf_MB ))
	    heads=128
	    sectors=32
	    ;;

2048)
	    echo "`date '+%b %e %T'`: Creating 2 Gigabyte Compact Flash"
	    flash_MB=1960
	    conf_MB=4
	    root_MB=$(( $flash_MB - $conf_MB ))
	    heads=256
	    sectors=32
	    ;;

8192)
	    echo "`date '+%b %e %T'`: Creating 8 Gigabyte Compact Flash"
	    flash_MB=7696
	    conf_MB=8
	    root_MB=$(( $flash_MB - $conf_MB ))
	    heads=1024
	    sectors=32
	    ;;


*)
	    echo "Usage: $0 {128|256|512|1024|2048|8192} {Originalimage}"
	    exit 1
	    ;;
esac

case "$ORIGINALCF" in
"")
	    echo "`date '+%b %e %T'`: Uups! Where is the original pfSense image? Exiting..."
	    exit 1
	    ;;
*)
	    echo "`date '+%b %e %T'`: And using $ORIGINALCF as source image."
	    ;;
esac

echo "`date '+%b %e %T'`:"

# Calculate all the required derived variables...
bs=512          # do not change!
flash_blocks=$(( $flash_MB * 1024 * 1024 / $bs ))
root_blocks=$(( $root_MB * 1024 * 1024 / $bs ))
conf_blocks=$(( $conf_MB * 1024 * 1024 / $bs ))
conf_block_offset=$(( $root_blocks ))
conf_byte_offset=$(( $conf_block_offset * $bs ))
cylinders=$(( $(( $flash_blocks )) /  $heads / $sectors ))

echo "`date '+%b %e %T'`: 	Real flash size: $flash_MB MB"
echo "`date '+%b %e %T'`: 	root size: $root_MB, root blocks: $root_blocks $root_block_offset"
echo "`date '+%b %e %T'`: 	conf size: $conf_MB, conf blocks: $conf_blocks $conf_block_offset"
echo "`date '+%b %e %T'`: 	cylinders: $cylinders, heads: $heads, sectors: $sectors"

echo "`date '+%b %e %T'`:"

############################################################################
#                                                                          #
# Creating empty flash image in `pwd`/pfSense.img                          #
#                                                                          #
############################################################################
echo "`date '+%b %e %T'`: Creating empty ${1}MB flash image in $FLASHTMP"
dd if=/dev/zero of=$FLASHTMP/pfSense-${1}MB.img bs=$bs count=$flash_blocks >/dev/null 2>&1

echo "`date '+%b %e %T'`:"

############################################################################
#                                                                          #
# Making filesystems                                                       #
#                                                                          #
############################################################################
echo "`date '+%b %e %T'`: Preparing Filesystems on $FLASHTMP/pfSense-${1}MB.img"
MD=`mdconfig -a -t vnode -f $FLASHTMP/pfSense-${1}MB.img`

TMPFILE1=`mktemp -t pfsenselabel`
cat >$TMPFILE1 <<-EOF
# /dev/md0:
8 partitions:
#        size   offset    fstype   [fsize bsize bps/cpg]
  a:   $root_blocks        0    4.2BSD     1024  8192 15000
  c:   $(( $root_blocks + $conf_blocks ))        0    unused        0     0         # "raw" part, don't edit
  d:   $conf_blocks     $root_blocks    4.2BSD     1024  8192   520
EOF
echo "`date '+%b %e %T'`:	Bsdlabel"
bsdlabel -R /dev/${MD} $TMPFILE1 >/dev/null 2>&1
bsdlabel -B /dev/${MD} >/dev/null 2>&1
echo "`date '+%b %e %T'`:	Newfs"
newfs /dev/${MD}a >/dev/null 2>&1
tunefs -L pfSense /dev/${MD}a >/dev/null 2>&1
newfs /dev/${MD}d >/dev/null 2>&1
tunefs -L pfSenseCfg /dev/${MD}d >/dev/null 2>&1
rm $TMPFILE1

mdconfig -d -u ${MD} >/dev/null 2>&1

echo "`date '+%b %e %T'`:"

############################################################################
#                                                                          #
# Extracting original filesystemcontent                                    #
#                                                                          #
############################################################################
echo "`date '+%b %e %T'`: Extracting content from $ORIGINALCF"
mkdir -p $FLASHTMP/mnt/a >/dev/null 2>&1
mkdir -p $FLASHTMP/mnt/d >/dev/null 2>&1
MD=`mdconfig -a -t vnode -f $ORIGINALCF`
mount /dev/${MD}a $FLASHTMP/mnt/a
mount /dev/${MD}d $FLASHTMP/mnt/d
cd $FLASHTMP/mnt/a
echo "`date '+%b %e %T'`:	-> $FLASHTMP/pfSense-slash.tar.bz2"
tar jcf $FLASHTMP/pfSense-slash.tar.bz2 .
cd $FLASHTMP/mnt/d
echo "`date '+%b %e %T'`:	-> $FLASHTMP/pfSense-conf.tar.bz2"
tar jcf $FLASHTMP/pfSense-conf.tar.bz2 .
cd $FLASHTMP
umount /dev/${MD}a
umount /dev/${MD}d
mdconfig -d -u ${MD} >/dev/null 2>&1

echo "`date '+%b %e %T'`:"

############################################################################
#                                                                          #
# Recreating filesystemcontent on new image                                #
#                                                                          #
############################################################################
echo "`date '+%b %e %T'`: Restoring content to $FLASHTMP/pfSense-${1}MB.img"
MD=`mdconfig -a -t vnode -f $FLASHTMP/pfSense-${1}MB.img`
mount /dev/${MD}a $FLASHTMP/mnt/a
mount /dev/${MD}d $FLASHTMP/mnt/d
cd $FLASHTMP/mnt/a
echo "`date '+%b %e %T'`:	<- $FLASHTMP/pfSense-slash.tar.bz2"
tar jxf $FLASHTMP/pfSense-slash.tar.bz2 -C $FLASHTMP/mnt/a
echo "`date '+%b %e %T'`:	<- $FLASHTMP/pfSense-conf.tar.bz2"
tar jxf $FLASHTMP/pfSense-conf.tar.bz2 -C $FLASHTMP/mnt/d
cd $FLASHTMP
umount /dev/${MD}a
umount /dev/${MD}d
echo "`date '+%b %e %T'`: 	Cleanig up."
rm -f $FLASHTMP/pfSense-slash.tar.bz2
rm -f $FLASHTMP/pfSense-conf.tar.bz2
mdconfig -d -u ${MD} >/dev/null 2>&1

echo "`date '+%b %e %T'`:"

echo "`date '+%b %e %T'`: Compressing $FLASHTMP/pfSense-${1}MB.img"
gzip -f $FLASHTMP/pfSense-${1}MB.img
echo "`date '+%b %e %T'`: 	Creating MD5 hash"
md5 $FLASHTMP/pfSense-${1}MB.img'.gz' > $FLASHTMP/pfSense-${1}MB.img'.gz.md5'

echo "`date '+%b %e %T'`:"

echo "`date '+%b %e %T'`: READY! Now you have a ${1}MB pfSense image."
echo "`date '+%b %e %T'`: You can get this image on your CF Card using:"
echo "`date '+%b %e %T'`: zcat $FLASHTMP/pfSense-${1}MB.img.gz | dd of=/dev/da0 bs=16k"

