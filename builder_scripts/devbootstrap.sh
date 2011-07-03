#!/bin/sh

sleep 15
echo ""
echo ""
echo ">>> Welcome to the pfSense builder environment"
echo ">>> Please wait while we configure the environment..."
echo ""
echo "WITHOUT_X11=yo" > /etc/make.conf
echo "BATCH=yo" >> /etc/make.conf
mkdir -p /home/pfsense/pfSenseGITREPO /usr/pfSensesrc
portsnap fetch extract 
cd /usr/ports/textproc/expat2 && make depends install
cd /usr/ports/devel/git && make depends install
cd /usr/ports/sysutils/fastest_cvsup/ && make depends install
rehash   
cd /home/pfsense && git clone git://github.com/bsdperimeter/pfsense-tools.git tools
cd /home/pfsense && git clone https://github.com/sullrich/pfSense-freesbie2.git freesbie2
cd /home/pfsense/tools/builder_scripts && chmod a+rx *.sh
csup -h `fastest_cvsup -c tld -q` /usr/share/examples/cvsup/standard-supfile
cd /home/pfsense/tools/builder_scripts 
./set_version.sh RELENG_2_0
./apply_kernel_patches.sh
./build_pfPorts.sh
rm -rf /home/pfsense/installer
./cvsup_bsdinstaller ; ./rebuild_bsdinstaller.sh
echo ">>> Environment is complete. Building ISO..."
./build_iso.sh
if [ -f /tmp/pfSense.iso ]; then
	echo ">>> ISO build completed."
	echo ">>> Moving devbootstrap.sh to /root/"
	mv /etc/rc.local /root/devbootstrap.sh
fi
echo ">>> Thanks for using the pfSense OVA build environment.  Goodbye."
