#!/bin/sh

#  cvs_sync
#  Written by Scott Ullrich
#  (C)2005 Scott Ullrich
#  Part of the pfSense project
#  For users of cvs accounts to keep your test machine up to date
#  
#  Usage example: setenv CVSUSER sullrich && ./cvs_sync.sh
#                 setenv CVSUSER sullrich && ./cvs_sync.sh update

if [ "$CVSUSER" = "" ]; then
    echo
    echo "You must export the variable CVSUSER as your cvs login name"
    echo
    echo "Example: setenv CVSUSER sullrich && ./cvs_sync.sh"
    echo
    exit
fi

# Temporary directory where we will check out to.
TMPDIR=/tmp/pfSense/

if [ -r $1 ]; then
    rm -rf $TMPDIR
    mkdir -p $TMPDIR
    cd $TMPDIR/.. && cvs -d:ext:${CVSUSER}@216.135.66.16:/cvsroot co pfSense        
else
    cd $TMPDIR && cvs -d:ext:${CVSUSER}@216.135.66.16:/cvsroot update -d
fi

cd ${TMPDIR}
find . -name pfSense.tgz -exec rm {} \; 2>/dev/null
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

echo "Installing new files..."
cd $TMPDIR
for FILE in *
do
        DIR=`echo $FILE | cut -d/ -f2`
        cd $TMPDIR && install $TMPDIR$DIR/* /$DIR/ 2>/dev/null
        echo "install $TMPDIR$DIR/* /$DIR/"
done
