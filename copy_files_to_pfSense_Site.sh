#!/bin/sh

VERSION=0.60
SCPUSERNAME=sullrich
DSTISO=pfSense-$VERSION.iso
LIVEFS=/usr/local/livefs/
PVERSUFFIX=`date "+%Y.%m%d"`-`cat /home/sullrich/pfSense/etc/version`
FILENAME=pfSense-Full-Update-${VERSION}-${PVERSUFFIX}.tgz
SRCISO=FreeSBIE.iso
DSTWEBSITE=www.pfsense.com:/usr/local/www/pfsense/Etomite0.6/downloads/
UPDATESDIR=/home/sullrich/updates
FREESBIEDIR=/home/sullrich/freesbie
WEBSITEWWWDIR=/usr/local/www/pfsense/Etomite0.6

# Copy image to root of developers box
echo Copying ISO to 10.0.250.50:~${SCPUSERNAME} ... CTRL-C to abort.
scp ${FREESBIEDIR}/FreeSBIE.iso ${SCPUSERNAME}@10.0.250.50:~

# Copy image to web site
echo Copying ISO to ${DSTWEBSITE} ... CTRL-C to abort.
scp -C ${FREESBIEDIR}/${SRCISO} ${SCPUSERNAME}@/${DSTWEBSITE}/${DSTISO}

cd ${LIVEFS}
rm -rf ${LIVEFS}/conf*
rm ${LIVEFS}/usr/local/www/trigger_initial_wizard
rm ${LIVEFS}/etc/master.passwd
rm ${LIVEFS}/etc/passwd
rm ${LIVEFS}/etc/ttys
rm ${LIVEFS}/boot/device.hints
rm ${LIVEFS}/boot/loader.conf
rm ${LIVEFS}/boot/loader.rc
cd ${LIVEFS} && tar czvPf ${UPDATESDIR}/${FILENAME} .

echo Copying pfSenseUpdate-${PVERSUFFIX}.tgz to updates folder/
scp -C ${UPDATESDIR}/pfSenseUpdate-${PVERSUFFIX}.tgz \
        ${SCPUSERNAME}@216.135.66.16:${WEBSITEWWWDIR}/updates/

echo Updating MD5
ssh ${SCPUSERNAME}@216.135.66.16 "rm ${WEBSITEWWWDIR}/latest.tgz ; \
	md5 ${WEBSITEWWWDIR}/updates/${FILENAME} .\
            > ${WEBSITEWWWDIR}/latest.tgz.md5 ; \
	ln -s ${WEBSITEWWWDIR}/updates/${FILENAME} . \
	${WEBSITEWWWDIR}/latest.tgz"

echo Copying ${LIVEFS}/etc/version to server
scp ${LIVEFS}/etc/version ${SCPUSERNAME}@216.135.66.16:${WEBSITEWWWDIR}/pfSense/

cd /home/sullrich/tools

