#!/bin/sh

echo 
echo "This script will reset all of /usr/local and repopulate *EVERYTHING*!"
echo "This is meant to be used when the builder environment is considered broken."
echo
echo "Press CTRL-C if you do not want all of /usr/loca/ whiped out!"
echo
sleep 5

echo "Beginning..."

chflags -R noschg /usr/local/
rm -rf /usr/local/*
rm -rf /var/db/pkg/*
rm -rf /usr/ports

mkdir /usr/local/bin
mkdir /usr/local/etc
mkdir /usr/local/include
mkdir /usr/local/info
mkdir /usr/local/lib
mkdir /usr/local/libdata
mkdir /usr/local/libexec
mkdir /usr/local/man
mkdir /usr/local/sbin
mkdir /usr/local/share
mkdir /usr/local/squid
mkdir /usr/local/www

cd /home/pfsense/tools/builder_scripts/

portsnap fetch
portsnap extract

./cvsup_current 

(cd /usr/ports/sysutils/screen && make install)

./build_snapshots.sh 

