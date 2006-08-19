#!/bin/sh

# pfSense upgrade script
# (C)2006 Scott Ullrich
# All rights reserved.

# This script will aide in upgrading
# to a newer pfSense version

# set -e -x

# -- SETABLE VARIABLES
# Previous version
PREVIOUS_VERSION="RC2"
# New version
TARGET_VERSION="RC2f"
# Set to 1 to force a kernel update and reboot
KERNEL_UPDATE_NEEDED=1
# Set to 1 if the ruleset will change after update
RULESET_CHANGES=1
# Where will the updates be stored
PATH_TO_UPDATE="http://www.pfsense.com/~sullrich"
# Strict upgrades needed.  RC2a -> RC2b only, etc.
# Set to 1 to enable otherwise loose mode is implied.
STRICT_UPGRADE_NEEDED=0

# -- NO SETABLE VARIABLES BEYOND THIS POINT!
# Read in platform variable
PLATFORM=`cat /etc/platform`
# Read in version variable
VERSION=`cat /etc/version`

# Platform independent updates should be formatted as:
#    ${PATH_TO_UPDATE}/$TARGET_VERSION.tgz
# Kernel updates should be formatted as:
#    ${PATH_TO_UPDATE}/${TARGET_VERSION}_${PLATFORM}_kernel.tgz

restore_backups() {
	echo
	echo "*** Something bad happened.  Aborting!"
	echo
	echo "Restoring backup..."
	/etc/rc.conf_mount_rw
	tar xzvpf /tmp/backup.tgz -C /
	if [ $KERNEL_UPDATE_NEEDED -gt 0 ]; then
		echo "Restoring kernel backup..."
		tar xzvpf /tmp/backup_kernel.tgz -C /
	fi
	echo "Going read only..."
	/etc/rc.conf_mount_ro
	echo -n "Reloading filter..."
	/etc/rc.filter_configure
	pfctl -f /tmp/rules.debug
	echo "done."
	echo "Script exiting due to errors."
	exit
}

backup() {
	echo "Backing up the files before we upgrade..."
	(cd / && fetch -q -o - ${PATH_TO_UPDATE}/$TARGET_VERSION.tgz \
		| tar tvzpf - | awk '{ print $9 }' | tar czvfp /tmp/backup.tgz -T -)
	if [ $? -ne 0 ]; then
		echo "ERROR!  Could not create backup.  Exiting."
		exit
	fi
}

backup_kernel() {
	if [ $KERNEL_UPDATE_NEEDED -gt 0 ]; then
	    echo "Kernel update needed for ${PLATFORM} platform, backing up..."
	    (cd / && fetch -q -o - ${PATH_TO_UPDATE}/${TARGET_VERSION}_${PLATFORM}_kernel.tgz \
	        | tar tvzpf - | awk '{ print $9 }' | tar czvfp /tmp/backup_kernel.tgz -T -)
		if [ $? -ne 0 ]; then
			echo "ERROR!  Could not create backup.  Exiting."
			exit
		fi
	fi
}

update() {
	echo "Now pulling down the update file, please wait..."
	fetch -q -o - ${PATH_TO_UPDATE}/$TARGET_VERSION.tgz | tar xzvpf - -C /
	if [ $? -ne 0 ]; then
		restore_backups
	fi
}

update_kernel() {
	if [ $KERNEL_UPDATE_NEEDED -gt 0 ]; then
	    echo "Now pulling down the kernel update file, please wait..."
	    fetch -q -o - ${PATH_TO_UPDATE}/${TARGET_VERSION}_${PLATFORM}_kernel.tgz \
			| tar xzvpf - -C /
	fi
	if [ $? -ne 0 ]; then
		restore_backups
	fi
}

reload_filter() {
	echo -n "Reloading filter... "
	cp /tmp/rules.debug /tmp/rules.debug.before_update
	/etc/rc.filter_configure
	TARGET_CHECKSUM=`md5 /tmp/rules.debug`
	if [ $RULESET_CHANGES -gt 0 ]; then
			if [ "$PREVIOUS_CHECKSUM" != "$TARGET_CHECKSUM" ]; then
			    echo "*** rule difference detected. ***"
			    echo "*** Notice ***  Filter rules appear to be different now!"
			    echo "                This may be normal if pfSense fixed a filter rule bug."
			    echo "                If you experience problems, run this command to restore"
			    echo "                the previous version: tar xzvpf /tmp/backup.tgz -C /"
			else
			    echo "done"
			fi
		else
			echo "done"
	fi
}

test_filter_status() {
	echo -n "Ensuring that new filter set is sane..."
	pfctl -f /tmp/rules.debug
	if [ $? -ne 0 ]; then
		restore_backups
	else
	    echo "You are now updated to $TARGET_VERSION"
	    echo $TARGET_VERSION > /etc/version
	fi
	echo "done."
}

rw() {
	echo -n "Making sure we are rw... "
	/etc/rc.conf_mount_rw
	PREVIOUS_CHECKSUM=`md5 /tmp/rules.debug`
	echo "done"
}

ro() {
	echo -n "Making sure we are ro... "
	/etc/rc.conf_mount_ro
	echo "done"
}

check_upgrade_status() {
	if [ $STRICT_UPGRADE_NEEDED -lt 1 ]; then
		# If strict upgrades are not turned on
		# allow the user to upgrade in the same
		# series aka combined upgrade. These
		# upgrades are generally much larger.
		GREPPED=`echo $VERSION | grep $PREVIOUS_VERSION | wc -l`
		if [ $GREPPED -lt 1 ]; then
		    echo "This upgrades $PREVIOUS_VERSION series only."
		    exit
		else
		    echo "$PREVIOUS_VERSION detected.  Beginning update."
		fi
	else
		# Require strict upgrade.  These upgrades
		# require a strict previous version to ensure
		# that the correct files are put into place.
		# These upgrades can save space over a period
		# of time.
		if [ $VERSION != $PREVIOUS_VERSION ]; then
		    echo "This upgrades version $PREVIOUS_VERSION strict only."
		    exit
		else
		    echo "$PREVIOUS_VERSION detected.  Beginning update."
		fi
	fi
}

alert_reboot_needed() {
	if [ $KERNEL_UPDATE_NEEDED -gt 0 ]; then
	    echo
	    echo "NOTE!  This upgrade will reboot pfSense after completion!"
	    echo
	    echo -n "CTRL-C now if this is a problem.  Upgrade will start in 10 seconds."
	    sleep 5
	    echo -n "."
	    sleep 5
	    echo "."
	    echo
	    if [ -f /usr/bin/clear ]; then
	    	/usr/bin/clear
	    fi
	fi
	echo
	echo "Beginning upgrade and setting reboot needed flag."
	echo
}

show_version_status() {
	echo -n "Old version: "
	echo $VERSION
	echo -n "New version: "
	cat /etc/version
}

reboot_if_needed() {
	if [ $KERNEL_UPDATE_NEEDED -gt 0 ]; then
	    echo
	    echo -n "Rebooting in 4.."
	    sleep 1
	    echo -n "3.."
	    sleep 1
	    echo -n "2."
	    sleep 1
	    echo -n "1."
	    sync
	    echo "."
	    sync
	    shutdown -r now
	fi
}

welcome() {
	echo
	echo "-----------------------------------------------------------------------"
	echo "            Welcome to the pfSense generic upgrade script"
	echo "-----------------------------------------------------------------------"
	echo
	echo "In a moment we will begin the upgrade to ${TARGET_VERSION}..."
	echo
	echo "Please note that this upgrade will not verify a digital signature"
	echo "during the upgrade but will verify CRC signatures during compression"
	echo "extraction."
	echo
	echo -n "If you find this to be a problem, please press CTRL-C now"
	sleep 2
	echo -n "."
	sleep 2
	echo -n "."
	sleep 2
	echo -n "."
	sleep 2
	echo -n "."
	sleep 2
	echo "."
}

check_upgrade_status
welcome
alert_reboot_needed
rw
backup
backup_kernel
update
update_kernel
reload_filter
test_filter_status
ro
show_version_status
reboot_if_needed

