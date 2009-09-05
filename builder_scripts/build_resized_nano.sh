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


# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

# Need some kind of safeguard to ensure a pre-built world exists

# Test $1 to make sure it is 512mb|1g|2g|4g

# Setup NanoBSD specific items
FLASH_SIZE=$1
FlashDevice $FLASH_MODEL $FLASH_SIZE
setup_nanobsd_etc
setup_nanobsd

# Get rid of non-wanted files
prune_usr

# Create the NanoBSD disk image
create_i386_diskimage

# Wrap up the show, Johnny
echo "Image completed."
echo "$MAKEOBJDIRPREFIXFINAL/"
ls -lah $MAKEOBJDIRPREFIXFINAL/nanobsd*

# Run final finish routines
finish
