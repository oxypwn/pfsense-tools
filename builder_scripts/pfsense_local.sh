#!/bin/sh

# $Id$

#export DNO_ATM=yes

# This is the base working directory for all builder
# operations
export BASE_DIR=${BASE_DIR:-/home/pfsense}

# This is the directory where the latest pfSense cvs co
# is checked out to.
export CVS_CO_DIR=${CVS_CO_DIR:-${BASE_DIR}/pfSense}

export CUSTOMROOT=${CUSTOMROOT:-${CVS_CO_DIR}}

# This is the user that has access to the pfSense repo
export CVS_USER=${CVS_USER:-sullrich}

# pfSense repo IP address. Typically cvs.pfsense.org,
# but somebody could use a ssh tunnel and specify
# a different one
export CVS_IP=${CVS_IP:-cvs.pfsense.org}

export UPDATESDIR=${UPDATESDIR:-$BASE_DIR/updates}

export PFSENSEBASEDIR=${PFSENSEBASEDIR:-/usr/local/pfsense-fs}

export PFSENSEISODIR=${PFSENSEISODIR:-/usr/local/pfsense-clone}

# pfSense cvs tag to build
export PFSENSETAG=${PFSENSETAG:-RELENG_1_2}
#export PFSENSETAG=${PFSENSETAG:-RELENG_1}

# FreeSBIE 2 toolkit path
export FREESBIE_PATH=${FREESBIE_PATH:-/home/pfsense/freesbie2}

# export variables used by freesbie2
export FREESBIE_CONF=${FREESBIE_CONF:-/dev/null} # No configuration file should be override our variables
export SRCDIR=${SRCDIR:-/usr/src}
export BASEDIR=${PFSENSEBASEDIR:-/usr/local/pfsense-fs}
export CLONEDIR=${PFSENSEISODIR:-/usr/local/pfsense-clone}
export MAKEOBJDIRPREFIX=${MAKEOBJDIRPREFIX:-/usr/obj.pfSense}
export ISOPATH=${ISOPATH:-${MAKEOBJDIRPREFIX}/pfSense.iso}
export IMGPATH=${IMGPATH:-${MAKEOBJDIRPREFIX}/pfSense.img}
export PKGFILE=${PKGFILE:-$PWD/conf/packages}
export FREESBIE_LABEL=pfSense
# IMPORTANT NOTE: Maintain the order of EXTRA freesbie plugins!
export EXTRA="${EXTRA:-"customroot customscripts buildmodules"}"
export BUILDMODULES="netgraph acpi ndis if_ndis padlock ipfw dummynet fdescfs cpufreq"

MAKEJ=" "

# FreeBSD version.  6 or 7
export pfSense_version="6"
export freebsd_branch="RELENG_6_3"

# Custom overlay for people building or extending pfSense images.
# The custom overlay tar gzipped file will be extracted over the root
# of the prepared image allowing for customization.
#
# Note: It is also possible to specify a directory instead of a
#       gezipped tarball.
#
# Tarball overlay (please uncomment): 
#export custom_overlay="/home/pfsense/custom_overlay.tgz"
#
# Directory overlay (please uncomment):
#export custom_overlay="/home/pfsense/custom_overlay"

# Package overlay. This gives people a change to build a pfSense
# installable image that already contains certain pfSense packages.
#
# Needs to point to a text file containing comma sepperated package
# names. Of course package names must be valid. Using non existent
# package name would yield an error.
#
#export custom_package_list="arping, Developers"

#export OVERRIDE_FREEBSD_CVSUP_HOST="cvsup.livebsd.com"

export INSTALL_PORTS="pfPorts/isc-dhcp3-server pfPorts/php4-pfsense pfPorts/libevent pfPorts/beep pfPorts/lighttpd pfPorts/check_reload_status pfPorts/minicron pfPorts/libart_lgpl pfPorts/rrdtool pfPorts/choparp pfPorts/miniupnpd pfPorts/mpd pfPorts/slbd pfPorts/olsrd pfPorts/dnsmasq pfPorts/openntpd pfPorts/sshlockout_pf pfPorts/expiretable pfPorts/lzo2 pfPorts/openvpn pfPorts/pecl-APC pfPorts/ipsec-tools pfPorts/pftop pfPorts/vtsh pfPorts/isc-dhcp3-relay pfPorts/pftpx pfPorts/clog pfPorts/fping pfPorts/links pfPorts/grub pfPorts/curl pfPorts/gettext"
                   
export INSTALL_PORTS_HEAD="pfPorts/isc-dhcp3-server pfPorts/php5-pfsense pfPorts/xcache pfPorts/libevent13 pfPorts/beep pfPorts/lighttpd pfPorts/check_reload_status pfPorts/minicron pfPorts/libart_lgpl pfPorts/rrdtool pfPorts/choparp pfPorts/miniupnpd pfPorts/mpd pfPorts/slbd pfPorts/olsrd pfPorts/dnsmasq pfPorts/openntpd pfPorts/sshlockout_pf pfPorts/expiretable pfPorts/lzo2 pfPorts/openvpn pfPorts/pecl-APC pfPorts/pftop pfPorts/vtsh pfPorts/isc-dhcp3-relay pfPorts/pftpx pfPorts/clog pfPorts/fping pfPorts/grub pfPorts/curl pfPorts/gettext pfPorts/rrdtool"

export STATIC_INSTALL_PORTS="pfPorts/ipsec-tools"

export SRC_CONF_INSTALL=${SRC_CONF_INSTALL:-"/dev/null"}
