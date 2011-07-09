#!/bin/sh
#
#  chroot_creator.sh
#  Scott Ullrich <sullrich@gmail.com>
#  (C) 2011 BSD Perimeter  
#  All Rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  
#  1. Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#  
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  
#  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
#  AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#  AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
#  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
#

BUILDER_CHROOTDIR=$1

ntpdate time.nist.gov 2>/dev/null

if [ "$BUILDER_CHROOTDIR" = "" ]; then
	echo "!!! You must specify a directory to hold the new chroot"
	exit 1
fi

if [ -d $BUILDER_CHROOTDIR ]; then
	echo "!!! Directory already exists!"
	exit 1
fi

if [ ! -f /etc/resolv.conf ]; then
	echo "!!! Could not locate /etc/resolv.conf"
	exit 1
fi

sleep_one() {
	/bin/echo -n "."
	sleep 1
}

# Install /usr/src/ if needed
if [ ! -f /usr/local/bin/fastest_cvsup ]; then
	echo  "!!! fastest_cvsup not found. pkg_add -r in 10 seconds!"
	/bin/echo -n "!!! CTRL-C to cancel..."
	sleep_one ; sleep_one ; sleep_one ; sleep_one ; sleep_one
	sleep_one ; sleep_one ; sleep_one ; sleep_one ; sleep_one
	echo
	pkg_add -r fastest_cvsup >/dev/null
fi

if [ "$2" = "" ]; then
	FASTEST_CVSUP=`/usr/local/bin/fastest_cvsup -c tld -q`
else 
	FASTEST_CVSUP="$2"
fi

# Update /usr/src
echo ">>> Fetching /usr/src/ from $FASTEST_CVSUP ..."
/usr/bin/csup -h $FASTEST_CVSUP \
	/usr/share/examples/cvsup/standard-supfile >/dev/null

# Handle ports if needed
if [ ! -d /usr/ports ]; then
	echo ">>> Fetching ports using portsnap..."
	portsnap fetch extract
else 
	echo ">>> Updating /usr/ports/ from $FASTEST_CVSUP ..."
	/usr/bin/csup -h $FASTEST_CVSUP \
		/usr/share/examples/cvsup/ports-supfile >/dev/null
fi

# Install git on host
if [ ! -f /usr/local/bin/git ]; then
	echo BATCH="YES" >> /etc/make.conf
	echo SUBTHREADS="`sysctl kern.smp.cpus | cut -d' ' -f2`" >> /etc/make.conf
	cd /usr/ports/devel/git && make install clean
fi

# Handle rsync
if [ ! -f /usr/local/bin/rsync ]; then
	echo ">>> Installing rsync..."
	cd /usr/ports/net/rsync && make install clean
fi

# Handle screen
if [ ! -f /usr/local/bin/screen ]; then
	echo ">>> Installing screen..."
	cd /usr/ports/sysutils/screen && make install clean	
fi

# Sync pfSense dev tools
if [ ! -d /home/pfsense ]; then
	mkdir -p /home/pfsense/pfSenseGITREPO /usr/pfSensesrc
	echo ">>> Grabbing pfSense tools..."
	cd /home/pfsense && git clone \
		git://github.com/bsdperimeter/pfsense-tools.git tools
	cd /home/pfsense && git clone \
		git://github.com/sullrich/pfSense-freesbie2.git freesbie2
	chmod a+rx /home/pfsense/tools/builder_scripts/*.sh
else
	echo ">>> Making sure git repos are in sync..."
	cd /home/pfsense/tools/builder_scripts && \
		./update_git_repos.sh >/dev/null
fi

# Create the chroot and get it ready
mkdir -p $BUILDER_CHROOTDIR

# Build chroot and install
echo ">>> Building world..."
cd /usr/src
make world -j`sysctl kern.smp.cpus | cut -d' ' -f2` \
	DESTDIR=$BUILDER_CHROOTDIR NO_CLEAN=yes >/dev/null
echo ">>> Building distribution..."
make distribution -j`sysctl kern.smp.cpus | cut -d' ' -f2` \
	DESTDIR=$BUILDER_CHROOTDIR NO_CLEAN=yes >/dev/null
mount -t devfs devfs $BUILDER_CHROOTDIR/dev
echo "mount -t devfs devfs $BUILDER_CHROOTDIR/dev" \
	>> /etc/rc.local

# Copy resolv.conf to chroot
cp /etc/resolv.conf $BUILDER_CHROOTDIR/etc/

# Copy make.conf to chroot
cp /etc/make.conf $BUILDER_CHROOTDIR/etc/

# Populate ports
echo ">>> Copying ports..."
rsync -av /usr/ports $BUILDER_CHROOTDIR/usr/ >/dev/null

# Do a devbootstrap
cp /home/pfsense/tools/builder_scripts/devbootstrap.sh \
	$BUILDER_CHROOTDIR/etc/
chmod a+rx $BUILDER_CHROOTDIR/etc/devbootstrap.sh
echo ">>> Launching dev bootstrap in 10 seconds"
/bin/echo -n "!!! CTRL-C to cancel..."
sleep_one ; sleep_one ; sleep_one ; sleep_one ; sleep_one
sleep_one ; sleep_one ; sleep_one ; sleep_one ; sleep_one
echo
echo ">>> Creating dev chroot... Please wait..."
chroot $BUILDER_CHROOTDIR /etc/devbootstrap.sh &
sleep 20
tail -f $BUILDER_CHROOTDIR/tmp/pfSense_Dev_Builder.txt
echo ">>> chroot_creator.sh has finished."
