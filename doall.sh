#!/bin/sh
cd /home/sullrich
rm -rf /home/sullrich/pfSense
cvs -d:ext:sullrich@216.135.66.16:/cvsroot co pfSense
cd /home/sullrich/pfSense
if [ ! -e /home/sullrich/pfSense/libexec ]; then
	mkdir -p /home/sullrich/pfSense/libexec
fi
cp /usr/lib/libkrb5.so.7 /usr/local/livefs/usr/lib/
mkdir -p /usr/local/livefs/var/run
echo "#!/bin/sh" > /home/sullrich/pfSense/script
echo ln -s /cf/conf /conf >> /home/sullrich/pfSense/script
echo ln -s /conf /cf/conf >> /home/sullrich/pfSense/script
echo ln -s /var/run/htpasswd /usr/local/www/.htpasswd >> /home/sullrich/pfSense/script
echo ln -s /var/run/hosts /etc/hosts >> /home/sullrich/pfSense/script
echo rm /etc/resolv.conf >> /home/sullrich/pfSense/script
echo ln -s /var/etc/resolv.conf /etc/resolv.conf >> /home/sullrich/pfSense/script
echo ln -s /lib/libm.so.3 /lib/libm.so.2 >> /home/sullrich/pfSense/script
echo ln -s /lib/libc.so.5 /lib/libc.so.4 >> /home/sullrich/pfSense/script
cat /home/sullrich/pfSense/script
chmod a+x /home/sullrich/pfSense/script
chroot /home/sullrich/pfSense/ /script
#rm /home/sullrich/pfSense/script
#find /home/sullrich/pfSense && find . -name CVS -exec rm -rf {} \;
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
cp /sbin/pf* /usr/local/livefs/sbin
chmod a+x /usr/local/livefs/sbin/pf*
cp /home/sullrich/freesbie/files/gettytab /usr/local/livefs/etc/
cp /sbin/ip* /usr/local/livefs/sbin/
cp /usr/sbin/ip* /usr/local/livefs/usr/sbin/
rm -rf /usr/local/livefs/dist/pfSense.tgz
cp /home/sullrich/pfSense.tgz /usr/local/livefs/dist/
cp /home/sullrich/freesbie/files/ip* /usr/local/livefs/boot/kernel/
cp /home/sullrich/freesbie/files/dummynet* /usr/local/livefs/boot/kernel/
cp /usr/lib/libstdc* /usr/local/livefs/usr/lib/
cp /home/sullrich/freesbie/files/foobar/ttys /usr/local/livefs/etc/ttys
mkdir -p /usr/local/livefs/usr/local/share/dfuibe_installer
cp /home/sullrich/freesbie/files/sources.conf /usr/local/livefs/usr/local/share/dfuibe_installer/sources.conf
cp /home/sullrich/freesbie/files/loader.rc /usr/local/livefs/boot/loader.rc
rm -rf /usr/local/livefs/etc/shells
cp /home/sullrich/freesbie/files/shells /usr/local/livefs/etc/shells
echo exit > /usr/local/livefs/root/.xcustom.sh
echo hint.acpi.0.disabled=\"1\" >> /usr/local/livefs/boot/device.hints
# trim off some extra fat.
rm -rf /usr/local/livefs/usr/include
rm -rf /usr/local/livefs/usr/local/include
./8.preparefs.sh
./81.mkiso.sh

echo Copying ISO to 10.0.250.50:~sullrich ... CTRL-C to abort.
scp /home/sullrich/freesbie/FreeSBIE.iso sullrich@10.0.250.50:~
echo Copying ISO to www.livebsd.com ... CTRL-C to abort.
scp -l200 -C /home/sullrich/freesbie/FreeSBIE.iso \
	sullrich@www.pfsense.com:/usr/local/www/pfsense/pfSense-0.13.iso
cd /home/sullrich/pfSense
rm -rf conf*
rm -rf usr/local/www/trigger_initial_wizard
PVERSUFFIX=`date "+%Y.%m%d"`
cd /home/sullrich/pfSense && tar czvPf /pfSenseUpdate-$PVERSUFFIX.tgz .
scp -C -l200 /pfSenseUpdate-$PVERSUFFIX.tgz \
	sullrich@216.135.66.16:/usr/local/www/pfsense/updates/
cd /home/sullrich/tools
