#!/bin/sh 

/sbin/ping -t 4 -oqc 5 -i 0.7 $1

return $?
