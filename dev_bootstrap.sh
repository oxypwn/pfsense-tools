#!/bin/sh

echo
echo This script will bootstrap your pfSense Developers 
echo iso into a full fledged building environment.
echo
echo This will take quite a while.  Go have a excellent beer.
echo
echo -n ">>> Press CTRL-C if you do not wish to go any further."
sleep 1
echo -n " "
sleep 1
echo -n "<"
sleep 1
echo -n "<"
sleep 1
echo "<"
sleep 1
echo
echo "Beginning bootstrap.  Beer time!"
echo

# Set script debugging mode for a bit
set -x

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

# Add cvsup
if [ ! -f "/usr/local/bin/cvsup" ]; then
	echo "Cannot find cvsup, pkg_add in progress..."
	/usr/sbin/pkg_add -v -r cvsup-without-gui
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

echo "SKIP_RSYNC=yo" > $HOME_PFSENSE/tools/builder_scripts/pfsense_local.sh

# Sync source tree
cvsup $HOME_PFSENSE/tools/builder_scripts/stable-supfile

cd $HOME_PFSENSE
touch ~/.cvspass
cvs -z3 -d :pserver:anonymous@cvs.freesbie.org:/cvs co -P freesbie2

# CVSSync
cd $HOME_PFSENSE/tools/builder_scripts && sh $HOME_PFSENSE/tools/builder_scripts/cvsup_current

# Bring this image up to date
cvs_sync.sh releng_1

# Self destruct script if hooked into official deviso
if [ -d /usr/src/sys ]; then
	rm -f /usr/local/etc/rc.d/dev_bootstrap.sh
fi

