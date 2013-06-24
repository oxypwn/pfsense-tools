#!/bin/sh

IFNAME="bridge0"
EMUNAME="$1"

if ! kldstat -v | grep -q if_tap; 
then
        if kldload if_tap; then
                echo "if_tap module loaded"
        else
                echo "if_tap module failed to load"
        fi
fi

ifconfig -l | grep $IFNAME > /dev/null

if [ $? = 0 ]; then
	if [ "$EMUNAME" = "tap0" ]; then
		ifconfig bridge0 destroy
		ifconfig bridge0 create
	fi
else 
	ifconfig bridge0 create
fi

ifconfig bridge0 addm $EMUNAME stp $EMUNAME 
ifconfig bridge0 up
