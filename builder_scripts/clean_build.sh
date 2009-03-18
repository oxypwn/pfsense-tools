#!/bin/sh

# pfSense clean builder obj directory
# (C)2009 Scott Ullrich and the pfSense project
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

# Invoke cleaning function in builder_common
pfSense_clean_obj_dir
