#!/bin/sh

# Set manually
TOOLSDIR=/home/pfsense/tools/builder_scripts/

# Copy pfsense-build.conf into TOOLSDIR
cp pfsense-build.conf  $TOOLSDIR

# cd $TOOLSDIR and read in pfsense_local.sh
cd $TOOLSDIR

. ./pfsense_local.sh

# Ensure $SRCDIR exists
mkdir -p $SRCDIR

# Start building
./clean_build.sh
./update_git_repos.sh
./apply_kernel_patches.sh
./build_pfPorts.sh
./build_iso.sh

