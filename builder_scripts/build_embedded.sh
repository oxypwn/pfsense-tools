#!/bin/sh

# pfSense master builder script
# (C)2005 Scott Ullrich and the pfSense project
# All rights reserved.

set -e -u		# uncomment me if you want to exit on shell errors

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Define the Kernel file we're using
export KERNCONF=pfSense_wrap.6

# Update cvs depot. If SKIP_RSYNC is defined, skip the RSYNC update.
# If also SKIP_CHECKOUT is defined, don't update the tree at all
if [ -z "${SKIP_RSYNC:-}" ]; then
	rm -rf $BASE_DIR/pfSense
	rsync -avz ${CVS_USER}@${CVS_IP}:/cvsroot /home/pfsense/
	(cd $BASE_DIR && cvs -d /home/pfsense/cvsroot co -r ${PFSENSETAG} pfSense)
elif [ -z "${SKIP_CHECKOUT:-}" ]; then
	rm -rf $BASE_DIR/pfSense
	(cd $BASE_DIR && cvs -d :ext:${CVS_USER}@${CVS_IP}:/cvsroot co -r ${PFSENSETAG} pfSense)
fi

# Calculate versions
export version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
export version_base=`cat $CVS_CO_DIR/etc/version_base`
export version=`cat $CVS_CO_DIR/etc/version`

# Check if the world and kernel are already built and set
# the NO variables accordingly
objdir=${MAKEOBJDIRPREFIX:-/usr/obj}
build_id=`basename ${KERNELCONF}`
if [ -f "${objdir}/${build_id}.world.done" ]; then
	export NO_BUILDWORLD=yo
fi
if [ -f "${objdir}/${build_id}.kernel.done" ]; then
	export NO_BUILDKERNEL=yo
fi

# Make world
freesbie_make buildworld
touch ${objdir}/${build_id}.world.done

# Make kernel
freesbie_make buildkernel
touch ${objdir}/${build_id}.kernel.done

freesbie_make installkernel installworld

# Checkout pfSense information and set our version variables.
(cd $BASE_DIR && cvs -d /home/pfsense/cvsroot co -r ${PFSENSETAG} pfSense)

# Calculate versions
version_kernel=`cat $CVS_CO_DIR/etc/version_kernel`
version_base=`cat $CVS_CO_DIR/etc/version_base`
version=`cat $CVS_CO_DIR/etc/version`

# Add extra files such as buildtime of version, bsnmpd, etc.
populate_extra

clone_system_only

fixup_wrap

