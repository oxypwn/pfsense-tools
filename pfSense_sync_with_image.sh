#!/bin/sh

DESTDIRROOT=/home/sullrich/pfSense

# mini_httpd.c patch
# Download mini_httpd.c patch from m0n0wall site if doesnt exist.
if [ ! -e /usr/ports/www/mini_httpd/files/patch-mini_httpd.c ]; then
  cd /usr/ports/www/mini_httpd/files && \
	fetch http://m0n0.ch/wall/downloads/mini_httpd.c.patch
  mv /usr/ports/www/mini_httpd/files/mini_httpd.c.patch \
	/usr/ports/www/mini_httpd/files/patch-mini_httpd.c
fi

# atareinit
if [ ! -e $DESTDIRROOT/usr/local/sbin/atareinit ]; then
  fetch http://m0n0.ch/wall/downloads/atareinit.c
  gcc -o $DESTDIRROOT/usr/local/sbin/atareinit atareinit.c
  rm atareinit.c
fi

# minicron
if [ ! -e $DESTDIRROOT/usr/local/minicron ]; then
    fetch http://m0n0.ch/wall/downloads/minicron.c
    gcc -o $DESTDIRROOT/usr/local/bin/minicron minicron.c
    rm minicron.c
fi

# bpalogin
if [ ! -e $DESTDIRROOT/usr/local/sbin/bpalogin ]; then
    fetch http://bpalogin.sourceforge.net/download/bpalogin-2.0.2.tar.gz
    tar xzvpf bpalogin-2.0.2.tar.gz
    cd bpalogin-2.0.2 && ./configure && make
    cp bpalogin $DESTDIRROOT/usr/local/sbin/bpalogin
    cd .. rm -rf bpa*
fi

cd /home/sullrich/pfSense/bin && \
for item in * ; do
        cd /usr/src/bin/$item && make clean && make  && make install
done

PACKAGES="/usr/ports/net/mpd \
    /usr/ports/security/racoon \
    /usr/ports/net/wol \
    /usr/ports/dns/ez-ipupdate \
    /usr/ports/net/msntp \
    /usr/ports/net/isc-dhcp3-server \
    /usr/ports/www/mini_httpd \
    /usr/ports/net-mgmt/choparp \
    /usr/ports/dns/dnsmasq \
    /usr/ports/security/openvpn \
    /usr/ports/net-mgmt/net-snmp4 \
    /usr/ports/www/links"

# Uncomment this to automatically install packages.
for package in $PACKAGES; do
cd $package && make clean install WITHOUT_X11=yes BATCH=yes
done
rm -rf /var/db/pkg/*

# copy files from host to pfSense skeleton image.
mkdir -p $DESTDIRROOT/usr/local/bin/
cp /usr/local/bin/ez-ipupdate $DESTDIRROOT/usr/local/bin/
cp /usr/local/bin/msntp $DESTDIRROOT/usr/local/bin/
cp /usr/local/bin/wol $DESTDIRROOT/usr/local/bin/
cp /usr/local/bin/minicron $DESTDIRROOT/usr/local/bin/
#cp /usr/local/bin/php $DESTDIRROOT/usr/local/bin/
cp /usr/local/bin/links $DESTDIRROOT/usr/local/bin/
chmod a+x $DESTDIRROOT/usr/local/bin/*

mkdir -p $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/atareinit $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/dhcpd $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/mini_httpd $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/bpalogin $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/mpd $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/racoon $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/choparp $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/dnsmasq $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/openvpn $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/snmpd $DESTDIRROOT/usr/local/sbin/
chmod a+x $DESTDIRROOT/usr/local/sbin/*

mkdir -p $DESTDIRROOT/sbin/
cp /sbin/adjkerntz $DESTDIRROOT/sbin/
cp /sbin/init $DESTDIRROOT/sbin/
cp /sbin/kldunload $DESTDIRROOT/sbin/
cp /sbin/route $DESTDIRROOT/sbin/
cp /sbin/dhclient $DESTDIRROOT/sbin/
cp /sbin/ipf $DESTDIRROOT/sbin/
cp /sbin/ldconfig $DESTDIRROOT/sbin/
cp /sbin/mount_procfs $DESTDIRROOT/sbin/
cp /sbin/shutdown $DESTDIRROOT/sbin/
cp /sbin/dhclient-script $DESTDIRROOT/sbin/
cp /sbin/ipfs $DESTDIRROOT/sbin/
cp /sbin/mount $DESTDIRROOT/sbin/
cp /sbin/mount_std $DESTDIRROOT/sbin/
cp /sbin/sysctl $DESTDIRROOT/sbin/
cp /sbin/dmesg $DESTDIRROOT/sbin/
cp /sbin/ipfstat $DESTDIRROOT/sbin/
cp /sbin/umount $DESTDIRROOT/sbin/
cp /sbin/fastboot $DESTDIRROOT/sbin/
cp /sbin/ipfw $DESTDIRROOT/sbin/
cp /sbin/fasthalt $DESTDIRROOT/sbin/
cp /sbin/ipmon $DESTDIRROOT/sbin/
cp /sbin/mount_linprocfs $DESTDIRROOT/sbin/
cp /sbin/nologin $DESTDIRROOT/sbin/
cp /sbin/halt $DESTDIRROOT/sbin/
cp /sbin/ipnat $DESTDIRROOT/sbin/
cp /sbin/mount_mfs $DESTDIRROOT/sbin/
cp /sbin/ping $DESTDIRROOT/sbin/
cp /sbin/ifconfig $DESTDIRROOT/sbin/
cp /sbin/kldload $DESTDIRROOT/sbin/
cp /sbin/reboot $DESTDIRROOT/sbin/
chmod a+x $DESTDIRROOT/sbin/*

mkdir -p $DESTDIRROOT/bin
cp /bin/[ $DESTDIRROOT/bin/
cp /bin/date $DESTDIRROOT/bin/
cp /bin/expr $DESTDIRROOT/bin/
cp /bin/mkdir $DESTDIRROOT/bin/
cp /bin/sleep $DESTDIRROOT/bin/
cp /bin/cat $DESTDIRROOT/bin/
cp /bin/dd $DESTDIRROOT/bin/
cp /bin/hostname $DESTDIRROOT/bin/
cp /bin/ps $DESTDIRROOT/bin/
cp /bin/stty $DESTDIRROOT/bin/
cp /bin/chmod $DESTDIRROOT/bin/
cp /bin/df $DESTDIRROOT/bin/
cp /bin/kill $DESTDIRROOT/bin/
cp /bin/rm $DESTDIRROOT/bin/
cp /bin/sync $DESTDIRROOT/bin/
cp /bin/cp $DESTDIRROOT/bin/
cp /bin/echo $DESTDIRROOT/bin/
cp /bin/ls $DESTDIRROOT/bin/
cp /bin/sh $DESTDIRROOT/bin/
cp /bin/test $DESTDIRROOT/bin/
chmod a+x $DESTDIRROOT/$DESTDIRROOT/bin/*

mkdir -p $DESTDIRROOT/usr/sbin
cp /usr/sbin/ancontrol $DESTDIRROOT/usr/sbin/
cp /usr/sbin/chroot $DESTDIRROOT/usr/sbin/
cp /usr/sbin/pccardd $DESTDIRROOT/usr/sbin/
#cp /usr/sbin/syslogd $DESTDIRROOT/usr/sbin/
cp /usr/sbin/arp $DESTDIRROOT/usr/sbin/
cp /usr/sbin/clog $DESTDIRROOT/usr/sbin/
cp /usr/sbin/pwd_mkdb $DESTDIRROOT/usr/sbin/
cp /usr/sbin/wicontrol $DESTDIRROOT/usr/sbin/
cp /usr/sbin/chown $DESTDIRROOT/usr/sbin/
cp /usr/sbin/dev_mkdb $DESTDIRROOT/usr/sbin/
cp /usr/sbin/setkey $DESTDIRROOT/usr/sbin/
chmod a+x $DESTDIRROOT/ $DESTDIRROOT/usr/sbin/*

mkdir -p $DESTDIRROOT/usr/bin/
cp /usr/bin/gunzip $DESTDIRROOT/usr/bin/
cp /usr/bin/killall $DESTDIRROOT/usr/bin/
cp /usr/bin/netstat $DESTDIRROOT/usr/bin/
cp /usr/bin/su $DESTDIRROOT/usr/bin/
cp /usr/bin/tar $DESTDIRROOT/usr/bin/
cp /usr/bin/touch $DESTDIRROOT/usr/bin/
cp /usr/bin/w $DESTDIRROOT/usr/bin/
cp /usr/bin/gzip $DESTDIRROOT/usr/bin/
cp /usr/bin/logger $DESTDIRROOT/usr/bin/
cp /usr/bin/nohup $DESTDIRROOT/usr/bin/
cp /usr/bin/tail $DESTDIRROOT/usr/bin/
cp /usr/bin/top $DESTDIRROOT/usr/bin/
cp /usr/bin/uptime $DESTDIRROOT/usr/bin/
chmod a+x $DESTDIRROOT/ $DESTDIRROOT/usr/bin/*


