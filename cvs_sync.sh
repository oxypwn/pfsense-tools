#!/bin/sh

#  cvs_sync
#  Written by Scott Ullrich
#  (C)2005 Scott Ullrich
#  Part of the pfSense project
#  For users of cvs accounts to keep your test machine
#  up to date

# **** SET THIS! ****
#CVSUSER=sullrich

# Temporary directory where we will check out to.
TMPDIR=/tmp/pfSense/

/sbin/killall syslogd

if [ ! -r $CVSUSER ]; then
    CVSUSER=`whoami`
fi

if [ -r $1 ]; then
    rm -rf $TMPDIR
    mkdir -p $TMPDIR
    cd $TMPDIR/.. && cvs -d:ext:${CVSUSER}@216.135.66.16:/cvsroot co pfSense        
else
    cd $TMPDIR/.. && cvs -d:ext:${CVSUSER}@216.135.66.16:/cvsroot update
fi

cd $TMPDIR/pfSense
cd ${TMPDIR}
find . -name pfSense.tgz -exec rm {} \;
rm -rf ${TMPDIR}/conf*
rm ${TMPDIR}usr/local/www/trigger_initial_wizard 2>/dev/null
rm ${TMPDIR}etc/master.passwd 2>/dev/null
rm ${TMPDIR}etc/passwd 2>/dev/null
rm ${TMPDIR}etc/fstab 2>/dev/null
rm ${TMPDIR}etc/ttys 2>/dev/null
rm ${TMPDIR}etc/fstab 2>/dev/null
rm ${TMPDIR}boot/device.hints 2>/dev/null
rm ${TMPDIR}boot/loader.conf 2>/dev/null
rm ${TMPDIR}boot/loader.rc 2>/dev/null
rm -rf ${TMPDIR}conf/ 2>/dev/null
rm -rf ${TMPDIR}cf/ 2>/dev/null
rm -rf ${TMPDIR}root/.shrc
rm -rf ${TMPDIR}root/.tcshrc

cd $TMPDIR

for FILE in *
do
        DIR=`echo $FILE | cut -d/ -f2`
        cd $TMPDIR && cp -P -R $TMPDIR$DIR/* /$DIR/
done

clog -i -s 10000 /var/log/system.log
clog -i -s 10000 /var/log/filter.log
clog -i -s 10000 /var/log/dhcpd.log
clog -i -s 10000 /var/log/vpn.log
clog -i -s 10000 /var/log/portalauth.log

/usr/sbin/syslogd
/bin/chmod 0600 /var/log/system.log /var/log/filter.log /var/log/dhcpd.log /var/log/vpn.log /var/log/portalauth.log
