#!/bin/sh

# Sync host system with pfSense image

$DESTDIRROOT=/home/sullrich/pfsense

cp /usr/local/bin/ez-ipupdate $DESTDIRROOT/usr/local/bin/
cp /usr/local/bin/msntp $DESTDIRROOT/usr/local/bin/
cp /usr/local/bin/runmsntp.sh $DESTDIRROOT/usr/local/bin/
cp /usr/local/bin/wol $DESTDIRROOT/usr/local/bin/
cp /usr/local/bin/minicron $DESTDIRROOT/usr/local/bin/
cp /usr/local/bin/php $DESTDIRROOT/usr/local/bin/
cp /usr/local/bin/verifysig $DESTDIRROOT/usr/local/bin/

cp /usr/local/sbin/atareinit $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/dhcpd $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/mini_httpd $DESTDIRROOT/usr/local/sbin/ 
cp /usr/local/sbin/ppp-linkup $DESTDIRROOT/usr/local/sbin/ 
cp /usr/local/sbin/vpn-linkdown $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/bpalogin $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/dhcrelay $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/mpd $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/racoon $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/vpn-linkup $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/choparp $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/dnsmasq $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/openvpn $DESTDIRROOT/usr/local/sbin/
cp /usr/local/sbin/snmpd $DESTDIRROOT/usr/local/sbin/

cp /sbin/adjkerntz $DESTDIRROOT/sbin/
cp /sbin/init $DESTDIRROOT/sbin/
cp /sbin/kldunload $DESTDIRROOT/sbin/
cp /sbin/mount_null $DESTDIRROOT/sbin/
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
cp /sbin/mount_fdesc $DESTDIRROOT/sbin/
cp /sbin/mount_umap $DESTDIRROOT/sbin/
cp /sbin/umount $DESTDIRROOT/sbin/
cp /sbin/fastboot $DESTDIRROOT/sbin/
cp /sbin/ipfw $DESTDIRROOT/sbin/
cp /sbin/mount_kernfs $DESTDIRROOT/sbin/
cp /sbin/mount_union $DESTDIRROOT/sbin/
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
cp /sbin/mount_msdos $DESTDIRROOT/sbin/
cp /sbin/reboot $DESTDIRROOT/sbin/

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

cp /usr/sbin/ancontrol $DESTDIRROOT/usr/sbin/
cp /usr/sbin/chroot $DESTDIRROOT/usr/sbin/
cp /usr/sbin/pccardd $DESTDIRROOT/usr/sbin/
cp /usr/sbin/syslogd $DESTDIRROOT/usr/sbin/
cp /usr/sbin/arp $DESTDIRROOT/usr/sbin/
cp /usr/sbin/clog $DESTDIRROOT/usr/sbin/
cp /usr/sbin/pwd_mkdb $DESTDIRROOT/usr/sbin/
cp /usr/sbin/wicontrol $DESTDIRROOT/usr/sbin/
cp /usr/sbin/chown $DESTDIRROOT/usr/sbin/
cp /usr/sbin/dev_mkdb $DESTDIRROOT/usr/sbin/
cp /usr/sbin/setkey $DESTDIRROOT/usr/sbin/

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

cp /usr/lib/libc.so.4 $DESTDIRROOT/usr/lib/
cp /usr/lib/libkvm.so.2 $DESTDIRROOT/usr/lib/
cp /usr/lib/libskey.so.2 $DESTDIRROOT/usr/lib/
cp /usr/lib/libcrypt.so.2 $DESTDIRROOT/usr/lib/
cp /usr/lib/libm.so.2 $DESTDIRROOT/usr/lib/
cp /usr/lib/libssl.so.3 $DESTDIRROOT/usr/lib/
cp /usr/lib/libcrypto.so.3 $DESTDIRROOT/usr/lib/
cp /usr/lib/libmd.so.2 $DESTDIRROOT/usr/lib/
cp /usr/lib/libutil.so.3 $DESTDIRROOT/usr/lib/$DESTDIRROOT/usr/lib/
cp /usr/lib/libedit.so.3 $DESTDIRROOT/usr/lib/
cp /usr/lib/libncurses.so.5 $DESTDIRROOT/usr/lib/
cp /usr/lib/libwrap.so.3 $DESTDIRROOT/usr/lib/
cp /usr/lib/libipsec.so.1 $DESTDIRROOT/usr/lib/
cp /usr/lib/libnetgraph.so.1 $DESTDIRROOT/usr/lib/
cp /usr/lib/libz.so.2 $DESTDIRROOT/usr/lib/
cp /usr/lib/libipx.so.2 $DESTDIRROOT/usr/lib/
cp /usr/lib/libradius.so.1 $DESTDIRROOT/usr/lib/

