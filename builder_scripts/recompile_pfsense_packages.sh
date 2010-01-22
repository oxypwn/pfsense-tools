#!/bin/sh

mkdir -p /usr/ports/packages/All

PORTS_TO_REBUILD="/usr/ports/net/ntop
/usr/ports/net/avahi
/usr/ports/net/arping
/usr/ports/net-mgmt/arpwatch
/usr/ports/dns/djbdns
/usr/ports/sysutils/daemontools
/usr/ports/net-mgmt/darkstat
/usr/ports/net/frickin
/usr/ports/net/freeradius
/usr/ports/net/haproxy-devel
/usr/ports/www/havp
/usr/ports/benchmarks/iperf
/usr/ports/www/lightsquid
/usr/ports/security/nmap
/usr/ports/misc/nut
/usr/ports/benchmarks/netio
/usr/ports/net/openbgpd
/usr/ports/emulators/open-vm-tools-nox11
/usr/ports/security/portsentry
/usr/ports/www/mod_security
/usr/ports/net/pfflowd
/usr/ports/net-mgmt/rate
/usr/ports/mail/spamd
/usr/ports/net/siproxd
/usr/ports/security/stunnel
/usr/ports/www/squid
/usr/ports/www/squidguard
/usr/ports/net/widentd
/usr/ports/net/vnstat"

for PORT in $PORTS_TO_REBUILD; do
	cd $PORT && make clean package-recursive FORCE_PKG_REGISTER=yes BATCH=yes
done

# ports that need custom pfPorts
#   anyterm
#   LCDProc