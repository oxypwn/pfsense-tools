#!/bin/sh

# special ports
#  /usr/ports/security/stunnel -- do not ask about adding users.
#  /usr/ports/dns/powerdns -- rather include sqlite3.

mkdir -p /usr/ports/packages/All
rm -rf /usr/ports/packages/All/*

PACKAGES="/usr/ports/ftp/pure-ftpd/ \
	/usr/ports/net/ntop/ \
	/usr/ports/security/nmap \
	/usr/ports/sysutils/pfstat"

for PORT in $PACKAGES; do
	cd $PORT && make package-recursive
done

