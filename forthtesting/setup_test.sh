#!/bin/sh

WD=`/bin/pwd`

echo Making testmain
cd /sys/boot/ficl
/usr/bin/make clean && /usr/bin/make testmain
cd $WD
echo Copying testmain to $WD
if [ -f ]; then
	/bin/cp -p /sys/boot/ficl/testmain $WD
elif [ -f /usr/obj/usr/src/sys/boot/ficl/testmain ]; then
	/bin/cp -p /usr/obj/usr/src/sys/boot/ficl/testmain $WD
else
	echo Cannot find testmain binary.
fi

if [ -f /usr/local/pfsense-fs/boot/beastie.4th ]; then
	echo Copying 4th files from /usr/local/pfsense-fs/boot/
	/bin/cp /usr/local/pfsense-fs/boot/beastie.4th $WD
	/bin/cp /usr/local/pfsense-fs/boot/screen.4th $WD
	/bin/cp /usr/local/pfsense-fs/boot/frames.4th $WD
else
	echo Copying 4th files from /usr/src/sys/boot/forth/
	/bin/cp /usr/src/sys/boot/forth/beastie.4th $WD
	/bin/cp /usr/src/sys/boot/forth/screen.4th $WD
	/bin/cp /usr/src/sys/boot/forth/frames.4th $WD
fi

echo Deactivating includes in beastie.4th

/usr/bin/sed -i.bak 's/^include/\/ include/' beastie.4th

echo Hack at beastie.4th and then run:
echo    ./testmain init.4th
