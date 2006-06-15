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
install -s /usr/local/bin/ez-ipupdate $DESTDIRROOT/usr/local/bin/
install -s /usr/local/bin/msntp $DESTDIRROOT/usr/local/bin/
install -s /usr/local/bin/wol $DESTDIRROOT/usr/local/bin/
install -s /usr/local/bin/minicron $DESTDIRROOT/usr/local/bin/
#cp /usr/local/bin/php $DESTDIRROOT/usr/local/bin/
install -s /usr/local/bin/links $DESTDIRROOT/usr/local/bin/
chmod a+x $DESTDIRROOT/usr/local/bin/*

mkdir -p $DESTDIRROOT/usr/local/sbin/
install -s /usr/local/sbin/atareinit $DESTDIRROOT/usr/local/sbin/
install -s /usr/local/sbin/dhcpd $DESTDIRROOT/usr/local/sbin/
install -s /usr/local/sbin/mini_httpd $DESTDIRROOT/usr/local/sbin/
install -s /usr/local/sbin/bpalogin $DESTDIRROOT/usr/local/sbin/
install -s /usr/local/sbin/mpd $DESTDIRROOT/usr/local/sbin/
install -s /usr/local/sbin/racoon $DESTDIRROOT/usr/local/sbin/
install -s /usr/local/sbin/choparp $DESTDIRROOT/usr/local/sbin/
install -s /usr/local/sbin/dnsmasq $DESTDIRROOT/usr/local/sbin/
install -s /usr/local/sbin/openvpn $DESTDIRROOT/usr/local/sbin/
install -s /usr/local/sbin/snmpd $DESTDIRROOT/usr/local/sbin/
chmod a+x $DESTDIRROOT/usr/local/sbin/*

mkdir -p $DESTDIRROOT/sbin/
install -s /sbin/adjkerntz $DESTDIRROOT/sbin/
install -s /sbin/init $DESTDIRROOT/sbin/
install -s /sbin/kldunload $DESTDIRROOT/sbin/
install -s /sbin/route $DESTDIRROOT/sbin/
install -s /sbin/dhclient $DESTDIRROOT/sbin/
install -s /sbin/ipf $DESTDIRROOT/sbin/
install -s /sbin/ldconfig $DESTDIRROOT/sbin/
install -s /sbin/mount_procfs $DESTDIRROOT/sbin/
install -s /sbin/shutdown $DESTDIRROOT/sbin/
install -s /sbin/dhclient-script $DESTDIRROOT/sbin/
install -s /sbin/ipfs $DESTDIRROOT/sbin/
install -s /sbin/mount $DESTDIRROOT/sbin/
install -s /sbin/mount_std $DESTDIRROOT/sbin/
install -s /sbin/sysctl $DESTDIRROOT/sbin/
install -s /sbin/dmesg $DESTDIRROOT/sbin/
install -s /sbin/ipfstat $DESTDIRROOT/sbin/
install -s /sbin/umount $DESTDIRROOT/sbin/
install -s /sbin/fastboot $DESTDIRROOT/sbin/
install -s /sbin/ipfw $DESTDIRROOT/sbin/
install -s /sbin/fasthalt $DESTDIRROOT/sbin/
install -s /sbin/ipmon $DESTDIRROOT/sbin/
install -s /sbin/mount_linprocfs $DESTDIRROOT/sbin/
install -s /sbin/nologin $DESTDIRROOT/sbin/
install -s /sbin/halt $DESTDIRROOT/sbin/
install -s /sbin/ipnat $DESTDIRROOT/sbin/
install -s /sbin/mount_mfs $DESTDIRROOT/sbin/
install -s /sbin/ping $DESTDIRROOT/sbin/
install -s /sbin/ifconfig $DESTDIRROOT/sbin/
install -s /sbin/kldload $DESTDIRROOT/sbin/
install -s /sbin/reboot $DESTDIRROOT/sbin/
chmod a+x $DESTDIRROOT/sbin/*

mkdir -p $DESTDIRROOT/bin
install -s /bin/[ $DESTDIRROOT/bin/
install -s /bin/date $DESTDIRROOT/bin/
install -s /bin/expr $DESTDIRROOT/bin/
install -s /bin/mkdir $DESTDIRROOT/bin/
install -s /bin/sleep $DESTDIRROOT/bin/
install -s /bin/cat $DESTDIRROOT/bin/
install -s /bin/dd $DESTDIRROOT/bin/
install -s /bin/hostname $DESTDIRROOT/bin/
install -s /bin/ps $DESTDIRROOT/bin/
install -s /bin/stty $DESTDIRROOT/bin/
install -s /bin/chmod $DESTDIRROOT/bin/
install -s /bin/df $DESTDIRROOT/bin/
install -s /bin/kill $DESTDIRROOT/bin/
install -s /bin/rm $DESTDIRROOT/bin/
install -s /bin/sync $DESTDIRROOT/bin/
install -s /bin/cp $DESTDIRROOT/bin/
install -s /bin/echo $DESTDIRROOT/bin/
install -s /bin/ls $DESTDIRROOT/bin/
install -s /bin/sh $DESTDIRROOT/bin/
install -s /bin/test $DESTDIRROOT/bin/
chmod a+x $DESTDIRROOT/$DESTDIRROOT/bin/*

mkdir -p $DESTDIRROOT/usr/sbin
install -s /usr/sbin/ancontrol $DESTDIRROOT/usr/sbin/
install -s /usr/sbin/chroot $DESTDIRROOT/usr/sbin/
install -s /usr/sbin/pccardd $DESTDIRROOT/usr/sbin/
#cp /usr/sbin/syslogd $DESTDIRROOT/usr/sbin/
install -s /usr/sbin/arp $DESTDIRROOT/usr/sbin/
install -s /usr/sbin/clog $DESTDIRROOT/usr/sbin/
install -s /usr/sbin/pwd_mkdb $DESTDIRROOT/usr/sbin/
install -s /usr/sbin/wicontrol $DESTDIRROOT/usr/sbin/
install -s /usr/sbin/chown $DESTDIRROOT/usr/sbin/
install -s /usr/sbin/dev_mkdb $DESTDIRROOT/usr/sbin/
install -s /usr/sbin/setkey $DESTDIRROOT/usr/sbin/
chmod a+x $DESTDIRROOT/ $DESTDIRROOT/usr/sbin/*

mkdir -p $DESTDIRROOT/usr/bin/
install -s /usr/bin/gunzip $DESTDIRROOT/usr/bin/
install -s /usr/bin/killall $DESTDIRROOT/usr/bin/
install -s /usr/bin/netstat $DESTDIRROOT/usr/bin/
install -s /usr/bin/su $DESTDIRROOT/usr/bin/
install -s /usr/bin/tar $DESTDIRROOT/usr/bin/
install -s /usr/bin/touch $DESTDIRROOT/usr/bin/
install -s /usr/bin/w $DESTDIRROOT/usr/bin/
install -s /usr/bin/gzip $DESTDIRROOT/usr/bin/
install -s /usr/bin/logger $DESTDIRROOT/usr/bin/
install -s /usr/bin/nohup $DESTDIRROOT/usr/bin/
install -s /usr/bin/tail $DESTDIRROOT/usr/bin/
install -s /usr/bin/top $DESTDIRROOT/usr/bin/
install -s /usr/bin/uptime $DESTDIRROOT/usr/bin/
chmod a+x $DESTDIRROOT/ $DESTDIRROOT/usr/bin/*


