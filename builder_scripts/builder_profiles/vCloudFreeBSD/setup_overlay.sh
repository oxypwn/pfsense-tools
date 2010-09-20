#!/bin/sh

# Set manually
TOOLSDIR=/home/pfsense/tools/builder_scripts/

# Copy pfsense-build.conf into TOOLSDIR
cp pfsense-build.conf	$TOOLSDIR
cp remove.list  		$TOOLSDIR
cp copy.list			$TOOLSDIR

# cd $TOOLSDIR and read in pfsense_local.sh
cd $TOOLSDIR

. ./pfsense_local.sh

# Ensure $SRCDIR exists
mkdir -p $SRCDIR

# Start building
if [ "$1" != "noupdate" ]; then
	echo ">>> noupdate flag NOT passed. Cleaning and updating GIT repo"
	./clean_build.sh
	./update_git_repos.sh
	./apply_kernel_patches.sh
fi
./build_freebsdisoonly.sh

