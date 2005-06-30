#!/bin/sh

# Launch BSD Installer with fake "installer root"
# Copyright 2004 BSD Installer Project and the FreeSBIE project
# This file is placed under the BSD license.

echo
echo "Launching pfSense Installer..."
echo

/usr/bin/killall syslogd 2>/dev/null 2>&1

sysctl kern.geom.debugflags=16

ln -s /FreeSBIE/tftpdroot /tmp/tftpdroot
echo "Mounting /FreeSBIE/dev..."
mount_devfs devfs /FreeSBIE/dev

echo "Mounting /FreeSBIE/usr..."
MD_LOCAL=`mdconfig -a -t vnode -f /FreeSBIE/uzip/usr.uzip`
mount -r /dev/$MD_LOCAL.uzip /FreeSBIE/usr

echo "Mounting /FreeSBIE/var..."
MD_LOCAL=`mdconfig -a -f /FreeSBIE/uzip/var.uzip`
mount -r /dev/$MD_LOCAL.uzip /FreeSBIE/var

mount -t unionfs /.var /FreeSBIE/var

# Let's access this now to prevent the "RockRidge" message
# during the actual install
ls /FreeSBIE/usr >/dev/null 2>&1
ls /FreeSBIE/var >/dev/null 2>&1

/sbin/ifconfig lo0 127.0.0.1/24
/sbin/ifconfig lo0 up

echo Starting backend...
/usr/local/sbin/dfuibe_installer -o /FreeSBIE/ \
	>/tmp/installerconsole.log 2>&1 &

echo Starting NCURSES frontend...

sleep 2 

/usr/local/sbin/dfuife_curses

echo
echo
echo
echo
echo
echo
echo
echo
echo
echo
echo "pfSense is now rebooting"
echo "After reboot and the console menu is displayed, open a web"
echo "browser and try to surf to http://192.168.1.1"
echo
echo Rebooting in 3 seconds.  CTRL-C to abort.
sleep 1
echo Rebooting in 2 seconds.  CTRL-C to abort.
sleep 1
echo Rebooting in 1 second..  CTRL-C to abort.
sleep 1
echo
echo pfSense is now rebooting.

shutdown -r now

