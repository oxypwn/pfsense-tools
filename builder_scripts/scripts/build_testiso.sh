#!/bin/sh

# $Id$

#set -e -u

# Set extra before pfsense_local.sh will do
# Add comconsole to the list
export EXTRAPLUGINS="comconsole buildmodules customroot"

sh -x ./build_iso.sh
