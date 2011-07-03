#!/bin/sh

echo
sleep 3
echo
echo ">>> Starting the pfSense builder setup in 30 seconds..."
/bin/sleep 30
HOME=/
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin
export HOME PATH
echo ""
echo ""
echo ">>> Welcome to the pfSense builder environment"
echo ">>> Please wait while we configure the environment..."
echo ""
echo "WITHOUT_X11=yo" > /etc/make.conf
echo "BATCH=yo" >> /etc/make.conf
/bin/mkdir -p /home/pfsense/pfSenseGITREPO /usr/pfSensesrc
/usr/sbin/portsnap fetch extract 
cd /usr/ports/textproc/expat2 && make depends install
cd /usr/ports/devel/git && make depends install
cd /usr/ports/sysutils/fastest_cvsup/ && make depends install
cd /home/pfsense && git clone git://github.com/bsdperimeter/pfsense-tools.git tools
cd /home/pfsense && git clone https://github.com/sullrich/pfSense-freesbie2.git freesbie2
cd /home/pfsense/tools/builder_scripts && chmod a+rx *.sh
/usr/bin/csup -h `fastest_cvsup -c tld -q` /usr/share/examples/cvsup/standard-supfile
cd /home/pfsense/tools/builder_scripts 
cd /home/pfsense/tools/builder_scripts && ./set_version.sh RELENG_2_0
cd /home/pfsense/tools/builder_scripts && ./apply_kernel_patches.sh
cd /home/pfsense/tools/builder_scripts && ./build_pfPorts.sh
/bin/rm -rf /home/pfsense/installer
cd /home/pfsense/tools/builder_scripts && ./cvsup_bsdinstaller ; ./rebuild_bsdinstaller.sh
echo ">>> Environment is complete. Building ISO..."
cd /home/pfsense/tools/builder_scripts && ./build_iso.sh
if [ -f /tmp/builder/pfSense.iso ]; then
	echo ">>> ISO build completed."
	echo ">>> Moving devbootstrap.sh to /root/"
	/bin/mv /etc/rc.local /root/devbootstrap.sh
	ls -lah /tmp/builder/
fi

echo
echo ">>> Thanks for using the pfSense OVA build environment.  Goodbye."
echo
