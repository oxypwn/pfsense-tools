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
#
# This script is the master wrapper for the snapshot builder system.
# It will loop through and build every 24 hours minimum and if the needed
# variables are defined pfSenseGITREPO and GIT_REBASE in 
# pfsense-build-snapshots.conf then the builder will check every 60 seconds
# if a new commit is deteceted and kick off a new build immediately.
#
# Crank up error reporting, debugging.

NO_UPLOAD=""

# Handle command line arguments
while test "$1" != "" ; do
	case $1 in
	--no-ports|--noports|-n)
		NO_PORTS=yo
		;;
	--noupload|-u)
		NO_UPLOAD="-u"
		;;
	esac
	shift
done

#  set -e
#  set -x

LOGFILE="/tmp/snapshots-build_$$.log"
LASTUPDATE="/tmp/snapshots-lastupdate_$$.log"
touch $LOGFILE
touch $LASTUPDATE

PWD=`pwd`

# Source pfsense-build-snapshots.conf
if [ -f "$PWD/pfsense-build-snapshots.conf" ]; then
	echo ">>> Execing pfsense-build-snapshots.conf"
	. $PWD/pfsense-build-snapshots.conf
fi

# Source pfsense-build.conf
if [ ! -f "$PWD/pfsense-build.conf" ]; then
	echo "You must run this utility from the same location as pfsense-build.conf !!"
	exit 1
fi

# Requires pfSenseGITREPO and GIT_RESET variables
# set in pfsense-build-snapshots.conf
git_last_commit() {
	if [ -d "$pfSenseGITREPO" ]; then
		if [ "$GIT_RESET" != "" ]; then 
			(cd $pfSenseGITREPO && git clean -f -f -x -d)
			(cd $pfSenseGITREPO && git fetch && git reset $GIT_RESET)>/dev/null
			CURRENT_COMMIT="`cd $pfSenseGITREPO && git log | head -n1 | cut -d' ' -f2`"
			CURRENT_AUTHOR="`cd $pfSenseGITREPO && git log | head -n2 | grep "Author" | cut -d':' -f2 | cut -d'<' -f1`"
			cd $PWD
		else 
			echo ">>> WARNING: GIT_RESET variable not set! Previous commit functions disabled."
		fi
	else
		echo ">>> WARNING: pfSenseGITREPO variable not set! Previous commit functions disabled."
	fi
}

# This routine is called in between runs. We
# will sleep for a bit and check for new commits
# in between sleeping for short durations.
sleep_between_runs() {
	COUNTER=0
	while [ "$COUNTER" -lt "$maxsleepvalue" ]; do
		sleep 60
		git_last_commit
		if [ "$LAST_COMMIT" != "$CURRENT_COMMIT" ]; then
			update_status ">>> New commit: $CURRENT_AUTHOR - $CURRENT_COMMIT .. No longer sleepy."
			COUNTER="`expr $maxsleepvalue + 60`"
		fi
		COUNTER="`expr $COUNTER + 60`"
	done
	if [ "$COUNTER" -eq "$maxsleepvalue" ]; then
		update_status ">>> Sleep timer expired. Restarting build."
		maxsleepvalue=0
		COUNTER=0
	fi
}

# This routine is called to write out to stdout
# a string.   The string is appeneded to $LOGFILE
# and we scp the log file to the builder host if
# needed for the real time logging functions.
update_status() {
	if [ "$1" = "" ]; then
		return
	fi
	echo $1
	echo "`date` -|- $1" >> $LOGFILE
	if [ -n "$MASTER_BUILDER_SSH_LOG_DEST" -a -z "${NO_UPLOAD}" ]; then
		LU=`cat $LASTUPDATE`
		CT=`date "+%H%M%S"`
		# Only update every minute
		if [ "$LU" != "$CT" ]; then 
			scp -q $LOGFILE $MASTER_BUILDER_SSH_LOG_DEST
			date "+%H%M%S" > $LASTUPDATE
		fi
	fi
}

# Copy the current log file to $filename.old on
# the snapshot www server (real time logs)
rotate_logfile() {
	if [ -d ${BUILDER_LOGS}/pfPort ]; then
		for FILE in ${BUILDER_LOGS}/pfPort; do
			echo "$FILE ------------------------------------------------" >> $LOGFILE
			cat $FILE >> $LOGFILE
		done
		rm -rf ${BUILDER_LOGS}/pfPort/*
	fi
	if [ -n "$MASTER_BUILDER_SSH_LOG_DEST" -a -z "${NO_UPLOAD}" ]; then
		scp -q $LOGFILE $MASTER_BUILDER_SSH_LOG_DEST.old
	fi
	# Cleanup log file
	rm $LOGFILE
	touch $LOGFILE
}

# Unset do not build ports flag
rm -f /tmp/pfSense_do_not_build_pfPorts

# Keeps track of how many time builder has looped
BUILDCOUNTER=0

touch $LOGFILE
rm $LOGFILE
touch $LOGFILE

# Main builder loop
while [ /bin/true ]; do
	BUILDCOUNTER=`expr $BUILDCOUNTER + 1`
	update_status ">>> Starting builder run #${BUILDCOUNTER}..."
	# We can disable ports builds
	if [ "$NO_PORTS" = "yo" ]; then
		update_status ">>> Not building pfPorts at all during this snapshot builder looped run..."
		touch /tmp/pfSense_do_not_build_pfPorts
	else
		if [ "$BUILDCOUNTER" -gt 1 ]; then 
			update_status ">>> Previous snapshot runs deteceted, not building pfPorts again..."
			touch /tmp/pfSense_do_not_build_pfPorts
		else
			update_status ">>> Building pfPorts on this snapshot run..."
			rm -f /tmp/pfSense_do_not_build_pfPorts
		fi
	fi
#	NANO_SIZE=`cat $PWD/pfsense-build.conf | grep FLASH_SIZE | cut -d'"' -f2`
#	# Loop through each builder run and alternate between image sizes.
#	# 512mb becomes 1g, 1g becomes 2g, 2g becomes 4g, 4g becomes 512m
#	# until the quick mode can be debugged and understand why an extra
#	# F3 partition shows when it should not.
#	if [ "$NANO_SIZE" = "" ]; then
#		NANO_SIZE="512mb"
#	fi
#	NEW_NANO_SIZE="512mb"
#	case $NANO_SIZE in
#		"512mb")
#			NEW_NANO_SIZE="1g"
#		;;
#		"1g")
#			NEW_NANO_SIZE="2g"
#		;;
#		"2g")
#			NEW_NANO_SIZE="4g"
#		;;
#		"4g")
#			NEW_NANO_SIZE="512mb"
#		;;
#	esac
#	# Tell the builder what size the image is
#	echo $NEW_NANO_SIZE > /tmp/nanosize.txt
#	# Record the combined total flash size
#	cat $PWD/pfsense-build.conf | grep -v FLASH_SIZE > /tmp/pfsense-build.conf
#	echo "export FLASH_SIZE=\"${NEW_NANO_SIZE}\"" >>/tmp/pfsense-build.conf
#	mv /tmp/pfsense-build.conf $PWD/pfsense-build.conf
#	# Note new sizes
#	update_status ">>> [nanoo] Previous NanoBSD size: $NANO_SIZE"
#	update_status ">>> [nanoo] New size has been set to: $NEW_NANO_SIZE"
	# Fetch last commit information
	git_last_commit
	# Record this commits info for later comparison
	# to the latest scanned commit during sleep phase.
	LAST_COMMIT="$CURRENT_COMMIT"
	LAST_AUTHOR="$CURRENT_AUTHOR"
	update_status ">>> Last known commit $LAST_AUTHOR - $LAST_COMMIT"
	# Record the commit information for the snapshots scripts
	# to pick up and include in the image as /etc/version.lastcommit
	echo "$LAST_COMMIT" > /tmp/build_commit_info.txt
	# Launch the snapshots builder script and pipe its
	# contents to the while loop so we can record the 
	# script progress in real time to the public facing
	# snapshot server (snapshots.pfsense.org).
	sh ./build_snapshots.sh ${NO_UPLOAD} | while read LINE
	do
		update_status "$LINE"
	done
	minsleepvalue=28800
	maxsleepvalue=86400
	update_status ">>> Sleeping for at least $minsleepvalue, at most $maxsleepvalue in between snapshot builder runs.  Last known commit $LAST_COMMIT"
	update_status ">>> Freezing build process at `date`."
	sleep $minsleepvalue
	update_status ">>> Thawing build process and resuming checks for pending commits at `date`."
	# Count some sheep or wait until a new commit turns up 
	# for one days time.  We will wake up if a new commit
	# is deteceted during sleepy time.
	sleep_between_runs $maxsleepvalue
	# If REBOOT_AFTER_SNAPSHOT_RUN is defined reboot
	# the box after the run. 
	if [ ! -z "${REBOOT_AFTER_SNAPSHOT_RUN:-}" ]; then
		update_status ">>> Rebooting `hostname` due to \$REBOOT_AFTER_SNAPSHOT_RUN"
		shutdown -r now
		kill $$
	fi
	# Rotate log file (.old)
	rotate_logfile
done

rm $LOGFILE
