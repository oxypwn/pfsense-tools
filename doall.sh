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

cd /home/sullrich/pfSense/ && tar czvPf /tmp/pfSense.tgz .
cd /usr/local/livefs && tar xzvpf /tmp/pfSense.tgz
rm /usr/local/livefs/etc/hosts

cd /home/sullrich/freesbie

./4.kernel.sh FREESBIE.5
./5.patchfiles.sh
./6.packages.sh
./7.customuser.sh
#./71.bsdinstaller.sh

# restore values if overwritten accidently.
. ../freesbie/config.sh
. ../freesbie/.common.sh

cp /sbin/pf* $FREESBIEBASEDIR/sbin
cp /sbin/pf* /home/sullrich/pfSense/sbin/
chmod a+x $FREESBIEBASEDIR/sbin/pf*
cp $LOCALDIR/files/gettytab $FREESBIEBASEDIR/etc/
cp /sbin/ip* $FREESBIEBASEDIR/sbin/
cp /usr/sbin/ip* $FREESBIEBASEDIR/usr/sbin/
rm -rf $FREESBIEBASEDIR/dist/pfSense.tgz
cp /home/sullrich/pfSense.tgz $FREESBIEBASEDIR/dist/
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

version_kernel=`cat /home/sullrich/pfSense/etc/version_kernel`
version_base=`cat /home/sullrich/pfSense/etc/version_base`
version=`cat /home/sullrich/pfSense/etc/version`

#./8.preparefs.sh
if [ "$?" != "0" ]; then
    echo "Something went wrong."
    exit 1;
fi
#./81.mkiso.sh

mkdir -p $UPDATES

#/home/sullrich/tools/copy_files_to_pfSense_Site.sh

