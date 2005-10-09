#!/bin/sh

# Lets cleanup from fake root environment
rm -rf /FreeSBIE/mnt/cloop
rm -rf /FreeSBIE/mnt/dist
rm -f /FreeSBIE/mnt/etc/rc.d/freesbie_1st
rm -f /FreeSBIE/mnt/usr/local/share/freesbie/files/000.freesbie_2nd.sh
rm -f /FreeSBIE/mnt/etc/rc.local
rm -f /FreeSBIE/mnt/root/.tcshrc
rm -f /FreeSBIE/mnt/etc/rc.conf
rm -f /FreeSBIE/mnt/etc/rc.conf
rm -f /FreeSBIE/mnt/etc/rc.firewall
rm -f /FreeSBIE/mnt/etc/rc.sendmail
touch /FreeSBIE/mnt/etc/rc.conf

# Copy the current running systems config.xml to the target installation area.
mkdir -p /FreeSBIE/mnt/cf/conf
cp /cf/conf/* /FreeSBIE/mnt/cf/conf/

# Prevent the system from asking for these twice
touch /FreeSBIE/mnt/root/.part_mount
touch /FreeSBIE/mnt/root/.first_time

# Updating boot loader
#cp -R /boot/* /FreeSBIE/mnt/boot/
cat /boot/loader.conf | grep -v ^mfsroot > /FreeSBIE/mnt/boot/loader.conf
echo debug.acpi.disable=\"thermal\" >> /FreeSBIE/mnt/boot/loader.conf


cd /FreeSBIE/mnt && rm -rf FreeSBIE/ cloop/ dist/ boot/mfsroot.gz

rm -f /FreeSBIE/mnt/etc/motd

#chroot /FreeSBIE/mnt ln -s /cf/conf /conf
#chroot /FreeSBIE/mnt ln -s /conf /cf/conf

# Set platform back to pfSense to prevent freesbie_1st from running
echo "pfSense" > /FreeSBIE/mnt/etc/platform

# Remove TCSHRC installer alias
echo "" > /FreeSBIE/mnt/root/.tcshrc
rm -rf /FreeSBIE/mnt/scripts
find /FreeSBIE/mnt/ -name installer -or -name lua_installer -exec rm {} \;

# Self destruct myself.
rm -f /FreeSBIE/mnt/usr/local/bin/after_installation_routines.sh

# Let parent script know that a install really happened
touch /tmp/install_complete

chmod a-w /FreeSBIE/mnt/boot/loader.rc
chflags schg /FreeSBIE/mnt/boot/loader.rc

mkdir -p /FreeSBIE/mnt/var/installer_logs
cp /tmp/install.disklabel /FreeSBIE/mnt/var/installer_logs
cp /tmp/bootup_messages /FreeSBIE/mnt/var/installer_logs
cp /tmp/install.disklabel.ad0s1 /FreeSBIE/mnt/var/installer_logs
cp /tmp/installer.log /FreeSBIE/mnt/var/installer_logs
cp /tmp/init_bootloader.sh /FreeSBIE/mnt/var/installer_logs
cp /tmp/install-session.sh /FreeSBIE/mnt/var/installer_logs
cp /tmp/new.fdisk /FreeSBIE/mnt/var/installer_logs

#Sync disks
/bin/sync