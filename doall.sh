#!/bin/sh

FREESBIEBASEDIR=/usr/local/livefs
LOCALDIR=/home/sullrich/freesbie
PATHISO=/home/sullrich/freesbie/FreeSBIE.iso

cd /home/sullrich
rm -rf /home/sullrich/pfSense
cvs -d:ext:sullrich@216.135.66.16:/cvsroot co pfSense

# if platform == net45xx/wrap ###########################
#rm pfSense/usr/local/www/trigger_initial_wizard
#ls -la pfSense/usr/local/www/trigger_initial_wizard
#echo net45xx >> pfSense/usr/local/www/platform
#sleep 3
# end if ################################################

cd /home/sullrich/pfSense
if [ ! -e /home/sullrich/pfSense/libexec ]; then
        mkdir -p /home/sullrich/pfSense/libexec
fi
cp /usr/lib/libkrb5.so.7 $$LOCALDIR/usr/lib/
mkdir -p $$LOCALDIR/var/run
echo "#!/bin/sh" > /home/sullrich/pfSense/script
echo rm /etc/resolv.conf >> /home/sullrich/pfSense/script
echo rm /etc/hosts >> /home/sullrich/pfSense/script
echo ln -s /cf/conf /conf >> /home/sullrich/pfSense/script
echo ln -s /conf /cf/conf >> /home/sullrich/pfSense/script
echo ln -s /var/run/htpasswd /usr/local/www/.htpasswd >> /home/sullrich/pfSense/script
echo ln -s /var/etc/hosts /etc/hosts >> /home/sullrich/pfSense/script
echo ln -s /var/etc/resolv.conf /etc/resolv.conf >> /home/sullrich/pfSense/script
echo ln -s /lib/libm.so.3 /lib/libm.so.2 >> /home/sullrich/pfSense/script
echo ln -s /lib/libc.so.5 /lib/libc.so.4 >> /home/sullrich/pfSense/script
cat /home/sullrich/pfSense/script
chmod a+x /home/sullrich/pfSense/script
chroot /home/sullrich/pfSense/ /script
find /home/sullrich/pfSense && find /home/sullrich/pfSense -name CVS -exec rm -rf {} \;
rm /home/sullrich/pfSense.tgz
cd /home/sullrich/pfSense & tar czvPf /home/sullrich/pfSense.tgz .
cd /home/sullrich/freesbie
./0.rmdir.sh
./1.mkdir.sh
#./2.buildworld.sh
./3.installworld.sh
./4.kernel.sh
./5.patchfiles.sh
./6.packages.sh
./7.customuser.sh
cp /sbin/pf* $$LOCALDIR/sbin
chmod a+x $$LOCALDIR/sbin/pf*
cp /home/sullrich/freesbie/files/gettytab $$LOCALDIR/etc/
cp /sbin/ip* $$LOCALDIR/sbin/
cp /usr/sbin/ip* $$LOCALDIR/usr/sbin/
rm -rf $$LOCALDIR/dist/pfSense.tgz
cp /home/sullrich/pfSense.tgz $$LOCALDIR/dist/
cp /home/sullrich/freesbie/files/ip* $$LOCALDIR/boot/kernel/
cp /home/sullrich/freesbie/files/dummynet* $$LOCALDIR/boot/kernel/
cp /usr/lib/libstdc* $$LOCALDIR/usr/lib/
cp /home/sullrich/freesbie/files/foobar/ttys $$LOCALDIR/etc/ttys
mkdir -p $$LOCALDIR/usr/local/share/dfuibe_installer
cp /home/sullrich/freesbie/files/sources.conf $$LOCALDIR/usr/local/share/dfuibe_installer/sources.conf
cp /home/sullrich/freesbie/files/loader.rc $$LOCALDIR/boot/loader.rc
rm -rf $$LOCALDIR/etc/shells
cp /home/sullrich/freesbie/files/shells $$LOCALDIR/etc/shells
echo exit > $$LOCALDIR/root/.xcustom.sh
echo hint.acpi.0.disabled=\"1\" >> $$LOCALDIR/boot/device.hints
echo "-m -P" >> $$LOCALDIR/boot.config
# trim off some extra fat.
./8.preparefs.sh
./81.mkiso.sh

/home/sullrich/tools/copy_files_to_pfSense_Site.sh
