#!/bin/sh
#
# pfSense snapshot building system
# (C)2007, 2008 Scott Ullrich
# All rights reserved
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#

rm -f /tmp/pfSense_do_not_build_pfPorts

while [ /bin/true ]; do
	./build_snapshots.sh
	# Grab a random value and sleep
	value=`od -A n -d -N2 /dev/random | awk '{ print $1 }'`
	# Sleep for that time.
	echo
	echo ">>> Sleeping for $value in between snapshot builder runs"
	echo
	sleep $value
done