#!/bin/sh
#
# Common functions to be used by build scripts
#
# $Id$

# Fixup needed library changes above and beyond current release version if needed
fixup_libmap() {
	
}

# This routine builds all kernels during the 
# build_iso.sh routines.
build_all_kernels() {
	# Build extra kernels (embedded, developers edition, etc)
	mkdir -p /tmp/kernels/wrap/boot/kernel
	mkdir -p /tmp/kernels/developers/boot/kernel
	mkdir -p /tmp/kernels/SMP/boot/kernel
	mkdir -p $PFSENSEBASEDIR/boot/kernel
	# Kernel will not install without these files
	echo -n ">>> Populating"
	echo -n " wrap"
	cp -R /boot/* /tmp/kernels/wrap/boot/
	echo -n " developers"
	cp -R /boot/* /tmp/kernels/developers/boot/
	echo -n " SMP"
	cp -R /boot/* /tmp/kernels/SMP/boot/
	find /tmp/kernels/ -name kernel.gz -exec rm {} \;
	# Copy pfSense kernel configuration files over to /usr/src/sys/i386/conf
	cp $BASE_DIR/tools/builder_scripts/conf/pfSense* /usr/src/sys/i386/conf/
	cp $BASE_DIR/tools/builder_scripts/conf/pfSense.6 /usr/src/sys/i386/conf/pfSense_SMP.6
	cp $BASE_DIR/tools/builder_scripts/conf/pfSense.7 /usr/src/sys/i386/conf/pfSense_SMP.7
	echo "" >> /usr/src/sys/i386/conf/pfSense_SMP.6
	echo "" >> /usr/src/sys/i386/conf/pfSense_SMP.7
	# Add SMP and APIC options
	echo "options 		SMP"   >> /usr/src/sys/i386/conf/pfSense_SMP.6
	echo "options 		SMP"   >> /usr/src/sys/i386/conf/pfSense_SMP.7
	echo "device		apic"" >> /usr/src/sys/i386/conf/pfSense_SMP.6
	echo "device		apic"" >> /usr/src/sys/i386/conf/pfSense_SMP.7
	# Build embedded kernel
	echo ">>> Building embedded kernel..."
	(cd /usr/src && make buildkernel NO_KERNELCLEAN=yo KERNCONF=pfSense_wrap.$pfSense_version) 
	(cd /usr/src && make installkernel KERNCONF=pfSense_wrap.$pfSense_version DESTDIR=/tmp/kernels/wrap/)
	# Build SMP kernel
	echo ">>> Building SMP kernel..."
	(cd /usr/src && make buildkernel NO_KERNELCLEAN=yo KERNCONF=pfSense_SMP.$pfSense_version) 
	(cd /usr/src && make installkernel KERNCONF=pfSense_SMP.$pfSense_version DESTDIR=/tmp/kernels/SMP/) 
	# Build Developers kernel
	echo ">>> Building Developers kernel..."
	(cd /usr/src && make buildkernel NO_KERNELCLEAN=yo KERNCONF=pfSense_Dev.$pfSense_version) 
	(cd /usr/src && make installkernel KERNCONF=pfSense_Dev.$pfSense_version DESTDIR=/tmp/kernels/developers/)
	# GZIP kernels and make smaller
	echo -n ">>> GZipping: embedded"
	(cd /tmp/kernels/wrap/boot/kernel/ && gzip kernel)
	echo -n " SMP"
	(cd /tmp/kernels/SMP/boot/kernel/ && gzip kernel)
	echo -n " developers"
	(cd /tmp/kernels/developers/boot/kernel/ && gzip kernel)
	echo -n " ."
	# Move files into place
	mkdir -p $PFSENSEBASEDIR/kernels
	cp /tmp/kernels/wrap/boot/kernel/kernel.gz $PFSENSEBASEDIR/kernels/kernel_wrap.gz
	echo -n "."
	cp /tmp/kernels/SMP/boot/kernel/kernel.gz $PFSENSEBASEDIR/kernels/kernel_SMP.gz
	echo -n "."
	cp /tmp/kernels/developers/boot/kernel/kernel.gz $PFSENSEBASEDIR/kernels/kernel_Dev.gz
	echo "."
	rm -rf /tmp/kernels
}

recompile_pfPorts() {
	if [ "$pfSense_version" = "7" ]; then
		if [ "$PFSENSETAG" = "HEAD" ]; then
			if [ -f /etc/make.conf ]; then
				mv /etc/make.conf /tmp/
			fi
			export FORCE_PKG_REGISTER=yo
	        pfSDESTINATIONDIR=/usr/local
	        pfSPORTS_BASE_DIR=/home/pfsense/tools
	        mkdir -p $pfSDESTINATIONDIR
	        mkdir -p $pfSDESTINATIONDIR/usr
	        mkdir -p $pfSDESTINATIONDIR/var
	        mkdir -p $pfSDESTINATIONDIR/root
	        mkdir -p $pfSDESTINATIONDIR/usr/local
	        mtree -PUer -q -p $pfSDESTINATIONDIR/usr < /etc/mtree/BSD.usr.dist
	        mtree -PUer -q -p $pfSDESTINATIONDIR/var/ < /etc/mtree/BSD.var.dist
	        mtree -PUer -q -p $pfSDESTINATIONDIR/root/ < /etc/mtree/BSD.root.dist
			mkdir -p $pfSDESTINATIONDIR/usr/local
	        mtree -PUer -q -p $pfSDESTINATIONDIR/usr/local < /etc/mtree/BSD.local.dist		
	        rm /home/pfsense/tools/pfPorts/isc-dhcp3-server/files/patch-server::dhcpd.c
	        export FORCE_PKG_REGISTER=yo
			echo "===> Compiling pfPorts..."
			echo "===> Setting pfPorts to HEAD pfPorts..."
			for pfSPORT in $INSTALL_PORTS_HEAD; do
                echo "===> Build Process for Compiling pfPorts ..."
                echo > /etc/make.conf
                COMPILE_STATIC=""
                for STATIC in $STATIC_INSTALL_PORTS; do
                        if [ "$STATIC" = "$pfSPORT" ]; then
                                echo 'CFLAGS="-static"' >  /etc/make.conf
                                echo "===> $STATIC is marked for static compilation..."
                        fi
				done
            echo "===> Operating on $pfSPORT..."
            (cd $pfSPORTS_BASE_DIR/$pfSPORT && make FORCE_PKG_REGISTER=yo BATCH=yo $COMPILE_STATIC)
            echo "===> Installing new port..."
            (cd $pfSPORTS_BASE_DIR/$pfSPORT && make install FORCE_PKG_REGISTER=yo BATCH=yo)
        done # HEAD Tag Check
	elif # pfSense_version check
	if [ "$PFSENSETAG" = "RELENG_1" ]; then
		echo "===> Setting pfPorts to RELENG_1 pfPorts..."
        for pfSPORT in $INSTALL_PORTS; do
		echo "===> Build Process for Compiling pfPorts ..."
        	echo > /etc/make.conf
        	COMPILE_STATIC=""
        	for STATIC in $STATIC_INSTALL_PORTS; do
        		if [ "$STATIC" = "$pfSPORT" ]; then
        			echo 'CFLAGS="-static"' >  /etc/make.conf
        			echo "===> $STATIC is marked for static compilation..."
        		fi
        	done
            echo "===> Operating on $pfSPORT..."
            (cd $pfSPORTS_BASE_DIR/$pfSPORT && make FORCE_PKG_REGISTER=yo BATCH=yo $COMPILE_STATIC)
            echo "===> Installing new port..."
            (cd $pfSPORTS_BASE_DIR/$pfSPORT && make install FORCE_PKG_REGISTER=yo BATCH=yo)
        done
        chflags -R noschg $pfSDESTINATIONDIR
        echo "===> End of pfPorts..."
        if [ -f /tmp/make.conf ]; then
        	mv /tmp/make.conf /etc/
        fi
	fi
	then
fi
fi
}
# Copies all extra files to the CVS staging area and ISO staging area (as needed)
populate_extra() {
    # Make devd
    ( cd ${SRCDIR}/sbin/devd; export __MAKE_CONF=${MAKE_CONF} NO_MAN=YES \
	make clean; make depend; make all; make DESTDIR=$CVS_CO_DIR install )

	mkdir -p ${CVS_CO_DIR}/lib

	if [ -f /usr/local/lib/libcurl.so.3 ]; then
		echo "Installing /usr/local/lib/libcurl.so.3"
		install -s /usr/local/lib/libcurl.so.3 ${CVS_CO_DIR}/usr/local/lib/
	fi

	if [ -f /usr/local/lib/libcurl.so.4 ]; then
		echo "Installing /usr/local/lib/libcurl.so.4"
		install -s /usr/local/lib/libcurl.so.4 ${CVS_CO_DIR}/usr/local/lib/
	fi

	if [ -f /usr/local/lib/libevent-1.2a.so ]; then
		echo "Installing /usr/local/lib/libevent-1.2a.so"
		install -s /usr/local/lib/libevent-1.2a.so ${CVS_CO_DIR}/usr/local/lib/
	fi

	if [ -f /usr/local/lib/libevent-1.2.so ]; then
		echo "Installing /usr/local/lib/libevent-1.2.so"
		install -s /usr/local/lib/libevent-1.2.so ${CVS_CO_DIR}/usr/local/lib/
	fi

	if [ -f /usr/local/lib/libevent-1.2.so.1 ]; then
		echo "Installing /usr/local/lib/libevent-1.2.so.1"	
		install -s /usr/local/lib/libevent-1.2.so.1 ${CVS_CO_DIR}/usr/local/lib/
	fi

	if [ -f /lib/libcrypto.so.4 ]; then
		echo "Installing /usr/local/lib/libcyrpto.so.4"
		install -s /lib/libcrypto.so.4 ${CVS_CO_DIR}/lib/
	fi

	if [ -f /lib/libcrypto.so.5 ]; then
		echo "Installing /lib/libcrypto.so.5"
		install -s /lib/libcrypto.so.5 ${CVS_CO_DIR}/lib/
	fi

	if [ -f /lib/libc.so.6 ]; then
		echo "Installing /lib/libc.so.6"
		install -s /lib/libc.so.6 ${CVS_CO_DIR}/lib/
	fi

	echo "Installing /usr/local/lib/libpcre.so.0"
    install -s /usr/local/lib/libpcre.so.0 ${CVS_CO_DIR}/usr/local/lib/

    mkdir -p $CVS_CO_DIR/var/run

    mkdir -p $CVS_CO_DIR/root/
    echo exit > $CVS_CO_DIR/root/.xcustom.sh
    touch $CVS_CO_DIR/root/.hushlogin

    # bsnmpd
    mkdir -p $CVS_CO_DIR/usr/share/snmp/defs/
    cp -R /usr/share/snmp/defs/ $CVS_CO_DIR/usr/share/snmp/defs/

    # Add lua installer items
    mkdir -p $CVS_CO_DIR/usr/local/share/dfuibe_lua/

    # This is now ready for general consumption! \o/
    mkdir -p $CVS_CO_DIR/usr/local/share/dfuibe_lua/conf/
    cp -r $BASE_DIR/tools/installer/conf $CVS_CO_DIR/usr/local/share/dfuibe_lua/
    cp -r $BASE_DIR/tools/installer/installer_root_dir $CVS_CO_DIR/usr/local/share/dfuibe_lua/install/

    # Set buildtime
    date > $CVS_CO_DIR/etc/version.buildtime
    mkdir -p $CVS_CO_DIR/scripts/
    mkdir -p $CVS_CO_DIR/conf
    cp $BASE_DIR/tools/pfi $CVS_CO_DIR/scripts/
    cp $BASE_DIR/tools/dev_bootstrap.sh $CVS_CO_DIR/scripts/
    cp $BASE_DIR/tools/lua_installer $CVS_CO_DIR/scripts/
    cp $BASE_DIR/tools/lua_installer $CVS_CO_DIR/scripts/installer
    chmod a+rx $CVS_CO_DIR/scripts/*

    mkdir -p $CVS_CO_DIR/usr/local/bin/

    cp $BASE_DIR/tools/after_installation_routines.sh \
	$CVS_CO_DIR/usr/local/bin/after_installation_routines.sh

    chmod a+rx $CVS_CO_DIR/scripts/*

    # Copy BSD Installer sources manifest
    mkdir -p $CVS_CO_DIR/usr/local/share/dfuibe_installer/

    # Make sure we're not running any x mojo
    mkdir -p $CVS_CO_DIR/root

    # Suppress extra spam when logging in
    touch $CVS_CO_DIR/root/.hushlogin

    # Setup login environment
    echo > $CVS_CO_DIR/root/.shrc
    echo "/etc/rc.initial" >> $CVS_CO_DIR/root/.shrc
    echo "exit" >> $CVS_CO_DIR/root/.shrc
    echo "/etc/rc.initial" >> $CVS_CO_DIR/root/.profile
    echo "exit" >> $CVS_CO_DIR/root/.profile

    # Trigger the pfSense wizzard
    echo "true" > $CVS_CO_DIR/trigger_initial_wizard

    # Nuke CVS dirs
    set +e
    find $CVS_CO_DIR -type d -name CVS -exec rm -rf {} \; 2> /dev/null
    find $CVS_CO_DIR -type d -name "_orange-flow" -exec rm -rf {} \; 2> /dev/null
    set -e

	if [ $pfSense_version = "7" ]; then
	    if [ ! -f /usr/src/usr.sbin/syslogd_patched ]; then
	    	echo "===> Patching syslogd..."
	    	(cd /usr/src/usr.sbin/syslogd && patch < $BASE_DIR/tools/patches/RELENG_6_1/syslogd.c.diff)
	    	touch /usr/src/usr.sbin/syslogd_patched        	
	    fi
	    echo "===> Building syslogd..."
	    (cd /usr/src/usr.sbin/syslogd && make clean && make && make install)
	    echo "===> Installing syslogd to $CVS_CO_DIR/usr/sbin/..."
	    install /usr/sbin/syslogd $CVS_CO_DIR/usr/sbin/
		echo "===> Building clog..."
		(cd /usr/src/usr.sbin/clog && make clean && make && make install)
	    echo "===> Installing clog to $CVS_CO_DIR/usr/sbin/..."
	    install /usr/sbin/clog $CVS_CO_DIR/usr/sbin/

		# Populate newer binaries if they exist from host
		FOUND_FILES=`(cd ${CVS_CO_DIR} && find usr/local -type f)`
		NEEDEDLIBS="`ldd /usr/sbin/syslogd | grep "=>" | awk '{ print $3 }'`"
		NEEDEDLIBS="`ldd /usr/local/sbin/dfuife_curses | grep "=>" | awk '{ print $3 }'`"

		for TEMPFILE in $FOUND_FILES; do
			if [ -f /$TEMPFILE ]; then 
				echo "**** cp /$TEMPFILE ${CVS_CO_DIR}/$TEMPFILE"
				cp /$TEMPFILE ${CVS_CO_DIR}/$TEMPFILE
				NEEDEDLIBS="$NEEDEDLIBS `ldd /$TEMPFILE | grep "=>" | awk '{ print $3 }'`"
			fi
		done
		NEEDEDLIBS="$NEEDEDLIBS `ldd /usr/sbin/clog | grep "=>" | awk '{ print $3 }'`"
		for NEEDLIB in $NEEDEDLIBS; do
			echo ">>>> Installing $NEEDLIB..."
			install $NEEDLIB ${CVS_CO_DIR}/lib/
		done	
	fi

	# Extract custom overlay if it's defined.
	if [ ! -z "${custom_overlay:-}" ]; then
		echo -n "Custom overlay defined - "
                if [ -d $custom_overlay ]; then
                        echo "found directory, copying..."
                        for i in $custom_overlay/*
                        do
                            if [ -d $i ]; then
                                echo "copying dir: $i ..."
                                cp -R $i $CVS_CO_DIR
                            else
                                echo "copying file: $i ..."
                                cp $i $CVS_CO_DIR
                            fi
                        done
		elif [ -f $custom_overlay ]; then
			echo "found file, extracting..."
			tar xzpf $custom_overlay -C $CVS_CO_DIR
		else
			echo " file not found $custom_overlay"
		fi
	fi
	
#	# Test for pfSense_version & PFSENSETAG on 7.X & HEAD
#	if [ $pfSense_version = "7" && PFSENSETAG = "-HEAD" ]; then
#	# Extract FreeBSD 7.x custom overlay if it's defined as HEAD.
#        if [ ! -z "${7_HEAD_custom_overlay:-}" ]; then
#                echo -n "FreeBSD 7.x HEAD Custom overlay defined - "
#                if [ -d $7_HEAD_custom_overlay ]; then
#                        echo "found directory, copying..."
#                        for i in $7_HEAD_custom_overlay/*
#                        do
#                            if [ -d $i ]; then
#                                echo "copying dir: $i ..."
#                                cp -R $i $CVS_CO_DIR
#                            else
#                                echo "copying file: $i ..."
#                                cp $i $CVS_CO_DIR
#                            fi
#                        done
#                elif [ -f $7_HEAD_custom_overlay ]; then
#                        echo "found file, extracting..."
#                        tar xzpf $7_HEAD_custom_overlay -C $CVS_CO_DIR
#                else
#                        echo " file not found $7_HEAD_custom_overlay"
#                fi
#        fi
#            fi

	fixup_libmap

    # Enable debug if requested
    if [ ! -z "${PFSENSE_DEBUG:-}" ]; then
		touch ${CVS_CO_DIR}/debugging
    fi
}

install_custom_packages() {
	# Extra package list if defined.
	if [ ! -z "${custom_package_list:-}" ]; then
		cp ./pfs_pkginstall.sh ${FREESBIE_PATH}/scripts/custom && \
		chmod a+x ${FREESBIE_PATH}/scripts/custom/pfs_pkginstall.sh
	else
		if [ -f ${FREESBIE_PATH}/scripts/custom/pfs_pkginstall.sh ]; then
			rm ${FREESBIE_PATH}/scripts/custom/pfs_pkginstall.sh
		fi
	fi
}

create_pfSense_BaseSystem_Small_update_tarball() {
	VERSION=`cat $CVS_CO_DIR/etc/version`
	FILENAME=pfSense-Mini-Embedded-BaseSystem-Update-${VERSION}.tgz

	mkdir -p $UPDATESDIR

	echo ; echo Creating ${UPDATESDIR}/${FILENAME} ...

	cp ${CVS_CO_DIR}/usr/local/sbin/check_reload_status /tmp/
	cp ${CVS_CO_DIR}/usr/local/sbin/mpd /tmp/

	rm -rf ${CVS_CO_DIR}/usr/local/sbin/*
	rm -rf ${CVS_CO_DIR}/usr/local/bin/*
	install -s /tmp/check_reload_status ${CVS_CO_DIR}/usr/local/sbin/check_reload_status
	install -s /tmp/mpd ${CVS_CO_DIR}/usr/local/sbin/mpd

	du -hd0 ${CVS_CO_DIR}

	rm -f ${CVS_CO_DIR}/etc/platform
	rm -f ${CVS_CO_DIR}/etc/*passwd*
	rm -f ${CVS_CO_DIR}/etc/pw*
	rm -f ${CVS_CO_DIR}/etc/ttys

	# Nuke /root/ directory contents
	rm -rf ${CVS_CO_DIR}/root

	cd ${CVS_CO_DIR} && tar czPf ${UPDATESDIR}/${FILENAME} .

	ls -lah ${UPDATESDIR}/${FILENAME}

	gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}
}

fixup_updates() {

	cd ${PFSENSEBASEDIR}
	rm -rf ${PFSENSEBASEDIR}/cf
	rm -rf ${PFSENSEBASEDIR}/conf
	find ${PFSENSEBASEDIR}/boot/ -type f -depth 1 -exec rm {} \;
	rm -rf ${PFSENSEBASEDIR}/etc/rc.conf
	rm -rf ${PFSENSEBASEDIR}/etc/motd
	rm -rf ${PFSENSEBASEDIR}/trigger*
	echo Removing pfSense.tgz used by installer..
	find ${PFSENSEBASEDIR} -name pfSense.tgz -exec rm {} \;
	rm -f ${PFSENSEBASEDIR}/etc/pwd.db 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/etc/group 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/etc/spwd.db 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/etc/passwd 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/etc/master.passwd 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/etc/fstab 2>/dev/null
	#rm -f ${PFSENSEBASEDIR}/etc/ttys 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/etc/platform 2>/dev/null
	echo > ${PFSENSEBASEDIR}/root/.tcshrc
	echo "alias installer /scripts/lua_installer" > ${PFSENSEBASEDIR}/root/.tcshrc
	# Setup login environment
	echo > ${PFSENSEBASEDIR}/root/.shrc
	echo "/etc/rc.initial" >> ${PFSENSEBASEDIR}/root/.shrc
	echo "exit" >> ${PFSENSEBASEDIR}/root/.shrc

	# Nuke the trigger wizard script
	rm -f ${PFSENSEBASEDIR}/trigger_initial_wizard

	mkdir -p ${PFSENSEBASEDIR}/usr/local/livefs/lib/

	echo `date` > ${PFSENSEBASEDIR}/etc/version.buildtime
}

fixup_wrap() {

    cp $CVS_CO_DIR/boot/device.hints_wrap \
            $CVS_CO_DIR/boot/device.hints
    cp $CVS_CO_DIR/boot/loader.conf_wrap \
            $CVS_CO_DIR/boot/loader.conf
    cp $CVS_CO_DIR/etc/ttys_wrap \
            $CVS_CO_DIR/etc/ttys

    echo `date` > $CVS_CO_DIR/etc/version.buildtime
    echo "" > $CVS_CO_DIR/etc/motd

    mkdir -p $CVS_CO_DIR/cf/conf/backup

    # Nuke the trigger wizard script
    rm -f $CVS_CO_DIR/trigger_initial_wizard

    echo /etc/rc.initial > $CVS_CO_DIR/root/.shrc
    echo exit >> $CVS_CO_DIR/root/.shrc
    rm -f $CVS_CO_DIR/usr/local/bin/after_installation_routines.sh 2>/dev/null

    touch $CVS_CO_DIR/conf/trigger_initial_wizard

    echo "embedded" > $CVS_CO_DIR/etc/platform
    echo "wrap" > /boot/kernel/pfsense_kernel.txt

    rm -rf $CVS_CO_DIR/conf
    ln -s /cf/conf $CVS_CO_DIR/conf
}

create_FreeBSD_system_update() {
	VERSION="FreeBSD"
	FILENAME=pfSense-Embedded-Update-${VERSION}.tgz
	mkdir -p $UPDATESDIR

	cd ${CLONEDIR}
	# Remove some fat and or conflicting
	# freebsd files
	rm -rf etc/
	rm -rf var/
	rm -rf usr/share/
	rm -rf root/
	echo "Creating ${UPDATESDIR}/${FILENAME} update file..."
	tar czPf ${UPDATESDIR}/${FILENAME} .

	echo "Signing ${UPDATESDIR}/${FILENAME} update file..."
	gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}
}

create_pfSense_Full_update_tarball() {
	VERSION=`cat ${PFSENSEBASEDIR}/etc/version`
	FILENAME=pfSense-Full-And-Embedded-Update-${VERSION}.tgz
	mkdir -p $UPDATESDIR

	echo ; echo "Deleting files listed in ${PRUNE_LIST}"
	set +e
	(cd ${PFSENSEBASEDIR} && sed 's/^#.*//g' ${PRUNE_LIST} | xargs rm -rvf > /dev/null 2>&1)

	echo ; echo Creating ${UPDATESDIR}/${FILENAME} ...
	cd ${PFSENSEBASEDIR} && tar czPf ${UPDATESDIR}/${FILENAME} .

	echo "Signing ${UPDATESDIR}/${FILENAME} update file..."
	gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}
}

create_pfSense_Small_update_tarball() {
	VERSION=`cat $CVS_CO_DIR/etc/version`
	FILENAME=pfSense-Mini-Embedded-Update-${VERSION}.tgz

	mkdir -p $UPDATESDIR

	echo ; echo Creating ${UPDATESDIR}/${FILENAME} ...

	cp ${CVS_CO_DIR}/usr/local/sbin/check_reload_status /tmp/
	cp ${CVS_CO_DIR}/usr/local/sbin/mpd /tmp/

	rm -rf ${CVS_CO_DIR}/usr/local/sbin/*
	rm -rf ${CVS_CO_DIR}/usr/local/bin/*
	install -s /tmp/check_reload_status ${CVS_CO_DIR}/usr/local/sbin/check_reload_status
	install -s /tmp/mpd ${CVS_CO_DIR}/usr/local/sbin/mpd

	du -hd0 ${CVS_CO_DIR}

	rm -f ${CVS_CO_DIR}/etc/platform
	rm -f ${CVS_CO_DIR}/etc/*passwd*
	rm -f ${CVS_CO_DIR}/etc/pw*

	cd ${CVS_CO_DIR} && tar czPf ${UPDATESDIR}/${FILENAME} .

	ls -lah ${UPDATESDIR}/${FILENAME}

	gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}

}

# Create tarball of pfSense cvs directory
create_pfSense_tarball() {
	rm -f $CVS_CO_DIR/boot/*

	find $CVS_CO_DIR -name CVS -exec rm -rf {} \; 2>/dev/null
	find $CVS_CO_DIR -name "_orange-flow" -exec rm -rf {} \; 2>/dev/null

	cd $CVS_CO_DIR && tar czPf /tmp/pfSense.tgz .
}

# Copy tarball of pfSense cvs directory to FreeSBIE custom directory
copy_pfSense_tarball_to_custom_directory() {
	rm -rf $LOCALDIR/customroot/*

	tar  xzPf /tmp/pfSense.tgz -C $LOCALDIR/customroot/

	rm -f $LOCALDIR/customroot/boot/*
	rm -rf $LOCALDIR/customroot/cf/conf/config.xml
	rm -rf $LOCALDIR/customroot/conf/config.xml
	rm -rf $LOCALDIR/customroot/conf
	mkdir -p $LOCALDIR/customroot/conf

	mkdir -p $LOCALDIR/var/db/
	chroot $LOCALDIR /bin/ln -s /var/db/rrd /usr/local/www/rrd

	chroot $LOCALDIR/ cap_mkdb /etc/master.passwd

}

copy_pfSense_tarball_to_freesbiebasedir() {
	cd $LOCALDIR

	tar  xzPf /tmp/pfSense.tgz -C $FREESBIEBASEDIR
}

# Set image as a CDROM type image
set_image_as_cdrom() {
	touch $CVS_CO_DIR/conf/trigger_initial_wizard
	echo cdrom > $CVS_CO_DIR/etc/platform
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
	cd $BASE_DIR && cvs -d /home/pfsense/cvsroot co pfSense -r ${PFSENSETAG}
	fixup_libmap
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

freesbie_make() {
	(cd ${FREESBIE_PATH} && make $*)
}

update_cvs_depot() {
    # Update cvs depot. If SKIP_RSYNC is defined, skip the RSYNC update
    # and prompt if the operator would like to download cvs.tgz from pfsense.com.
    # If also SKIP_CHECKOUT is defined, don't update the tree at all
    if [ -z "${SKIP_RSYNC:-}" ]; then
		rm -rf $BASE_DIR/pfSense
		rsync -avz ${CVS_USER}@${CVS_IP}:/cvsroot /home/pfsense/
		(cd $BASE_DIR && cvs -d /home/pfsense/cvsroot co -r ${PFSENSETAG} pfSense)
		fixup_libmap
		else
		cvsup pfSense-supfile
		rm -rf pfSense
		rm -rf $BASE_DIR/pfSense
		(cd $BASE_DIR && cvs -d /home/pfsense/cvsroot co -r ${PFSENSETAG} pfSense)
		(cd $BASE_DIR/tools/ && cvs update -d)
		fixup_libmap
    fi
}

make_world_kernel() {
    # Check if the world and kernel are already built and set
    # the NO variables accordingly
    objdir=${MAKEOBJDIRPREFIX:-/usr/obj}
    build_id_w=`basename ${KERNELCONF}`
    build_id_k=${build_id_w}

    # If PFSENSE_DEBUG is set, build debug kernel, if a .DEBUG kernel
    # configuration file exists
    if [ ! -z "${PFSENSE_DEBUG:-}" -a -f ${KERNELCONF}.DEBUG ]; then
	# Yes, use it
	export KERNELCONF=${KERNELCONF}.DEBUG
	build_id_k=${build_id_w}.DEBUG
    fi

    if [ -f "${objdir}/${build_id_w}.world.done" ]; then
	export NO_BUILDWORLD=yo
    fi
    if [ -f "${objdir}/${build_id_k}.kernel.done" ]; then
	export NO_BUILDKERNEL=yo
    fi

    # Make world
    freesbie_make buildworld
    touch ${objdir}/${build_id_w}.world.done

    # Make kernel
    freesbie_make buildkernel
    touch ${objdir}/${build_id_k}.kernel.done

    freesbie_make installkernel installworld
}
