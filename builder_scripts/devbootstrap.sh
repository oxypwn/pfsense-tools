#!/bin/sh

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

echo "WITHOUT_X11=yo" > /etc/make.conf
echo "BATCH=yo" >> /etc/make.conf

echo ""
echo ""
echo ">>> Welcome to the pfSense builder environment"
echo ">>> Please wait while we configure the environment..."
echo
echo ">>> To watch the progress use option 8 (shell) and then type:"
echo "    tail -f /tmp/pfSense_Dev_Builder.txt "
echo
/bin/echo -n "Enter an option: "

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

# Back to the builder_scripts dir
cd /home/pfsense/tools/builder_scripts 

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
