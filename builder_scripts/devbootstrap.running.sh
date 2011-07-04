#!/bin/sh

if [ -f /tmp/pfSense_Dev_Builder.txt ]; then
	tail -f /tmp/pfSense_Dev_Builder.txt &	
fi