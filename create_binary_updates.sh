#!/bin/sh

#set -e -u

. ../freesbie/config.sh
. ../freesbie/.common.sh

PFSENSECVS=/home/sullrich/pfSense
UPDATES=/home/sullrich/updates

# XXX: tar up base and kernel for pfsense versions
echo Creating tarballs...
cd /usr/local/livefs
rm -rf cf
tar czpf /$UPDATES/kernel-${version_kernel}.tgz boot/
rm -rf boot/
tar czpf /$UPDATES/base-${version_base}.tgz .
cd /home/sullrich/pfSense/
tar zcpf /$UPDATES/pfSense-${version}.tgz .

