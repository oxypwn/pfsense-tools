#!/bin/sh

#echo Copying ISO to 10.0.250.50:~sullrich ... CTRL-C to abort.
#scp /home/sullrich/freesbie/FreeSBIE.iso sullrich@10.0.250.50:~
#echo Copying ISO to www.livebsd.com ... CTRL-C to abort.
#scp -C -l250 /home/sullrich/freesbie/FreeSBIE.iso \
#        sullrich@www.pfsense.com:/usr/local/www/pfsense/Etomite0.6/downloads/pfSense-0.22.iso


cd /home/sullrich/pfSense
rm -rf conf*
rm -rf usr/local/www/trigger_initial_wizard
PVERSUFFIX=`date "+%Y.%m%d"`
#cd /home/sullrich/pfSense && tar czvPf /pfSenseUpdate-$PVERSUFFIX.tgz .
#scp -C /pfSenseUpdate-$PVERSUFFIX.tgz \
#        sullrich@216.135.66.16:/usr/local/www/pfsense/Etomite0.6/updates/


ssh sullrich@216.135.66.16 "rm /usr/local/www/pfsense/Etomite0.6/latest.tgz"
ssh sullrich@216.135.66.16 "md5 /usr/local/www/pfsense/Etomite0.6/updates/pfSenseUpdate-$PVERSUFFIX.tgz > /usr/local/www/pfsense/Etomite0.6/latest.tgz.md5"

ssh sullrich@216.135.66.16 "ln -s /usr/local/www/pfsense/Etomite0.6/updates/pfSenseUpdate-$PVERSUFFIX.tgz \
	/usr/local/www/pfsense/Etomite0.6/latest.tgz"

cd /home/sullrich/tools

