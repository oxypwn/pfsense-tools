#!/bin/sh
#
# Make a different size image from an already built nano source to save 
# builder run time.
#
# NOTE: This does NOT resize an .img file, it makes a new .img from the 
#       existing files from a previous builder run.
#
# usage: ./build_resized_nano.sh 2g
#
# Be sure to copy any existing /tmp/builder/nanobsd.full.img and 
#   nanobsd.upgrade.img to a safe place before running this again.

# Copy some variables from build_nano.sh
export IS_NANO_BUILD=yes
export NO_COMPRESSEDFS=yes

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Need some kind of safeguard to ensure a pre-built world exists
if [ ! -f "$PFSENSEBASEDIR/COPYRIGHT" ]; then
	echo "You must run build_nano.sh first!"
	exit 1
fi

# Is it a nanobsd VGA image?
[ -f "${PFSENSEBASEDIR}/etc/nano_use_vga.txt" ] \
	&& NANO_WITH_VGA="yes"

# Test $1 to make sure it is 512mb|1g|2g|4g
ISGOODSIZE="no"
case $1 in 
	512mb|512MB)
		ISGOODSIZE="YES"
	;;
	1g|1G)
		ISGOODSIZE="YES"
	;;
	2g|2G)
		ISGOODSIZE="YES"
	;;
	4g|4G)
		ISGOODSIZE="YES"
	;;
	8g|8G)
		ISGOODSIZE="YES"
	;;
	16g|16G)
		ISGOODSIZE="YES"
	;;
esac
if [ "$ISGOODSIZE" = "no" ]; then
	echo "Incorrect size passed.  Available sizes are 512mb, 1g, 2g and 4g"
	exit 1
fi

# Setup NanoBSD specific items
FLASH_SIZE=$1
FlashDevice $FLASH_MODEL $FLASH_SIZE
echo "$FLASH_SIZE" > /tmp/nanosize.txt
setup_nanobsd_etc
setup_nanobsd

# Get rid of non-wanted files
prune_usr

# Create the NanoBSD disk image for i386
if [ "$ARCH" = "i386" ]; then
	create_i386_diskimage
fi
# Create the NanoBSD disk image for mips
if [ "$ARCH" = "mips" ]; then
	create_mips_diskimage
fi

# Wrap up the show, Johnny
echo "Image completed."
echo "$MAKEOBJDIRPREFIXFINAL/"
[ -z "${NANO_WITH_VGA}" ] \
	&& ls -lah $MAKEOBJDIRPREFIXFINAL/nanobsd.* \
	|| ls -lah $MAKEOBJDIRPREFIXFINAL/nanobsd_vga.*

# Run final finish routines
finish
