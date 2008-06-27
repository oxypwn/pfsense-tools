#!/bin/sh

######################################
# pfSense builder configuration file #
# See user settable options area for #
# common user changable options.     #
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
export FREESBIE_LABEL=pfSense

# IMPORTANT NOTE: Maintain the order of EXTRA freesbie plugins!
export EXTRA="${EXTRA:-"customroot customscripts buildmodules"}"

# Extra modules that we want (FreeBSD)
export BUILDMODULES="ipfw netgraph acpi ndis if_ndis padlock ipfw dummynet fdescfs cpufreq"

# Must be defined after MAKEOBJDIRPREFIX!
export ISOPATH=${ISOPATH:-${MAKEOBJDIRPREFIX}/pfSense.iso}
export IMGPATH=${IMGPATH:-${MAKEOBJDIRPREFIX}/pfSense.img}

# Binary staging area for pfSense specific binaries.
export PFSENSE_HOST_BIN_PATH="/usr/local/pfsense-bin/"

# Leave this alone.
export SRC_CONF_INSTALL=${SRC_CONF_INSTALL:-"/dev/null"}

#### User settable options follow ### 

# FreeBSD version.
export pfSense_version="7"
export freebsd_branch="RELENG_7_0"

# pfSense cvs tag to build
export PFSENSETAG=${PFSENSETAG:-RELENG_1_2}

# Development version
# export PFSENSETAG=${PFSENSETAG:-RELENG_1}

export MAKEJ_WORLD=${MAKEJ_WORLD:-"-j4"}
export MAKEJ_KERNEL=${MAKEJ_KERNEL:-""}
export MAKEJ_PORTS=${MAKEJ_PORTS:-"-j1"}

export NO_CLEAN=${NO_CLEAN:-"yo"}
export NO_KERNELCLEAN=${NO_CLEAN:-"yo"}

# Custom overlay for people building or extending pfSense images.
# The custom overlay tar gzipped file will be extracted over the root
# of the prepared image allowing for customization.
#
# Note: It is also possible to specify a directory instead of a
#       gzipped tarball.
#
# Tarball overlay (please uncomment): 
#export custom_overlay="/home/pfsense/custom_overlay.tgz"
#
# Directory overlay (please uncomment):
#export custom_overlay="/home/pfsense/custom_overlay"

# Package overlay. This gives people a chance to build a pfSense
# installable image that already contains certain pfSense packages.
#
# Needs to contain comma separated package names. Of course
# package names must be valid. Using non existent
# package name would yield an error.
#
#export custom_package_list="arping, Developers"

# This is used for developers with access to the pfSense
# cvsup update server.  Note that it is firewalled by default.
# If uncommented the system will use fastest-cvsup to find
# a suitable update source to spread the load.
#export OVERRIDE_FREEBSD_CVSUP_HOST="cvsup.livebsd.com"
