#!/bin/sh

# cvs_sync
# Part of the pfSense project
# For users of cvs accounts to keep your test machine
# up to date

#CVSUSER=sullrich
TMPDIR=/tmp/pfSense/

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
