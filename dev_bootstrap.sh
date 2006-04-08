#!/bin/sh

echo
echo This script will bootstrap your pfSense Developers iso
echo into a full fledged building environment.
echo
echo This will take quite a while.  Go have a excellent beer.
echo

set -x

CVSROOT="/home/pfsense/cvsroot"
HOME_PFSENSE="/home/pfsense"

mkdir -p $HOME_PFSENSE
mkdir -p $CVSROOT

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
	echo "Cannot find cvsup, pkg_add in progress"
	/usr/sbin/pkg_add -r cvsup-without-gui
fi

# Cvsup pfSense files
cvsup /tmp/bootstrap-supfile

# Checkout needed items
cd $HOME_PFSENSE && cvs -d $CVSROOT co tools
cd $HOME_PFSENSE && cvs -d $CVSROOT co pfSense
cd $HOME_PFSENSE && cvs -d $CVSROOT co www

# Make sure everything is set
cvsup $HOME_PFSENSE/tools/builder_scripts/pfSense-supfile

# CVSSync
sh $HOME_PFSENSE/tools/builder_scripts/cvsup_current

# Bring this image up to date
cvs_sync.sh releng_1

# Self destruct script if hooked into official deviso
if [ -d /usr/src/sys ]; then
	rm -f /usr/local/etc/rc.d/dev_bootstrap.sh
fi


