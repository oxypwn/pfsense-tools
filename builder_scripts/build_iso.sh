#!/bin/sh

# pfSense master builder script
# (C)2005 Scott Ullrich and the pfSense project
# All rights reserved.

# set -e -u		# uncomment me if you want to exit on shell errors

set -x

# If config.sh does not exist, lets run the freesbie config script
# to prompt for the values.
[ -f ../../freesbie/config.sh ] || ../../freesbie/freesbie

# Read in FreeSBIE configuration variables and set:
#   FREESBIEBASEDIR=/usr/local/livefs
#   LOCALDIR=/home/pfSense/freesbie
#   PATHISO=/home/pfSense/freesbie/FreeSBIE.iso
. ../../freesbie/config.sh
. ../../freesbie/.common.sh

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Remove staging area files
rm -rf $LOCALDIR/files/custom/*
rm -rf $BASE_DIR/pfSense

# Checkout pfSense information and set our version variables.
cd $BASE_DIR && cvs -d:ext:$CVS_USER@216.135.66.16:/cvsroot co pfSense 

# Calculate versions
version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
version_base=`cat $CVS_CO_DIR/etc/version_base`
version=`cat $CVS_CO_DIR/etc/version`

# Define the Kernel file we're using
export KERNCONF=pfSense.6

cd $LOCALDIR 

echo ">>> Phase 0"
$LOCALDIR/0.rmdir.sh

echo ">>> Phase 1"
$LOCALDIR/1.mkdir.sh

echo ">>> Phase 2"
$LOCALDIR/2.buildworld.sh		# This can be remarked out if completed
					# prior to this build

echo ">>> Phase 3"
$LOCALDIR/3.installworld.sh

echo ">>> Phase 4"
$LOCALDIR/4.kernel.sh

echo ">>> Phase 5"
$LOCALDIR/5.patchfiles.sh

echo ">>> Phase 6"
$LOCALDIR/6.packages.sh

# Add extra files such as buildtime of version, bsnmpd, etc.
echo ">>> Phase populate_extra"
populate_extra
echo ">>> Phase set_image_as_cdrom"
set_image_as_cdrom
echo ">>> Phase create_pfSense_tarball"
create_pfSense_tarball
echo ">>> Phase copy_pfSesne_tarball_to_custom_directory"
copy_pfSesne_tarball_to_custom_directory

echo ">>> Phase 7"
$LOCALDIR/7.customuser.sh
$LOCALDIR/71.bsdinstaller.sh

echo ">>> Phase 8"
$LOCALDIR/8.preparefs.sh

echo ">>> Phase 8.1"
$LOCALDIR/81.mkiso.sh


