#!/bin/sh

# pfSense master builder script
# (C)2005 Scott Ullrich and the pfSense project
# All rights reserved.

#set -e -u		# uncomment me if you want to exit on shell errors

# If config.sh does not exist, lets run the freesbie config script
# to prompt for the values.
[ -e ../../freesbie/config.sh ] || ../../freesbie/freesbie

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

# Checkout pfSense information and set our version variables.
cd $BASE_DIR && cvs -d:ext:$CVS_USER@216.135.66.16:/cvsroot co pfSense >/dev/null

# Calculate versions
version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
version_base=`cat $CVS_CO_DIR/etc/version_base`
version=`cat $CVS_CO_DIR/etc/version`

cd $LOCALDIR 

$LOCALDIR/0.rmdir.sh

$LOCALDIR/1.mkdir.sh

#$LOCALDIR/2.buildworld.sh		# This can be remarked out if completed
					# prior to this build
$LOCALDIR/3.installworld.sh

$LOCALDIR/4.kernel.sh pfSense.6

$LOCALDIR/5.patchfiles.sh

$LOCALDIR/6.packages.sh

$LOCALDIR/7.customuser.sh

# Add extra files such as buildtime of version, bsnmpd, etc.
populate_extra
set_image_as_cdrom
create_pfSense_tarball
copy_pfSesne_tarball_to_custom_directory

$LOCALDIR/8.preparefs.sh

$LOCALDIR/81.mkiso.sh




