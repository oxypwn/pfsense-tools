#!/bin/sh

for DIRECTORY in *; do
	if [ -e $DIRECTORY/Makefile ]; then
		if [ -f /tmp/pfSensePortCompare ]; then
		        rm /tmp/pfSensePortCompare
		fi
		touch /tmp/pfSensePortCompare
		echo -n "$DIRECTORY $VERSION Finding PORT directory ... "
		PORTDIR=`find /usr/ports -name $DIRECTORY`
		if [ -e "$PORTDIR/Makefile" ]; then
			VERSION=`cat $DIRECTORY/Makefile | grep PORTVERSION | awk '{ print $2 }' | grep -v ":" | grep -v "{"`
			echo -n "$PORTDIR"
			PORTVERSION=`cat $PORTDIR/Makefile | grep "PORTVERSION\=" | awk '{ print $2 }' | grep -v ":" | grep -v "{"`
			if [ "$VERSION" != "$PORTVERSION" ]; then
				echo "$DIRECTORY   $VERSION     $PORTVVERSION" >> /tmp/pfSensePortCompare
			fi
				echo "    $VERSION - $PORTVERSION"
		else 
		echo "Not in /usr/ports/"
		fi
	fi
done

echo
echo
echo "Versions of pfPorts that do not match /usr/ports are:"
echo
cat /tmp/pfSensePortCompare
echo

