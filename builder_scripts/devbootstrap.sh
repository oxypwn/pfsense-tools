#!/bin/sh
#
#  devbootstrap.sh
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

# Definable
PFS_VERSION=RELENG_2_0

# Needs changing of pfsense-build.conf if you change this.
SRCDIR=/usr/pfSensesrc

echo

sleep 3

echo ""
echo ""

echo ">>> Starting the pfSense builder setup in 15 seconds..."
/bin/sleep 15

DCPUS=`sysctl kern.smp.cpus | cut -d' ' -f2`
CPUS=`expr $DCPUS '*' 3
echo ">>> Detected CPUs * 3: $CPUS"

echo WITHOUT_X11="yo" > /etc/make.conf
echo BATCH="yo" >> /etc/make.conf
echo SUBTHREADS="${CPUS}" >> /etc/make.conf"

echo ""
echo ""
echo ">>> Welcome to the pfSense builder environment"
echo ">>> Please wait while we configure the environment..."
echo
echo ">>> To watch the progress use option 8 (shell) and then type:"
echo "    tail -f /tmp/pfSense_Dev_Builder.txt "
echo
/bin/echo -n "Enter an option: "

# " UNBREAK TEXTMATE FORMATTING.

# Check to see if the internet connection is working.
INTERNETUP=false
while [ "$INTERNETUP" = "false" ]; do
	STATUS=`ping -q -c1 google.com | grep transmitted | awk '{ print $4 }'`
	if [ "$STATUS" = "1" ]; then
		INTERNETUP=true
	else 
		echo "!!! Warning.  It appears the internet connection is not working."
		echo "              Will check again in 10 seconds."
		sleep 10
	fi
done
kldload ng_socket 2>/dev/null

exec > /tmp/pfSense_Dev_Builder.txt 2>&1

# Ensure folders are present
/bin/mkdir -p /home/pfsense/pfSenseGITREPO $SRCDIR

# Install fastest_cvsup if needed
if [ ! -f /usr/local/bin/fastest_cvsup ]; then
	echo ">>> Installing fastest_cvsup binary package..."
	( pkg_add -r fastest_cvsup ) >/dev/null
	rm -rf /var/db/pkg/*
fi

# CVSUp /usr/ports
/usr/bin/csup -h `/usr/local/bin/fastest_cvsup -c tld -q` /usr/share/examples/cvsup/ports-supfile

# Build a few required ports
cd /usr/ports/textproc/expat2 && make depends install
cd /usr/ports/devel/git && make depends install
cd /usr/ports/sysutils/screen && make depends install
cd /usr/ports/sysutils/fastest_cvsup/ && make depends install

# Checkout tools if needed
if [ ! -d tools ]; then
	cd /home/pfsense && git clone git://github.com/bsdperimeter/pfsense-tools.git tools
fi

# Checkout freesbie2 if needed
if [ ! -d freesbie2 ]; then
	cd /home/pfsense && git clone https://github.com/sullrich/pfSense-freesbie2.git freesbie2
fi

# Ensure scripts have +x
cd /home/pfsense/tools/builder_scripts && chmod a+rx *.sh

# CVSUp /usr/src/ in case some packages need kernel src
/usr/bin/csup -h `/usr/local/bin/fastest_cvsup -c tld -q` /usr/share/examples/cvsup/standard-supfile

# Set version as $PFS_VERSION
cd /home/pfsense/tools/builder_scripts && ./set_version.sh $PFS_VERSION

# Make some includes
echo ">>> Building includes..."
( cd $SRCDIR && make includes ) | egrep -wi '(^>>>|error)'

# Start up from where the above stops.
cd /home/pfsense/tools/pfPorts && ./buildports.RELENG_2_0

# Tidy up installer
/bin/rm -rf /home/pfsense/installer
cd /home/pfsense/tools/builder_scripts && ./cvsup_bsdinstaller ; ./rebuild_bsdinstaller.sh

# We should be done!
echo ">>> Environment is complete. Building ISO..."
cd /home/pfsense/tools/builder_scripts && ./build_iso.sh
if [ -f /tmp/builder/pfSense.iso ]; then
	echo ">>> ISO build completed."
	echo ">>> Moving devbootstrap.sh to /root/"
	/bin/mv /etc/rc.local /root/devbootstrap.sh
	chmod a+rx /root/devbootstrap.sh
	ls -lah /tmp/builder/
fi

# Stay thirsty my friends.
echo
echo ">>> Thanks for using the pfSense OVA build environment."
echo
