#!/bin/sh
#
# Common functions to be used by build scripts
#
# $Id$

# Copies all extra files to the CVS staging area and ISO staging area (as needed)
populate_extra() {
    # Make devd
    ( cd ${SRCDIR}/sbin/devd; export __MAKE_CONF=${MAKE_CONF} \
	make clean; make depend; make all; make DESTDIR=$CVS_CO_DIR install )

    cp /usr/local/lib/libcurl.so.3 $CVS_CO_DIR/usr/local/lib/
    cp /usr/local/lib/libpcre.so.0 $CVS_CO_DIR/usr/local/lib/
    cp /usr/local/lib/libevent-1.1a.so.1 ${CVS_CO_DIR}/usr/local/lib/

    mkdir -p $CVS_CO_DIR/var/run

    mkdir -p $CVS_CO_DIR/root/
    echo exit > $CVS_CO_DIR/root/.xcustom.sh
    touch $CVS_CO_DIR/root/.hushlogin

    # bsnmpd
    mkdir -p $CVS_CO_DIR/usr/share/snmp/defs/
    cp -R /usr/share/snmp/defs/ $CVS_CO_DIR/usr/share/snmp/defs/

    # Add lua installer items
    mkdir -p $CVS_CO_DIR/usr/local/share/dfuibe_lua/
    cp -r $BASE_DIR/tools/installer/conf $CVS_CO_DIR/usr/local/share/dfuibe_lua/
    cp -r $BASE_DIR/tools/installer/installer_root_dir $CVS_CO_DIR/usr/local/share/dfuibe_lua/install

    # Set buildtime
    date > $CVS_CO_DIR/etc/version.buildtime
    mkdir -p $CVS_CO_DIR/scripts/
    mkdir -p $CVS_CO_DIR/conf
    cp $BASE_DIR/tools/pfi $CVS_CO_DIR/scripts/
    cp $BASE_DIR/tools/lua_installer $CVS_CO_DIR/scripts/
    cp $BASE_DIR/tools/lua_installer $CVS_CO_DIR/scripts/installer
    cp $BASE_DIR/tools/installer.sh $CVS_CO_DIR/scripts/
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
    set -e

    # Enable debug if requested
    if [ ! -z "${PFSENSE_DEBUG:-}" ]; then
	touch ${CVS_CO_DIR}/debugging
    fi
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
	rm -f ${PFSENSEBASEDIR}/etc/ttys 2>/dev/null
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

        cp /usr/local/lib/libevent-1.1a.so.1 ${PFSENSEBASEDIR}/usr/local/lib/

	echo `date` > ${PFSENSEBASEDIR}/etc/version.buildtime
}

fixup_wrap() {

    mv $CVS_CO_DIR/boot/device.hints_wrap \
            $CVS_CO_DIR/boot/device.hints
    mv $CVS_CO_DIR/boot/loader.conf_wrap \
            $CVS_CO_DIR/boot/loader.conf
    mv $CVS_CO_DIR/etc/ttys_wrap \
            $CVS_CO_DIR/etc/ttys

    rm ${CVS_CO_DIR}/boot/label.proto_wrap 
    
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

    rm -rf $CVS_CO_DIR/conf
    ln -s /cf/conf $CVS_CO_DIR/conf
}

create_pfSense_Full_update_tarball() {
	VERSION=`cat ${PFSENSEBASEDIR}/etc/version`
	FILENAME=pfSense-Full-Update-${VERSION}.tgz
	mkdir -p $UPDATESDIR

        echo ; echo Creating ${UPDATESDIR}/${FILENAME} ...

        cd ${PFSENSEBASEDIR} && tar  czPf ${UPDATESDIR}/${FILENAME} .

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
	cp /tmp/check_reload_status ${CVS_CO_DIR}/usr/local/sbin/check_reload_status
	cp /tmp/mpd ${CVS_CO_DIR}/usr/local/sbin/mpd
	chmod a+rx ${CVS_CO_DIR}/usr/local/sbin/*

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
	rm -rf $BASE_DIR/pfSense
	(cd $BASE_DIR && cvs -d :ext:${CVS_USER}@${CVS_IP}:/cvsroot co -r ${PFSENSETAG} pfSense)	
    else
	echo "NOTE!  This option will download a 48+ megabyte file!"
        echo -n "Do you want to sync with pfSense.com cvs.tgz? [N/y]: "
        read ANSWER
        if [ "${ANSWER}" = "Y" -o "${ANSWER}" = "y" ]; then
		echo "Downloading from pfSense.com ... This may take a moment!"
		(cd $BASE_DIR && fetch -o $BASE_DIR/cvs.tgz http://www.pfsense.com/cvs.tgz)
		(cd $BASE_DIR && tar xzvpf cvs.tgz)
		(cd $BASE_DIR/tools && cvs update -d)
		(cd $BASE_DIR/pfSense && cvs update -d pfSense)
		(rm $BASE_DIR/cvs.tgz)
        fi
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

