
. ../freesbie/config.sh
. ../freesbie/.common.sh

PFSENSECVS=/home/sullrich/pfSense

rm pfSense/usr/local/www/trigger_initial_wizard
ls -la pfSense/usr/local/www/trigger_initial_wizard
cho net45xx >> pfSense/usr/local/www/platform
sleep 3

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
rm $PFSENSECVS.tgz
cd $PFSENSECVS & tar czvPf $PFSENSECVS.tgz .
cd $LOCALDIR
./0.rmdir.sh
./1.mkdir.sh
#./2.buildworld.sh
./3.installworld.sh
./4.kernel.sh FREESBIE.5.WRAP-SOEKRIS
./5.patchfiles.sh
./6.packages.sh
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
touch $FREESBIEBASEDIR/root/.hushlogin
echo hint.acpi.0.disabled=\"1\" >> $FREESBIEBASEDIR/boot/device.hints
# trim off some extra fat.
#./8.preparefs.sh
#./81.mkiso.sh

# XXX: tar up kernel and world for embedded updates
version_kernel=`cat /usr/local/livefs/etc/version_kernel`
version_base=`cat /usr/local/livefs/etc/version_base`
version=`cat /usr/local/livefs/etc/version`
cd /usr/local/livefs
tar czvpf /kernel-${version_kernel}-wrap-soekris.tgz /usr/local/livefs/boot/
rm -rf /usr/local/livefs/boot/
tar czvpf /base-${version_base}-wrap-soekris.tgz .

# Finish up wrap configuration
/home/sullrich/tools/finish_wrap.sh

