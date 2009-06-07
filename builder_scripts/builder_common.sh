#!/bin/sh
#
# Common functions to be used by build scripts
#
#  builder_common.sh
#  Copyright (C) 2004-2009 Scott Ullrich
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  
#  1. Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#  
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  
#  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
#  AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#  AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
#  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
#
# Crank up error reporting, debugging.
#  set -e 
#  set -x

# Set TARGET_ARCH_CONF_DIR
if [ "$TARGET_ARCH" = "" ]; then
	TARGET_ARCH_CONF_DIR=$SRCDIR/sys/i386/conf/
else
	TARGET_ARCH_CONF_DIR=$SRCDIR/sys/${TARGET_ARCH}/conf/
fi

fixup_libmap() {
	
}

print_error_pfS() {
	echo
	echo "####################################"
	echo "Something went wrong, check errors!" >&2
	echo "####################################"
	echo
    [ -n "${LOGFILE:-}" ] && \
        echo "Log saved on ${LOGFILE}" && \
	tail -n20 ${LOGFILE} >&2
	report_error
    sleep 999
    kill $$ # NOTE: exit 1 won't work.
}

# Removes NAT_T and other unneeded kernel options from 1.2 images.
fixup_kernel_options() {

	# Create area where kernels will be copied on LiveCD
	mkdir -p $PFSENSEBASEDIR/kernels/

	# Copy pfSense kernel configuration files over to $SRCDIR/sys/${TARGET_ARCH}/conf
	if [ "$TARGET_ARCH" = "" ]; then
		cp $BUILDER_TOOLS/builder_scripts/conf/pfSense* $SRCDIR/sys/i386/conf/
	else
		cp $BUILDER_TOOLS/builder_scripts/conf/pfSense* $SRCDIR/sys/${TARGET_ARCH}/conf/
	fi

	# Copy stock FreeBSD configurations
	cp $BUILDER_TOOLS/builder_scripts/conf/FreeBSD.* $SRCDIR/sys/i386/conf/
		
	# Build extra kernels (embedded, developers edition, etc)
	mkdir -p /tmp/kernels/wrap/boot/defaults
	mkdir -p /tmp/kernels/wrap/boot/kernel
	mkdir -p /tmp/kernels/developers/boot/kernel
	mkdir -p /tmp/kernels/freebsd/boot/kernel

	# Do not remove or move support to freesbie2/scripts/installekrnel.sh
	mkdir -p /tmp/kernels/SMP/boot/kernel
	mkdir -p /tmp/kernels/uniprocessor/boot/kernel
	mkdir -p /tmp/kernels/freebsd/boot/kernel

	# Do not remove or move support to freesbie2/scripts/installekrnel.sh
	mkdir -p /tmp/kernels/wrap/boot/defaults/
	mkdir -p /tmp/kernels/developers/boot/defaults/
	mkdir -p /tmp/kernels/SMP/boot/defaults/
	mkdir -p /tmp/kernels/uniprocessor/boot/defaults/
	mkdir -p /tmp/kernels/freebsd/boot/defaults/

	# Do not remove or move support to freesbie2/scripts/installekrnel.sh
	touch /tmp/kernels/wrap/boot/defaults/loader.conf
	touch /tmp/kernels/developers/boot/defaults/loader.conf
	touch  /tmp/kernels/SMP/boot/defaults/loader.conf
	touch  /tmp/kernels/uniprocessor/boot/defaults/loader.conf
	touch  /tmp/kernels/freebsd/boot/defaults/loader.conf

	# Do not remove or move support to freesbie2/scripts/installekrnel.sh
	mkdir -p $PFSENSEBASEDIR/boot/kernel
	
	if [ "$WITH_DTRACE" = "" ]; then
		echo ">>> Not adding D-Trace to Developers Kernel..."
	else
		echo "options KDTRACE_HOOKS" >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_Dev.8
		echo "options DDB_CTF" >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_Dev.8
	fi

	if [ "$TARGET_ARCH" = "" ]; then 
		# Copy pfSense kernel configuration files over to $SRCDIR/sys/i386/conf
		cp $BUILDER_TOOLS/builder_scripts/conf/pfSense* $SRCDIR/sys/i386/conf/
		cp $BUILDER_TOOLS/builder_scripts/conf/pfSense.6 $SRCDIR/sys/i386/conf/pfSense_SMP.6
		cp $BUILDER_TOOLS/builder_scripts/conf/pfSense.7 $SRCDIR/sys/i386/conf/pfSense_SMP.7
		cp $BUILDER_TOOLS/builder_scripts/conf/pfSense.8 $SRCDIR/sys/i386/conf/pfSense_SMP.8
		echo "" >> $SRCDIR/sys/i386/conf/pfSense_SMP.8
		echo "" >> $SRCDIR/sys/i386/conf/pfSense_SMP.6
		echo "" >> $SRCDIR/sys/i386/conf/pfSense_SMP.7
		if [ ! -f "$SRCDIR/sys/i386/conf/pfSense.7" ]; then
			echo ">>> Could not find $SRCDIR/sys/i386/conf/pfSense.7"
			print_error_pfS
		fi
	else
		cp $BUILDER_TOOLS/builder_scripts/conf/pfSense* $SRCDIR/sys/${TARGET_ARCH}/conf/
		cp $BUILDER_TOOLS/builder_scripts/conf/pfSense.6 $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.6
		cp $BUILDER_TOOLS/builder_scripts/conf/pfSense.7 $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.7
		cp $BUILDER_TOOLS/builder_scripts/conf/pfSense.8 $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.8
		echo "" >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.8
		echo "" >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.6
		echo "" >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.7	
		if [ ! -f "$SRCDIR/sys/${TARGET_ARCH}/conf/pfSense.7" ]; then
			echo ">>> Could not find $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense.7"
			print_error_pfS
		fi
	fi

	# Add SMP and APIC options
	echo "device 		apic" >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.8
	echo "options		ALTQ_NOPCC" >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.8
	echo "options 		SMP"   >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.8
	echo "device 		apic" >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_Dev.8
	echo "options		ALTQ_NOPCC" >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_Dev.8
	echo "options 		SMP"   >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_Dev.8
	echo "options 		SMP"   >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.7
	echo "options		ALTQ_NOPCC" >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.7
	echo "device 		apic" >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.7
	echo "device 		apic" >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.6
	echo "options		ALTQ_NOPCC" >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.6
	echo "options 		SMP"   >> $SRCDIR/sys/${TARGET_ARCH}/conf/pfSense_SMP.6

	# NOTE!  If you remove this, you WILL break booting!  These file(s) are read
	#        by FORTH and for some reason installkernel with DESTDIR does not
	#        copy this file over and you will end up with a blank file?
	cp $SRCDIR/sys/boot/forth/loader.conf /tmp/kernels/wrap/boot/defaults/
	cp $SRCDIR/sys/boot/forth/loader.conf /tmp/kernels/uniprocessor/boot/defaults/
	cp $SRCDIR/sys/boot/forth/loader.conf /tmp/kernels/SMP/boot/defaults/
	cp $SRCDIR/sys/boot/forth/loader.conf /tmp/kernels/developers/boot/defaults/
	#
	cp $SRCDIR/sys/i386/conf/GENERIC.hints /tmp/kernels/wrap/boot/device.hints
	cp $SRCDIR/sys/i386/conf/GENERIC.hints /tmp/kernels/uniprocessor/boot/device.hints
	cp $SRCDIR/sys/i386/conf/GENERIC.hints /tmp/kernels/SMP/boot/device.hints
	cp $SRCDIR/sys/i386/conf/GENERIC.hints /tmp/kernels/developers/boot/device.hints
	# END NOTE.

	# Danger will robinson -- 7.2+ will NOT boot if these files are not present.
	# the loader will stop at |
	touch /tmp/kernels/wrap/boot/loader.conf touch /tmp/kernels/wrap/boot/loader.conf.local
	touch /tmp/kernels/uniprocessor/boot/loader.conf touch /tmp/kernels/uniprocessor/boot/loader.conf.local
	touch /tmp/kernels/SMP/boot/loader.conf touch /tmp/kernels/SMP/boot/loader.conf.local
	touch /tmp/kernels/developers/boot/loader.conf touch /tmp/kernels/developers/boot/loader.conf.local
	# Danger, warning, achtung
	
}

build_embedded_kernel() {
	# Common fixup code
	fixup_kernel_options
	# Build embedded kernel
	echo ">>>> Building embedded kernel..."
	find $MAKEOBJDIRPREFIX -name ".*kernel*" -print | xargs rm -f
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF	
	export KERNCONF=pfSense_wrap.${FREEBSD_VERSION}
	export KERNEL_DESTDIR="/tmp/kernels/wrap"
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/pfSense_wrap.${FREEBSD_VERSION}"
	freesbie_make buildkernel
	echo ">>>> Installing embedded kernel..."
	freesbie_make installkernel
	cp $SRCDIR/sys/boot/forth/loader.conf /tmp/kernels/wrap/boot/defaults/
	cp $SRCDIR/sys/i386/conf/GENERIC.hints /tmp/kernels/developers/boot/device.hints	
	echo -n ">>>> Installing kernels to LiveCD area..."
	(cd /tmp/kernels/wrap/boot/ && tar czf $PFSENSEBASEDIR/kernels/kernel_wrap.gz .) 	
	echo -n "."
	chflags -R noschg $PFSENSEBASEDIR/boot/
	(cd $PFSENSEBASEDIR/boot/ && tar xzf $PFSENSEBASEDIR/kernels/kernel_wrap.gz -C $PFSENSEBASEDIR/boot/)
	echo "done."
}

build_dev_kernel() {
	# Common fixup code
	fixup_kernel_options
	# Build Developers kernel
	echo ">>>> Building Developers kernel..."
	find $MAKEOBJDIRPREFIX -name ".*kernel*" -print | xargs rm -f
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/pfSense_Dev.${FREEBSD_VERSION}"
	export KERNEL_DESTDIR="/tmp/kernels/developers"
	export KERNCONF=pfSense_Dev.${FREEBSD_VERSION}
	freesbie_make buildkernel
	echo ">>>> installing Developers kernel..."
	freesbie_make installkernel
	cp $SRCDIR/sys/boot/forth/loader.conf /tmp/kernels/developers/boot/defaults/
	cp $SRCDIR/sys/i386/conf/GENERIC.hints /tmp/kernels/developers/boot/device.hints	
	(cd /tmp/kernels/developers/boot/ && tar czf $PFSENSEBASEDIR/kernels/kernel_Dev.gz .)	
	(cd $PFSENSEBASEDIR/boot/ && tar xzf $PFSENSEBASEDIR/kernels/kernel_Dev.gz -C $PFSENSEBASEDIR/boot/)
}

build_freebsd_only_kernel() {
	# Common fixup code
	fixup_kernel_options
	# Build Developers kernel
	echo ">>>> Building Developers kernel..."
	find $MAKEOBJDIRPREFIX -name ".*kernel*" -print | xargs rm -f
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/FreeBSD.${FREEBSD_VERSION}"
	export KERNEL_DESTDIR="/tmp/kernels/freebsd"
	export KERNCONF=FreeBSD.${FREEBSD_VERSION}
	freesbie_make buildkernel
	echo ">>>> installing FreeBSD kernel..."
	freesbie_make installkernel
	cp $SRCDIR/sys/boot/forth/loader.conf /tmp/kernels/freebsd/boot/defaults/
	cp $SRCDIR/sys/i386/conf/GENERIC.hints /tmp/kernels/freebsd/boot/device.hints	
	(cd /tmp/kernels/freebsd/boot/ && tar czf $PFSENSEBASEDIR/kernels/FreeBSD.tgz .)	
	(cd $PFSENSEBASEDIR/boot/ && tar xzf $PFSENSEBASEDIR/kernels/FreeBSD.tgz -C $PFSENSEBASEDIR/boot/)
}

# This routine builds all kernels during the 
# build_iso.sh routines.
build_all_kernels() {

	# Common fixup code
	fixup_kernel_options
	# Build uniprocessor kernel
	echo ">>>> Building uniprocessor kernel..."
	find $MAKEOBJDIRPREFIX -name ".*kernel*" -print | xargs rm -f
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNCONF=pfSense.${FREEBSD_VERSION}
	export KERNEL_DESTDIR="/tmp/kernels/uniprocessor"
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/pfSense.${FREEBSD_VERSION}"
	freesbie_make buildkernel
	echo ">>>> installing uniprocessor kernel..."
	freesbie_make installkernel

	# Build embedded kernel
	echo ">>>> Building embedded kernel..."
	find $MAKEOBJDIRPREFIX -name ".*kernel*" -print | xargs rm -f
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNCONF=pfSense_wrap.${FREEBSD_VERSION}
	export KERNEL_DESTDIR="/tmp/kernels/wrap"
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/pfSense_wrap.${FREEBSD_VERSION}"
	freesbie_make buildkernel
	echo ">>>> installing wrap kernel..."
	freesbie_make installkernel

	# Build Developers kernel
	echo ">>>> Building Developers kernel..."
	find $MAKEOBJDIRPREFIX -name ".*kernel*" -print | xargs rm -f
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNCONF=pfSense_Dev.${FREEBSD_VERSION}
	export KERNEL_DESTDIR="/tmp/kernels/developers"
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/pfSense_Dev.${FREEBSD_VERSION}"	
	freesbie_make buildkernel
	echo ">>>> installing Developers kernel..."
	freesbie_make installkernel
	
	# Build SMP kernel
	echo ">>>> Building SMP kernel..."
	find $MAKEOBJDIRPREFIX -name ".*kernel*" -print | xargs rm -f
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNCONF=pfSense_SMP.${FREEBSD_VERSION}
	export KERNEL_DESTDIR="/tmp/kernels/SMP"
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/pfSense_SMP.${FREEBSD_VERSION}"
	freesbie_make buildkernel
	echo ">>>> installing SMP kernel..."
	freesbie_make installkernel

	# Nuke symbols
	echo -n ">>>> Cleaning up .symbols..."
    if [ -z "${PFSENSE_DEBUG:-}" ]; then
		echo -n "."
		find $PFSENSEBASEDIR/ -name "*.symbols" -exec rm -f {} \;
		echo -n "."
		find /tmp/kernels -name "*.symbols" -exec rm -f {} \;
    fi

	# Nuke old kernel if it exists
	find /tmp/kernels -name kernel.old -exec rm -rf {} \; 2>/dev/null
	echo "done."

	echo -n ">>>> Installing kernels to LiveCD area..."
	(cd /tmp/kernels/uniprocessor/boot/ && tar czf $PFSENSEBASEDIR/kernels/kernel_uniprocessor.gz .) 	
	echo -n "."
	(cd /tmp/kernels/wrap/boot/ && tar czf $PFSENSEBASEDIR/kernels/kernel_wrap.gz .) 	
	echo -n "."
	(cd /tmp/kernels/developers/boot/ && tar czf $PFSENSEBASEDIR/kernels/kernel_Dev.gz .)
	echo -n "."	
	(cd /tmp/kernels/SMP/boot/ && tar czf $PFSENSEBASEDIR/kernels/kernel_SMP.gz .)
	echo -n "."
	chflags -R noschg $PFSENSEBASEDIR/boot/
	echo -n "."	
	# Install DEV ISO kernel if we are building a dev iso
	if [ -z "${IS_DEV_ISO:-}" ]; then
		echo -n "DEF:SMP."
		(cd $PFSENSEBASEDIR/boot/ && tar xzf $PFSENSEBASEDIR/kernels/kernel_SMP.gz -C $PFSENSEBASEDIR/boot/)
	else 
		echo -n "DEF:DEV."
		(cd $PFSENSEBASEDIR/boot/ && tar xzf $PFSENSEBASEDIR/kernels/kernel_Dev.gz -C $PFSENSEBASEDIR/boot/)
	fi
	echo ".done"
	
}

recompile_pfPorts() {

	if [ ! -f /tmp/pfSense_do_not_build_pfPorts ]; then 

		# Set some neede variables
		pfSPORTS_COPY_BASE_DIR="$BUILDER_TOOLS/pfPorts"
		pfSPORTS_BASE_DIR="/usr/ports/pfPorts"
		if [ -n "$PFSPORTSFILE" ]; then
			USE_PORTS_FILE="${pfSPORTS_COPY_BASE_DIR}/${PFSPORTSFILE}"
		else 
			USE_PORTS_FILE="${pfSPORTS_COPY_BASE_DIR}/buildports.${PFSENSETAG}"
		fi
		PFPORTSBASENAME=`basename ${USE_PORTS_FILE}`
		
		# Warn user about make includes operation
		echo
		echo "===> Preparing for pfPorts build ${PFPORTSBASENAME}"
		echo
		echo "   NOTE!  If you are building a different version of pfSense it may"
		echo "          be necessary to rm -rf /var/db/pkg/* before running this script!"
		echo
		echo "WARNING!  We are about to run make includes."
		echo
		echo "             Press CTRl-C to abort this operation...."
		echo 
		sleep 5

		# Since we are using NAT-T we need to run this prior
		# to the build.  Once NAT-T is included in FreeBSD
		# we can remove this step. 
		echo "===> Starting make includes operation..."
		( cd $SRCDIR && make includes ) | egrep -wi '(^>>>|warning|error)'
		
		rm -rf ${pfSPORTS_BASE_DIR}
		mkdir ${pfSPORTS_BASE_DIR}
	
		echo "===> Compiling pfPorts..."
		if [ -f /etc/make.conf ]; then
			mv /etc/make.conf /tmp/
			echo "WITHOUT_X11=yo" >> /etc/make.conf
			echo "CFLAGS=-O2" >> /etc/make.conf
			MKCNF="pfPorts"
		fi
		export FORCE_PKG_REGISTER=yo

		chmod a+rx $USE_PORTS_FILE
		echo ">>>> Executing $PFPORTSBASENAME"
		( su - root -c "cd /usr/ports/ && ${USE_PORTS_FILE} ${MAKEJ_PORTS}" ) 2>&1 \
			| egrep -v '(\-Werror|ignored|error\.[a-z])' | egrep -wi "(^>>>|error|finding)"
		
		if [ "${MKCNF}x" = "pfPortsx" ]; then
			if [ -f /tmp/make.conf ]; then
				mv /tmp/make.conf /etc/
			fi
		fi

		echo "===> End of pfPorts..."
	
	else
		echo
		echo "/tmp/pfSense_do_not_build_pfPorts is set, skipping pfPorts build..."
		echo
	fi
}

cust_overlay_host_binaries() {
    echo "===> Building syslogd..."
    (cd $SRCDIR/usr.sbin/syslogd && make clean && make && make install)
    echo "===> Installing syslogd to $PFSENSEBASEDIR/usr/sbin/..."
    install /usr/sbin/syslogd $PFSENSEBASEDIR/usr/sbin/
	echo "===> Building clog..."
	(cd $SRCDIR/usr.sbin/clog && make clean && make && make install)
    echo "===> Installing clog to $PFSENSEBASEDIR/usr/sbin/..."
    install $SRCDIR/usr.sbin/clog/clog $PFSENSEBASEDIR/usr/sbin/
    install $SRCDIR/usr.sbin/sysllogd/syslogd $PFSENSEBASEDIR/usr/sbin/

	mkdir -p ${PFSENSEBASEDIR}/bin
	mkdir -p ${PFSENSEBASEDIR}/sbin
	mkdir -p ${PFSENSEBASEDIR}/usr/bin
	mkdir -p ${PFSENSEBASEDIR}/usr/sbin
	mkdir -p ${PFSENSEBASEDIR}/usr/lib
	mkdir -p ${PFSENSEBASEDIR}/usr/libexec
	mkdir -p ${PFSENSEBASEDIR}/usr/local/bin
	mkdir -p ${PFSENSEBASEDIR}/usr/local/sbin
	mkdir -p ${PFSENSEBASEDIR}/usr/local/lib
	mkdir -p ${PFSENSEBASEDIR}/usr/local/lib/mysql
	mkdir -p ${PFSENSEBASEDIR}/usr/local/libexec
	
	# Temporary hack for RELENG_1_2
	mkdir -p ${PFSENSEBASEDIR}/usr/local/lib/php/extensions/no-debug-non-zts-20020429/

	if [ ! -z "${CUSTOM_COPY_LIST:-}" ]; then
		echo ">>>> Using ${CUSTOM_COPY_LIST:-}..."
		FOUND_FILES=`cat ${CUSTOM_COPY_LIST:-}`
	else
		echo ">>>> Using copy.list.${PFSENSETAG}..."
		FOUND_FILES=`cat copy.list.${PFSENSETAG}`
	fi

	# Process base system libraries
	NEEDEDLIBS=""
	echo ">>>>> Populating newer binaries found on host jail/os (usr/local)..."
	for TEMPFILE in $FOUND_FILES; do
		echo "Looking for /${TEMPFILE} "
		if [ -f /${TEMPFILE} ]; then
			echo " Found $TEMPFILE"
			FILETYPE=`file /$TEMPFILE | egrep "(dynamically|shared)" | wc -l | awk '{ print $1 }'`
			if [ "$FILETYPE" -gt 0 ]; then
				NEEDEDLIBS="$NEEDEDLIBS `ldd /${TEMPFILE} | grep "=>" | awk '{ print $3 }'`"
				echo "cp /${TEMPFILE} ${PFSENSEBASEDIR}/$TEMPFILE"
				cp /${TEMPFILE} ${PFSENSEBASEDIR}/$TEMPFILE
				chmod a+rx ${PFSENSEBASEDIR}/${TEMPFILE}
				if [ -d $CLONEDIR ]; then
					echo "cp /$NEEDLIB ${PFSENSEBASEDIR}${NEEDLIB}"
					cp /$NEEDLIB ${PFSENSEBASEDIR}${NEEDLIB}
				fi
			else 
				echo "Binary does not contain libraries, copying..."
				cp /${TEMPFILE} ${PFSENSEBASEDIR}/$TEMPFILE
			fi
		else
			echo "Could not find ${TEMPFILE}"
			if [ -f ${CVS_CO_DIR}/${TEMPFILE} ]; then
				FILETYPE=`file ${CVS_CO_DIR}/${TEMPFILE} | grep dynamically | wc -l | awk '{ print $1 }'`
				if [ "$FILETYPE" -gt 0 ]; then
					NEEDEDLIBS="$NEEDEDLIBS `ldd ${CVS_CO_DIR}/${TEMPFILE} | grep "=>" | awk '{ print $3 }'`"									
				fi
			fi
		fi
	done		
	echo ">>>>> Installing collected library information (usr/local), please wait..."
	# Unique the libraries so we only copy them once
	NEEDEDLIBS=`for LIB in ${NEEDEDLIBS} ; do echo $LIB ; done |sort -u`
	for NEEDLIB in $NEEDEDLIBS; do
		if [ -f $NEEDLIB ]; then 
			echo "install $NEEDLIB ${PFSENSEBASEDIR}${NEEDLIB}"
			install $NEEDLIB ${PFSENSEBASEDIR}${NEEDLIB}
			if [ -d $CLONEDIR ]; then
				echo "install $NEEDLIB ${PFSENSEBASEDIR}${NEEDLIB}"
				install $NEEDLIB ${PFSENSEBASEDIR}${NEEDLIB}					
			fi
		fi
	done
	
}

report_zero_sized_files() {
	if [ -f $MAKEOBJDIRPREFIX/zero_sized_files.txt ]; then 
		cat $MAKEOBJDIRPREFIX/zero_sized_files.txt
		rm $MAKEOBJDIRPREFIX/zero_sized_files.txt
	fi
}

check_for_zero_size_files() {
	find $PFSENSEBASEDIR -perm -+x -type f -size 0 -exec echo "WARNING: {} is 0 sized" >> $MAKEOBJDIRPREFIX/zero_sized_files.txt \;
}

cust_populate_installer_bits_freebsd_only() {
    # Add lua installer items
    mkdir -p $PFSENSEBASEDIR/usr/local/share/dfuibe_lua/install/
	mkdir -p $PFSENSEBASEDIR/scripts/
    # This is now ready for general consumption! \o/
    mkdir -p $PFSENSEBASEDIR/usr/local/share/dfuibe_lua/conf/
    cp -r $BUILDER_TOOLS/installer/conf \
		$PFSENSEBASEDIR/usr/local/share/dfuibe_lua/
	# Copy installer launcher scripts
    cp $BUILDER_TOOLS/pfi $PFSENSEBASEDIR/etc/rc.d/
    cp $BUILDER_TOOLS/freebsd_installer $PFSENSEBASEDIR/scripts/
    chmod a+rx $PFSENSEBASEDIR/scripts/*
}

cust_populate_installer_bits() {
    # Add lua installer items
	echo "Using FreeBSD 7 BSDInstaller dfuibelua structure."
    mkdir -p $PFSENSEBASEDIR/usr/local/share/dfuibe_lua/install/
	mkdir -p $PFSENSEBASEDIR/scripts/
    # This is now ready for general consumption! \o/
    mkdir -p $PFSENSEBASEDIR/usr/local/share/dfuibe_lua/conf/
    cp -r $BUILDER_TOOLS/installer/conf \
		$PFSENSEBASEDIR/usr/local/share/dfuibe_lua/
	# 599_ belongs in installation directory
	cp $BUILDER_TOOLS/installer/installer_root_dir7/599* \
		$PFSENSEBASEDIR/usr/local/share/dfuibe_lua/install/
	# 300_ belongs in dfuibe_lua/
	cp $BUILDER_TOOLS/installer/installer_root_dir7/300* \
		$PFSENSEBASEDIR/usr/local/share/dfuibe_lua/
	# 500_ belongs in dfuibe_lua/
	cp $BUILDER_TOOLS/installer/installer_root_dir7/500* \
		$PFSENSEBASEDIR/usr/local/share/dfuibe_lua/
	# Copy Centipede Networks sponsored easy-install into place
	cp -r $BUILDER_TOOLS/installer/easy_install \
		$PFSENSEBASEDIR/usr/local/share/dfuibe_lua/
	# Copy Centipede Networks sponsored easy-install into place
	cp $BUILDER_TOOLS/installer/installer_root_dir7/150_easy_install.lua \
		$PFSENSEBASEDIR/usr/local/share/dfuibe_lua/
	# Override the base installers welcome and call the Install step "Custom Install"
	cp $BUILDER_TOOLS/installer/installer_root_dir7/200_install.lua \
		$PFSENSEBASEDIR/usr/local/share/dfuibe_lua/
	# Copy custom 950_reboot.lua script which touches /tmp/install_complete
	cp $BUILDER_TOOLS/installer/installer_root_dir7/950_reboot.lua \
		$PFSENSEBASEDIR/usr/local/share/dfuibe_lua/
	# Copy installer launcher scripts
    cp $BUILDER_TOOLS/pfi $PFSENSEBASEDIR/scripts/
    cp $BUILDER_TOOLS/lua_installer $PFSENSEBASEDIR/scripts/
    cp $BUILDER_TOOLS/freebsd_installer $PFSENSEBASEDIR/scripts/
    cp $BUILDER_TOOLS/lua_installer_rescue $PFSENSEBASEDIR/scripts/
    cp $BUILDER_TOOLS/lua_installer_rescue $PFSENSEBASEDIR/scripts/
    cp $BUILDER_TOOLS/lua_installer_full $PFSENSEBASEDIR/scripts/
    chmod a+rx $PFSENSEBASEDIR/scripts/*
    cp $BUILDER_TOOLS/after_installation_routines.sh \
		$PFSENSEBASEDIR/usr/local/bin/after_installation_routines.sh
    chmod a+rx $PFSENSEBASEDIR/scripts/*		
}

# Copies all extra files to the CVS staging area and ISO staging area (as needed)
cust_populate_extra() {
    # Make devd
    ( cd ${SRCDIR}/sbin/devd; export __SRCCONF=${SRC_CONF} SRCCONF=${SRC_CONF} NO_MAN=YES \
	make clean; make depend; make all; make DESTDIR=$PFSENSEBASEDIR install )

	mkdir -p ${CVS_CO_DIR}/lib

	if [ -f /usr/lib/pam_unix.so ]; then
		install -s /usr/lib/pam_unix.so ${PFSENSEBASEDIR}/usr/lib/
	fi
	
	STRUCTURE_TO_CREATE="var/run root scripts conf usr/local/share/dfuibe_installer root usr/local/bin usr/local/sbin usr/local/lib usr/local/etc usr/local/lib/php/20060613 usr/local/lib/lighttpd"
	
	for TEMPDIR in $STRUCTURE_TO_CREATE; do	
		mkdir -p ${CVS_CO_DIR}/${TEMPDIR}
		mkdir -p ${PFSENSEBASEDIR}/${TEMPDIR}
	done
	
    echo exit > $CVS_CO_DIR/root/.xcustom.sh
    touch $CVS_CO_DIR/root/.hushlogin

    # bsnmpd
    mkdir -p $CVS_CO_DIR/usr/share/snmp/defs/
    cp -R /usr/share/snmp/defs/ $CVS_CO_DIR/usr/share/snmp/defs/

    # Set buildtime
	mkdir -p $CVS_CO_DIR/etc
    date > $CVS_CO_DIR/etc/version.buildtime

    # Suppress extra spam when logging in
	mkdir -p $CVS_CO_DIR/root
    touch $CVS_CO_DIR/root/.hushlogin

    # Setup login environment
    echo > $CVS_CO_DIR/root/.shrc
    echo "/etc/rc.initial" >> $CVS_CO_DIR/root/.shrc
    echo "exit" >> $CVS_CO_DIR/root/.shrc
    echo "/etc/rc.initial" >> $CVS_CO_DIR/root/.profile
    echo "exit" >> $CVS_CO_DIR/root/.profile
	mkdir -p $PFSENSEBASEDIR/root
    echo > $PFSENSEBASEDIR/root/.shrc
    echo "/etc/rc.initial" >> $PFSENSEBASEDIR/root/.shrc
    echo "exit" >> $PFSENSEBASEDIR/root/.shrc
    echo "/etc/rc.initial" >> $PFSENSEBASEDIR/root/.profile
    echo "exit" >> $PFSENSEBASEDIR/root/.profile

	# Turn off error checking
    set +e

    # Nuke CVS dirs
    find $CVS_CO_DIR -type d -name CVS -exec rm -rf {} \; 2> /dev/null
    find $CVS_CO_DIR -type d -name "_orange-flow" -exec rm -rf {} \; 2> /dev/null

	install_custom_overlay
	
    # Enable debug if requested
    if [ ! -z "${PFSENSE_DEBUG:-}" ]; then
		touch ${CVS_CO_DIR}/debugging
    fi
}

cust_install_config_xml() {
	if [ ! -z "${USE_CONFIG_XML:-}" ]; then
		if [ -f "$USE_CONFIG_XML" ]; then
			echo ">>>> Using custom config.xml file ${USE_CONFIG_XML} ..."
			cp ${USE_CONFIG_XML} ${PFSENSEBASEDIR}/cf/conf/config.xml
			cp ${USE_CONFIG_XML} ${PFSENSEBASEDIR}/conf.default/config.xml 2>/dev/null
			cp ${USE_CONFIG_XML} ${CVS_CO_DIR}/cf/conf/config.xml
			cp ${USE_CONFIG_XML} ${CVS_CO_DIR}/conf.default/config.xml 2>/dev/null		
		fi
	fi
}

install_custom_overlay() {
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
			sleep 999999999999
		fi
	fi

    # Enable debug if requested
    if [ ! -z "${PFSENSE_DEBUG:-}" ]; then
		touch ${CVS_CO_DIR}/debugging
    fi
}

install_custom_overlay_final() {
	# Extract custom overlay if it's defined.
	if [ ! -z "${custom_overlay_final:-}" ]; then
		echo -n "Custom overlay defined - "
	    if [ -d $custom_overlay_final ]; then
			echo "found directory, copying..."
			for i in $custom_overlay_final/*
			do
			    if [ -d $i ]; then
			        echo "copying dir: $i $PFSENSEBASEDIR ..."
			        cp -R $i $PFSENSEBASEDIR
			    else
			        echo "copying file: $i $PFSENSEBASEDIR ..."
			        cp $i $PFSENSEBASEDIR
			    fi
			done
		elif [ -f $custom_overlay ]; then
			echo "found file, extracting..."
			tar xzpf $custom_overlay -C $PFSENSEBASEDIR
		else
			echo " file not found $custom_overlay_final"
			sleep 999999999999
		fi
	fi

    # Enable debug if requested
    if [ ! -z "${PFSENSE_DEBUG:-}" ]; then
		touch ${CVS_CO_DIR}/debugging
    fi
}


install_custom_packages() {

	DEVFS_MOUNT=`mount | grep ${BASEDIR}/dev | wc -l | awk '{ print $1 }'`

	if [ "$DEVFS_MOUNT" -lt 1 ]; then
		echo "Mounting devfs ${BASEDIR}/dev ..."
		mount -t devfs devfs ${BASEDIR}/dev
	fi
		
	DESTNAME="pkginstall.sh"
	
	# Extra package list if defined.
	if [ ! -z "${custom_package_list:-}" ]; then
		# execute setup script
	else
		# cleanup if file does exist
		if [ -f ${FREESBIE_PATH}/extra/customscripts/${DESTNAME} ]; then
			rm ${FREESBIE_PATH}/extra/customscripts/${DESTNAME}
		fi
	fi

	# Clean up after ourselves.
	umount ${BASEDIR}/dev

}

create_pfSense_BaseSystem_Small_update_tarball() {
	VERSION=${PFSENSE_VERSION}
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

	( cd ${CVS_CO_DIR} && tar czPf ${UPDATESDIR}/${FILENAME} . )

	ls -lah ${UPDATESDIR}/${FILENAME}
	if [ -e /usr/local/sbin/gzsig ]; then 
		echo "Executing command: gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}"
		gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}
	fi
}

fixup_updates() {

	# This step should be the last step before tarring the update, or 
	# rolling an iso.
	
	#find ${PFSENSEBASEDIR}/boot/ -type f -depth 1 -exec rm {} \;

	PREVIOUSDIR=`pwd`

	cd ${PFSENSEBASEDIR}
	rm -rf ${PFSENSEBASEDIR}/cf
	rm -rf ${PFSENSEBASEDIR}/conf
	rm -f ${PFSENSEBASEDIR}/etc/rc.conf
	rm -f ${PFSENSEBASEDIR}/etc/motd
	rm -f ${PFSENSEBASEDIR}/etc/pwd.db 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/etc/group 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/etc/spwd.db 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/etc/passwd 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/etc/master.passwd 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/etc/fstab 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/etc/ttys 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/etc/platform 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/root/.* 2>/dev/null

	echo > ${PFSENSEBASEDIR}/root/.tcshrc
	echo "alias installer /scripts/lua_installer" > ${PFSENSEBASEDIR}/root/.tcshrc
	
	# Setup login environment
	echo > ${PFSENSEBASEDIR}/root/.shrc
	echo "/etc/rc.initial" >> ${PFSENSEBASEDIR}/root/.shrc
	echo "exit" >> ${PFSENSEBASEDIR}/root/.shrc

	mkdir -p ${PFSENSEBASEDIR}/usr/local/livefs/lib/

	echo `date` > ${PFSENSEBASEDIR}/etc/version.buildtime

	if [ -d "${PFSENSEBASEDIR}" ]; then 
		echo Removing pfSense.tgz used by installer..
		find ${PFSENSEBASEDIR} -name pfSense.tgz -exec rm {} \;
	fi 
	
	cd $PREVIOUSDIR

}

cust_fixup_wrap() {

	echo "Fixing up WRAP Specific items..."
    	cp $CVS_CO_DIR/boot/device.hints_wrap \
            	$PFSENSEBASEDIR/boot/device.hints
    cp $CVS_CO_DIR/boot/loader.conf_wrap \
            $PFSENSEBASEDIR/boot/loader.conf
    cp $CVS_CO_DIR/etc/ttys_wrap \
            $PFSENSEBASEDIR/etc/ttys

    echo `date` > $PFSENSEBASEDIR/etc/version.buildtime
    echo "" > $PFSENSEBASEDIR/etc/motd

    mkdir -p $PFSENSEBASEDIR/cf/conf/backup

    echo /etc/rc.initial > $PFSENSEBASEDIR/root/.shrc
    echo exit >> $PFSENSEBASEDIR/root/.shrc
    rm -f $PFSENSEBASEDIR/usr/local/bin/after_installation_routines.sh 2>/dev/null

    echo "embedded" > $PFSENSEBASEDIR/etc/platform
    echo "wrap" > $PFSENSEBASEDIR/boot/kernel/pfsense_kernel.txt

	echo "-D" >> $PFSENSEBASEDIR/boot.config

	FBSD_VERSION=`/usr/bin/uname -r | /usr/bin/cut -d"." -f1`
	if [ "$FBSD_VERSION" = "8" ]; then
		# Enable getty on console
		sed -i "" -e /ttyd0/s/off/on/ ${PFSENSEBASEDIR}/etc/ttys

		# Disable getty on syscons devices
		sed -i "" -e '/^ttyv[0-8]/s/    on/     off/' ${PFSENSEBASEDIR}/etc/ttys

		# Tell loader to use serial console early.
		echo " -h" > ${PFSENSEBASEDIR}/boot.config
	fi

}

create_FreeBSD_system_update() {
	VERSION="FreeBSD"
	FILENAME=pfSense-Embedded-Update-${VERSION}.tgz
	mkdir -p $UPDATESDIR

	PREVIOUSDIR=`pwd`

	cd ${CLONEDIR}
	# Remove some fat and or conflicting
	# freebsd files
	rm -rf etc/
	rm -rf var/
	rm -rf usr/share/
	echo "Creating ${UPDATESDIR}/${FILENAME} update file..."
	tar czPf ${UPDATESDIR}/${FILENAME} .

	echo "Signing ${UPDATESDIR}/${FILENAME} update file..."
	if [ -e /usr/local/sbin/gzsig ]; then 	
		echo ">>>> Executing command: gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}"
		gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}
	fi
	
	cd $PREVIOUSDIR
	
}

create_pfSense_Full_update_tarball() {
	VERSION=${PFSENSE_VERSION}
	FILENAME=pfSense-Full-Update-${VERSION}-`date "+%Y%m%d-%H%M"`.tgz
	mkdir -p $UPDATESDIR

	PREVIOUSDIR=`pwd`

	echo ; echo "Deleting files listed in ${PRUNE_LIST}"
	set +e
	
	# Ensure that we do not step on /root/ scripts that
	# control auto login, console menu, etc.
	rm -f ${PFSENSEBASEDIR}/root/.* 2>/dev/null
		
	(cd ${PFSENSEBASEDIR} && sed 's/^#.*//g' ${PRUNE_LIST} | xargs rm -rvf > /dev/null 2>&1)

	echo -n ">>> Creating md5 summary of files present..."
	rm -f $PFSENSEBASEDIR/etc/pfSense_md5.txt
	echo "#!/bin/sh" > $PFSENSEBASEDIR/chroot.sh
	echo "find / -type f | /usr/bin/xargs /sbin/md5 >> /etc/pfSense_md5.txt" >> $PFSENSEBASEDIR/chroot.sh
	chmod a+rx $PFSENSEBASEDIR/chroot.sh
	chroot $PFSENSEBASEDIR /chroot.sh
	rm $PFSENSEBASEDIR/chroot.sh
	echo "Done."

	echo ; echo Creating ${UPDATESDIR}/${FILENAME} ...
	cd ${PFSENSEBASEDIR} && tar czPf ${UPDATESDIR}/${FILENAME} .

	echo "Signing ${UPDATESDIR}/${FILENAME} update file..."
	if [ -e /usr/local/sbin/gzsig ]; then 
		echo ">>>> Executing command: gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}"
		gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}
	fi

	cd $PREVIOUSDIR
}

create_pfSense_Embedded_update_tarball() {
	VERSION=${PFSENSE_VERSION}
	FILENAME=pfSense-Embedded-Update-${VERSION}-`date "+%Y%m%d-%H%M"`.tgz
	mkdir -p $UPDATESDIR

	PREVIOUSDIR=`pwd`

	echo ; echo "Deleting files listed in ${PRUNE_LIST}"
	set +e
	(cd ${PFSENSEBASEDIR} && sed 's/^#.*//g' ${PRUNE_LIST} | xargs rm -rvf > /dev/null 2>&1)

	# Remove all other kernels and replace full kernel with the embedded
	# kernel that was built during the builder process
	mv ${PFSENSEBASEDIR}/kernels/kernel_wrap.gz ${PFSENSEBASEDIR}/boot/kernel/kernel.gz
	rm -rf ${PFSENSEBASEDIR}/kernels/*

	echo ; echo Creating ${UPDATESDIR}/${FILENAME} ...
	cd ${PFSENSEBASEDIR} && tar czPf ${UPDATESDIR}/${FILENAME} .

	echo "Signing ${UPDATESDIR}/${FILENAME} update file..."
	if [ -e /usr/local/sbin/gzsig ]; then 
		echo "Executing command: gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}"
		gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}
	fi
	
	cd $PREVIOUSDIR
	
}

create_pfSense_Small_update_tarball() {
	VERSION=${PFSENSE_VERSION}
	FILENAME=pfSense-Mini-Embedded-Update-${VERSION}-`date "+%Y%m%d-%H%M"`.tgz

	PREVIOUSDIR=`pwd`

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
	rm -f ${CVS_CO_DIR}/etc/ttys*
	
	cd ${CVS_CO_DIR} && tar czPf ${UPDATESDIR}/${FILENAME} .

	ls -lah ${UPDATESDIR}/${FILENAME}

	if [ -e /usr/local/sbin/gzsig ]; then 
		echo ">>>> Executing command: gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}"
		gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}
	fi

	cd $PREVIOUSDIR

}

# Create tarball of pfSense cvs directory
create_pfSense_tarball() {
	rm -f $CVS_CO_DIR/boot/*

	PREVIOUSDIR=`pwd`

	find $CVS_CO_DIR -name CVS -exec rm -rf {} \; 2>/dev/null
	find $CVS_CO_DIR -name "_orange-flow" -exec rm -rf {} \; 2>/dev/null

	cd $CVS_CO_DIR && tar czPf /tmp/pfSense.tgz .

	cd $PREVIOUSDIR
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
	PREVIOUSDIR=`pwd`
	cd $LOCALDIR
	tar  xzPf /tmp/pfSense.tgz -C $FREESBIEBASEDIR
	cd $PREVIOUSDIR
}

# Set image as a CDROM type image
set_image_as_cdrom() {
	echo cdrom > $CVS_CO_DIR/etc/platform
}

#Create a copy of FREESBIEBASEDIR. This is useful to modify the live filesystem
clone_system_only()
{

	PREVIOUSDIR=`pwd`

	echo -n "Cloning $FREESBIEBASEDIR to $FREESBIEISODIR..."

	mkdir -p $FREESBIEISODIR || print_error_pfS
	if [ -r $FREESBIEISODIR ]; then
	      chflags -R noschg $FREESBIEISODIR || print_error_pfS
	      rm -rf $FREESBIEISODIR/* || print_error_pfS
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

	FBSD_VERSION=`/usr/bin/uname -r | /usr/bin/cut -d"." -f1`
	if [ "$FBSD_VERSION" = "8" ]; then
		echo ">>> Using TAR to clone clone_system_only()..."
		tar cf - * | ( cd /$FREESBIEISODIR; tar xfp -)
	else
		echo ">>> Using CPIO to clone..."
		find . -print -depth | cpio --quiet -pudm $FREESBIEISODIR
	fi

	umount_devices $MDDEVICES

	trap "" INT

	echo " [DONE]"
	
	cd $PREVIOUSDIR
}

checkout_pfSense_git() {
	echo "Using GIT to checkout ${PFSENSETAG}"
	# XXX: do we need to revert the co to HEAD if it has been 
	#      checked out on another branch?
	if [ "${PFSENSETAG}" != "HEAD" ]; then
		current_branch=`cd ${GIT_REPO_DIR}/pfSenseGITREPO && git branch | grep ${PFSENSETAG}`
		if [ "$current_branch" = "" ]; then
			(cd $GIT_REPO_DIR/pfSenseGITREPO && git checkout -b ${PFSENSETAG} origin/${PFSENSETAG})
		else 
			(cd $GIT_REPO_DIR/pfSenseGITREPO && git checkout ${PFSENSETAG})
		fi
	else 
		(cd ${GIT_REPO_DIR}/pfSenseGITREPO && git checkout master)
	fi
	if [ $? != 0 ]; then
		echo "Something went wrong while checking out GIT."
		print_error_pfS
	fi
	mkdir -p $CVS_CO_DIR
	(cd ${GIT_REPO_DIR}/pfSenseGITREPO && tar czpf /tmp/pfSense.tgz .)
	(cd $CVS_CO_DIR && tar xzpf /tmp/pfSense.tgz)
	rm /tmp/pfSense.tgz
	rm -rf ${CVS_CO_DIR}/.git	
}

checkout_pfSense() {
	PREVIOUSDIR=`pwd`
	echo ">>>> Checking out pfSense version ${PFSENSETAG}..."
	rm -rf $CVS_CO_DIR
	if [ -z "${USE_GIT:-}" ]; then
		(cd $BASE_DIR && cvs -d ${BASE_DIR}/cvsroot co pfSense -r ${PFSENSETAG})
	else
		checkout_pfSense_git
	fi
	fixup_libmap	
	cd $PREVIOUSDIR
}

checkout_freesbie() {
	echo ">>>> Getting FreeSBIE"
	rm -rf $LOCALDIR
}

print_flags() {

	printf "      pfSense build dir: %s\n" $SRCDIR
	printf "        pfSense version: %s\n" $PFSENSE_VERSION
	printf "               CVS User: %s\n" $CVS_USER
	printf "              Verbosity: %s\n" $BE_VERBOSE
	printf "               Base dir: %s\n" $BASE_DIR
	printf "           Checkout dir: %s\n" $CVS_CO_DIR
	printf "            Custom root: %s\n" $CUSTOMROOT
	printf "         CVS IP address: %s\n" $CVS_IP
	printf "            Updates dir: %s\n" $UPDATESDIR
	printf "           pfS Base dir: %s\n" $PFSENSEBASEDIR
	printf "          FreeSBIE path: %s\n" $FREESBIE_PATH
	printf "          FreeSBIE conf: %s\n" $FREESBIE_CONF
	printf "             Source DIR: %s\n" $SRCDIR
	printf "              Clone DIR: %s\n" $CLONEDIR
	printf "         Custom overlay: %s\n" $custom_overlay
	printf "        pfSense version: %s\n" $FREEBSD_VERSION
	printf "         FreeBSD branch: %s\n" $FREEBSD_BRANCH
	printf "            pfSense Tag: %s\n" $PFSENSETAG
	printf "       MAKEOBJDIRPREFIX: %s\n" $MAKEOBJDIRPREFIX
	printf "                  EXTRA: %s\n" $EXTRA
	printf "           BUILDMODULES: %s\n" $BUILDMODULES
	printf "         Git Repository: %s\n" $GIT_REPO
	printf "             Git Branch: %s\n" $GIT_BRANCH
	printf "          Custom Config: %s\n" $USE_CONFIG_XML
	printf "                ISOPATH: %s\n" $ISOPATH
	printf "                IMGPATH: %s\n" $IMGPATH
	printf "             KERNELCONF: %s\n" $KERNELCONF
	printf "FREESBIE_COMPLETED_MAIL: %s\n" $FREESBIE_COMPLETED_MAIL
	printf "    FREESBIE_ERROR_MAIL: %s\n" $FREESBIE_ERROR_MAIL
if [ -n "$PFSENSECVSDATETIME" ]; then
	printf "         pfSense TSTAMP: %s\n" "-D \"$PFSENSECVSDATETIME\""
fi
	printf "               SRC_CONF: %s\n" $SRC_CONF
	echo
	echo "Sleeping for 5 seconds..."
	sleep 5

}

clear_custom() {
	echo ">> Clearing custom/*"
	rm -rf $LOCALDIR/customroot/*
}

backup_pfSense() {
	echo ">>>> Backing up pfSense repo"
	cp -R $CVS_CO_DIR $BASE_DIR/pfSense_bak
}

restore_pfSense() {
	echo ">>>> Restoring pfSense repo"
	cp -R $BASE_DIR/pfSense_bak $CVS_CO_DIR
}

freesbie_make() {
	(cd ${FREESBIE_PATH} && make $*)
}

update_cvs_depot() {
	if [ -z "${USE_GIT:-}" ]; then
		local _cvsdate
		echo "Launching csup pfSense-supfile..."
		/usr/bin/csup -b $BASE_DIR/cvsroot pfSense-supfile
		rm -rf pfSense
		echo "Updating ${BASE_DIR}/pfSense..."
		rm -rf $BASE_DIR/pfSense
		if [ -n "$PFSENSECVSDATETIME" ]; then
			_cvsdate="-D $PFSENSECVSDATETIME"
		fi
		(cd ${BASE_DIR} && cvs -d /home/pfsense/cvsroot co -r ${PFSENSETAG} $_cvsdate pfSense) \
		| egrep -wi "(^\?|^M|^C|error|warning)"
		(cd ${BUILDER_TOOLS}/ && cvs update -d) \
		| egrep -wi "(^\?|^M|^C|error|warning)"
	else
		if [ ! -d "${GIT_REPO_DIR}" ]; then
			echo ">>> Creating ${GIT_REPO_DIR}"
			mkdir -p ${GIT_REPO_DIR}
		fi
		if [ -d "${GIT_REPO_DIR}/pfSenseGITREPO" ]; then 
	    	echo ">>> Removing pfSebseGITREPO from ${GIT_REPO_DIR}"			
	    	rm -rf ${GIT_REPO_DIR}/pfSenseGITREPO	# XXX: remove this once we are fully working on GIT
		fi
		if [ ! -d "${GIT_REPO_DIR}/pfSenseGITREPO" ]; then
			rm -rf ${GIT_REPO_DIR}/pfSense
			echo ">>> Cloning ${GIT_REPO} using GIT and switching to ${PFSENSETAG}"
	    		(cd ${GIT_REPO_DIR} && git clone ${GIT_REPO})
			if [ -d "${GIT_REPO_DIR}/mainline" ]; then
				mv "${GIT_REPO_DIR}/mainline" "${GIT_REPO_DIR}/pfSenseGITREPO"
			fi
			if [ -d "${GIT_REPO_DIR}/pfSense" ]; then
				mv "${GIT_REPO_DIR}/pfSense" "${GIT_REPO_DIR}/pfSenseGITREPO"
			fi
		fi
		checkout_pfSense_git
		if [ $? != 0 ]; then	
			echo "Something went wrong while checking out GIT."
			print_error_pfS
		fi
	fi
}

make_world() {
    # Check if the world and kernel are already built and set
    # the NO variables accordingly
    if [ -f "${MAKEOBJDIRPREFIX}/.world.done" ]; then
		export NO_BUILDWORLD=yo
    fi

    # Make world
    freesbie_make buildworld
    touch ${MAKEOBJDIRPREFIX}/.world.done

	# Sometimes inbetween build_iso runs btxld seems to go missing.
	# ensure that this binary is always built and ready.
	echo ">>> Ensuring that the btxld problem does not happen on subsequent runs..."
	(cd $SRCDIR/sys/boot && env TARGET_ARCH=${ARCH} MAKEOBJDIRPREFIX=$MAKEOBJDIRPREFIX make) 2>&1 \
		| egrep -wi '(patching\ file|warning|error)'
	(cd $SRCDIR/usr.sbin/btxld && env TARGET_ARCH=${ARCH} MAKEOBJDIRPREFIX=$MAKEOBJDIRPREFIX make) 2>&1 \
		| egrep -wi '(patching\ file|warning|error)'
	(cd $SRCDIR/usr.sbin/btxld && env TARGET_ARCH=${ARCH} MAKEOBJDIRPREFIX=$MAKEOBJDIRPREFIX make) 2>&1 \
		| egrep -wi '(patching\ file|warning|error)'
	(cd $SRCDIR/sys/boot/i386/btx/btx && env TARGET_ARCH=${ARCH} MAKEOBJDIRPREFIX=$MAKEOBJDIRPREFIX make) 2>&1 \
		| egrep -wi '(patching\ file|warning|error)'
	freesbie_make installworld

}

setup_nanobsd_etc ( ) {
	echo "## configure nanobsd /etc"

	cd ${CLONEDIR}

	# create diskless marker file
	touch etc/diskless
	touch nanobuild

	# Make root filesystem R/O by default
	echo "root_rw_mount=NO" >> etc/defaults/rc.conf

	# save config file for scripts
	# echo "NANO_DRIVE=${NANO_DRIVE}" > etc/nanobsd.conf

	echo "/dev/ufs/root0 / ufs ro 1 1" > etc/fstab
	echo "/dev/ufs/cfg /cfg ufs rw,noauto 2 2" >> etc/fstab
	echo "/dev/ufs/cf /cf ufs ro 1 1" >> etc/fstab
	mkdir -p cfg
}

setup_nanobsd ( ) {
	echo "## configure nanobsd setup"
	echo "### log: ${MAKEOBJDIRPREFIX}/_.dl"

	cd ${CLONEDIR}

	# Move /usr/local/etc to /etc/local so that the /cfg stuff
	# can stomp on it.  Otherwise packages like ipsec-tools which
	# have hardcoded paths under ${prefix}/etc are not tweakable.
	if [ -d usr/local/etc ] ; then
		(
		mkdir etc/local
		cd usr/local/etc
		FBSD_VERSION=`/usr/bin/uname -r | /usr/bin/cut -d"." -f1`
		if [ "$FBSD_VERSION" = "8" ]; then
			echo ">>> Using TAR to clone setup_nanobsd()..."
			tar cf - * | ( cd ../../../etc/local; tar xfp -)
		else
			echo ">>> Using CPIO to clone..."
			find . -print | cpio -dump -l ../../../etc/local
		fi		
		cd ..
		rm -rf etc
		ln -s ../../etc/local etc
		)
	fi
	# Create /conf directory hier
	for d in etc
	do
		# link /$d under /${CONFIG_DIR}
		# we use hard links so we have them both places.
		# the files in /$d will be hidden by the mount.
		# XXX: configure /$d ramdisk size
		mkdir -p ${CONFIG_DIR}/base/$d ${CONFIG_DIR}/default/$d
		FBSD_VERSION=`/usr/bin/uname -r | /usr/bin/cut -d"." -f1`
		if [ "$FBSD_VERSION" = "8" ]; then
			echo ">>> Using TAR to clone setup_nanobsd()..."
			find $d -print | tar cf - | ( cd ${CONFIG_DIR}/base/; tar xfp -)
		else
			echo ">>> Using CPIO to clone..."
			find $d -print | cpio -dump -l ${CONFIG_DIR}/base/
		fi
	done

	echo "$NANO_RAM_ETCSIZE" > ${CONFIG_DIR}/base/etc/md_size
	# add /nano/base/var manually for md_size 
	mkdir -p ${CONFIG_DIR}/base/var
	echo "$NANO_RAM_TMPVARSIZE" > ${CONFIG_DIR}/base/var/md_size 

	# pick up config files from the special partition
	echo "mount -o ro /dev/ufs/cfg" > ${CONFIG_DIR}/default/etc/remount

	# Put /tmp on the /var ramdisk (could be symlink already)
	rm -rf tmp || true
	ln -s var/tmp tmp

}

prune_usr() {

	# Remove all empty directories in /usr 
	find ${NANO_WORLDDIR}/usr -type d -depth -print |
		while read d
		do
			rmdir $d > /dev/null 2>&1 || true 
		done
}

FlashDevice () {
    . FlashDevice.sub
    sub_FlashDevice $1 $2
}

create_i386_diskimage ( ) {
	echo "## build diskimage"
	echo "### log: ${MAKEOBJDIRPREFIX}/_.di"
	TIMESTAMP=`date "+%Y%m%d.%H%M"`
	echo $NANO_MEDIASIZE $NANO_IMAGES \
		$NANO_SECTS $NANO_HEADS \
		$NANO_CODESIZE $NANO_CONFSIZE $NANO_DATASIZE |
	awk '
	{
		printf "# %s\n", $0

		# size of cylinder in sectors
		cs = $3 * $4

		# number of full cylinders on media
		cyl = int ($1 / cs)

		# output fdisk geometry spec, truncate cyls to 1023
		if (cyl <= 1023)
			print "g c" cyl " h" $4 " s" $3
		else
			print "g c" 1023 " h" $4 " s" $3

		if ($7 > 0) { 
			# size of data partition in full cylinders
			dsl = int (($7 + cs - 1) / cs)
		} else {
			dsl = 0;
		}

		# size of config partition in full cylinders
		csl = int (($6 + cs - 1) / cs)

		if ($5 == 0) {
			# size of image partition(s) in full cylinders
			isl = int ((cyl - dsl - csl) / $2)
		} else {
			isl = int (($5 + cs - 1) / cs)
		}

		# First image partition start at second track
		print "p 1 165 " $3, isl * cs - $3
		c = isl * cs;

		# Second image partition (if any) also starts offset one 
		# track to keep them identical.
		if ($2 > 1) {
			print "p 2 165 " $3 + c, isl * cs - $3
			c += isl * cs;
		}

		# Config partition starts at cylinder boundary.
		print "p 3 165 " c, csl * cs
		c += csl * cs

		# Data partition (if any) starts at cylinder boundary.
		if ($7 > 0) {
			print "p 4 165 " c, dsl * cs
		} else if ($7 < 0 && $1 > $c) {
			print "p 4 165 " c, $1 - $c
		} else if ($1 < c) {
			print "Disk space overcommitted by", \
			    c - $1, "sectors" > "/dev/stderr"
			exit 2
		}
	}
	' > ${MAKEOBJDIRPREFIX}/_.fdisk

	IMG=${MAKEOBJDIRPREFIX}/nanobsd.full.img
	MNT=${MAKEOBJDIRPREFIX}/_.mnt
	mkdir -p ${MNT}

	dd if=/dev/zero of=${IMG} bs=${NANO_SECTS}b \
	    count=`expr ${NANO_MEDIASIZE} / ${NANO_SECTS}`

	MD=`mdconfig -a -t vnode -f ${IMG} -x ${NANO_SECTS} -y ${NANO_HEADS}`

	fdisk -i -f ${MAKEOBJDIRPREFIX}/_.fdisk ${MD}
	fdisk ${MD}
	# XXX: params
	# XXX: pick up cached boot* files, they may not be in image anymore.
	boot0cfg -B -b ${CLONEDIR}/${NANO_BOOTLOADER} ${NANO_BOOT0CFG} ${MD}
	bsdlabel -w -B -b ${CLONEDIR}/boot/boot ${MD}s1
	bsdlabel ${MD}s1

	# Create first image
	newfs ${NANO_NEWFS} /dev/${MD}s1a
	tunefs -L root0 /dev/${MD}s1a
	mount /dev/${MD}s1a ${MNT}
	df -i ${MNT}
	
	FBSD_VERSION=`/usr/bin/uname -r | /usr/bin/cut -d"." -f1`
	if [ "$FBSD_VERSION" = "8" ]; then
		echo ">>> Using TAR to clone create_i386_diskimage()..."
		( cd ${CLONEDIR} && tar cf - * | ( cd /$MNT; tar xfp -) )
	else
		echo ">>> Using CPIO to clone..."
		( cd ${CLONEDIR} && find . -print | cpio -dump ${MNT} )
	fi	

	df -i ${MNT}
	( cd ${MNT} && mtree -c ) > ${MAKEOBJDIRPREFIX}/_.mtree
	( cd ${MNT} && du -k ) > ${MAKEOBJDIRPREFIX}/_.du
	umount ${MNT}

	if [ $NANO_IMAGES -gt 1 -a $NANO_INIT_IMG2 -gt 0 ] ; then
		# Duplicate to second image (if present)
		dd if=/dev/${MD}s1 of=/dev/${MD}s2 bs=64k
		tunefs -L root1 /dev/${MD}s2a
		mount /dev/${MD}s2a ${MNT}
		for f in ${MNT}/etc/fstab ${MNT}/conf/base/etc/fstab
		do
			sed -i "" "s/root0/root1/g" $f
		done
		umount ${MNT}

	fi
	
	# Create Config slice
	newfs ${NANO_NEWFS} /dev/${MD}s3
	tunefs -L cfg /dev/${MD}s3
	# XXX: fill from where ?

	# Create Data slice, if any.
	if [ $NANO_DATASIZE -gt 0 ] ; then
		newfs ${NANO_NEWFS} /dev/${MD}s4
		tunefs -L cf /dev/${MD}s4
                # Mount data partition and copy contents of /cf
                # Can be used later to create custom default config.xml while building
                mount /dev/${MD}s4 ${MNT}

				FBSD_VERSION=`/usr/bin/uname -r | /usr/bin/cut -d"." -f1`
				if [ "$FBSD_VERSION" = "8" ]; then
					echo ">>> Using TAR to clone create_i386_diskimage()..."
					( cd ${CLONEDIR}/cf && tar cf - * | ( cd /$MNT; tar xfp -) )
				else
					echo ">>> Using CPIO to clone..."
					( cd ${CLONEDIR}/cf && find . -print | cpio -dump ${MNT} )
				fi

                umount ${MNT}
	fi

	dd if=/dev/${MD}s1 of=${MAKEOBJDIRPREFIX}/nanobsd.slice.img bs=64k
	mdconfig -d -u $MD
}

pfsense_install_custom_packages_exec() {
	# Function originally written by Daniel S. Haischt
	#	Copyright (C) 2007 Daniel S. Haischt <me@daniel.stefan.haischt.name>
	#   Copyright (C) 2008 Scott Ullrich <sullrich@gmail.com>
	
	DESTNAME="pkginstall.sh"	
	TODIR="${PFSENSEBASEDIR}"

	# Extra package list if defined.
	if [ ! -z "${custom_package_list:-}" ]; then
		# Notes:
		# ======
		# devfs mount is required cause PHP requires /dev/stdin
		# php.ini needed to make PHP argv capable
		#
		/bin/echo "Installing custom packages to: ${TODIR} ..."

		cp ${TODIR}/etc/platform ${TODIR}/tmp/

		/bin/echo "Mounting temporary devfs filesystem to ${TODIR} ..."
		/sbin/mount -t devfs devfs ${TODIR}/dev

		/bin/echo "Copying resolv.conf to ${TODIR}/var/etc/ to enable pkg manager to resolve DNS names ..."
		/bin/mkdir -p ${TODIR}/var/etc/
		/bin/cp /etc/resolv.conf ${TODIR}/etc/
		
		/bin/echo "Dumping contents of custom_package_list to ${TODIR}/tmp/pkgfile.lst ..."
		/bin/echo ${custom_package_list} > ${TODIR}/tmp/pkgfile.lst

		/bin/echo "Installing custom pfSense package installer to ${TODIR}/tmp ..."
		/bin/cp ${BUILDER_TOOLS}/builder_scripts/pfspkg_installer ${TODIR}/tmp
		/bin/chmod a+x ${TODIR}/tmp/pfspkg_installer
		
		cp ${TODIR}/usr/local/lib/php.ini /tmp/
		if [ -f /tmp/php.ini ]; then 
			cat /tmp/php.ini | grep -v apc > ${TODIR}/usr/local/lib/php.ini
			cat /tmp/php.ini | grep -v apc > ${TODIR}/usr/local/etc/php.ini
		fi
		
	# setup script that will be run within the chroot env
	/bin/cat > ${TODIR}/${DESTNAME} <<EOF
#!/bin/sh
#
# ------------------------------------------------------------------------
# ATTENTION: !!! This script is supposed to be run within a chroot env !!!
# ------------------------------------------------------------------------
#
#
# Setup
#

# Handle php.ini if /etc/rc.php_ini_setup exists
if [ -f "/etc/rc.php_ini_setup" ]; then
	echo "Running /etc/rc.php_ini_setup..."
	/etc/rc.php_ini_setup 2>/dev/null
	cat /usr/local/etc/php.ini | grep -v apc > /tmp/php.ini.new
	cp /tmp/php.ini.new /usr/local/etc/php.ini
	cp /tmp/php.ini.new /usr/local/lib/php.ini	
fi

if [ ! -f "/usr/local/bin/php" ]; then
	echo 
	echo 
	echo 	
	echo "ERROR.  A copy of php does not exist in /usr/local/bin/"
	echo
	echo "This script cannot continue."
	echo 	
	while [ /bin/true ]; do
		sleep 999
	done	
fi

if [ ! -f "/COPYRIGHT" ]; then
	echo 
	echo 
	echo 	
	echo "ERROR.  Could not detect the correct CHROOT environment (missing /COPYRIGHT)."
	echo
	echo "This script cannot continue."
	echo 	
	while [ /bin/true ]; do
		sleep 999
	done
fi

# backup original conf dir
if [ -d /conf ]; then
	/bin/echo "Backing up conf dir to /conf.org ..."
	/bin/mv /conf /conf.org
	/usr/bin/touch /tmp/restore_conf_dir
fi

# test whether conf dir is already a symlink
if [ ! -h /conf ]; then
	# install the symlink as it would exist on a live system
	/bin/echo "Symlinking /conf.default to /conf ..."
	/bin/ln -s /conf.default /conf
	/bin/ln -s /conf /cf
	/usr/bin/touch /tmp/remove_conf_symlink
else
	# seems like we are already working with a conf dir that is a symlink
	/bin/echo "Using existing conf dir from / ..."
fi

# now that we do have the symlink in place create
# a backup dir if necessary.
if [ ! -d /conf/backup ]; then
	/bin/echo "Creating backup dir in /conf ..."
	/bin/mkdir -p /conf/backup
	/usr/bin/touch /tmp/remove_backup
else
	/bin/echo "Using existing backup dir from ${TODIR}/conf ..."
fi

#
# Assemble package list if necessary
#
/tmp/pfspkg_installer -q -m config -l /tmp/pkgfile.lst -p .:/etc/inc:/usr/local/www:/usr/local/captiveportal:/usr/local/pkg

#
# Exec PHP script which installs pfSense packages in place
#
/tmp/pfspkg_installer -q -m install -l /tmp/pkgfile.lst -p .:/etc/inc:/usr/local/www:/usr/local/captiveportal:/usr/local/pkg

# Copy config.xml to conf.default/
cp /conf/config.xml conf.default/

#
# Cleanup, aisle 7!
#
if [ -f /tmp/remove_platform ]; then
	/bin/echo "Removing temporary platform file from /etc ..."
	/bin/rm /etc/platform
	/bin/rm /tmp/remove_platform
fi

if [ -f /tmp/remove_backup ]; then
	/bin/echo "Removing temporary backup dir from /conf ..."
	/bin/rm -rf /conf/backup
	/bin/rm /tmp/remove_backup
fi

if [ -f /tmp/remove_conf_symlink ]; then
	/bin/echo "Removing temporary conf dir ..."
	/bin/rm /conf
	if [ -h /cf ]; then
		/bin/rm /cf
	fi
	/bin/rm /tmp/remove_conf_symlink
fi

if [ -f /tmp/restore_conf_dir ]; then
	/bin/echo "Restoring original conf dir ..."
	/bin/mv /conf.org /conf
	/bin/rm /tmp/restore_conf_dir
fi

if [ -f /tmp/platform ]; then
	/bin/echo "Restoring platform file ..."
	mv /tmp/platform /etc/platform
fi

/bin/echo "Removing pfspkg_installer script from /tmp ..."
/bin/rm /tmp/pfspkg_installer

/bin/echo "Removing custom packages list file from /tmp ..."
/bin/rm /tmp/pkgfile.lst

/bin/echo "Removing possible package install leftover (*.tbz, *.log) ..."
/bin/rm /tmp/*.log /tmp/*.tbz 2>/dev/null

/bin/echo "Removing config.cache which was generating during package install ..."
if [ -f /tmp/config.cache ]; then
	/bin/rm /tmp/config.cache
fi

/bin/echo "Removing /etc/resolv.conf ..."	
/bin/rm /etc/resolv.conf

/bin/rm /${DESTNAME}

if [ -f /tmp/php.ini ]; then 
	cp /tmp/php.ini /usr/local/lib/php.ini 
	cp /tmp/php.ini /usr/local/etc/php.ini
fi

EOF

		echo ">>>> Installing custom pfSense-XML packages inside chroot ..."
		chmod a+rx ${TODIR}/${DESTNAME}
		chroot ${TODIR} /bin/sh /${DESTNAME}
		echo ">>>> Unmounting ${TODIR}/dev ..."
		umount -f ${TODIR}/dev
	
	fi		
}

pfSense_clean_obj_dir() {
	# Clean out directories
	echo ">>> Cleaning up old directories..."
	freesbie_make cleandir
	echo -n "Cleaning up previous build environment...Please wait..."
	# Allow old CVS_CO_DIR to be deleted later
	if [ "$CVS_CO_DIR" != "" ]; then
		if [ -d "$CVS_CO_DIR" ]; then 
			echo -n "."
			chflags -R noschg $CVS_CO_DIR/*
			rm -rf $CVS_CO_DIR 2>/dev/null
		fi
	fi
	echo -n "."
	if [ -d "${PFSENSEBASEDIR}/dev" ]; then
		echo -n "."	
		umount -f "${PFSENSEBASEDIR}/dev" 2>/dev/null
		echo -n "."			
		rm -rf ${PFSENSEBASEDIR}/dev 2>&1
		echo -n "."			
	fi
	if [ -d "$PFSENSEBASEDIR" ]; then 
		echo -n "."	
		chflags -R noschg ${PFSENSEBASEDIR}
		echo -n "."
		(cd ${CURRENTDIR} && rm -rf ${PFSENSEBASEDIR})	
	fi
	if [ -d "$PFSENSEISODIR" ]; then 
		echo -n "."
		chflags -R noschg ${PFSENSEISODIR}
		echo -n "."
		(cd ${CURRENTDIR} && rm -rf ${PFSENSEISODIR})	
	fi
	echo -n "."
	(cd ${CURRENTDIR} && rm -rf ${MAKEOBJDIRPREFIX})
	echo -n "."
	rm -rf /tmp/kernels
	if [ -d "${GIT_REPO_DIR}/pfSenseGITREPO" ]; then
		echo -n "."
		rm -rf "${GIT_REPO_DIR}/pfSenseGITREPO"
	fi
	echo "Done!"
	echo -n ">>> Ensuring $SRCDIR is clean..."
	(cd ${SRCDIR}/ && make clean) 2>&1 \
		| egrep -wi '(NOTFONNAFIND)'	
	echo "Done!"
}

copy_config_xml_from_conf_default() {
	if [ ! -f "${PFSENSEBASEDIR}/cf/conf/config.xml" ]; then
		echo ">>> Copying config.xml from conf.default/ to cf/conf/"
		cp ${PFSENSEBASEDIR}/conf.default/config.xml ${PFSENSEBASEDIR}/cf/conf/
	fi
}

email_operation_completed() {
    if [ ! -z ${FREESBIE_COMPLETED_MAIL:-} ]; then
	echo "Build / operation completed." | \
	    mail -s "FreeSBIE (pfSense) operation completed." \
	    ${FREESBIE_COMPLETED_MAIL}
    fi	
}

create_iso_cf_conf_symbolic_link() {
	echo ">>> Creating symbolic link for /cf/conf /conf ..."
	rm -rf ${PFSENSEBASEDIR}/conf
	chroot ${PFSENSEBASEDIR} /bin/ln -s /cf/conf /conf
}
