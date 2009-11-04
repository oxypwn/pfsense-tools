#!/bin/sh
#
# pfSense snapshot building system
# (C)2007, 2008, 2009 Scott Ullrich
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

# Crank up error reporting
# set -e
# set -x

LOGFILE="/tmp/snapshots-build_$$.log"
touch $LOGFILE

PWD=`pwd`

# Requires pfSenseGITREPO and GIT_REBASE variables
# set in pfsense-build-snapshots.conf
git_last_commit() {
	if [ -d "$pfSenseGITREPO" ]; then
		if [ "$GIT_REBASE" != "" ]; then 
			(cd $pfSenseGITREPO && git fetch && git rebase $GIT_REBASE)>/dev/null
			VERSION="`cd $pfSenseGITREPO && git log | head -n1 | cut -d' ' -f2`"
			cd $PWD
			CURRENT_COMMIT="$VERSION"
			return
		fi
	fi
	return
}

sleep_between_runs() {
	COUNTER=0
	while $COUNTER -lt $value; do
		sleep 60
		git_last_commit
		if [ "$LAST_COMMIT" != "$CURRENT_COMMIT" ]; then
			update_status ">>> New commit $CURRENT_COMMIT .. No longer sleepy."
			COUNTER="`expr $value + 60`"
		fi
		COUNTER="`expr $COUNTER + 60`"
	done
}
	
update_status() {
	if [ "$1" = "" ]; then
		return
	fi
	echo $1
	echo "`date` -|- $1" >> $LOGFILE
	if [ "$MASTER_BUILDER_SSH_LOG_DEST" ]; then
		scp -q $LOGFILE $MASTER_BUILDER_SSH_LOG_DEST
	fi
}

rotate_logfile() {
	if [ "$MASTER_BUILDER_SSH_LOG_DEST" ]; then
		scp -q $LOGFILE $MASTER_BUILDER_SSH_LOG_DEST.old
	fi
}

if [ -f "$PWD/pfsense-build-snapshots.conf" ]; then
	echo ">>> Execing pfsense-build-snapshots.conf"
	. $PWD/pfsense-build-snapshots.conf
fi

if [ ! -f "$PWD/pfsense-build.conf" ]; then
	echo "You must run this utility from the same location as pfsense-build.conf !!"
	exit 1
fi

rm -f /tmp/pfSense_do_not_build_pfPorts

# Handle command line arguments
while test "$1" != "" ; do
	case $1 in
		--noports|-n)
		echo "$2"
		NO_PORTS=yo
		shift
	;;
	esac
	shift
done

# Main builder loop
COUNTER=0
while [ /bin/true ]; do
	rm $LOGFILE
	touch $LOGFILE
	COUNTER=`expr $COUNTER + 1`
	update_status ">>> Starting builder run #${COUNTER}..."
	# We can disable ports builds
	if [ "$NO_PORTS" = "yo" ]; then
		update_status ">>> Not building pfPorts at all during this snapshot builder looped run..."
		touch /tmp/pfSense_do_not_build_pfPorts
	else
		if [ "$COUNTER" -gt 1 ]; then 
			update_status ">>> Previous snapshot runs deteceted, not building pfPorts again..."
			touch /tmp/pfSense_do_not_build_pfPorts
		else
			update_status ">>> Building pfPorts on this snapshot run..."
			rm -f /tmp/pfSense_do_not_build_pfPorts
		fi
	fi
	NANO_SIZE=`cat $PWD/pfsense-build.conf | grep FLASH_SIZE | cut -d'"' -f2`
	# Loop through each builder run and alternate between image sizes.
	# 512mb becomes 1g, 1g becomes 2g, 2g becomes 4g, 4g becomes 512m.
	if [ "$NANO_SIZE" = "" ]; then
		NANO_SIZE="512mb"
	fi
	NEW_NANO_SIZE="512mb"
	case $NANO_SIZE in
		"512mb")
			NEW_NANO_SIZE="1g"
		;;
		"1g")
			NEW_NANO_SIZE="2g"
		;;
		"2g")
			NEW_NANO_SIZE="4g"
		;;
		"4g")
			NEW_NANO_SIZE="512mb"
		;;
	esac
	echo $NEW_NANO_SIZE > /tmp/nanosize.txt
	cat $PWD/pfsense-build.conf | grep -v FLASH_SIZE > /tmp/pfsense-build.conf
	echo "export FLASH_SIZE=\"${NEW_NANO_SIZE}\"" >>/tmp/pfsense-build.conf
	mv /tmp/pfsense-build.conf $PWD/pfsense-build.conf
	update_status ">>> [nanoo] Previous NanoBSD size: $NANO_SIZE"
	update_status ">>> [nanoo] New size has been set to: $NEW_NANO_SIZE"
	git_last_commit
	update_status ">>> Last known commit $CURRENT_COMMIT"
	sh ./build_snapshots.sh | while read LINE 
	do
		update_status "$LINE"
	done
	# Grab a random value and sleep
	value=`od -A n -d -N2 /dev/random | awk '{ print $1 }'`
	# Sleep for that time.
	update_status ">>> Sleeping for $value in between snapshot builder runs.  Last known commit $LAST_COMMIT"
	# Rotate log file
	rotate_logfile
	# Count some sheep or wait until a new commit turns up.
	sleep_between_runs $value
	# If REBOOT_AFTER_SNAPSHOT_RUN is defined reboot
	# the box after the run. 
	if [ ! -z "${REBOOT_AFTER_SNAPSHOT_RUN:-}" ]; then
		update_status ">>> Shutting down build `hostname` due to \$REBOOT_AFTER_SNAPSHOT_RUN"
		shutdown -r now
		kill $$
	fi
done

rm $LOGFILE
