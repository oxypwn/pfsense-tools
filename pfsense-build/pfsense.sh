#!/bin/sh
FREESBIE_CONF=$PWD/pfsense-freesbie.conf
FREESBIE_PATH=/home/pfsense/freesbie2
CUSTOMROOT=$PWD/customroot
PKGFILE=$PWD/packages
KERNELCONF=$PWD/PFSENSE
MAKE_CONF=$PWD/make.conf

export FREESBIE_CONF
export CUSTOMROOT
export PKGFILE
export KERNELCONF
export MAKE_CONF
cd $FREESBIE_PATH

make iso



