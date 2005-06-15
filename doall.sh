#!/bin/sh

# pfSense master builder script
# (C)2005 Scott Ullrich and the pfSense project
# All rights reserved.

#set -e -u

. ../freesbie/config.sh
. ../freesbie/.common.sh

PFSENSECVS=/home/sullrich/pfSense
UPDATES=/home/sullrich/updates

cd /home/sullrich
rm -rf $PFSENSECVS

cvs -d:ext:sullrich@216.135.66.16:/cvsroot co pfSense

cd $PFSENSECVS
if [ ! -e $PFSENSECVS/libexec ]; then
        mkdir -p $PFSENSECVS/libexec
fi
#cp /usr/lib/libkrb5.so.7 $LOCALDIR/usr/lib/
mkdir -p $LOCALDIR/var/run
echo "#!/bin/sh" > $PFSENSECVS/script
echo rm /etc/resolv.conf >> $PFSENSECVS/script
echo rm /etc/hosts >> $PFSENSECVS/script
echo ln -s /cf/conf /conf >> $PFSENSECVS/script
echo ln -s /conf /cf/conf >> $PFSENSECVS/script
echo ln -s /var/etc/hosts /etc/hosts >> $PFSENSECVS/script
echo ln -s /var/etc/resolv.conf /etc/resolv.conf >> $PFSENSECVS/script
echo ln -s /lib/libm.so.3 /lib/libm.so.2 >> $PFSENSECVS/script
echo ln -s /lib/libc.so.5 /lib/libc.so.4 >> $PFSENSECVS/script
echo ln -s /lib/libc.so.6 /lib/libc.so.5 >> $PFSENSECVS/script

cat $PFSENSECVS/script
chmod a+x $PFSENSECVS/script
chroot $PFSENSECVS/ /script
#find $PFSENSECVS -name CVS -exec rm -rf {} \;
rm -rf $PFSENSECVS.tgz
cd $PFSENSECVS & tar czvPf $PFSENSECVS.tgz .
cd $LOCALDIR
./0.rmdir.sh
./1.mkdir.sh
#./2.buildworld.sh
./3.installworld.sh

# nuke some extra stuff
find /usr/local/livefs -name sysinstall -exec rm -rf {} \;

cd /home/sullrich/pfSense/ && tar czvPf /tmp/pfSense.tgz .
cd /usr/local/livefs && tar xzvpf /tmp/pfSense.tgz
rm /usr/local/livefs/etc/hosts

cd /home/sullrich/freesbie

#./4.kernel.sh pfSense.6
./4.kernel.sh pfSense_wrap.6

cp /sbin/brconfig /usr/local/livefs/sbin/
cp /usr/sbin/bsnmpd /usr/local/livefs/sbin/
chmod a+rx /usr/local/livefs/sbin/brconfig

./5.patchfiles.sh
./6.packages.sh
./7.customuser.sh
#./71.bsdinstaller.sh

# restore values if overwritten accidently.
. ../freesbie/config.sh
. ../freesbie/.common.sh

cp /sbin/pf* $FREESBIEBASEDIR/sbin
cp /sbin/pf* /home/sullrich/pfSense/sbin/
chmod a+rx $FREESBIEBASEDIR/sbin/pf*
cp $LOCALDIR/files/gettytab $FREESBIEBASEDIR/etc/
rm -rf $FREESBIEBASEDIR/dist/pfSense.tgz
cp /home/sullrich/pfSense.tgz $FREESBIEBASEDIR/dist/
cp /usr/lib/libstdc* $FREESBIEBASEDIR/usr/lib/

cp $LOCALDIR/files/foobar/ttys $FREESBIEBASEDIR/etc/ttys
cp $LOCALDIR/files/loader.rc $FREESBIEBASEDIR/boot/loader.rc
echo hint.acpi.0.disabled=\"1\" >> $FREESBIEBASEDIR/boot/device.hints
cp /boot/defaults/loader.conf $FREESBIEBASEDIR/boot/loader.conf
cp /boot/beastie.4th /usr/local/livefs/boot/

mkdir -p $FREESBIEBASEDIR/usr/local/share/dfuibe_installer
cp $LOCALDIR/files/sources.conf \
	$FREESBIEBASEDIR/usr/local/share/dfuibe_installer/sources.conf
rm -rf $FREESBIEBASEDIR/etc/shells
cp $LOCALDIR/files/shells $FREESBIEBASEDIR/etc/shells
echo exit > $FREESBIEBASEDIR/root/.xcustom.sh
touch $FREESBIEBASEDIR/root/.hushlogin
cp $FREESBIEBASEDIR/lib/libc.so.6 $FREESBIEBASEDIR/lib/libc.so.5
cp $FREESBIEBASEDIR/lib/libc.so.6 $FREESBIEBASEDIR/lib/libc.so.4

# extra stuff for man pages
# cp /usr/bin/groff /usr/bin/groff /usr/bin/tbl /usr/local/livefs/usr/bin/

# bsnmpd related
mkdir -p /usr/local/livefs/usr/share/snmp/defs/
cp -R /usr/share/snmp/defs/ /usr/local/livefs/usr/share/snmp/defs/

version_kernel=`cat /home/sullrich/pfSense/etc/version_kernel`
version_base=`cat /home/sullrich/pfSense/etc/version_base`
version=`cat /home/sullrich/pfSense/etc/version`

# pf related binaries
cd /usr/src/sbin/pfctl && make && make install && cd /home/sullrich/freesbie
cd /usr/src/sbin/pflogd && make && make install && cd /home/sullrich/freesbie
cp /sbin/pfctl /usr/local/livefs/sbin/
cp /sbin/pflogd /usr/local/livefs/sbin/

./8.preparefs.sh
./81.mkiso.sh

mkdir -p $UPDATES

