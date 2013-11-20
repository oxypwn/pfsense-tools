#!/bin/sh

###########################################
# pfSense builder configuration file      #
# Please don't modify this file, you      #
# can put your settings and options       #
# in pfsense-build.conf, which is         #
# sourced at the beginning of this file   #
###########################################

export BUILD_CONF=./pfsense-build.conf

# Ensure file exists
if [ -f ${BUILD_CONF} ]; then
	. ${BUILD_CONF}
elif [ -f ../${BUILD_CONF} ]; then
	. ../${BUILD_CONF}
else
	echo
	echo "You must first run ./set_version.sh !"
	echo "See http://devwiki.pfsense.org/DevelopersBootStrapAndDevIso for more information."
	echo
	echo "You can also run ./menu.sh which will assist with the available options"
	echo
fi

OIFS=$IFS
IFS=%

# FreeBSD version and build information
export pfSense_version=${pfSense_version:-8}
export FREEBSD_VERSION=${FREEBSD_VERSION:-8}
export FREEBSD_BRANCH=${FREEBSD_BRANCH:-"RELENG_8_3"}

export PRODUCT_NAME=${PRODUCT_NAME:-pfSense}

# Area that the final image will appear in
export MAKEOBJDIRPREFIXFINAL=${MAKEOBJDIRPREFIXFINAL:-/tmp/${PRODUCT_NAME}/}

# Leave near the top.
export MAKEOBJDIRPREFIX=${MAKEOBJDIRPREFIX:-/usr/obj.${PRODUCT_NAME}}

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

# Generally /home/pfsense/tools/builder_scripts/builder_profiles
export BUILDER_PROFILES=${BUILDER_SCRIPTS}/builder_profiles

# path to pfPorts
export pfSPORTS_BASE_DIR=${pfSPORTS_BASE_DIR:-${BASE_DIR}/${TOOLS_DIR}/pfPorts}

# Set it to "-c" to don't rebuild already built packages
CHECK_PORTS_INSTALLED=${CHECK_PORTS_INSTALLED:-""}

# This is the directory where the latest pfSense cvs co
# is checked out to.
export CVS_CO_DIR=${CVS_CO_DIR:-${BASE_DIR}/${PFSENSE_DIR}}

# Where pfSense is checked out.  This directory will
# be overlayed onto the image later in the process
export CUSTOMROOT=${CUSTOMROOT:-${CVS_CO_DIR}}

# This is where updates will be stored once they are created.
export UPDATESDIR=${UPDATESDIR:-$MAKEOBJDIRPREFIXFINAL/updates}

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
export PFSPKGFILE=${PFSPKGFILE:-/tmp/pfspackages}
export PFSBUILDERREQUIREDPORTS=${PFSBUILDERREQUIREDPORTS:-${BUILDER_SCRIPTS}/conf/pfPorts/builder_required_ports}
export FREESBIE_LABEL=${FREESBIE_LABEL:-${PRODUCT_NAME}}

# IMPORTANT NOTE: Maintain the order of EXTRAPLUGINS freesbie plugins!
if [ ${FREEBSD_VERSION} -ge 10 ]; then
	export EXTRAPLUGINS="${EXTRAPLUGINS:-"customroot customscripts pkgnginstall"}"
else
	export EXTRAPLUGINS="${EXTRAPLUGINS:-"customroot customscripts pkginstall"}"
fi

# Items beyond this must be defined after MAKEOBJDIRPREFIX!

# OVF/vmdk parms
export OVFPATH=${OVFPATH:-${MAKEOBJDIRPREFIXFINAL}}
# Name of ovf file included inside OVA archive
export OVFFILE=${OVFFILE:-${PRODUCT_NAME}.ovf}
# On disk name of VMDK file included in OVA
export OVFVMDK=${OVFVMDK:-${PRODUCT_NAME}.vmdk}
# Filename of final image output
export OVAFILE=${OVAFILE:-${PRODUCT_NAME}.ova}
# optional
export OVFCERT=${OVFCERT:-""}
# optional
export OVFSTRINGS=${OVFSTRINGS:-""}
# optional
export OVFMF=${OVFMF:-""}
# 10 gigabyte on disk VMDK size
export OVADISKSIZE=${OVADISKSIZE:-"10737418240"}
# dd buffering size when creating raw backed VMDK
export OVABLOCKSIZE=${OVABLOCKSIZE:-"409600"}
# first partition size (freebsd-ufs) GPT
export OVA_FIRST_PART_SIZE=${OVA_FIRST_PART_SIZE:-"8G"}
# swap partition size (freebsd-swap) GPT -
# remaining space of 10G-8G - 128 block beginning/loader
export OVA_SWAP_PART_SIZE=${OVA_SWAP_PART_SIZE:-"4193725"}
# 10737254400 = 10240MB = virtual box vmdk file size XXX grab this value from vbox creation
export OVA_DISKSECTIONALLOCATIONUNITS=${OVA_DISKSECTIONALLOCATIONUNITS:-"10737254400"}
# end of OVF

# Binary staging area for pfSense specific binaries.
export PFSENSE_HOST_BIN_PATH=${PFSENSE_HOST_BIN_PATH:-/usr/local/pfsense-bin/}

# Leave this alone.
export SRC_CONF_INSTALL=${SRC_CONF_INSTALL:-"/dev/null"}

#### User settable options follow ###

# This is used for using svnup for retrieving src instead of csup
# export USE_SVNUP=yes

# This is for specifying extra options to svnup
# Especially useful for CURRENT on FreeBSD
# export ${EXTRA_SVNUP_OPTIONS="-r $revision_in_svn"

export SVNUP_TARGET=${SVNUP_TARGET:-release}

# This is used for using svn for retrieving src
# export USE_SVN=yes
export SVN_BASE=${SVN_BASE:-"http://svn.freebsd.org/base"}
export SVN_BRANCH=${SVN_BRANCH:-"head"}

# Define FreeBSD SUPFILE
export SUPFILE=${SUPFILE:-"${BUILDER_TOOLS}/builder_scripts/conf/csup/${FREEBSD_BRANCH}-supfile"} 

# "UNBREAK TEXTMATE FORMATTING.  PLEASE LEAVE ME THANKS.

# Version that will be applied to this build
export PFSENSE_VERSION=${PFSENSE_VERSION:-2.1-DEVELOPMENT}

# pfSense cvs tag to build
export PFSENSETAG=${PFSENSETAG:-HEAD}

# Patch directory and patch file that lists patches to apply
export PFSPATCHDIR=${PFSPATCHDIR:-${BUILDER_TOOLS}/patches/${FREEBSD_BRANCH}}
export PFSPATCHFILE=${PFSPATCHFILE:-${BUILDER_TOOLS}/builder_scripts/conf/patchlist/patches.${PFSENSETAG}}

# Path to kernel files being built
export KERNEL_BUILD_PATH=${KERNEL_BUILD_PATH:-"/tmp/kernels"}

# Controls how many concurrent make processes are run for each stage
if [ "${NO_MAKEJ}" = "" ]; then
	CPUS=`sysctl kern.smp.cpus | awk '{ print $2 }'`
	CPUS=`expr $CPUS '*' 2`
	export MAKEJ_WORLD=${MAKEJ_WORLD:-"-j$CPUS"}
	export MAKEJ_KERNEL=${MAKEJ_KERNEL:-"-j$CPUS"}
else
	export MAKEJ_WORLD=${MAKEJ_WORLD:-""}
	export MAKEJ_KERNEL=${MAKEJ_KERNEL:-""}
fi
if [ ${FREEBSD_VERSION} -ge 10 ]; then
	export MODULES_OVERRIDE=${MODULES_OVERRIDE:-"i2c ipmi acpi ndis ipfw ipdivert dummynet fdescfs cpufreq opensolaris zfs glxsb if_stf virtio coretemp amdtemp aesni sfxge mps ahci"}
elif [ ${FREEBSD_VERSION} -gt 7 -a "$FREEBSD_BRANCH" != "RELENG_8_1" ]; then
	export MODULES_OVERRIDE=${MODULES_OVERRIDE:-"i2c ipmi acpi ndis ipfw ipdivert dummynet fdescfs cpufreq opensolaris zfs glxsb runfw if_stf virtio coretemp amdtemp aesni sfxge mps ahci"}
else
	export MODULES_OVERRIDE=${MODULES_OVERRIDE:-"i2c ipmi acpi ndis ipfw ipdivert dummynet fdescfs cpufreq opensolaris zfs glxsb runfw if_stf coretemp amdtemp"}
fi
export MAKEJ_PORTS=${MAKEJ_PORTS:-""}
export NOEXTRA_DEVICES=${NOEXTRA_DEVICES:-}
export EXTRA_OPTIONS=${EXTRA_OPTIONS:-}
export NOEXTRA_OPTIONS=${NOEXTRA_OPTIONS:-}

# DO NOT SET THIS.  IT WILL BREAK 1.2.3 builds.  This is now
# set by default in setup_overlay.sh
# export EXTRA_DEVICES=${EXTRA_DEVICES:-"siba_bwn,bwn,run"}

# Do not clean.  Makes subsequent builds quicker.
export NO_CLEAN=${NO_CLEAN:-"yo"}
export NO_KERNEL_CLEAN=${NO_CLEAN:-"yo"}

# Config directory for nanobsd build
export CONFIG_DIR=conf
export NANO_NAME=pfsense
export CONFIG_DIR=nano
# Number of code images on media (1 or 2)
export NANO_IMAGES=2
# 0 -> Leave second image all zeroes so it compresses better.
# 1 -> Initialize second image with a copy of the first
export NANO_INIT_IMG2=1
export NANO_RAM_ETCSIZE=30720
export NANO_RAM_TMPVARSIZE=51200
export NANO_WITH_VGA=${NANO_WITH_VGA:-""}
export NANO_NEWFS="-b 4096 -f 512 -i 8192 -O1"
export FLASH_MODEL=${FLASH_MODEL:-"sandisk"}
export FLASH_SIZE=${FLASH_SIZE:-"1g"}
# Size of code file system in 512 bytes sectors
# If zero, size will be as large as possible.
export NANO_CODESIZE=0
# Size of data file system in 512 bytes sectors
# If zero: no partition configured.
# If negative: max size possible
export NANO_DATASIZE=0
# Size of pfSense /conf partition  # 102400 = 50 megabytes.
export NANO_CONFSIZE=102400
# Add UNIONFS
export NO_UNIONFS=YES
export UNION_DIRS="etc usr root"
# packet is OK for 90% of embedded
export NANO_BOOT0CFG="-o packet -s 1 -m 3"

# Architecture, supported ARCH values are: 
#  Tier 1: i386, AMD64, and PC98
#  Tier 2: ARM, PowerPC, ia64, Sparc64 and sun4v
#  Tier 3: MIPS and S/390
#  Tier 4: None at the moment
#  Source: http://www.freebsd.org/doc/en/articles/committers-guide/archs.html
export ARCH=${ARCH:-"`uname -m`"}
#export TARGET_ARCH=${TARGET_ARCH:-"i386"}

# Set this if you are cross compiling on i386 and have a
# .tgz file which includes full path to all of the platforms
# pfPorts binaries.  An example of this is with mips.
#export CROSS_COMPILE_PORTS_BINARIES="~sullrich/mips.tgz"

# Custom Copy and Remove lists that override base remove.list.* and copy.list.*
export CUSTOM_REMOVE_LIST=${CUSTOM_REMOVE_LIST:-"${BUILDER_SCRIPTS}/conf/rmlist/remove.list.iso.$FREEBSD_VERSION"}

# " - UNBREAK TEXTMATE FORMATTING - PLEASE LEAVE.

# Use a custom config.xml
#export USE_CONFIG_XML=${USE_CONFIG_XML:-"/path/to/custom/config.xml"}

# GIT pfSense, BSDInstaller & FreeSBIE GIT repo settings
export USE_GIT=${USE_GIT:-"yo"}
export GIT_REPO=${GIT_REPO:-"git://github.com/pfsense/pfsense.git"}
export GIT_REPO_DIR="${BASE_DIR}/pfSenseGITREPO"
export GIT_REPO_FREESBIE2=${GIT_REPO_FREESBIE2:-"git://github.com/pfsense/freesbie2.git freesbie2"}
export GIT_REPO_TOOLS=${GIT_TOOLS_REPO:-"git://github.com/pfsense/pfsense-tools.git tools"}

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
#export custom_overlay="${BASE_DIR}/custom_overlay"

# Package overlay. This gives people a chance to build a pfSense
# installable image that already contains certain pfSense packages.
#
# Needs to contain comma separated package names. Of course
# package names must be valid. Using non existent
# package name would yield an error.
#
#export custom_package_list=""

# This is used for developers with access to the pfSense
# cvsup update server.  Note that it is firewalled by default.
# If uncommented the system will use fastest-cvsup to find
# a suitable update source to spread the load.
#export OVERRIDE_FREEBSD_CVSUP_HOST="cvsup.livebsd.com"

# This will allow overriding of which pfSense components
# to include during this build run.  'all' will use
# the old behavior and install *everything*
# Available modules:
# all auth authgui captiveportal certificate_managaer
# config crypto filter interfaces ipsec notifications
# openvpn  pkg routing rrd shaper utils vpn
export PFSENSE_MODULES=${PFSENSE_MODULES:-"all"}

# Items that can be turned off (snapshots)
#
#export DO_NOT_BUILD_ISO="true"
#export DO_NOT_BUILD_NANOBSD="true"
#export DO_NOT_BUILD_PFPORTS="true"
#export DO_NOT_BUILD_UPDATES="true"

# General builder output filenames
export ISOPATH=${ISOPATH:-${MAKEOBJDIRPREFIXFINAL}/${PRODUCT_NAME}-LiveCD-${PFSENSE_VERSION}-${ARCH}-`date '+%Y%m%d-%H%M'`.iso}
export IMGPATH=${IMGPATH:-${MAKEOBJDIRPREFIXFINAL}/${PRODUCT_NAME}-${PFSENSE_VERSION}-${ARCH}-`date '+%Y%m%d-%H%M'`.img}
export MEMSTICKPATH=${MEMSTICKPATH:-${MAKEOBJDIRPREFIXFINAL}/${PRODUCT_NAME}-memstick-${PFSENSE_VERSION}-${ARCH}-`date '+%Y%m%d-%H%M'`.img}
export MEMSTICKSERIALPATH=${MEMSTICKSERIALPATH:-${MAKEOBJDIRPREFIXFINAL}/${PRODUCT_NAME}-memstick-serial-${PFSENSE_VERSION}-${ARCH}-`date '+%Y%m%d-%H%M'`.img}

# set full-update update filename
export UPDATES_TARBALL_FILENAME=${UPDATES_TARBALL_FILENAME:-"${UPDATESDIR}/${PRODUCT_NAME}-Full-Update-${PFSENSE_VERSION}-${ARCH}-`date '+%Y%m%d-%H%M'`.tgz"}

# " - UNBREAK TEXTMATE FORMATTING - PLEASE LEAVE.

# Checkout the GIT repo every time. This is normally not necessary.
# export PFSENSE_WITH_FULL_GIT_CHECKOUT="true"

# Can call custom functions during build such as disable_lan_disable_dhcpd_enable_sshd
export CUSTOM_CALL_SHELL_FUNCTION=${CUSTOM_CALL_SHELL_FUNCTION:-""}

export BUILDER_AUTO_UPDATE_APPLY_PATCHES=${BUILDER_AUTO_UPDATE_APPLY_PATCHES:-"YES"}

if [ -z "${NANO_WITH_VGA}" ]; then
	export BUILD_KERNELS=${BUILD_KERNELS:-"pfSense_SMP.${FREEBSD_VERSION} pfSense_wrap.${FREEBSD_VERSION}.${ARCH}"}
else
	export BUILD_KERNELS=${BUILD_KERNELS:-"pfSense_SMP.${FREEBSD_VERSION} pfSense_wrap_vga.${FREEBSD_VERSION}.${ARCH}"}
fi

if [ ${FREEBSD_VERSION} -ge 10 ]; then
	USE_PKGNG=yes
	PKG_INFO="pkg info"
	PKG_QUERY="pkg query %n"
else
	PKG_INFO="pkg_info"
	PKG_QUERY="pkg_info -e"
fi

# This needs to be at the very end of the file.
IFS=$OIFS
