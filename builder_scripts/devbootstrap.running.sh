#!/bin/sh

if [ -f /tmp/pfSense_Dev_Builder.txt ]; then
	sleep 5 && tail -f /tmp/pfSense_Dev_Builder.txt &	
fi