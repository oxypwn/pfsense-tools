#!/bin/sh

# pfSense master builder script
# (C)2005 Scott Ullrich and the pfSense project
# All rights reserved.

. ../freesbie/config.sh
. ../freesbie/.common.sh

PFSENSECVS=/home/sullrich/pfSense

# XXX: these above values should also be defined in
#      $LOCALDIR/config.sh


# XXX: when we finally support these platforms, automate this.
# if platform == net45xx/wrap ###########################
#rm pfSense/usr/local/www/trigger_initial_wizard
#ls -la pfSense/usr/local/www/trigger_initial_wizard
#echo net45xx >> pfSense/usr/local/www/platform
#sleep 3
# end if ############################################XXX#

cd $PFSENSECVS
if [ ! -e $PFSENSECVS/libexec ]; then
        mkdir -p $PFSENSECVS/libexec
fi
cp /usr/lib/libkrb5.so.7 $LOCALDIR/usr/lib/
mkdir -p $LOCALDIR/var/run
echo "#!/bin/sh" > $PFSENSECVS/script
echo rm /etc/resolv.conf >> $PFSENSECVS/script
echo rm /etc/hosts >> $PFSENSECVS/script
echo ln -s /cf/conf /conf >> $PFSENSECVS/script
echo ln -s /conf /cf/conf >> $PFSENSECVS/script
echo ln -s /var/run/htpasswd /usr/local/www/.htpasswd >> $PFSENSECVS/script
echo ln -s /var/etc/hosts /etc/hosts >> $PFSENSECVS/script
echo ln -s /var/etc/resolv.conf /etc/resolv.conf >> $PFSENSECVS/script
echo ln -s /lib/libm.so.3 /lib/libm.so.2 >> $PFSENSECVS/script
echo ln -s /lib/libc.so.5 /lib/libc.so.4 >> $PFSENSECVS/script
cat $PFSENSECVS/script
chmod a+x $PFSENSECVS/script
chroot $PFSENSECVS/ /script
find $PFSENSECVS && find $PFSENSECVS -name CVS -exec rm -rf {} \;
cd $LOCALDIR
./0.rmdir.sh
./1.mkdir.sh
#./2.buildworld.sh
./3.installworld.sh
./4.kernel.sh
./5.patchfiles.sh
#./6.packages.sh
./7.customuser.sh

# restore values if overwritten accidently.
. ../freesbie/config.sh
. ../freesbie/.common.sh

cp /sbin/pf* $FREESBIEBASEDIR/sbin
chmod a+x $FREESBIEBASEDIR/sbin/pf*
cp $LOCALDIR/files/gettytab $FREESBIEBASEDIR/etc/
cp /sbin/ip* $FREESBIEBASEDIR/sbin/
cp /usr/sbin/ip* $FREESBIEBASEDIR/usr/sbin/
rm -rf $FREESBIEBASEDIR/dist/pfSense.tgz
cp /home/sullrich/pfSense.tgz $FREESBIEBASEDIR/dist/
cp $LOCALDIR/files/ip* $FREESBIEBASEDIR/boot/kernel/
cp $LOCALDIR/files/dummynet* $FREESBIEBASEDIR/boot/kernel/
cp /usr/lib/libstdc* $FREESBIEBASEDIR/usr/lib/
cp $LOCALDIR/files/foobar/ttys $FREESBIEBASEDIR/etc/ttys
mkdir -p $FREESBIEBASEDIR/usr/local/share/dfuibe_installer
cp $LOCALDIR/files/sources.conf \
        $FREESBIEBASEDIR/usr/local/share/dfuibe_installer/sources.conf
cp $LOCALDIR/files/loader.rc $FREESBIEBASEDIR/boot/loader.rc
rm -rf $FREESBIEBASEDIR/etc/shells
cp $LOCALDIR/files/shells $FREESBIEBASEDIR/etc/shells
echo exit > $FREESBIEBASEDIR/root/.xcustom.sh
echo hint.acpi.0.disabled=\"1\" >> $FREESBIEBASEDIR/boot/device.hints
# trim off some extra fat.

cd /usr/local/livefs/
rm -rf $PFSENSECVS
cd /home/sullrich/ && cvs -d:ext:sullrich@216.135.66.16:/cvsroot co pfSense
cd /home/sullrich/pfSense/ && tar czvPf /home/sullrich/pfSense.tgz .
cd /usr/local/livefs && tar xzvPf /home/sullrich/pfSense.tgz

cp /home/sullrich/pfSense/boot/loader.conf_wrap /usr/local/livefs/boot/
cp /home/sullrich/pfSense/boot/device.hints_wrap /usr/local/livefs/boot/


dd if=/dev/zero of=image.bin bs=1k count=131072
mdconfig -a -t vnode -u91 -f image.bin
newfs -b 8192 -f 1024 /dev/md91
disklabel -BR md91 /usr/local/livefs/boot/label.proto_wrap
mount /dev/md91 /tmp/mnt
mv /usr/local/livefs/* /tmp/mnt/
umount /tmp/mnt
mdconfig -d -u 91
gzip -9 image.bin
mv image.bin pfSense-128-megs.bin
