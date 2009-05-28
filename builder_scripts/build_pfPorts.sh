#!/bin/sh

# pfSense master builder script
# (C)2005-2006 Scott Ullrich and the pfSense project
# All rights reserved.
#
# $Id$

# Crank up error reporting, debugging.
#set -e 
#set -x

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

if [ ! -d /usr/ports/ ]; then
	echo "===> Please wait, grabbing port files from FreeBSD.org..."
	portsnap fetch
	echo "===> Please wait, extracting port files..."
	portsnap extract
fi

recompile_pfPorts


