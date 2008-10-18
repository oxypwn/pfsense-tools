#!/bin/sh 

/sbin/ping -oqc 5 -i 0.7 $1

return $?
