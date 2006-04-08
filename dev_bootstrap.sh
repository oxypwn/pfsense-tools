#!/bin/sh

echo
echo This script will bootstrap your pfSense Developers iso
echo into a full fledged building environment.
echo
echo This will take quite a while.  Go have a excellent beer.
echo

BUILDER_SCRIPTS="/home/pfsense/tools/builder_scripts"
CVSROOT="/home/pfsense/cvsroot"

mkdir -p $BUILDER_SCRIPTS
mkdir -p $CVSROOT

# Create bootstrap supfile
echo "*default host=cvs.pfsense.com" >/tmp/bootstrap-supfile
echo "*default base=/home/pfsense/cvsroot" >>/tmp/bootstrap-supfile
echo "*default release=cvs" >>/tmp/bootstrap-supfile
echo "*default delete use-rel-suffix" >>/tmp/bootstrap-supfile
echo "pfSense" >>/tmp/bootstrap-supfile
echo "*default compress" >>/tmp/bootstrap-supfile

# Add cvsup
pkg_add -r cvsup-without-gui

# Cvsup pfSense files
cvsup /tmp/bootstrap-supfile

# Make sure everything is set
cvsup $BUILDER_SCRIPTS/pfSense-supfile

# CVSSync
sh $BUILDER_SCRIPTS/cvsup_current


