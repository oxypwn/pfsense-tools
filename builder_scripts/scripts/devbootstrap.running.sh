#!/bin/sh

if [ -f /tmp/pfSense_Dev_Builder.txt ]; then
	sleep 10 && echo "resuming tail -f /tmp/pfSense_Dev_Builder.txt" && tail -f /tmp/pfSense_Dev_Builder.txt &	
fi