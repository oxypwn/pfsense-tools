#!/bin/sh
echo ">>> Fixing up git repo URLs for a stock build."
if [ -d /home/pfsense/pfSenseGITREPO/pfSenseGITREPO/.git ]; then
	echo ">>>   Setting pfSense repo to git://github.com/pfsense/pfsense.git"
	cd /home/pfsense/pfSenseGITREPO/pfSenseGITREPO/
	git remote set-url origin git://github.com/pfsense/pfsense.git
fi

if [ -d /home/pfsense/pfSenseGITREPO/.git ]; then
	echo ">>>   Setting pfSense repo to git://github.com/pfsense/pfsense.git"
	cd /home/pfsense/pfSenseGITREPO/
	git remote set-url origin git://github.com/pfsense/pfsense.git
fi

if [ -d /home/pfsense/tools/.git ]; then
	echo ">>>   Setting Tools repo to git://github.com/pfsense/pfsense-tools.git"
	cd /home/pfsense/tools/
	git remote set-url origin git://github.com/pfsense/pfsense-tools.git
fi

if [ -d /home/pfsense/packages/.git ]; then
	echo ">>>   Setting Packages repo to git://github.com/pfsense/pfsense-packages.git"
	cd /home/pfsense/packages/ 
	git remote set-url origin git://github.com/pfsense/pfsense-packages.git
fi

if [ -d /home/pfsense/freesbie2/.git ]; then
	echo ">>>   Setting freesbie repo to git://github.com/pfsense/freesbie2.git"
	cd /home/pfsense/freesbie2/
	git remote set-url origin git://github.com/pfsense/freesbie2.git
fi

if [ -d /home/pfsense/installer/.git ]; then
	echo ">>>   Setting installer repo to git://github.com/pfsense/bsdinstaller.git"
	cd /home/pfsense/installer/
	git remote set-url origin git://github.com/pfsense/bsdinstaller.git
fi

