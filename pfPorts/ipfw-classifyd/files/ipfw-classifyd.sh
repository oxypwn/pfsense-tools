#!/bin/sh
#
# $Id
#

# PROVIDE: ipfw-classifyd
# REQUIRE: netif ppp
# BEFORE: NETWORKING ipfw

. /etc/rc.subr

name=ipfw_classifyd
rcvar=`set_rcvar`
command="/usr/local/sbin/ipfw-classifyd"
extra_commands="reload"

load_rc_config $name
run_rc_command "$1"
