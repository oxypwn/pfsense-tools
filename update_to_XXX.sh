#!/bin/sh

# -- SETABLE VARIABLES
# Previous version
PREVIOUS_VERSION="RC2"
# New version
TARGET_VERSION="RC2f"
# Set to 1 to force a kernel update and reboot
KERNEL_UPDATE_NEEDED=0
# Set to 1 if the ruleset will change after update
RULESET_CHANGES=0
# Where will the updates be stored
PATH_TO_UPDATE="http://www.pfsense.com/~sullrich"

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
	echo "Something bad happened.  Aborting."
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

if [ $VERSION != $PREVIOUS_VERSION ]; then
    echo "This upgrades version $PREVIOUS_VERSION only."
    exit
else
    echo "$PREVIOUS_VERSION detected.  Beginning update."
fi

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
fi

echo "One moment, we are going to upgrade to ${TARGET_VERSION}..."
echo -n "Making sure we are rw... "
/etc/rc.conf_mount_rw
PREVIOUS_CHECKSUM=`md5 /tmp/rules.debug`
echo "done"

echo "Backing up the files before we upgrade..."
(cd / && fetch -q -o - ${PATH_TO_UPDATE}/$TARGET_VERSION.tgz \
	| tar tvzpf - | awk '{ print $9 }' | tar czvfp /tmp/backup.tgz -T -)
if [ $? -ne 0 ]; then
	echo "ERROR!  Could not create backup.  Exiting."
	exit
fi
if [ $KERNEL_UPDATE_NEEDED -gt 0 ]; then
    echo "Kernel update needed for ${PLATFORM} platform, backing up..."
    (cd / && fetch -q -o - ${PATH_TO_UPDATE}/${TARGET_VERSION}_${PLATFORM}_kernel.tgz \
        | tar tvzpf - | awk '{ print $9 }' | tar czvfp /tmp/backup_kernel.tgz -T -)
	if [ $? -ne 0 ]; then
		echo "ERROR!  Could not create backup.  Exiting."
		exit
	fi
fi

echo "Now pulling down the update file, please wait..."
fetch -q -o - ${PATH_TO_UPDATE}/$TARGET_VERSION.tgz | tar xzvpf - -C /
if [ $? -ne 0 ]; then
	restore_backups
fi
if [ $KERNEL_UPDATE_NEEDED -gt 0 ]; then
    echo "Now pulling down the kernel update file, please wait..."
    fetch -q -o - ${PATH_TO_UPDATE}/${TARGET_VERSION}_${PLATFORM}_kernel.tgz \
		| tar xzvpf - -C /
fi
if [ $? -ne 0 ]; then
	restore_backups
fi

echo -n "Reloading filter... "
cp /tmp/rules.debug /tmp/rules.debug.before_update
/etc/rc.filter_configure
TARGET_CHECKSUM=`md5 /tmp/rules.debug`
if [ $RULESET_CHANGES -gt 0 ]; then
		if [ "$PREVIOUS_CHECKSUM" != "$TARGET_CHECKSUM" ]; then
		    echo " *** rule difference detected. ***"
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

pfctl -f /tmp/rules.debug
if [ $? -ne 0 ]; then
	restore_backups
else
    echo "You are now updated to $TARGET_VERSION"
    echo $TARGET_VERSION > /etc/version
fi

echo -n "Making sure we are ro... "
/etc/rc.conf_mount_ro
echo "done"
echo -n "Old version: "
echo $VERSION
echo -n "New version: "
cat /etc/version

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

