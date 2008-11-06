#!/bin/sh 

/sbin/ping -t 5 -oqc 5 -i 0.7 $1

return $?
