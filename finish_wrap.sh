#!/bin/sh

echo

umount /tmp/mnt 2>/dev/null
mdconfig -d -u 91 2>/dev/null

cd /home/sullrich

chflags -R noschg /tmp/mnt/
rm -rf /tmp/mnt/*

cp /home/sullrich/pfSense/boot/device.hints_wrap \
        /usr/local/livefs/boot/device.hints
cp /home/sullrich/pfSense/boot/loader.conf_wrap \
        /usr/local/livefs/boot/loader.conf

echo Calculating size of /usr/local/livefs...
du -H -d0 /usr/local/livefs
cd /home/sullrich/tools
echo Running DD
/bin/dd if=/dev/zero of=image.bin bs=1k count=111072
echo Running mdconfig
/sbin/mdconfig -a -t vnode -u91 -f image.bin
echo Running newfs
fdisk /dev/md91
newfs /dev/md91
disklabel -BR md91 /usr/local/livefs/boot/label.proto_wrap
mount /dev/md91 /tmp/mnt
cd /usr/local/livefs/ && tar czPf /home/sullrich/livefs.tgz .
cd /tmp/mnt && tar xzPf /home/sullrich/livefs.tgz .
cd /home/sullrich/tools
umount /tmp/mnt
#fdisk -B -b /boot/boot0 md91
boot0cfg -B -v -o packet /dev/md91
/sbin/mdconfig -d -u 91
gzip -9 image.bin
mv image.bin.gz pfSense-128-megs.bin.gz
