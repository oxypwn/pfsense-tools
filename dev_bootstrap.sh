#!/bin/sh
#
# pfSense developer iso bootstrap
# Written by Scott Ullrich
# Part of the pfSense project
#
# This script will bootstrap and build
# an inital iso.
#

# Wait until bootup is finished
echo -n "Bootstrap waiting for bootup to finish..."
while [ -e /var/run/booting ]; do
	echo -n "."
	sleep 30
done
echo "."
echo

echo This script will bootstrap your pfSense Developers
echo iso into a full fledged building environment.
echo
echo This will take quite a while.  Go have a excellent beer.
echo
echo -n ">>> Press CTRL-C if you do not wish to go any further."
sleep 3
echo -n " "
sleep 3
echo -n "<"
sleep 3
echo -n "<"
sleep 3
echo "<"
sleep 3
echo
echo "Beginning bootstrap.  Beer time!"
echo
sleep 3

# Set script debugging mode for a bit
# set -x

# Set some shell variables
CVSROOT="/home/pfsense/cvsroot"
HOME_PFSENSE="/home/pfsense"

# Create needed directories
mkdir -p $HOME_PFSENSE
mkdir -p $CVSROOT
mkdir -p /usr/src/

cd $HOME_PFSENSE

# Create bootstrap supfile
echo "*default host=cvs.pfsense.com" >/tmp/bootstrap-supfile
echo "*default base=/home/pfsense/cvsroot" >>/tmp/bootstrap-supfile
echo "*default release=cvs" >>/tmp/bootstrap-supfile
echo "*default delete use-rel-suffix" >>/tmp/bootstrap-supfile
echo "pfSense" >>/tmp/bootstrap-supfile
echo "*default compress" >>/tmp/bootstrap-supfile

# Failed, lets try with passive mode
if [ ! -f "/usr/local/bin/cvsup" ]; then
	echo "Cannot find cvsup, pkg_add in progress (PASSIVE FTP)..."
	env FTP_PASSIVE_MODE=yes /usr/sbin/pkg_add -r cvsup-without-gui
fi
# Add cvsup
if [ ! -f "/usr/local/bin/cvsup" ]; then
	echo "Cannot find cvsup, pkg_add in progress..."
	/usr/sbin/pkg_add -r cvsup-without-gui
fi

# Failed, lets try with passive mode
if [ ! -f "/usr/local/bin/fastest_cvsup" ]; then
	echo "Cannot find fastest_cvsup, pkg_add in progress (PASSIVE FTP)..."
	env FTP_PASSIVE_MODE=yes /usr/sbin/pkg_add -r fastest_cvsup
fi
# Add cvsup
if [ ! -f "/usr/local/bin/fastest_cvsup" ]; then
	echo "Cannot find fastest_cvsup, pkg_add in progress..."
	/usr/sbin/pkg_add -r fastest_cvsup
fi

# Cvsup pfSense files
cvsup /tmp/bootstrap-supfile

# Cleanup after ourself
rm /tmp/bootstrap-supfile

# Checkout needed items
cd $HOME_PFSENSE && cvs -d $CVSROOT co tools
cd $HOME_PFSENSE && cvs -d $CVSROOT co pfSense
cd $HOME_PFSENSE && cvs -d $CVSROOT co www

# Make sure all scripts are executable
chmod a+rx $HOME_PFSENSE/tools/builder_scripts/*

# Make sure everything is set
cvsup $HOME_PFSENSE/tools/builder_scripts/pfSense-supfile

echo "SKIP_RSYNC=yo" >> $HOME_PFSENSE/tools/builder_scripts/pfsense_local.sh

# Sync source tree
echo "Finding fastest cvsup server.  This will take a moment..."
/usr/local/bin/fastest_cvsup -q -c tld >/var/db/fastest_cvsup

# Sync FreeBSD tree with fastest server found
cvsup -h `cat /var/db/fastest_cvsup` $HOME_PFSENSE/tools/builder_scripts/stable-supfile

cd $HOME_PFSENSE
touch ~/.cvspass
cvs -z3 -d :pserver:anonymous@cvs.freesbie.org:/cvs co -P freesbie2

cd $HOME_PFSENSE/tools/builder_scripts

# Update BSDInstaller
./cvsup_bsdinstaller

echo "Bootstrap completed."
echo
echo -n "Beginning initial ISO build.  CTRL-C to abort."
echo -n "." ; sleep 1 ; echo -n "." ; sleep 1 ; echo -n "."
sleep 1 ; echo -n "." ; sleep 1 ; echo -n "." ; sleep 1
sleep 1 ; echo -n "." ; sleep 1 ; echo "" ; sleep 1

cd $HOME_PFSENSE/tools/builder_scripts; sh ./cvsup_current

# Kill off console tailing process if needed
/usr/bin/killall tail

# If iso completed, self destruct.
if [ -f /usr/obj.pfSense/pfSense.iso ]; then
	echo "Removing developer bootstrap..."
	rm -rf /usr/local/etc/rc.d/dev_bootstrap.sh
fi
