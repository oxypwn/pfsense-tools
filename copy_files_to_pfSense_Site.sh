#!/bin/sh

VERSION=0.62.1
PRODUCTNAME=pfSense
SCPUSERNAME=sullrich
DSTISO=pfSense-$VERSION.iso
LIVEFS=/usr/local/livefs/
PVERSUFFIX=`cat /home/sullrich/pfSense/etc/version`
FILENAME=${PRODUCTNAME}-Full-Update-${PVERSUFFIX}.tgz
SRCISO=FreeSBIE.iso
DSTWEBSITE=www.pfsense.com:/usr/local/www/pfsense/Etomite0.6/downloads/
UPDATESDIR=/home/sullrich/updates/
FREESBIEDIR=/home/sullrich/freesbie/
WEBSITEWWWDIR=/usr/local/www/pfsense/Etomite0.6/

cd ${LIVEFS}
rm -rf ${LIVEFS}/conf*
echo Removing pfSense.tgz used by installer..
find . -name pfSense.tgz -exec rm {} \;
rm ${LIVEFS}usr/local/www/trigger_initial_wizard 2>/dev/null
rm ${LIVEFS}etc/master.passwd 2>/dev/null
rm ${LIVEFS}etc/pwd.db 2>/dev/null
rm ${LIVEFS}etc/spwd.db 2>/dev/null
rm ${LIVEFS}etc/passwd 2>/dev/null
rm ${LIVEFS}etc/fstab 2>/dev/null
rm ${LIVEFS}etc/ttys 2>/dev/null
rm ${LIVEFS}etc/fstab 2>/dev/null
rm ${LIVEFS}boot/device.hints 2>/dev/null
rm ${LIVEFS}boot/loader.conf 2>/dev/null
rm ${LIVEFS}boot/loader.rc 2>/dev/null
rm -rf ${LIVEFS}conf/ 2>/dev/null
rm -rf ${LIVEFS}cf/ 2>/dev/null
echo > ${LIVEFS}root/.tcshrc
# Setup login environment
echo > ${LIVEFS}root/.shrc
echo "/etc/rc.initial" >> ${LIVEFS}root/.shrc
echo "exit" >> ${LIVEFS}root/.shrc

echo ; echo Creating ${UPDATESDIR}/${FILENAME} ...
cd ${LIVEFS} && tar czPf ${UPDATESDIR}/${FILENAME} .

# Copy image to root of developers box
echo ; echo Copying ISO to 10.0.250.50:~${SCPUSERNAME} ... CTRL-C to abort.
scp ${FREESBIEDIR}/FreeSBIE.iso ${SCPUSERNAME}@10.0.250.50:~

# Copy image to web site
echo ; echo Copying ISO to ${DSTWEBSITE} ... CTRL-C to abort.
scp -C ${FREESBIEDIR}/${SRCISO} ${SCPUSERNAME}@${DSTWEBSITE}/${DSTISO}

echo ; echo Copying $FILENAME to updates folder/
scp -C ${UPDATESDIR}/$FILENAME \
        ${SCPUSERNAME}@216.135.66.16:${WEBSITEWWWDIR}/updates/

echo ; echo Updating MD5
ssh ${SCPUSERNAME}@216.135.66.16 "rm ${WEBSITEWWWDIR}/latest.tgz ; \
	md5 ${WEBSITEWWWDIR}/updates/${FILENAME} .\
            > ${WEBSITEWWWDIR}/latest.tgz.md5 ; \
	ln -s ${WEBSITEWWWDIR}/updates/${FILENAME} . \
	${WEBSITEWWWDIR}/latest.tgz"


echo ; echo Copying ${LIVEFS}/etc/version to server
scp ${LIVEFS}/etc/version ${SCPUSERNAME}@216.135.66.16:${WEBSITEWWWDIR}/pfSense/


cd /home/sullrich/tools




