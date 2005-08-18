#!/bin/sh

# pfSense master builder script
# (C)2005 Scott Ullrich and the pfSense project
# All rights reserved.

#set -e -u		# uncomment me if you want to exit on shell errors

CUWD=`/bin/pwd`

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

# Define the Kernel file we're using
export KERNCONF=pfSense.6
#export KERNCONF=pfSense_wrap.6

# Remove staging area files
rm -rf $LOCALDIR/files/custom/*
rm -rf $BASE_DIR/pfSense

# Update cvs depot
rsync -avz sullrich@216.135.66.16:/cvsroot /home/pfsense/
cd $BASE_DIR && cvs -d /home/pfsense/cvsroot co pfSense

# Calculate versions
version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
version_base=`cat $CVS_CO_DIR/etc/version_base`
version=`cat $CVS_CO_DIR/etc/version`

cd $LOCALDIR 

# Add extra files such as buildtime of version, bsnmpd, etc.
populate_extra
create_pfSense_tarball
copy_pfSense_tarball_to_freesbiebasedir
fixup_updates

create_pfSense_Full_update_tarball


