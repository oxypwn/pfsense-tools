#!/bin/sh

# Copies all extra files to the CVS staging area and ISO staging area (as needed)
populate_extra() {
	cd $LOCALDIR

        # Nuke CVS dirs
        find $CVS_CO_DIR -type d -name CVS -exec rm -rf {} \; 2>/dev/null

	mkdir -p $CVS_CO_DIR/libexec
	mkdir -p $CVS_CO_DIR/lib
	mkdir -p $CVS_CO_DIR/bin
	cp /lib/libedit* $CVS_CO_DIR/lib/
	cp /bin/sh $CVS_CO_DIR/bin/
	cp /lib/libncurses.so.5 $CVS_CO_DIR/lib/
	cp /bin/ln /bin/rm $CVS_CO_DIR/bin/

	cp /usr/local/lib/libcurl.so.3 $CVS_CO_DIR/usr/local/lib/
	cp /usr/local/lib/libpcre.so.0 $CVS_CO_DIR/usr/local/lib/

	mkdir -p $LOCALDIR/var/run

	mkdir -p $CVS_CO_DIR/root/
	echo exit > $CVS_CO_DIR/root/.xcustom.sh
	touch $CVS_CO_DIR/root/.hushlogin
	cp $CVS_CO_DIR/lib/libc.so.6 $CVS_CO_DIR/lib/libc.so.5
	cp $CVS_CO_DIR/lib/libc.so.6 $CVS_CO_DIR/lib/libc.so.4

	# bsnmpd
	mkdir -p $CVS_CO_DIR/usr/share/snmp/defs/
	cp -R /usr/share/snmp/defs/ $CVS_CO_DIR/usr/share/snmp/defs/

	# Add lua installer items
	cp $BASE_DIR/tools/installer/conf/* $FREESBIEBASEDIR/usr/local/share/dfuibe_lua/conf/
	cp $BASE_DIR/tools/installer/installer_root_dir/* $FREESBIEBASEDIR/usr/local/share/dfuibe_lua/install
	#rm $FREESBIEBASEDIR/usr/local/share/dfuibe_lua/install/600_*

	# Set buildtime
	date > $CVS_CO_DIR/etc/version.buildtime
	mkdir -p $FREESBIEBASEDIR/scripts/
	cp $BASE_DIR/tools/pfi $FREESBIEBASEDIR/scripts/
	cp $BASE_DIR/tools/lua_installer $FREESBIEBASEDIR/scripts/
	cp $BASE_DIR/tools/lua_installer $FREESBIEBASEDIR/scripts/installer
	cp $BASE_DIR/tools/installer.sh $FREESBIEBASEDIR/scripts/
	chmod a+rx $FREESBIEBASEDIR/scripts/*

	mkdir -p $LOCALDIR/customroot/usr/local/bin
	mkdir -p $FREESBIEBASEDIR/usr/local/bin/

	cp $BASE_DIR/tools/after_installation_routines.sh \
		$LOCALDIR/customroot/usr/local/bin/after_installation_routines.sh

	cp $BASE_DIR/tools/after_installation_routines.sh \
		$FREESBIEBASEDIR/usr/local/bin/after_installation_routines.sh

	chmod a+rx $FREESBIEBASEDIR/scripts/*

	# Copy BSD Installer sources manifest
	mkdir -p $FREESBIEBASEDIR/usr/local/share/dfuibe_installer/
	cp $LOCALDIR/customroot/sources.conf \
		$FREESBIEBASEDIR/usr/local/share/dfuibe_installer/sources.conf

	# Update shells
	cp $LOCALDIR/customroot/shells $FREESBIEBASEDIR/etc/shells

	echo "#!/bin/sh" > $FREESBIEBASEDIR/script
	echo "/bin/ln -s /cf/conf /conf" >> $FREESBIEBASEDIR/script
	chmod a+rx $FREESBIEBASEDIR/script
	chroot $FREESBIEBASEDIR /script

	# Make sure we're not running any x mojo
	mkdir -p $FREESBIEBASEDIR/root
	echo exit > $FREESBIEBASEDIR/root/.xcustom.sh

	# Supress extra spam when logging in
	touch $FREESBIEBASEDIR/root/.hushlogin

	# Copy libraries since some files are compiled with older libc
	cp $FREESBIEBASEDIR/lib/libc.so.6 $FREESBIEBASEDIR/lib/libc.so.5
	cp $FREESBIEBASEDIR/lib/libc.so.6 $FREESBIEBASEDIR/lib/libc.so.4

	cd /usr/src/sbin/pfctl && make clean && make && make install
	cd /usr/src/sbin/pflogd && make clean && make && make install
	mkdir -p $CVS_CO_DIR/sbin/
	cp /sbin/pf* $CVS_CO_DIR/sbin/
	chmod a+rx $CVS_CO_DIR/sbin/pf*

	mkdir -p $CVS_CO_DIR/usr/lib $CVS_CO_DIR/lib
	cp /usr/lib/libstdc* $CVS_CO_DIR/usr/lib/

	# Copy devd into place
	cp /sbin/devd $FREESBIEBASEDIR/sbin/
	chmod a+rx $FREESBIEBASEDIR/sbin/devd

	# Setup login environment
	echo > $CVS_CO_DIR/root/.shrc
	echo "/etc/rc.initial" >> $CVS_CO_DIR/root/.shrc
	echo "exit" >> $CVS_CO_DIR/root/.shrc
	echo "/etc/rc.initial" >> $CVS_CO_DIR/root/.profile
	echo "exit" >> $CVS_CO_DIR/root/.profile

	echo md                 /tmp            mfs     rw,-s16m                1 \
		0 >> $CVS_CO_DIR/etc/fstab

	# Trigger the pfSense wizzard
	echo "true" > $CVS_CO_DIR/trigger_initial_wizard

	mkdir -p $FREESBIEBASEDIR/conf.default
	cp $CVS_CO_DIR/conf.default/* $FREESBIEBASEDIR/conf.default/

	mkdir -p ${FREESBIEBASEDIR}/usr/local/livefs/lib/

	cp /usr/lib/libcrypt.so ${FREESBIEBASEDIR}/usr/lib/libcrypt.so.2
	cp /usr/lib/libm.so ${FREESBIEBASEDIR}/usr/lib/libm.so.3
	cp /usr/lib/libssl.so ${FREESBIEBASEDIR}/usr/lib/libssl.so.3
	cp /usr/lib/libcrypto.so ${FREESBIEBASEDIR}/usr/lib/libcrypto.so.3
	cp /usr/lib/libz.so ${FREESBIEBASEDIR}/usr/lib/libz.so.2
	cp /usr/lib/libc.so ${FREESBIEBASEDIR}/usr/lib/libc.so.5
	cp /lib/libutil.so.5 ${FREESBIEBASEDIR}/lib/libutil.so.4
	cp /usr/local/lib/libnetsnmpagent.so.7 ${FREESBIEBASEDIR}/usr/local/lib/
	cp /usr/local/lib/libnetsnmphelpers.so.7 ${FREESBIEBASEDIR}/usr/local/lib/
	cp /usr/local/lib/libnetsnmp.so.7 ${FREESBIEBASEDIR}/usr/local/lib/

	cp /usr/lib/libpthread.so.1 ${FREESBIEBASEDIR}/usr/lib/
	cp /usr/local/lib/libevent-1.1a.so.1 ${FREESBIEBASEDIR}/usr/local/lib/
	cp /usr/local/lib/libnetsnmpmibs.so.7 ${FREESBIEBASEDIR}/usr/local/lib/

	# Install all netgraph modules
	cd /usr/src/sys/modules/netgraph/
	make
	make install DESTDIR=$FREESBIEBASEDIR

	cd /usr/src/usr.sbin/authpf
	make
	make install DESTDIR=$FREESBIEBASEDIR

	# Make sure ACPI is all ready
	cd /usr/src/sys/modules/acpi
	make
	make install DESTDIR=$FREESBIEBASEDIR

	# NDIS
        cd /usr/src/sys/modules/ndis
        make
        make install DESTDIR=$FREESBIEBASEDIR

	cd /usr/src/sys/modules/if_ndis
	make
	make install DESTDIR=$FREESBIEBASEDIR

	cd /usr/src/sys/modules/padlock
	make
	make install DESTDIR=$FREESBIEBASEDIR

	cd /usr/src/sys/modules/geom
	make
	make install DESTDIR=$FREESBIEBASEDIR

	cd /usr/src/sys/modules/ipfw
	make
	make install DESTDIR=$FREESBIEBASEDIR

	cd /usr/src/sys/modules/dummynet
	make
	make install DESTDIR=$FREESBIEBASEDIR

	cd /usr/src/usr.sbin/watchdogd
	make 
	make install DESTDIR=$FREESBIEBASEDIR

	cd /usr/src/usr.sbin/watchdog
	make
	make install DESTDIR=$FREESBIEBASEDIR

	setenv IPFIREWALL_DEFAULT_TO_ACCEPT yes
	setenv IPV6FIREWALL_DEFAULT_TO_ACCEPT yes
	cd /usr/src/sys/modules/ipfw
	make IPFIREWALL_DEFAULT_TO_ACCEPT=yes
	env IPFIREWALL_DEFAULT_TO_ACCEPT=yes && make install DESTDIR=$FREESBIEBASEDIR

}

fixup_updates() {
	VERSION=`cat $CVS_CO_DIR/etc/version`
	DSTISO=pfSense-$VERSION.iso
	FILENAME=pfSense-Full-Update-${VERSION}.tgz

	cd ${FREESBIEBASEDIR}
	rm -rf ${FREESBIEBASEDIR}/cf
	rm -rf ${CVS_CO_DIR}/cf
	rm -rf ${FREESBIEBASEDIR}/conf
	rm -rf ${CVS_CO_DIR}/conf
	rm -f ${FREESBIEBASEDIR}/boot/*
	rm -rf ${FREESBIEBASEDIR}/etc/rc.conf
	rm -rf ${FREESBIEBASEDIR}/etc/motd
	rm -rf ${FREESBIEBASEDIR}/trigger*
	rm -rf ${CVS_CO_DIR}/etc/rc.conf
	rm -rf ${CVS_CO_DIR}/etc/motd
	rm -f ${CVS_CO_DIR}/boot/*
	find ${CVS_CO_DIR} -name CVS -exec rm {} \;

	echo Removing pfSense.tgz used by installer..
	find . -name pfSense.tgz -exec rm {} \;
	rm -f ${FREESBIEBASEDIR}/etc/pwd.db 2>/dev/null
	rm -f ${FREESBIEBASEDIR}/etc/group 2>/dev/null
	rm -f ${FREESBIEBASEDIR}/etc/spwd.db 2>/dev/null
	rm -f ${FREESBIEBASEDIR}/etc/passwd 2>/dev/null
	rm -f ${FREESBIEBASEDIR}/etc/master.passwd 2>/dev/null
	rm -f ${FREESBIEBASEDIR}/etc/pwd.db
	rm -f ${FREESBIEBASEDIR}/etc/spwd.db
	rm -rf ${CVS_CO_DIR}/etc/pwd.db
	rm -rf ${CVS_CO_DIR}/etc/spwd.db
	rm -rf ${CVS_CO_DIR}/etc/group
	rm -rf ${CVS_CO_DIR}/etc/passwd
	rm -rf ${CVS_CO_DIR}/etc/master.passwd
	rm -f ${FREESBIEBASEDIR}/etc/fstab 2>/dev/null
	rm -f ${FREESBIEBASEDIR}/etc/ttys 2>/dev/null
	rm -f ${FREESBIEBASEDIR}/etc/fstab 2>/dev/null
	rm -f ${FREESBIEBASEDIR}/boot/device.hints 2>/dev/null
	rm -f ${FREESBIEBASEDIR}/boot/loader.rc 2>/dev/null
	rm -rf ${FREESBIEBASEDIR}/conf/ 2>/dev/null
	rm -rf ${FREESBIEBASEDIR}/cf/ 2>/dev/null
	echo > ${FREESBIEBASEDIR}/root/.tcshrc
	echo "alias installer /scripts/lua_installer" > ${FREESBIEBASEDIR}/root/.tcshrc
	# Setup login environment
	echo > ${FREESBIEBASEDIR}/root/.shrc
	echo "/etc/rc.initial" >> ${FREESBIEBASEDIR}/root/.shrc
	echo "exit" >> ${FREESBIEBASEDIR}/root/.shrc

	# Nuke the trigger wizard script
	rm -f ${CVS_CO_DIR}/trigger_initial_wizard
	rm -f ${FREESBIEBASEDIR}/trigger_initial_wizard

	mkdir -p ${FREESBIEBASEDIR}/usr/local/livefs/lib/

	cp /usr/bin/dig ${FREESBIEBASEDIR}/usr/bin/dig
	cp /usr/bin/host ${FREESBIEBASEDIR}/usr/bin/host

        cp /usr/lib/libcrypt.so ${FREESBIEBASEDIR}/usr/lib/libcrypt.so.2
        cp /usr/lib/libm.so ${FREESBIEBASEDIR}/usr/lib/libm.so.3
        cp /usr/lib/libssl.so ${FREESBIEBASEDIR}/usr/lib/libssl.so.3
        cp /usr/lib/libcrypto.so ${FREESBIEBASEDIR}/usr/lib/libcrypto.so.3
        cp /usr/lib/libz.so ${FREESBIEBASEDIR}/usr/lib/libz.so.2
        cp /usr/lib/libc.so ${FREESBIEBASEDIR}/usr/lib/libc.so.5
	cp /lib/libutil.so.5 ${FREESBIEBASEDIR}/lib/libutil.so.4
	cp /usr/local/lib/libnetsnmpagent.so.7 ${FREESBIEBASEDIR}/usr/local/lib/
        cp /usr/local/lib/libnetsnmphelpers.so.7 ${FREESBIEBASEDIR}/usr/local/lib/
        cp /usr/local/lib/libnetsnmp.so.7 ${FREESBIEBASEDIR}/usr/local/lib/

        cp /usr/lib/libpthread.so.1 ${FREESBIEBASEDIR}/usr/lib/
        cp /usr/local/lib/libevent-1.1a.so.1 ${FREESBIEBASEDIR}/usr/local/lib/
        cp /usr/local/lib/libnetsnmpmibs.so.7 ${FREESBIEBASEDIR}/usr/local/lib/

	echo `date` > /usr/local/livefs/etc/version.buildtime

}

fixup_wrap() {

    CURRENT_WD=`pwd`

    # Checkout pfSense information and set our version variables.
    rm -rf $BASE_DIR/pfSense
    cd $BASE_DIR && cvs -d /home/pfsense/cvsroot co -r RELENG_1 pfSense

    chflags -R noschg /tmp/ 2>/dev/null
    rm -rf /tmp/* 2>/dev/null
    rm -rf /tmp/root/*.* 2>/dev/null
    rm -rf /tmp/cf/*.* 2>/dev/null
    mkdir -p /tmp/root 2>/dev/null
    mkdir -p /tmp/cf 2>/dev/null
    
    umount /tmp/root 2>/dev/null
    umount /tmp/cf 2>/dev/null
    mdconfig -d -u 91 2>/dev/null
     
    cp /usr/lib/libcrypt.so ${FREESBIEBASEDIR}/usr/lib/libcrypt.so.2
    cp /usr/lib/libm.so ${FREESBIEBASEDIR}/usr/lib/libm.so.3
    cp /usr/lib/libssl.so ${FREESBIEBASEDIR}/usr/lib/libssl.so.3
    cp /usr/lib/libcrypto.so ${FREESBIEBASEDIR}/usr/lib/libcrypto.so.3
    cp /usr/lib/libz.so ${FREESBIEBASEDIR}/usr/lib/libz.so.2
    cp /usr/lib/libc.so ${FREESBIEBASEDIR}/usr/lib/libc.so.5
    cp /lib/libutil.so.5 ${FREESBIEBASEDIR}/lib/libutil.so.4
    cp /usr/local/lib/libnetsnmpagent.so.7 ${FREESBIEBASEDIR}/usr/local/lib/
    cp /usr/local/lib/libnetsnmphelpers.so.7 ${FREESBIEBASEDIR}/usr/local/lib/
    cp /usr/local/lib/libnetsnmp.so.7 ${FREESBIEBASEDIR}/usr/local/lib/
  
    cp /usr/lib/libpthread.so.1 ${FREESBIEBASEDIR}/usr/lib/
    cp /usr/local/lib/libevent-1.1a.so.1 ${FREESBIEBASEDIR}/usr/local/lib/
    cp /usr/local/lib/libnetsnmpmibs.so.7 ${FREESBIEBASEDIR}/usr/local/lib/
 
    cp $CVS_CO_DIR/boot/device.hints_wrap \
            $FREESBIEISODIR/boot/device.hints
    cp $CVS_CO_DIR/boot/loader.conf_wrap \
            $FREESBIEISODIR/boot/loader.conf
    cp $CVS_CO_DIR/etc/ttys_wrap \
            $FREESBIEISODIR/etc/
    
    echo `date` > $FREESBIEISODIR/etc/version.buildtime
    echo "" > $FREESBIEISODIR/etc/motd
    
    mkdir -p $FREESBIEISODIR/cf/conf/backup
    
    mkdir  $FREESBIEISODIR/dev 2>/dev/null
    rm -f $FREESBIEISODIR/etc/rc.d/freesbie_1st 2>/dev/null
    rm -rf $FREESBIEISODIR/cloop 2>/dev/null
    rm -rf $FREESBIEISODIR/dist 2>/dev/null
    rm -f $FREESBIEISODIR/etc/rc.local 2>/dev/null
    rm $FREESBIEISODIR/root/.tcshrc 2>/dev/null
    echo "alias installer /scripts/lua_installer" > $FREESBIEISODIR/root/.tcshrc
    rm $FREESBIEISODIR/root/.message* 2>/dev/null
    rm $FREESBIEISODIR/etc/rc.conf 2>/dev/null
    touch $FREESBIEISODIR/etc/rc.conf 2>/dev/null

    # Nuke the trigger wizard script
    rm -f $CVS_CO_DIR/trigger_initial_wizard
    
    # Prevent the system from asking for these twice
    touch $FREESBIEISODIR/root/.part_mount
    touch $FREESBIEISODIR/root/.first_time
    
    echo > $FREESBIEISODIR/etc/motd
    echo /etc/rc.initial > $FREESBIEISODIR/root/.shrc
    echo exit >> $FREESBIEISODIR/root/.shrc
    rm -f $FREESBIEISODIR/usr/local/bin/after_installation_routines.sh 2>/dev/null
    
    echo Calculating size of /usr/local/livefs...
    du -H -d0 /usr/local/livefs
    
    echo Running DD
    /bin/dd if=/dev/zero of=/tmp/image.bin bs=1k count=111072
    echo Running mdconfig
    /sbin/mdconfig -a -t vnode -u91 -f /tmp/image.bin
    #/sbin/disklabel -BR md91 /home/pfsense/pfSense/boot/label.proto_wrap
    /sbin/bsdlabel -BR md91 /home/pfsense/pfSense/boot/label.proto_wrap
    
    echo Running newfs
    newfs /dev/md91a
    newfs /dev/md91d
    
    echo -n "Mounting -> [ /tmp/root "
    mount /dev/md91a /tmp/root
    echo -n "/tmp/cf "
    mount /dev/md91d /tmp/cf
    echo "]"
    echo -n "Populating /tmp/root -> [ "
    echo -n "livefs "
    cd $FREESBIEBASEDIR/ && tar  czPf /home/pfsense/livefs.tgz .
    cd /tmp/root && tar xzPf  /home/pfsense/livefs.tgz
    echo -n "pfSense "
    cd /home/pfsense/pfSense && tar  czPf /home/pfsense/pfSense.tgz .
    cd /tmp/root && tar  xzPf /home/pfsense/pfSense.tgz
    echo "]"
    
    echo /dev/ad0a          /               ufs     ro              1 \
            1 > /tmp/root/etc/fstab
    echo /dev/ad0d          /cf             ufs     ro              1 \
            1 >> /tmp/root/etc/fstab
    echo md                 /tmp            mfs     rw,-s16m                1 \
            0 >> /tmp/root/etc/fstab
    
    rm -rf /tmp/root/var/run
    rm -rf /tmp/root/var/log
    rm -rf /tmp/root/var/etc
    rm -rf /tmp/root/var/tmp
    rm -rf /tmp/root/var/db
    
    # setup symlinks
    echo "#!/bin/sh" > /tmp/root/script
    echo "ln -s /tmp /var/tmp" >> /tmp/root/script
    echo "ln -s /tmp /var/run" >> /tmp/root/script
    echo "ln -s /tmp /var/etc" >> /tmp/root/script
    echo "ln -s /tmp /var/log" >> /tmp/root/script
    echo "ln -s /tmp /var/db"  >> /tmp/root/script
    echo "ln -s /cf/conf /conf" >> /tmp/root/script
    chmod a+x /tmp/root/script
    chroot /tmp/root/ /script
    
    mkdir -p /tmp/root/cf /tmp/root/usr/savecore
    
    rm -rf /home/pfsense/pfSense/cf/conf/CVS
    cp /home/pfsense/pfSense/cf/conf/* \
            /tmp/root/cf/conf/
    
    mkdir -p /tmp/cf/conf
    cp /home/pfsense/pfSense/cf/conf/* /tmp/cf/conf/
    
    echo -n "Config directory: "
    ls -lah /tmp/cf/conf
    
    echo "wrap" > /tmp/root/etc/platform
    
    /sbin/fsck -y /dev/md91a
    /sbin/fsck -y /dev/md91d

    echo -n "Unmounting: [ "
    echo -n "/tmp/root "
    cd /home/pfsense/tools && umount /tmp/root
    echo -n "/tmp/cf "
    cd /home/pfsense/tools && umount /tmp/cf
    echo -n "md "
    /sbin/mdconfig -d -u 91
    echo "]"
    
    echo gzipping image.bin
    cd /tmp/ && gzip -9 image.bin
    echo -n "Image size: "
    ls -lah /tmp/image.bin.gz
    
    echo Cleaning up /tmp/
    
    rm -rf /tmp/root
    rm -rf /tmp/cf/

    cd $CURRENT_WD

}

create_pfSense_Full_update_tarball() {
	mkdir -p $UPDATESDIR

        echo ; echo Creating ${UPDATESDIR}/${FILENAME} ...

        cd ${FREESBIEBASEDIR} && tar  czPf ${UPDATESDIR}/${FILENAME} .

	gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}

}

create_pfSense_Small_update_tarball() {
	VERSION=`cat $CVS_CO_DIR/etc/version`
	FILENAME=pfSense-Mini-Wrap-Update-${VERSION}.tgz

	mkdir -p $UPDATESDIR

	echo ; echo Creating ${UPDATESDIR}/${FILENAME} ...

	rm -rf ${CVS_CO_DIR}/usr/local/sbin ${CVS_CO_DIR}/usr/local/bin

	du -hd0 ${CVS_CO_DIR}
	
	cd ${CVS_CO_DIR} && tar czPf ${UPDATESDIR}/${FILENAME} .

	ls -lah ${UPDATESDIR}/${FILENAME}

	gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}

}

# Create tarball of pfSense cvs directory
create_pfSense_tarball() {
	cd $LOCALDIR

	rm -f $CVS_CO_DIR/boot/*

	find $CVS_CO_DIR -name CVS -exec rm -rf {} \; 2>/dev/null

	cd $CVS_CO_DIR && tar czPf /tmp/pfSense.tgz .
}

# Copy tarball of pfSense cvs directory to FreeSBIE custom directory
copy_pfSense_tarball_to_custom_directory() {
	cd $LOCALDIR

	rm -rf $LOCALDIR/customroot/*

	tar  xzPf /tmp/pfSense.tgz -C $LOCALDIR/customroot/

	rm -f $LOCALDIR/customroot/boot/*
	rm -rf $LOCALDIR/customroot/cf/conf/config.xml
	rm -rf $LOCALDIR/customroot/conf/config.xml
	rm -rf $LOCALDIR/customroot/conf
	mkdir -p $LOCALDIR/customroot/conf
	
}

copy_pfSense_tarball_to_freesbiebasedir() {
	cd $LOCALDIR

	tar  xzPf /tmp/pfSense.tgz -C $FREESBIEBASEDIR
}

# Set image as a CDROM type image
set_image_as_cdrom() {
	cd $LOCALDIR

	echo cdrom > $CVS_CO_DIR/etc/platform
}

# Set image as a WRAP type image
set_image_as_wrap() {
	cd $LOCALDIR

        echo wrap > $CVS_CO_DIR/etc/platform
}

#Create a copy of FREESBIEBASEDIR. This is useful to modify the live filesystem
clone_system_only()
{
  echo -n "Cloning $FREESBIEBASEDIR to $FREESBIEISODIR..."

  mkdir -p $FREESBIEISODIR || print_error
  if [ -r $FREESBIEISODIR ]; then
        chflags -R noschg $FREESBIEISODIR || print_error
        rm -rf $FREESBIEISODIR/* || print_error
  fi

  #We are making files containing /usr and /var partition

  #Before uzip'ing filesystems, we have to save the directories tree
  mkdir -p $FREESBIEISODIR/dist
  mtree -Pcdp $FREESBIEBASEDIR/usr > $FREESBIEISODIR/dist/FreeSBIE.usr.dirs
  mtree -Pcdp $FREESBIEBASEDIR/var > $FREESBIEISODIR/dist/FreeSBIE.var.dirs

  #Define a function to create the vnode $1 of the size expected for
  #$FREESBIEBASEDIR/$2 directory, mount it under $FREESBIEISODIR/$2
  #and print the md device
  create_vnode() {
      UFSFILE=$1
      CLONEDIR=$FREESBIEBASEDIR/$2
      MOUNTPOINT=$FREESBIEISODIR/$2
      cd $CLONEDIR
      FSSIZE=$((`du -kd 0 | cut -f 1` + 94000))
      dd if=/dev/zero of=$UFSFILE bs=1k count=$FSSIZE > /dev/null 2>&1

      DEVICE=/dev/`mdconfig -a -t vnode -f $UFSFILE`
      newfs $DEVICE > /dev/null 2>&1
      mkdir -p $MOUNTPOINT
      mount -o noatime ${DEVICE} $MOUNTPOINT
      echo ${DEVICE}
  }

  #Umount and detach md devices passed as parameters
  umount_devices() {
      for i in $@; do
          umount ${i}
          mdconfig -d -u ${i}
      done
  }

  mkdir -p $FREESBIEISODIR/uzip
  MDDEVICES=`create_vnode $FREESBIEISODIR/uzip/usr.ufs usr`
  MDDEVICES="$MDDEVICES `create_vnode $FREESBIEISODIR/uzip/var.ufs var`"

  trap "umount_devices $MDDEVICES; exit 1" INT

  cd $FREESBIEBASEDIR

  find . -print -depth | cpio --quiet -pudm $FREESBIEISODIR

  umount_devices $MDDEVICES

  trap "" INT

  echo " [DONE]"
}

checkout_pfSense() {
        echo ">>> Getting pfSense"
        rm -rf $CVS_CO_DIR
	cd $BASE_DIR && cvs -d /home/pfsense/cvsroot co pfSense -r RELENG_1
}

checkout_freesbie() {
        echo ">>> Getting FreeSBIE"
        rm -rf $LOCALDIR
}

print_flags() {
        if [ $BE_VERBOSE = "yes" ]
        then
                echo "Current flags:"
                printf "\tbuilder.sh\n"
                printf "\t\tCVS User: %s\n" $CVS_USER
                printf "\t\tVerbosity: %s\n" $BE_VERBOSE
                printf "\t\tTargets:%s\n" "$TARGETS"
                printf "\tconfig.sh\n"
                printf "\t\tLiveFS dir: %s\n" $FREESBIEBASEDIR
                printf "\t\tFreeSBIE dir: %s\n" $LOCALDIR
                printf "\t\tISO dir: %s\n" $PATHISO
                printf "\tpfsense_local.sh\n"
                printf "\t\tBase dir: %s\n" $BASE_DIR
                printf "\t\tCheckout dir: %s\n\n" $CVS_CO_DIR
        fi
}

clear_custom() {
        echo ">> Clearing custom/*"
        rm -rf $LOCALDIR/customroot/*
}

backup_pfSense() {
        echo ">>> Backing up pfSense repo"
        cp -R $CVS_CO_DIR $BASE_DIR/pfSense_bak
}

restore_pfSense() {
        echo ">>> Restoring pfSense repo"
        cp -R $BASE_DIR/pfSense_bak $CVS_CO_DIR
}
