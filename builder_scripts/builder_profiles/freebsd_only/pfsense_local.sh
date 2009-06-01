#!/bin/sh

######################################
# pfSense builder configuration file #
# Please don't modify this file, you #
# can put your settings and options  #
# in pfsense-build.conf, which is    #
# sourced at the end of this file    #
######################################

# $Id$

# Ensure file exists
if [ ! -f ./pfsense-build.conf ]; then
	echo "You must first run ./set_version.sh !"
	exit 1
fi

. ./pfsense-build.conf

# Leave near the top.  
export MAKEOBJDIRPREFIX=${MAKEOBJDIRPREFIX:-/usr/obj.FreeBSD}

# Generally /home/pfsense
export BASE_DIR=${BASE_DIR:-/home/pfsense}

# pfSense and tools directory name
# Used for Git checkout
export TOOLS_DIR=${TOOLS_DIR:-tools}
export PFSENSE_DIR=${PFSENSE_DIR:-pfSense}
export FREESBIE_DIR=${FREESBIE_DIR:-freesbie2}

# Generally /home/pfsense/tools
export BUILDER_TOOLS=${BUILDER_TOOLS:-${BASE_DIR}/${TOOLS_DIR}}

# Generally /home/pfsense/tools/builder_scripts
export BUILDER_SCRIPTS=${BUILDER_SCRIPTS:-${BUILDER_TOOLS}/builder_scripts}

# path to pfPorts
export pfSPORTS_BASE_DIR=${pfSPORTS_BASE_DIR:-${BASE_DIR}/${TOOLS_DIR}/pfPorts}

# This is the directory where the latest pfSense cvs co
# is checked out to.
export CVS_CO_DIR=${CVS_CO_DIR:-${BASE_DIR}/${PFSENSE_DIR}}

# Where pfSense is checked out.  This directory will
# be overlayed onto the image later in the process
export CUSTOMROOT=${CUSTOMROOT:-${CVS_CO_DIR}}

# This is the user that has access to the pfSense repo
export CVS_USER=${CVS_USER:-sullrich}

# pfSense repo IP address. Typically cvs.pfsense.org,
# but somebody could use a ssh tunnel and specify
# a different one
export CVS_IP=${CVS_IP:-cvs.pfsense.org}

# This is where updates will be stored once they are created.
export UPDATESDIR=${UPDATESDIR:-$BASE_DIR/updates}

# This is where FreeSBIE will initially install all files to
export PFSENSEBASEDIR=${PFSENSEBASEDIR:-/usr/local/pfsense-fs}

# Directory that FreeSBIE will clone to in order to create
# iso staging area.
export PFSENSEISODIR=${PFSENSEISODIR:-/usr/local/pfsense-clone}

# FreeSBIE 2 toolkit path
export FREESBIE_PATH=${FREESBIE_PATH:-${BASE_DIR}/${FREESBIE_DIR}}

# export variables used by freesbie2
export FREESBIE_CONF=${FREESBIE_CONF:-/dev/null} # No configuration file should be override our variables
export SRCDIR=${SRCDIR:-/usr/pfSensesrc/src}
export BASEDIR=${PFSENSEBASEDIR:-/usr/local/pfsense-fs}
export CLONEDIR=${PFSENSEISODIR:-/usr/local/pfsense-clone}
export PKGFILE=${PKGFILE:-$PWD/conf/packages}
export FREESBIE_LABEL=FreeBSD

# IMPORTANT NOTE: Maintain the order of EXTRA freesbie plugins!
export EXTRA="${EXTRA:-"customscripts buildmodules"}"

# Extra modules that we want (FreeBSD)
export BUILDMODULES="ipfw netgraph acpi ndis if_ndis padlock ipfw dummynet fdescfs cpufreq"

# Must be defined after MAKEOBJDIRPREFIX!
export ISOPATH=${ISOPATH:-${MAKEOBJDIRPREFIX}/FreeBSD.iso}
export IMGPATH=${IMGPATH:-${MAKEOBJDIRPREFIX}/FreeBSD.img}

# Binary staging area for pfSense specific binaries.
export PFSENSE_HOST_BIN_PATH="/usr/local/pfsense-bin/"

# Leave this alone.
export SRC_CONF_INSTALL=${SRC_CONF_INSTALL:-"/dev/null"}

#### User settable options follow ### 

# FreeBSD version and build information
export pfSense_version=${pfSense_version:-"8"}
export FREEBSD_VERSION=${FREEBSD_VERSION:-"8"}
export FREEBSD_BRANCH=${FREEBSD_BRANCH:-"RELENG_8_0"}

# Define FreeBSD SUPFILE
export SUPFILE=${SUPFILE:-"${BUILDER_TOOLS}/builder_scripts/${FREEBSD_BRANCH}-supfile"}

# Version that will be applied to this build
export PFSENSE_VERSION=${PFSENSE_VERSION:-1.2.1-RC2}

# pfSense cvs tag to build
export PFSENSETAG=${PFSENSETAG:-RELENG_1_2}

# Development version
# export PFSENSETAG=${PFSENSETAG:-RELENG_1}

# Patch directory and patch file that lists patches to apply
export PFSPATCHDIR=${PFSPATCHDIR:-${BUILDER_TOOLS}/patches/${FREEBSD_BRANCH}}
export PFSPATCHFILE=${PFSPATCHFILE:-${BUILDER_TOOLS}/builder_scripts/patches.${PFSENSETAG}}

# Controls how many concurrent make processes are run for each stage
export MAKEJ_WORLD=${MAKEJ_WORLD:-"-j8"}
export MAKEJ_KERNEL=${MAKEJ_KERNEL:-""}
export MAKEJ_PORTS=${MAKEJ_PORTS:-""}

# Do not clean.  Makes subsequent builds quicker.
export NO_CLEAN=${NO_CLEAN:-"yo"}
export NO_KERNELCLEAN=${NO_CLEAN:-"yo"}

# Config directory for nanobsd build
export CONFIG_DIR=conf
export NANO_NAME=pfsense
export CONFIG_DIR=nano
export NANO_IMAGES=1
export NANO_INIT_IMG2=0
export NANO_DATASIZE=20480
export NANO_RAM_ETCSIZE=30720
export NANO_RAM_TMPVARSIZE=51200
export NANO_BOOT0CFG="-o packet -s 1 -m 3 -v"
export NANO_BOOTLOADER="boot/boot0"
export NANO_NEWFS="-b 4096 -f 512 -i 8192 -O1"
export NANO_MEDIASIZE=1000000 
export NANO_SECTS=63 
export NANO_HEADS=16
export FLASH_MODEL="sandisk" 
export FLASH_SIZE="256mb"
export NANO_CODESIZE=0 
export NANO_CONFSIZE=2048 

# Add UNIONFS
export NO_UNIONFS=NO
export UNION_DIRS="etc usr root"

# Architecture, supported ARCH values are: 
#  Tier 1: i386, AMD64, and PC98
#  Tier 2: ARM, PowerPC, ia64, Sparc64 and sun4v
#  Tier 3: MIPS and S/390
#  Tier 4: None at the moment
#  Source: http://www.freebsd.org/doc/en/articles/committers-guide/archs.html
export ARCH="i386"
#export TARGET_ARCH="i386"

# Custom Copy and Remove lists that override base remove.list.* and copy.list.*
#export CUSTOM_REMOVE_LIST=""
#export CUSTOM_COPY_LIST=""

# Use a custom config.xml
#export USE_CONFIG_XML=${USE_CONFIG_XML:-"/path/to/custom/config.xml"}

# GIT pfSense, BSDInstaller & FreeSBIE GIT repo settings
#export USE_GIT=${USE_GIT:-"yo"}
#export GIT_REPO=${GIT_REPO:-"http://gitweb.pfsense.org/pfsense/mainline.git pfSense"}
#export GIT_REPO_DIR="${BASE_DIR}/pfSenseGITREPO"
#export GIT_REPO_BSDINSTALLER=${GIT_REPO_BSDINSTALLER:-"http://gitweb.pfsense.org/bsdinstaller/mainline.git"}
#export GIT_REPO_FREESBIE2=${GIT_REPO_FREESBIE2:-"http://gitweb.pfsense.org/freesbie2/mainline.git"}

# Custom overlay for people building or extending pfSense images.
# The custom overlay tar gzipped file will be extracted over the root
# of the prepared image allowing for customization.
#
# Note: It is also possible to specify a directory instead of a
#       gzipped tarball.
#
# Tarball overlay (please uncomment): 
#export custom_overlay="${BASE_DIR}/custom_overlay.tgz"
#
# Directory overlay (please uncomment):
export custom_overlay="${BUILDER_PROFILES}/freebsd_only/copy_overlay/"

# Package overlay. This gives people a chance to build a pfSense
# installable image that already contains certain pfSense packages.
#
# Needs to contain comma separated package names. Of course
# package names must be valid. Using non existent
# package name would yield an error.
#
#export custom_package_list="AutoConfigBackup, siproxd"

# This is used for developers with access to the pfSense
# cvsup update server.  Note that it is firewalled by default.
# If uncommented the system will use fastest-cvsup to find
# a suitable update source to spread the load.
#export OVERRIDE_FREEBSD_CVSUP_HOST="cvsup.livebsd.com"
