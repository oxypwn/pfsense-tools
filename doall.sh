#!/bin/sh

FREESBIEBASEDIR=/usr/local/livefs
LOCALDIR=/home/sullrich/freesbie
PATHISO=/home/sullrich/freesbie/FreeSBIE.iso

cd /home/sullrich
rm -rf $LOCALDIR
cvs -d:ext:sullrich@216.135.66.16:/cvsroot co pfSense

# if platform == net45xx/wrap ###########################
#rm pfSense/usr/local/www/trigger_initial_wizard
#ls -la pfSense/usr/local/www/trigger_initial_wizard
#echo net45xx >> pfSense/usr/local/www/platform
#sleep 3
# end if ################################################

cd $LOCALDIR
if [ ! -e $LOCALDIR/libexec ]; then
	mkdir -p $LOCALDIR/libexec
fi
cp /usr/lib/libkrb5.so.7 $FREESBIEBASEDIR/usr/lib/
mkdir -p $FREESBIEBASEDIR/var/run
echo "#!/bin/sh" > $LOCALDIR/script
echo rm /etc/resolv.conf >> $LOCALDIR/script
echo rm /etc/hosts >> $LOCALDIR/script
echo ln -s /cf/conf /conf >> $LOCALDIR/script
echo ln -s /conf /cf/conf >> $LOCALDIR/script
echo ln -s /var/run/htpasswd /usr/local/www/.htpasswd >> $LOCALDIR/script
echo ln -s /var/etc/hosts /etc/hosts >> $LOCALDIR/script
echo ln -s /var/etc/resolv.conf /etc/resolv.conf >> $LOCALDIR/script
echo ln -s /lib/libm.so.3 /lib/libm.so.2 >> $LOCALDIR/script
echo ln -s /lib/libc.so.5 /lib/libc.so.4 >> $LOCALDIR/script
cat $LOCALDIR/script
chmod a+x $LOCALDIR/script
chroot $LOCALDIR/ /script
find $LOCALDIR && find $LOCALDIR -name CVS -exec rm -rf {} \;
rm $LOCALDIR.tgz
cd $LOCALDIR & tar czvPf $LOCALDIR.tgz .
cd /home/sullrich/freesbie
./0.rmdir.sh
./1.mkdir.sh
#./2.buildworld.sh
./3.installworld.sh
./4.kernel.sh
./5.patchfiles.sh
./6.packages.sh
./7.customuser.sh
cp /sbin/pf* $FREESBIEBASEDIR/sbin
chmod a+x $FREESBIEBASEDIR/sbin/pf*
cp /home/sullrich/freesbie/files/gettytab $FREESBIEBASEDIR/etc/
cp /sbin/ip* $FREESBIEBASEDIR/sbin/
cp /usr/sbin/ip* $FREESBIEBASEDIR/usr/sbin/
rm -rf $FREESBIEBASEDIR/dist/pfSense.tgz
cp $LOCALDIR.tgz $FREESBIEBASEDIR/dist/
cp /home/sullrich/freesbie/files/ip* $FREESBIEBASEDIR/boot/kernel/
cp /home/sullrich/freesbie/files/dummynet* $FREESBIEBASEDIR/boot/kernel/
cp /usr/lib/libstdc* $FREESBIEBASEDIR/usr/lib/
cp /home/sullrich/freesbie/files/foobar/ttys $FREESBIEBASEDIR/etc/ttys
mkdir -p $FREESBIEBASEDIR/usr/local/share/dfuibe_installer
cp /home/sullrich/freesbie/files/sources.conf $FREESBIEBASEDIR/usr/local/share/dfuibe_installer/sources.conf
cp /home/sullrich/freesbie/files/loader.rc $FREESBIEBASEDIR/boot/loader.rc
rm -rf $FREESBIEBASEDIR/etc/shells
cp /home/sullrich/freesbie/files/shells $FREESBIEBASEDIR/etc/shells
echo exit > $FREESBIEBASEDIR/root/.xcustom.sh
echo hint.acpi.0.disabled=\"1\" >> $FREESBIEBASEDIR/boot/device.hints
echo "-m -P" >> $FREESBIEBASEDIR/boot.config
# trim off some extra fat.
./8.preparefs.sh
./81.mkiso.sh

/home/sullrich/tools/copy_files_to_pfSense_Site.sh

