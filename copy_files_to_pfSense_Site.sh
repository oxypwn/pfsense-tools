#!/bin/sh

echo Copying ISO to 10.0.250.50:~sullrich ... CTRL-C to abort.
scp /home/sullrich/freesbie/FreeSBIE.iso sullrich@10.0.250.50:~
echo Copying ISO to www.livebsd.com ... CTRL-C to abort.
scp -C /home/sullrich/freesbie/FreeSBIE.iso \
        sullrich@www.pfsense.com:/usr/local/www/pfsense/Etomite0.6/downloads/pfSense-0.53.iso

cd /home/sullrich/pfSense
rm -rf conf*
rm -rf usr/local/www/trigger_initial_wizard
PVERSUFFIX=`date "+%Y.%m%d"`-`cat /home/sullrich/pfSense/etc/version`
rm /home/sullrich/pfSense/master.passwd /home/sullrich/pfSense/passwd
rm /home/sullrich/pfSense/ttys
cd /home/sullrich/pfSense && cp -R /usr/local/livefs/boot .
cd /home/sullrich/pfSense/boot && rm device.hints loader.conf loader.rc
cd /home/sullrich/pfSense && tar czvPf /pfSenseUpdate-$PVERSUFFIX.tgz .
echo Copying pfSenseUpdate-$PVERSUFFIX.tgz to updates folder/
scp -C /pfSenseUpdate-$PVERSUFFIX.tgz \
        sullrich@216.135.66.16:/usr/local/www/pfsense/Etomite0.6/updates/

echo Updating MD5
ssh sullrich@216.135.66.16 "rm /usr/local/www/pfsense/Etomite0.6/latest.tgz ; \
	md5 /usr/local/www/pfsense/Etomite0.6/updates/pfSenseUpdate-$PVERSUFFIX.tgz > /usr/local/www/pfsense/Etomite0.6/latest.tgz.md5 ; \
	ln -s /usr/local/www/pfsense/Etomite0.6/updates/pfSenseUpdate-$PVERSUFFIX.tgz \
	/usr/local/www/pfsense/Etomite0.6/latest.tgz"

echo Copying /home/sullrich/pfSense/etc/version to server
scp /home/sullrich/pfSense/etc/version sullrich@216.135.66.16:/usr/local/www/pfsense/Etomite0.6/pfSense/

cd /home/sullrich/tools

