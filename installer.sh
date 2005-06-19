#!/bin/sh

# Launch BSD Installer with fake "installer root"
# Copyright 2004 BSD Installer Project and the FreeSBIE project
# This file is placed under the BSD license.

echo
echo "Launching pfSense Installer..."
echo

/usr/bin/killall syslogd 2>/dev/null 2>&1

sysctl kern.geom.debugflags=16

echo pass in quick all   > /tmp/tmp
echo pass out quick all >> /tmp/tmp
ipf -f /tmp/tmp 2>/dev/null
pfctl -f /tmp/tmp 2>/dev/null

for FILE in "/FreeSBIE/" ; do
	find $FILE >/dev/null 2>&1
done

# Launch the backend
#lua /usr/local/share/dfuibe_lua/dfuibe.lua \
	#dir.root=/FreeSBIE/ \
	#scripts/demo/ \
	#>/dev/null 2>&1 &

# Launch the curses based frontend

if [ -e /tmp/thttpd.conf ]; then
	clear
	echo
	echo
	echo pfi has setup pfSense for CGI Installer mode.
	echo
	echo "THTTPD is running and ready for an install on:"
	echo
	/sbin/ifconfig | grep "inet " | cut -d" " -f 2
	echo
	/usr/local/sbin/dfuibe_installer -o /FreeSBIE/ \
		>/tmp/installerconsole.log 2>&1
else
	echo
	echo Starting keyboard map picker...
	/usr/sbin/kbdmap
	echo Starting backend...
	/usr/local/sbin/dfuibe_installer -o /FreeSBIE/ \
		>/tmp/installerconsole.log 2>&1 &
	echo Starting NCURSES frontend...
	/usr/local/sbin/dfuife_curses
fi

echo
echo
echo
echo
echo
echo
echo "Once the system reboots you will be asked to associate your network"
echo "interfaces as either WAN, LAN or OPT."
echo
echo After assigning network interfaces and rebooting you should be able to
echo browse http://192.168.1.1 on your LAN interface for further configuration.
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