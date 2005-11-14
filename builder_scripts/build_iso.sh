#!/bin/sh

# pfSense master builder script
# (C)2005 Scott Ullrich and the pfSense project
# All rights reserved.

# set -e -u		# uncomment me if you want to exit on shell errors

set -x

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Remove staging area files
rm -rf $LOCALDIR/customroot/*
rm -rf $BASE_DIR/pfSense
chflags -R noschg $FREESBIEBASEDIR/
chflags -R noschg $FREESBIEISODIR/
rm -rf $FREESBIEBASEDIR/*
rm -rf $FREESBIEISODIR/*
mkdir -p $FREESBIEBASEDIR
mkdir -p $FREESBIEISODIR
mtree -deU -f $LOCALDIR/files/FREESBIE.run.dist -p $FREESBIEBASEDIR || echo "Error running mtree"

# Update cvs depot
rsync -avz sullrich@216.135.66.16:/cvsroot /home/pfsense/
cd $BASE_DIR && cvs -d /home/pfsense/cvsroot co -r RELENG_1 pfSense

# Calculate versions
version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
version_base=`cat $CVS_CO_DIR/etc/version_base`
version=`cat $CVS_CO_DIR/etc/version`

# Define the Kernel file we're using
export KERNCONF=pfSense.6

cd $LOCALDIR 

# Add extra files such as buildtime of version, bsnmpd, etc.
echo ">>> Phase populate_extra"
populate_extra
echo ">>> Phase set_image_as_cdrom"
set_image_as_cdrom
echo ">>> Phase create_pfSense_tarball"
create_pfSense_tarball
echo ">>> Phase copy_pfSesne_tarball_to_custom_directory"
copy_pfSense_tarball_to_custom_directory

cd /var/db/pkg && ls | grep bsdinstaller > $LOCALDIR/packages
cd /var/db/pkg && ls | grep cpdup >> $LOCALDIR/packages

# Invoke FreeSBIE2 rebuild command
cd $LOCALDIR 
./rebuild
