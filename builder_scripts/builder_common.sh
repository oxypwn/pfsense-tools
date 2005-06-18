#!/bin/sh

# Copies all extra files to the CVS staging area and ISO staging area (as needed)
populate_extra() {
	cd $LOCALDIR

	mkdir -p $CVS_CO_DIR/libexec
	cp /libexec/ld-elf.so.1 $CVS_CO_DIR/libexec/ld-elf.so.1
	cp /lib/libedit* $CVS_CO_DIR/lib/
	cp /bin/sh $CVS_CO_DIR/bin/
	cp /lib/libncurses.so.5 $CVS_CO_DIR/lib/
	cp /lib/libc* $CVS_CO_DIR/lib/
	cp /bin/ln /bin/rm $CVS_CO_DIR/bin/
	mkdir -p $LOCALDIR/var/run
	echo "#!/bin/sh" > $CVS_CO_DIR/script
	echo ln -s /cf/conf /conf >> $CVS_CO_DIR/script
	echo ln -s /conf /cf/conf >> $CVS_CO_DIR/script
	echo ln -s /var/etc/hosts /etc/hosts >> $CVS_CO_DIR/script
	echo ln -s /lib/libm.so.3 /lib/libm.so.2 >> $CVS_CO_DIR/script
	cat $CVS_CO_DIR/script
	chmod a+x $CVS_CO_DIR/script
	chroot $CVS_CO_DIR/ /bin/sh /script

	echo exit > $CVS_CO_DIR/root/.xcustom.sh
	touch $CVS_CO_DIR/root/.hushlogin
	cp $CVS_CO_DIR/lib/libc.so.6 $CVS_CO_DIR/lib/libc.so.5
	cp $CVS_CO_DIR/lib/libc.so.6 $CVS_CO_DIR/lib/libc.so.4

	# bsnmpd
	mkdir -p $CVS_CO_DIR/usr/share/snmp/defs/
	cp -R /usr/share/snmp/defs/ $CVS_CO_DIR/usr/share/snmp/defs/

	# Set buildtime
	date > $CVS_CO_DIR/etc/version.buildtime

	# Nuke CVS dirs
	find $CVS_CO_DIR -type d -name CVS -exec rm -rf {}/* \;

	# Copy BSD Installer sources manifest
	cp $LOCALDIR/files/sources.conf \
		$FREESBIEBASEDIR/usr/local/share/dfuibe_installer/sources.conf

	# Update shells
	cp $LOCALDIR/files/shells $FREESBIEBASEDIR/etc/shells

	# Make sure we're not running any x mojo
	echo exit > $FREESBIEBASEDIR/root/.xcustom.sh

	# Supress extra spam when logging in
	touch $FREESBIEBASEDIR/root/.hushlogin

	# Copy libraries since some files are compiled with older libc
	cp $FREESBIEBASEDIR/lib/libc.so.6 $FREESBIEBASEDIR/lib/libc.so.5
	cp $FREESBIEBASEDIR/lib/libc.so.6 $FREESBIEBASEDIR/lib/libc.so.4

	cd /usr/src/sbin/pfctl && make && make install
	cd /usr/src/sbin/pflogd && make && make install
	cp /sbin/pf* $CVS_CO_DIR/sbin/
	chmod a+rx $CVS_CO_DIR/sbin/pf*

	cp $LOCALDIR/files/gettytab $CVS_CO_DIR/etc/
	mkdir -p $CVS_CO_DIR/usr/lib $CVS_CO_DIR/lib
	cp /usr/lib/libstdc* $CVS_CO_DIR/usr/lib/
}

fixup_updates() {
	VERSION=`cat $CVS_CO_DIR/etc/version.buildtime`
	PRODUCTNAME=pfSense
	DSTISO=pfSense-$VERSION.iso
	FILENAME=${PRODUCTNAME}-Full-Update-${VERSION}.tgz

	cd ${FREESBIEBASEDIR}
	rm -rf ${FREESBIEBASEDIR}/conf*
	echo Removing pfSense.tgz used by installer..
	find . -name pfSense.tgz -exec rm {} \;
	rm ${FREESBIEBASEDIR}usr/local/www/trigger_initial_wizard 2>/dev/null
	rm ${FREESBIEBASEDIR}etc/master.passwd 2>/dev/null
	rm ${FREESBIEBASEDIR}etc/pwd.db 2>/dev/null
	rm ${FREESBIEBASEDIR}etc/spwd.db 2>/dev/null
	rm ${FREESBIEBASEDIR}etc/passwd 2>/dev/null
	rm ${FREESBIEBASEDIR}etc/fstab 2>/dev/null
	rm ${FREESBIEBASEDIR}etc/ttys 2>/dev/null
	rm ${FREESBIEBASEDIR}etc/fstab 2>/dev/null
	rm ${FREESBIEBASEDIR}boot/device.hints 2>/dev/null
	rm ${FREESBIEBASEDIR}boot/loader.conf 2>/dev/null
	rm ${FREESBIEBASEDIR}boot/loader.rc 2>/dev/null
	rm -rf ${FREESBIEBASEDIR}conf/ 2>/dev/null
	rm -rf ${FREESBIEBASEDIR}cf/ 2>/dev/null
	echo > ${FREESBIEBASEDIR}root/.tcshrc
	# Setup login environment
	echo > ${FREESBIEBASEDIR}root/.shrc
	echo "/etc/rc.initial" >> ${FREESBIEBASEDIR}root/.shrc
	echo "exit" >> ${FREESBIEBASEDIR}root/.shrc

	echo `date` > /usr/local/livefs/etc/version.buildtime

	echo ; echo Creating ${UPDATESDIR}/${FILENAME} ...
	cd ${FREESBIEBASEDIR} && tar czPf ${UPDATESDIR}/${FILENAME} .

}

# Create tarball of pfSense cvs directory
create_pfSense_tarball() {
	cd $LOCALDIR
	rm -rf $CVS_CO_DIR/boot/
	cd $CVS_CO_DIR && tar czPf /tmp/pfSense.tgz .
}

# Copy tarball of pfSense cvs directory to FreeSBIE custom directory
copy_pfSesne_tarball_to_custom_directory() {
	cd $LOCALDIR

	tar xzvPf /tmp/pfSense.tgz -C $LOCALDIR/files/custom/
}

copy__pfSesne_tarball_to_freesbiebasedir() {
	cd $LOCALDIR

	tar xzvPf /tmp/pfSense.tgz -C  $FREESBIEBASEDIR
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


