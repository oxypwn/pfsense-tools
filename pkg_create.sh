#!/bin/sh

echo Removing old ports structures...
rm -rf /usr/ports/*

rm /etc/ports-supfile
cp ports-supfile /etc/
cvsup /etc/ports-supfile
mkdir -p /usr/ports/packages/All
mkdir -p /usr/ports/distfiles/

mkdir -p /usr/ports/packages/All
rm -rf /usr/ports/packages/All/*

PACKAGES="/usr/ports/ftp/pure-ftpd/ \
	/usr/ports/net/ntop/ \
	/usr/ports/security/nmap \
	/usr/ports/dns/powerdns \
	/usr/ports/security/stunnel \
	/usr/ports/security/nmap \
	/usr/ports/sysutils/pfstat"

for PORT in $PACKAGES; do
	cd $PORT && make deinstall
	cd $PORT && make package-recursive
done

# Handle stunnel special case where we need to eliminate
# the script from asking if a user should be added or
# removed.