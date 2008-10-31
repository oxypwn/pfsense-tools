#!/bin/sh

######################################
# pfSense builder configuration file #
# Please don't modify this file, you #
# can put your settings and options  #
# in pfsense-build.conf, which is    #
# sourced at the end of this file    #
######################################

# $Id$

# Leave near the top.  
export MAKEOBJDIRPREFIX=${MAKEOBJDIRPREFIX:-/usr/obj.pfSense}

# Generally /home/pfsense
export BASE_DIR=${BASE_DIR:-/home/pfsense}

# path to pfPorts
export pfSPORTS_BASE_DIR=${pfSPORTS_BASE_DIR:-/home/pfsense/tools/pfPorts}

# This is the base working directory for all builder operations
export BASE_DIR=${BASE_DIR:-/home/pfsense}

# This is the directory where the latest pfSense cvs co
# is checked out to.
export CVS_CO_DIR=${CVS_CO_DIR:-${BASE_DIR}/pfSense}

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
export FREESBIE_PATH=${FREESBIE_PATH:-/home/pfsense/freesbie2}

# export variables used by freesbie2
export FREESBIE_CONF=${FREESBIE_CONF:-/dev/null} # No configuration file should be override our variables
export SRCDIR=${SRCDIR:-/usr/src}
export BASEDIR=${PFSENSEBASEDIR:-/usr/local/pfsense-fs}
export CLONEDIR=${PFSENSEISODIR:-/usr/local/pfsense-clone}
export PKGFILE=${PKGFILE:-$PWD/conf/packages}
export FREESBIE_LABEL=pfDNS

# IMPORTANT NOTE: Maintain the order of EXTRA freesbie plugins!
export EXTRA="${EXTRA:-"customroot customscripts buildmodules"}"

# Extra modules that we want (FreeBSD)
export BUILDMODULES="ipfw netgraph acpi ndis if_ndis padlock ipfw dummynet fdescfs cpufreq"

# Must be defined after MAKEOBJDIRPREFIX!
export ISOPATH=${ISOPATH:-${MAKEOBJDIRPREFIX}/pfDNS.iso}
export IMGPATH=${IMGPATH:-${MAKEOBJDIRPREFIX}/pfDNS.img}

# Binary staging area for pfSense specific binaries.
export PFSENSE_HOST_BIN_PATH="/usr/local/pfsense-bin/"

# Leave this alone.
export SRC_CONF_INSTALL=${SRC_CONF_INSTALL:-"/dev/null"}

#### User settable options follow ### 

# FreeBSD version.
export pfSense_version="7"
export FreeBSD_version="7"
export freebsd_branch="RELENG_7"

# Define FreeBSD SUPFILE
export SUPFILE="${BASE_DIR}/tools/builder_scripts/${freebsd_branch}-supfile"

# Version that will be applied to this build
export PFSENSEVERSION=${PFSENSEVERSION:-1.0-BETA1}

export PFSENSETAG=${PFSENSETAG:-RELENG_1}

# Patch directory and patch file that lists patches to apply
export PFSPATCHDIR=${BASE_DIR}/tools/patches/RELENG_7
export PATCHFILE=${BASE_DIR}/tools/builder_scripts/patches.RELENG_2_0

export MAKEJ_WORLD=${MAKEJ_WORLD:-"-j4"}
export MAKEJ_KERNEL=${MAKEJ_KERNEL:-""}
export MAKEJ_PORTS=${MAKEJ_PORTS:-"-j1"}

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
export NANO_DRIVE=ad0
export NANO_MEDIASIZE=1000000 
export NANO_SECTS=63 
export NANO_HEADS=16
export NANO_CODESIZE=0 
export NANO_CONFSIZE=2048 

# Add UNIONFS
export NO_UNIONFS=NO
export UNION_DIRS="etc usr root"

# Custom Copy and Remove lists that override base remove.list.* and copy.list.*
export CUSTOM_REMOVE_LIST="${BASE_DIR}/tools/builder_scripts/builder_profiles/pfDNS/remove.list"
export CUSTOM_COPY_LIST="${BASE_DIR}/tools/builder_scripts/builder_profiles/pfDNS/copy.list"

# Use a custom config.xml
export USE_CONFIG_XML=${USE_CONFIG_XML:-"${BASE_DIR}/tools/builder_scripts/builder_profiles/pfDNS/config/config.xml"}

# Architecture, supported ARCH values are: 
#  Tier 1: i386, AMD64, and PC98
#  Tier 2: ARM, PowerPC, ia64, Sparc64 and sun4v
#  Tier 3: MIPS and S/390
#  Tier 4: None at the moment
#  Source: http://www.freebsd.org/doc/en/articles/committers-guide/archs.html
export ARCH="i386"

# GIT pfSense, BSDInstaller & FreeSBIE settings
#export USE_GIT=${USE_GIT:-"yo"}
#export GIT_REPO=${GIT_REPO:-"http://gitweb.pfsense.org/pfsense-import-test-minus-binaries/mainline.git pfSense"}
#export GIT_REPO_BSDINSTALLER=${GIT_REPO_BSDINSTALLER:-"http://gitweb.pfsense.org/bsdinstaller/mainline.git"}
#export GIT_REPO_FREESBIE2=${GIT_REPO_FREESBIE2:-"http://gitweb.pfsense.org/freesbie2/mainline.git"}

export custom_overlay="${BASE_DIR}/tools/builder_scripts/builder_profiles/pfDNS/copy_overlay/"

export custom_package_list="dns-server, AutoConfigBackup"

# This is used for developers with access to the pfSense
# cvsup update server.  Note that it is firewalled by default.
# If uncommented the system will use fastest-cvsup to find
# a suitable update source to spread the load.
#export OVERRIDE_FREEBSD_CVSUP_HOST="cvsup.livebsd.com"

############################################
# The following line must always come last #
############################################
[ -r "pfsense-build.conf" ] && . pfsense-build.conf

