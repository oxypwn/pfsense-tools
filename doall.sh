#!/bin/sh
rm -rf /home/sullrich/pfSense
cd /home/sullrich
cvs -d:ext:sullrich@216.135.66.16:/cvsroot co pfSense
cd /home/sullrich/pfSense
cp /bin/ln /home/sullrich/pfSense/bin && chmod a+x /home/sullrich/pfSense/bin/*
echo "#!/bin/sh" > /home/sullrich/pfSense/script
echo ln -s /cf/conf /conf >> /home/sullrich/pfSense/script
echo ln -s /conf /cf/conf >> /home/sullrich/pfSense/script
chmod a+x /home/sullrich/pfSense/script
chroot /home/sullrich/pfSense/ "/script"
rm /home/sullrich/pfSense/script
ls -la /home/sullrich/pfSense
cd /home/sullrich/pfSense & tar czvPf ../pfSense.tgz .
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
cp /home/sullrich/pfSense.tgz /usr/local/livefs/dist/
cp /home/sullrich/freesbie/files/ip* /usr/local/livefs/boot/kernel/
cp /home/sullrich/freesbie/files/dummynet* /usr/local/livefs/boot/kernel/
rm -rf /usr/local/livefs/etc/shells
cp /home/sullrich/freesbie/files/shells /usr/local/livefs/etc/shells
echo exit > /usr/local/livefs/root/.xcustom.sh
./8.preparefs.sh
./81.mkiso.sh
echo Copying ISO to 10.0.250.50:~sullrich ... CTRL-C to abort.
scp /home/sullrich/freesbie/FreeSBIE.iso sullrich@10.0.250.50:~
echo Copying ISO to www.livebsd.com ... CTRL-C to abort.
scp -C /home/sullrich/freesbie/FreeSBIE.iso sullrich@www.pfsense.com:/usr/local/www/pfsense/pfSense-.01.iso
