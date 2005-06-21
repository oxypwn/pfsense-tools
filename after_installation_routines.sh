#!/bin/sh

# Lets cleanup from fake root environment
rm -f /FreeSBIE/mnt/etc/rc.d/freesbie_1st
rm -f /FreeSBIE/mnt/usr/local/share/freesbie/files/000.freesbie_2nd.sh
rm -rf /FreeSBIE/mnt/cloop
rm -rf /FreeSBIE/mnt/dist
rm -f /FreeSBIE/mnt/etc/rc.local
rm /FreeSBIE/mnt/root/.tcshrc
rm /FreeSBIE/mnt/root/.message*
rm /FreeSBIE/mnt/etc/rc.conf
touch /FreeSBIE/mnt/etc/rc.conf

# Zap some unneeded rc stuff
rm -rf /FreeSBIE/mnt/etc/rc.subr
rm -rf /FreeSBIE/mnt/etc/rc.d
rm /FreeSBIE/mnt/etc/rc.conf
rm /FreeSBIE/mnt/etc/rc.firewall*
rm /FreeSBIE/mnt/etc/rc.sendmail

# Copy the current running systems config.xml to the
# target installation area.
mkdir -p /FreeSBIE/mnt/cf/conf
cp /cf/conf/* /FreeSBIE/mnt/cf/conf

# Prevent the system from asking for these twice
touch /FreeSBIE/mnt/root/.part_mount
touch /FreeSBIE/mnt/root/.first_time

# Update boot loader
cp -R /boot/* /FreeSBIE/mnt/boot/
cat /boot/loader.conf | grep -v ^mfsroot > /FreeSBIE/mnt/boot/loader.conf

# Enable permission for playback.
cd /FreeSBIE/mnt && bzcat /FreeSBIE/dist/FreeSBIE.root.dist.bz2 | mtree -PU -p /FreeSBIE/mnt
cd /FreeSBIE/mnt/usr && bzcat /FreeSBIE/dist/FreeSBIE.usr.dist.bz2  | mtree -PUr -p /FreeSBIE/mnt/usr
cd /FreeSBIE/mnt/var && bzcat /FreeSBIE/dist/FreeSBIE.var.dist.bz2  | mtree -PUr -p /FreeSBIE/mnt/var

cd /FreeSBIE/mnt && rm FreeSBIE/ cloop/ dist/ boot/mfsroot.gz

rm /FreeSBIE/mnt/etc/motd

#echo /etc/rc.initial > /FreeSBIE/mnt/root/.shrc
#echo exit >> /FreeSBIE/mnt/root/.shrc

# Set platform back to pfSense to prevent freesbie_1st
# from running
echo "pfSense" > /FreeSBIE/mnt/etc/platform

chroot /FreeSBIE/mnt/ ln -s /config.xml /cf/conf/config.xml
# Self destruct myself.
if [ -e "/FreeSBIE/mnt/usr/local/bin/after_installation_routines.sh" ];then
        rm -f /FreeSBIE/mnt/usr/local/bin/after_installation_routines.sh
fi
