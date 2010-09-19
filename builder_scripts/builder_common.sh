#!/bin/sh
#
#  builder_common.sh
#  Copyright (C) 2004-2009 Scott Ullrich
#  All rights reserved.
#
#  NanoBSD portions of the code
#  Copyright (c) 2005 Poul-Henning Kamp.
#  and copied from nanobsd.sh
#  All rights reserved.
#
#  FreeSBIE portions of the code
#  Copyright (c) 2005 Dario Freni
#  and copied from FreeSBIE project
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
#  This is the brains of the builder and is included
#  by the various pfSense builder scripts such as
#  build_iso.sh and build_nano.sh, etc.
#
# Crank up error reporting, debugging.
#  set -e
#  set -x

if [ "$MAKEOBJDIRPREFIXFINAL" ]; then
	mkdir -p $MAKEOBJDIRPREFIXFINAL
else
	echo "MAKEOBJDIRPREFIXFINAL is not defined"
	print_error_pfS
fi

# Set TARGET_ARCH_CONF_DIR
if [ "$TARGET_ARCH" = "" ]; then
	export TARGET_ARCH=i386
fi
TARGET_ARCH_CONF_DIR=$SRCDIR/sys/${TARGET_ARCH}/conf/

# Set KERNEL_BUILD_PATH if it has not been set
if [ "$KERNEL_BUILD_PATH" = "" ]; then
	KERNEL_BUILD_PATH=/tmp/kernels
fi

# This routine will post a tweet to twitter
post_tweet() {
	TWEET_MESSAGE="$1"
	if [ "$TWITTER_USERNAME" ="" ]; then
		echo ">>> ERROR: Could not find TWITTER_USERNAME -- tweet cancelled."
		return
	fi
	if [ "$TWITTER_PASSWORD" = "" ]; then
		echo ">>> ERROR: Could not find TWITTER_PASSWORD -- tweet cancelled."
		return
	fi
	if [ ! -f "/usr/local/bin/curl" ]; then
		echo ">>> ERROR: Could not find /usr/local/bin/curl -- tweet cancelled."
		return
	fi
	echo -n ">>> Posting tweet to twitter: $TWEET_MESSAGE"
	`/usr/local/bin/curl --silent --basic --user "$TWITTER_USERNAME:$TWITTER_PASSWORD" --data status="$TWEET_MESSAGE" http://twitter.com/statuses/update.xml`
	echo "Done!"
}

# This routine handles the athstats directory since it lives in
# SRCDIR/tools/tools/ath/athstats and changes from various freebsd
# versions which makes adding this to pfPorts difficult.
handle_athstats() {
	echo -n ">>> Building athstats..."
	cd $SRCDIR/tools/tools/ath/athstats
	(make clean && make && make install) | egrep -wi '(^>>>|error)'
	echo "Done!"
}

# This routine will output that something went wrong
print_error_pfS() {
	echo
	echo "####################################"
	echo "Something went wrong, check errors!" >&2
	echo "####################################"
	echo
	echo "NOTE: a lot of times you can run ./clean_build.sh to resolve."
	echo
	if [ "$1" != "" ]; then
		echo $1
	fi
    [ -n "${LOGFILE:-}" ] && \
        echo "Log saved on ${LOGFILE}" && \
		tail -n20 ${LOGFILE} >&2
	report_error_pfsense
	echo
	echo "Press enter to continue."
    read ans
    kill $$ # NOTE: kill $$ won't work.
}

# This routine will verify that the kernel has been
# installed OK to the staging area.
ensure_kernel_exists() {
	if [ ! -f "$1/boot/kernel/kernel.gz" ]; then
		echo "Could not locate $1/boot/kernel.gz"
		print_error_pfS
		kill $$
	fi
	KERNEL_SIZE=`ls -la $1/boot/kernel/kernel.gz | awk '{ print $5 }'`
	if [ "$KERNEL_SIZE" -lt 3500 ]; then
		echo "Kernel $1/boot/kernel.gz appears to be smaller than it should be: $KERNEL_SIZE"
		print_error_pfS
		kill $$
	fi
}

# Removes NAT_T and other unneeded kernel options from 1.2 images.
fixup_kernel_options() {

	# Do not remove or move support to freesbie2/scripts/installkernel.sh

	# Cleanup self
	find $MAKEOBJDIRPREFIX -name .done_buildkernel -exec rm {} \;
	find $MAKEOBJDIRPREFIX -name .done_installkernel -exec rm {} \;
	if [ -d "$KERNEL_DESTDIR/boot" ]; then
		rm -rf $KERNEL_DESTDIR/boot/*
	fi

	# Create area where kernels will be copied on LiveCD
	mkdir -p $PFSENSEBASEDIR/kernels/
	# Make sure directories exist
	mkdir -p $KERNEL_DESTDIR/boot/kernel
	mkdir -p $KERNEL_DESTDIR/boot/defaults

	# Copy pfSense kernel configuration files over to $SRCDIR/sys/$ARCH/conf
	cp $BUILDER_TOOLS/builder_scripts/conf/$KERNCONF $KERNELCONF
	if [ ! -f "$KERNELCONF" ]; then
		echo ">>> Could not find $KERNELCONF"
		print_error_pfS
	fi
	echo "" >> $KERNELCONF


	if [ "$WITH_DTRACE" = "" ]; then
		echo ">>> Not adding D-Trace to Kernel..."
	else
		echo "options KDTRACE_HOOKS" >> $KERNELCONF
		echo "options DDB_CTF" >> $KERNELCONF
	fi

	if [ "$TARGET_ARCH" = "" ]; then
		TARGET_ARCH=$ARCH
	fi

	# Add SMP and APIC options for i386 platform
	if [ "$ARCH" = "i386" ]; then
		echo "device 		apic" >> $KERNELCONF
		echo "options 		SMP"   >> $KERNELCONF
	fi

	# Add ALTQ_NOPCC which is needed for ALTQ
	echo "options		ALTQ_NOPCC" >> $KERNELCONF

	# Add SMP
	if [ "$ARCH" = "amd64" ]; then
		echo "options 		SMP"   >> $KERNELCONF
	fi
	if [ "$ARCH" = "powerpc" ]; then
		echo "options 		SMP"   >> $KERNELCONF
	fi

	if [ "$EXTRA_DEVICES" != "" ]; then
		echo "devices	$EXTRA_DEVICES" >> $KERNELCONF
	fi
	if [ "$NOEXTRA_DEVICES" != "" ]; then
		echo "nodevices	$NOEXTRA_DEVICES" >> $KERNELCONF
	fi
	if [ "$EXTRA_OPTIONS" != "" ]; then
		echo "options	$EXTRA_OPTIONS" >> $KERNELCONF
	fi
	if [ "$NOEXTRA_OPTIONS" != "" ]; then
		echo "nooptions	$NOEXTRA_OPTIONS" >> $KERNELCONF
	fi

	# NOTE!  If you remove this, you WILL break booting!  These file(s) are read
	#        by FORTH and for some reason installkernel with DESTDIR does not
	#        copy this file over and you will end up with a blank file?
	cp $SRCDIR/sys/boot/forth/loader.conf $KERNEL_DESTDIR/boot/defaults
	if [ -f $SRCDIR/sys/$ARCH/conf/GENERIC.hints ]; then
		cp $SRCDIR/sys/$ARCH/conf/GENERIC.hints	$KERNEL_DESTDIR/boot/device.hints
	fi
	if [ -f $SRCDIR/sys/mips/conf/$KERNCONF.hints ]; then
		cp $SRCDIR/sys/mips/conf/$KERNCONF.hints $KERNEL_DESTDIR/boot/device.hints
	fi
	# END NOTE.

	# Danger will robinson -- 7.2+ will NOT boot if these files are not present.
	# the loader will stop at |
	touch $KERNEL_DESTDIR/boot/loader.conf

}

# This routine builds nanobsd with VGA
build_embedded_kernel_vga() {
	# Build embedded kernel
	echo ">>> Building embedded VGA kernel..."
	find $MAKEOBJDIRPREFIX -name .done_buildkernel -exec rm {} \;
	find $MAKEOBJDIRPREFIX -name .done_installkernel -exec rm {} \;
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNCONF=pfSense_wrap_vga.${FREEBSD_VERSION}.${ARCH}
	export KERNEL_DESTDIR="$KERNEL_BUILD_PATH/wrap_vga"
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/pfSense_wrap_vga.${FREEBSD_VERSION}.${ARCH}"
	# Common fixup code
	fixup_kernel_options
	freesbie_make buildkernel
	echo ">>> Installing embedded VGA kernel..."
	freesbie_make installkernel
	mkdir -p $KERNEL_BUILD_PATH/wrap_vga/boot/defaults
	cp $SRCDIR/sys/boot/forth/loader.conf $KERNEL_BUILD_PATH/wrap_vga/boot/defaults/
	cp $SRCDIR/sys/$ARCH/conf/GENERIC.hints $KERNEL_BUILD_PATH/wrap_vga/boot/device.hints
	echo -n ">>> Installing kernels to LiveCD area..."
	(cd $KERNEL_BUILD_PATH/wrap_vga/boot/ && tar czf $PFSENSEBASEDIR/kernels/kernel_wrap_vga.gz .)
	echo -n "."
	chflags -R noschg $PFSENSEBASEDIR/boot/
	ensure_kernel_exists $KERNEL_DESTDIR
	(cd $PFSENSEBASEDIR/boot/ && tar xzf $PFSENSEBASEDIR/kernels/kernel_wrap_vga.gz -C $PFSENSEBASEDIR/boot/)
	echo "done."
}

# This routine builds the rspro kernel
build_rspro_kernel() {
	# Build embedded kernel
	echo ">>> Building rspro kernel..."
	find $MAKEOBJDIRPREFIX -name .done_buildkernel -exec rm {} \;
	find $MAKEOBJDIRPREFIX -name .done_installkernel -exec rm {} \;
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNCONF=AR71XX
	export KERNEL_DESTDIR="$KERNEL_BUILD_PATH/AR71XX"
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/AR71XX"
	cp $BUILDER_TOOLS/builder_scripts/conf/AR71XX* $SRCDIR/sys/mips/conf/
	# Common fixup code
	fixup_kernel_options
	freesbie_make buildkernel
	echo ">>> Installing rspro kernel..."
	freesbie_make installkernel
	cp $SRCDIR/sys/boot/forth/loader.conf $KERNEL_BUILD_PATH/AR71XX/boot/defaults/
	cp $SRCDIR/sys/$ARCH/conf/AR71XX.hints $KERNEL_BUILD_PATH/AR71XX/boot/device.hints
	echo -n ">>> Installing kernels to LiveCD area..."
	(cd $KERNEL_BUILD_PATH/AR71XX/boot/ && tar czf $PFSENSEBASEDIR/kernels/kernel_AR71XX.gz .)
	echo -n "."
	chflags -R noschg $PFSENSEBASEDIR/boot/
	ensure_kernel_exists $KERNEL_DESTDIR
	(cd $PFSENSEBASEDIR/boot/ && tar xzf $PFSENSEBASEDIR/kernels/kernel_AR71XX.gz -C $PFSENSEBASEDIR/boot/)
	echo "done."
}

# This routine builds the embedded kernel aka wrap
build_embedded_kernel() {
	# Build embedded kernel
	echo ">>> Building embedded kernel..."
	find $MAKEOBJDIRPREFIX -name .done_buildkernel -exec rm {} \;
	find $MAKEOBJDIRPREFIX -name .done_installkernel -exec rm {} \;
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNCONF=pfSense_wrap.${FREEBSD_VERSION}.${ARCH}
	export KERNEL_DESTDIR="$KERNEL_BUILD_PATH/wrap"
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/pfSense_wrap.${FREEBSD_VERSION}.${ARCH}"
	# Common fixup code
	fixup_kernel_options
	freesbie_make buildkernel
	echo ">>> Installing embedded kernel..."
	freesbie_make installkernel
	cp $SRCDIR/sys/boot/forth/loader.conf $KERNEL_BUILD_PATH/wrap/boot/defaults/
	cp $SRCDIR/sys/$ARCH/conf/GENERIC.hints $KERNEL_BUILD_PATH/wrap/boot/device.hints
	echo -n ">>> Installing kernels to LiveCD area..."
	(cd $KERNEL_BUILD_PATH/wrap/boot/ && tar czf $PFSENSEBASEDIR/kernels/kernel_wrap.gz .)
	echo -n "."
	chflags -R noschg $PFSENSEBASEDIR/boot/
	ensure_kernel_exists $KERNEL_DESTDIR
	(cd $PFSENSEBASEDIR/boot/ && tar xzf $PFSENSEBASEDIR/kernels/kernel_wrap.gz -C $PFSENSEBASEDIR/boot/)
	echo "done."
}

# This routine builds the developers kernel
build_dev_kernel() {
	# Build Developers kernel
	echo ">>> Building Developers kernel..."
	find $MAKEOBJDIRPREFIX -name .done_buildkernel -exec rm {} \;
	find $MAKEOBJDIRPREFIX -name .done_installkernel -exec rm {} \;
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/pfSense_Dev.${FREEBSD_VERSION}"
	export KERNEL_DESTDIR="$KERNEL_BUILD_PATH/developers"
	export KERNCONF=pfSense_Dev.${FREEBSD_VERSION}
	# Common fixup code
	fixup_kernel_options
	freesbie_make buildkernel
	echo ">>> Installing Developers kernel..."
	freesbie_make installkernel
	cp $SRCDIR/sys/boot/forth/loader.conf $KERNEL_BUILD_PATH/developers/boot/defaults/
	cp $SRCDIR/sys/$ARCH/conf/GENERIC.hints $KERNEL_BUILD_PATH/developers/boot/device.hints
	(cd $KERNEL_BUILD_PATH/developers/boot/ && tar czf $PFSENSEBASEDIR/kernels/kernel_Dev.gz .)
	ensure_kernel_exists $KERNEL_DESTDIR
	(cd $PFSENSEBASEDIR/boot/ && tar xzf $PFSENSEBASEDIR/kernels/kernel_Dev.gz -C $PFSENSEBASEDIR/boot/)
}

# This routine builds a freebsd specific kernel (no pfSense options)
build_freebsd_only_kernel() {
	# Build Developers kernel
	echo ">>> Building Developers kernel..."
	find $MAKEOBJDIRPREFIX -name .done_buildkernel -exec rm {} \;
	find $MAKEOBJDIRPREFIX -name .done_installkernel -exec rm {} \;
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/FreeBSD.${FREEBSD_VERSION}"
	export KERNEL_DESTDIR="$KERNEL_BUILD_PATH/freebsd"
	export KERNCONF=FreeBSD.${FREEBSD_VERSION}
	# Common fixup code
	fixup_kernel_options
	freesbie_make buildkernel
	echo ">>> Installing FreeBSD kernel..."
	freesbie_make installkernel
	cp $SRCDIR/sys/boot/forth/loader.conf $KERNEL_BUILD_PATH/freebsd/boot/defaults/
	cp $SRCDIR/sys/$ARCH/conf/GENERIC.hints $KERNEL_BUILD_PATH/freebsd/boot/device.hints
	(cd $KERNEL_BUILD_PATH/freebsd/boot/ && tar czf $PFSENSEBASEDIR/kernels/FreeBSD.tgz .)
	ensure_kernel_exists $KERNEL_DESTDIR
	(cd $PFSENSEBASEDIR/boot/ && tar xzf $PFSENSEBASEDIR/kernels/FreeBSD.tgz -C $PFSENSEBASEDIR/boot/)
}

# This routine builds all pfSense related kernels
# during the build_iso.sh and build_deviso.sh routines
build_all_kernels() {

	# If we have already installed kernels
	# no need to build them again.
	if [ "`find $MAKEOBJDIRPREFIX -name .done_installkernel | wc -l`" -gt 0 ]; then
		NO_BUILDKERNEL=yo
	fi

	# Build uniprocessor kernel
	echo ">>> Building uniprocessor kernel..."
	find $MAKEOBJDIRPREFIX -name .done_buildkernel -exec rm {} \;
	find $MAKEOBJDIRPREFIX -name .done_installkernel -exec rm {} \;
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNCONF=pfSense.${FREEBSD_VERSION}
	export KERNEL_DESTDIR="$KERNEL_BUILD_PATH/uniprocessor"
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/pfSense.${FREEBSD_VERSION}"
	# Common fixup code
	fixup_kernel_options
	freesbie_make buildkernel
	echo ">>> Installing uniprocessor kernel..."
	freesbie_make installkernel
	ensure_kernel_exists $KERNEL_DESTDIR

	# Build embedded kernel
	echo ">>> Building embedded kernel..."
	find $MAKEOBJDIRPREFIX -name .done_buildkernel -exec rm {} \;
	find $MAKEOBJDIRPREFIX -name .done_installkernel -exec rm {} \;
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNCONF=pfSense_wrap.${FREEBSD_VERSION}.${ARCH}
	export KERNEL_DESTDIR="$KERNEL_BUILD_PATH/wrap"
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/pfSense_wrap.${FREEBSD_VERSION}.${ARCH}"
	# Common fixup code
	fixup_kernel_options
	freesbie_make buildkernel
	echo ">>> Installing wrap kernel..."
	freesbie_make installkernel
	ensure_kernel_exists $KERNEL_DESTDIR

	# Build Developers kernel
	echo ">>> Building Developers kernel..."
	find $MAKEOBJDIRPREFIX -name .done_buildkernel -exec rm {} \;
	find $MAKEOBJDIRPREFIX -name .done_installkernel -exec rm {} \;
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNCONF=pfSense_Dev.${FREEBSD_VERSION}
	export KERNEL_DESTDIR="$KERNEL_BUILD_PATH/developers"
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/pfSense_Dev.${FREEBSD_VERSION}"
	# Common fixup code
	fixup_kernel_options
	freesbie_make buildkernel
	echo ">>> Installing Developers kernel..."
	freesbie_make installkernel
	ensure_kernel_exists $KERNEL_DESTDIR

	# Build SMP kernel
	echo ">>> Building SMP kernel..."
	find $MAKEOBJDIRPREFIX -name .done_buildkernel -exec rm {} \;
	find $MAKEOBJDIRPREFIX -name .done_installkernel -exec rm {} \;
	unset KERNCONF
	unset KERNEL_DESTDIR
	unset KERNELCONF
	export KERNCONF=pfSense_SMP.${FREEBSD_VERSION}
	export KERNEL_DESTDIR="$KERNEL_BUILD_PATH/SMP"
	export KERNELCONF="${TARGET_ARCH_CONF_DIR}/pfSense_SMP.${FREEBSD_VERSION}"
	# Common fixup code
	fixup_kernel_options
	freesbie_make buildkernel
	echo ">>> Installing SMP kernel..."
	freesbie_make installkernel
	ensure_kernel_exists $KERNEL_DESTDIR

	# Nuke symbols
	echo -n ">>> Cleaning up .symbols..."
	if [ -z "${PFSENSE_DEBUG:-}" ]; then
		echo -n "."
		find $PFSENSEBASEDIR/ -name "*.symbols" -exec rm -f {} \;
		echo -n "."
		find $KERNEL_BUILD_PATH -name "*.symbols" -exec rm -f {} \;
	fi

	# Nuke old kernel if it exists
	find $KERNEL_BUILD_PATH -name kernel.old -exec rm -rf {} \; 2>/dev/null
	echo "done."

	echo -n ">>> Installing kernels to LiveCD area..."
	(cd $KERNEL_BUILD_PATH/uniprocessor/boot/ && tar czf $PFSENSEBASEDIR/kernels/kernel_uniprocessor.gz .)
	echo -n "."
	(cd $KERNEL_BUILD_PATH/wrap/boot/ && tar czf $PFSENSEBASEDIR/kernels/kernel_wrap.gz .)
	echo -n "."
	(cd $KERNEL_BUILD_PATH/developers/boot/ && tar czf $PFSENSEBASEDIR/kernels/kernel_Dev.gz .)
	echo -n "."
	(cd $KERNEL_BUILD_PATH/SMP/boot/ && tar czf $PFSENSEBASEDIR/kernels/kernel_SMP.gz .)
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

# This routine rebuilds all pfPorts files which are generally
# in /home/pfsense/tools/pfPorts/
recompile_pfPorts() {

	if [ ! -d /usr/ports/ ]; then
		echo "==> Please wait, grabbing port files from FreeBSD.org..."
		portsnap fetch
		echo "==> Please wait, extracting port files..."
		portsnap extract
	fi

	if [ ! -f /tmp/pfSense_do_not_build_pfPorts ] || [ "$1" != "" ]; then

		# Set some neede variables
		pfSPORTS_COPY_BASE_DIR="$BUILDER_TOOLS/pfPorts"
		pfSPORTS_BASE_DIR="/usr/ports/pfPorts"
		if [ -n "$PFSPORTSFILE" ]; then
			USE_PORTS_FILE="${pfSPORTS_COPY_BASE_DIR}/${PFSPORTSFILE}"
		else
			USE_PORTS_FILE="${pfSPORTS_COPY_BASE_DIR}/buildports.${PFSENSETAG}"
		fi
		PFPORTSBASENAME=`basename ${USE_PORTS_FILE}`

		echo "--> Preparing for pfPorts build ${PFPORTSBASENAME}"
		if [ "$1" = "" ]; then
			# Warn user about make includes operation
			echo "--> WARNING!  We are about to run make includes."
			echo -n "--> Press CTRl-C to abort this operation"
			echo -n "."
			sleep 1
			echo -n "."
			sleep 1
			echo -n "."
			sleep 1
			echo -n "."
			sleep 1
			echo "."
			sleep 1

			# Since we are using NAT-T we need to run this prior
			# to the build.  Once NAT-T is included in FreeBSD
			# we can remove this step.
			echo "==> Starting make includes operation..."
			( cd $SRCDIR && make includes ) | egrep -wi '(^>>>|error)'
		else
			echo "--> Skipping the make includes run for a single port build."
		fi

		rm -rf ${pfSPORTS_BASE_DIR}
		mkdir ${pfSPORTS_BASE_DIR}

		echo "==> Compiling pfPorts..."
		if [ -f /etc/make.conf ]; then
			mv /etc/make.conf /tmp/
			echo "WITHOUT_X11=yo" >> /etc/make.conf
			MKCNF="pfPorts"
		fi
		if [ "$ARCH" = "mips" ]; then
			echo "WITHOUT_PERL_MALLOC=1" >> /etc/make.conf
			echo "TARGET_BIG_ENDIAN=yes" >> /etc/make.conf
		fi
		export FORCE_PKG_REGISTER=yo

		chmod a+rx $USE_PORTS_FILE
		echo ">>> Executing $PFPORTSBASENAME"

		if [ "$1" != "" ]; then
			( su - root -c "${USE_PORTS_FILE} -P ${1} -J '${MAKEJ_PORTS}' ${CHECK_PORTS_INSTALLED}" ) 2>&1
		else
			( su - root -c "${USE_PORTS_FILE} -J '${MAKEJ_PORTS}' ${CHECK_PORTS_INSTALLED}" ) 2>&1 \
				| egrep -v '(\-Werror|ignored|error\.[a-z])' | egrep -wi "(^>>>|error)"
		fi

		if [ "${MKCNF}x" = "pfPortsx" ]; then
			if [ -f /tmp/make.conf ]; then
				mv /tmp/make.conf /etc/
			fi
		fi

		if [ "$1" = "" ] || [ "$1" = "athstats" ]; then
			# athstats is a rare animal since it's src contents
			# live in $SRCDIR/tools/tools/ath/athstats
			handle_athstats

			touch /tmp/pfSense_do_not_build_pfPorts

			echo "==> End of pfPorts..."
		fi

	else
		echo "--> /tmp/pfSense_do_not_build_pfPorts is set, skipping pfPorts build..."
	fi
}

# This routine overlays needed binaries found in the
# CUSTOM_COPY_LIST variable.  Clog and syslgod are handled
# specially.
cust_overlay_host_binaries() {
	# Ensure directories exist
	# BEGIN required by gather_pfPorts_binaries_in_tgz
	mkdir -p ${PFSENSEBASEDIR}/lib/geom
	mkdir -p ${PFSENSEBASEDIR}/usr/local/lib/php/20060613/
	mkdir -p ${PFSENSEBASEDIR}/usr/local/share/rrdtool/fonts/
	mkdir -p ${PFSENSEBASEDIR}/usr/local/share/smartmontools/
	mkdir -p ${PFSENSEBASEDIR}/usr/local/lib/lighttpd/
	mkdir -p ${PFSENSEBASEDIR}/usr/share/man/man8
	mkdir -p ${PFSENSEBASEDIR}/usr/share/man/man5
	# END required by gather_pfPorts_binaries_in_tgz
	mkdir -p ${PFSENSEBASEDIR}/bin
	mkdir -p ${PFSENSEBASEDIR}/sbin
	mkdir -p ${PFSENSEBASEDIR}/usr/bin
	mkdir -p ${PFSENSEBASEDIR}/usr/sbin
	mkdir -p ${PFSENSEBASEDIR}/usr/lib
	mkdir -p ${PFSENSEBASEDIR}/usr/sbin
	mkdir -p ${PFSENSEBASEDIR}/usr/libexec
	mkdir -p ${PFSENSEBASEDIR}/usr/local/bin
	mkdir -p ${PFSENSEBASEDIR}/usr/local/sbin
	mkdir -p ${PFSENSEBASEDIR}/usr/local/lib
	mkdir -p ${PFSENSEBASEDIR}/usr/local/lib/mysql
	mkdir -p ${PFSENSEBASEDIR}/usr/local/libexec
	mkdir -p /tmp/pfPort

	# Overlay host binaries
	if [ ! -z "${CROSS_COMPILE_PORTS_BINARIES:-}" ]; then
		# This function is used where we can cross build the system
		# but ports require building on another box.  An example of
		# this scenario is mips.
		if [ -f $CROSS_COMPILE_PORTS_BINARIES  ]; then
			echo ">>> Found $CROSS_COMPILE_PORTS_BINARIES.  Installing..."
			(cd $PFSENSEBASEDIR && tar xzpf $CROSS_COMPILE_PORTS_BINARIES)
		else
			echo "The variable CROSS_COMPILE_PORTS_BINARIES is set but we cannot find the tgz."
			print_error_pfS
		fi
		return
	fi

	# handle syslogd
	PWD=`pwd`
	# Note, (cd foo && make) does not seem to work.
	# If you think you are cleaning this up then prepare
	# to spend a fair amount of time figuring out why the built
	# syslogd file doe snot reside in the correct directory to
	# install from.  Just move along now, nothing to see here.
	echo "==> Building syslogd..."
	cd $SRCDIR/usr.sbin/syslogd
	(make clean) | egrep -wi '(^>>>|error)'
 	(make ARCH=$ARCH) | egrep -wi '(^>>>|error)'
	(make install) | egrep -wi '(^>>>|error)'
	(make install DESTDIR=$PFSENSEBASEDIR) | egrep -wi '(^>>>|error)'
	echo "==> Installing syslogd to $PFSENSEBASEDIR/usr/sbin/..."
	if [ -f ${MAKEOBJDIRPREFIX}${SRCDIR}/usr.sbin/syslogd/syslogd ]; then
		install ${MAKEOBJDIRPREFIX}${SRCDIR}/usr.sbin/syslogd/syslogd $PFSENSEBASEDIR/usr/sbin/
	fi
	cd $PWD

	# Handle clog
	echo "==> Building clog..."
	if [ -d $SRCDIR/usr.sbin/clog ]; then
		(cd $SRCDIR/usr.sbin/clog && make clean) | egrep -wi '(^>>>|error)'
		(cd $SRCDIR/usr.sbin/clog && make ARCH=$ARCH) | egrep -wi '(^>>>|error)'
		(cd $SRCDIR/usr.sbin/clog && make install DESTDIR=$PFSENSEBASEDIR) | egrep -wi '(^>>>|error)'
	    echo "==> Installing clog to $PFSENSEBASEDIR/usr/sbin/..."
		if [ -f $SRCDIR/usr.sbin/clog/clog ]; then
	    	install $SRCDIR/usr.sbin/clog/clog $PFSENSEBASEDIR/usr/sbin/
		fi
	fi

	# Temporary hack for RELENG_1_2
	mkdir -p ${PFSENSEBASEDIR}/usr/local/lib/php/extensions/no-debug-non-zts-20020429/

	if [ ! -z "${CUSTOM_COPY_LIST:-}" ]; then
		echo ">>> Using ${CUSTOM_COPY_LIST:-}..."
		FOUND_FILES=`cat ${CUSTOM_COPY_LIST:-}`
	else
		echo ">>> Using copy.list.${PFSENSETAG}..."
		FOUND_FILES=`cat copy.list.${PFSENSETAG}`
	fi

	if [ -f /tmp/pfPort/copy.list ]; then
		rm /tmp/pfPort/copy.list
		touch /tmp/pfPort/copy.list
	else
		touch /tmp/pfPort/copy.list
	fi

	# Process base system libraries
	NEEDEDLIBS=""
	echo ">>> Populating newer binaries found on host jail/os (usr/local)..."
	for TEMPFILE in $FOUND_FILES; do
		if [ -f /${TEMPFILE} ]; then
			FILETYPE=`file /$TEMPFILE | egrep "(dynamically|shared)" | wc -l | awk '{ print $1 }'`
			if [ "$FILETYPE" -gt 0 ]; then
				NEEDLIB=`ldd /${TEMPFILE} | grep "=>" | awk '{ print $3 }'`
				NEEDEDLIBS="$NEEDEDLIBS $NEEDLIB" 
				cp /${TEMPFILE} ${PFSENSEBASEDIR}/${TEMPFILE}
				chmod a+rx ${PFSENSEBASEDIR}/${TEMPFILE}
				if [ -d $CLONEDIR ]; then
					for NEEDL in $NEEDLIB; do
						if [ -f $NEEDL ]; then
							cp /$NEEDL ${PFSENSEBASEDIR}/${NEEDL}
						fi
					done
				fi
			else
				cp /${TEMPFILE} ${PFSENSEBASEDIR}/$TEMPFILE
			fi
		else
			if [ -f ${CVS_CO_DIR}/${TEMPFILE} ]; then
				FILETYPE=`file ${CVS_CO_DIR}/${TEMPFILE} | grep dynamically | wc -l | awk '{ print $1 }'`
				if [ "$FILETYPE" -gt 0 ]; then
					NEEDEDLIBS="$NEEDEDLIBS `ldd ${CVS_CO_DIR}/${TEMPFILE} | grep "=>" | awk '{ print $3 }'`"
				fi
			else
				echo "Could not locate $TEMPFILE" >> /tmp/pfPort/copy.list				
			fi
		fi
	done
	echo ">>> Installing collected library information (usr/local), please wait..."
	# Unique the libraries so we only copy them once
	NEEDEDLIBS=`for LIB in ${NEEDEDLIBS} ; do echo $LIB ; done |sort -u`
	for NEEDLIB in $NEEDEDLIBS; do
		if [ -f $NEEDLIB ]; then
			install $NEEDLIB ${PFSENSEBASEDIR}${NEEDLIB}
			if [ -d $CLONEDIR ]; then
				install $NEEDLIB ${PFSENSEBASEDIR}${NEEDLIB}
			fi
		fi
	done

}

# This routine outputs the zero found files report
report_zero_sized_files() {
	if [ -f $MAKEOBJDIRPREFIX/zero_sized_files.txt ]; then
		cat $MAKEOBJDIRPREFIX/zero_sized_files.txt \
			| grep -v 270_install_bootblocks
		rm $MAKEOBJDIRPREFIX/zero_sized_files.txt
	fi
}

# This routine notes any files that are 0 sized.
check_for_zero_size_files() {
	rm -f $MAKEOBJDIRPREFIX/zero_sized_files.txt
	find $PFSENSEBASEDIR -perm -+x -type f -size 0 -exec echo "WARNING: {} is 0 sized" >> $MAKEOBJDIRPREFIX/zero_sized_files.txt \;
	find $KERNEL_BUILD_PATH/ -perm -+x -type f -size 0 -exec echo "WARNING: {} is 0 sized" >> $MAKEOBJDIRPREFIX/zero_sized_files.txt \;
	cat $MAKEOBJDIRPREFIX/zero_sized_files.txt
}

# Install custom BSDInstaller bits for FreeBSD
# only installations (no pfSense bits)
cust_populate_installer_bits_freebsd_only() {
	# Add lua installer items
	mkdir -p $PFSENSEBASEDIR/usr/local/share/dfuibe_lua/install/
	mkdir -p $PFSENSEBASEDIR/scripts/
	# This is now ready for general consumption! \o/
	mkdir -p $PFSENSEBASEDIR/usr/local/share/dfuibe_lua/conf/
	cp -r $BUILDER_TOOLS/installer/conf \
		$PFSENSEBASEDIR/usr/local/share/dfuibe_lua/
	# Copy installer launcher scripts
	cp $BUILDER_TOOLS/freebsd_installer $PFSENSEBASEDIR/scripts/
	chmod a+rx $PFSENSEBASEDIR/scripts/*
	rm -f $PFSENSEBASEDIR/usr/local/share/dfuibe_lua/install/599_after_installation_tasks.lua
	rm -f $CVS_CO_DIR/root/.hushlogin
	rm -f $PFSENSEBASEDIR/root/.hushlogin
}

# Install custom BSDInstaller bits for pfSense
cust_populate_installer_bits() {
	# Add lua installer items
	echo ">>> Using FreeBSD ${FREEBSD_VERSION} BSDInstaller dfuibelua structure."
	mkdir -p $PFSENSEBASEDIR/usr/local/share/dfuibe_lua/install/
	mkdir -p $PFSENSEBASEDIR/scripts/
	# This is now ready for general consumption! \o/
	mkdir -p $PFSENSEBASEDIR/usr/local/share/dfuibe_lua/conf/
	cp -r $BUILDER_TOOLS/installer/conf \
		$PFSENSEBASEDIR/usr/local/share/dfuibe_lua/
	# 597_ belongs in installation directory
	cp $BUILDER_TOOLS/installer/installer_root_dir7/597* \
		$PFSENSEBASEDIR/usr/local/share/dfuibe_lua/install/
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
	if [ "${PFSENSETAG}" = "RELENG_2_0" ]; then
		cp $BUILDER_TOOLS/lua_installer_RELENG_2 $PFSENSEBASEDIR/scripts/lua_installer
	else
		cp $BUILDER_TOOLS/lua_installer $PFSENSEBASEDIR/scripts/lua_installer
	fi
	cp $BUILDER_TOOLS/freebsd_installer $PFSENSEBASEDIR/scripts/
	cp $BUILDER_TOOLS/lua_installer_rescue $PFSENSEBASEDIR/scripts/
	cp $BUILDER_TOOLS/lua_installer_rescue $PFSENSEBASEDIR/scripts/
	cp $BUILDER_TOOLS/lua_installer_full $PFSENSEBASEDIR/scripts/
	chmod a+rx $PFSENSEBASEDIR/scripts/*
	cp $BUILDER_TOOLS/after_installation_routines.sh \
		$PFSENSEBASEDIR/usr/local/bin/after_installation_routines.sh
	chmod a+rx $PFSENSEBASEDIR/scripts/*
}

# Copies all extra files to the CVS staging
# area and ISO staging area (as needed)
cust_populate_extra() {
	# Make devd
	echo -n ">>> Making devd... "
	( cd ${SRCDIR}/sbin/devd && make clean >/tmp/make_devd_clean.out 2>&1 )
	( cd ${SRCDIR}/sbin/devd && make >/tmp/make_devd_all.out 2>&1 )
	if ( cd ${SRCDIR}/sbin/devd && make install DESTDIR=${PFSENSEBASEDIR} >/tmp/make_devd_install.out 2>&1 ); then
		echo "Done."
	else
		echo "Failed!"
	fi

	rm -f /tmp/make_devd_*.out

	mkdir -p ${CVS_CO_DIR}/lib

	if [ -f /usr/lib/pam_unix.so ]; then
		install -s /usr/lib/pam_unix.so ${PFSENSEBASEDIR}/usr/lib/
	fi

	STRUCTURE_TO_CREATE="root etc usr/local/pkg/parse_config var/run scripts conf usr/local/share/dfuibe_installer root usr/local/bin usr/local/sbin usr/local/lib usr/local/etc usr/local/lib/php/20060613 usr/local/lib/lighttpd"

	for TEMPDIR in $STRUCTURE_TO_CREATE; do
		mkdir -p ${CVS_CO_DIR}/${TEMPDIR}
		mkdir -p ${PFSENSEBASEDIR}/${TEMPDIR}
	done

	echo exit > $CVS_CO_DIR/root/.xcustom.sh
	touch $CVS_CO_DIR/root/.hushlogin

	# bsnmpd
	mkdir -p $CVS_CO_DIR/usr/share/snmp/defs/
	cp -R /usr/share/snmp/defs/ $CVS_CO_DIR/usr/share/snmp/defs/

	# Make sure parse_config exists

	# Set buildtime
	date > $CVS_CO_DIR/etc/version.buildtime

	# Record last commit info if it is available.
	if [ -f /tmp/build_commit_info.txt ]; then
		cp /tmp/build_commit_info.txt $CVS_CO_DIR/etc/version.lastcommit
	fi

	# Suppress extra spam when logging in
	touch $CVS_CO_DIR/root/.hushlogin

	# Setup login environment
	echo > $CVS_CO_DIR/root/.shrc

	# Detect interactive logins and display the shell
	echo "if [ \`env | grep SSH_TTY | wc -l\` -gt 0 ] || [ \`env | grep cons25 | wc -l\` -gt 0 ]; then" > $CVS_CO_DIR/root/.shrc
	echo "        /etc/rc.initial" >> $CVS_CO_DIR/root/.shrc
	echo "        exit" >> $CVS_CO_DIR/root/.shrc
	echo "fi" >> $CVS_CO_DIR/root/.shrc
	echo "if [ \`env | grep SSH_TTY | wc -l\` -gt 0 ] || [ \`env | grep cons25 | wc -l\` -gt 0 ]; then" >> $CVS_CO_DIR/root/.profile
	echo "        /etc/rc.initial" >> $CVS_CO_DIR/root/.profile
	echo "        exit" >> $CVS_CO_DIR/root/.profile
	echo "fi" >> $CVS_CO_DIR/root/.profile

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

# Copy a custom defined config.xml used commonly
# in rebranding and such applications.
cust_install_config_xml() {
	if [ ! -z "${USE_CONFIG_XML:-}" ]; then
		if [ -f "$USE_CONFIG_XML" ]; then
			echo ">>> Using custom config.xml file ${USE_CONFIG_XML} ..."
			cp ${USE_CONFIG_XML} ${PFSENSEBASEDIR}/cf/conf/config.xml
			cp ${USE_CONFIG_XML} ${PFSENSEBASEDIR}/conf.default/config.xml 2>/dev/null
			cp ${USE_CONFIG_XML} ${CVS_CO_DIR}/cf/conf/config.xml
			cp ${USE_CONFIG_XML} ${CVS_CO_DIR}/conf.default/config.xml 2>/dev/null
		fi
	fi
}

# This routine will copy over $custom_overlay onto
# the staging area.  It is commonly used for rebranding
# and or custom appliances.
install_custom_overlay() {
	# Extract custom overlay if it's defined.
	if [ ! -z "${custom_overlay:-}" ]; then
		echo -n ">>> Custom overlay defined - "
		if [ -d $custom_overlay ]; then
			echo " found directory, $custom_overlay copying..."
			for i in $custom_overlay/*
			do
			    if [ -d "$i" ]; then
			        echo ">>> Copying dir: $i ..."
			        cp -R $i $CVS_CO_DIR
			    else
			        echo ">>> Copying file: $i ..."
			        cp $i $CVS_CO_DIR
			    fi
			done
		elif [ -f $custom_overlay ]; then
			echo " found file, $custom_overlay extracting..."
			tar xzpf $custom_overlay -C $CVS_CO_DIR
		else
			echo " file not found $custom_overlay"
			print_error_pfS
		fi
	fi
	if [ ! -z "${custom_overlay_archive:-}" ]; then
		echo -n ">>> Custom overlay archive defined - "
		if [ -d $custom_overlay_archive ]; then
			echo " found directory, $custom_overlay_archive extracting files..."
			for i in $custom_overlay_archive/*
			do
			    if [ -f "$i" ]; then
			        echo ">>> Extracting file: $i ..."
			        tar xzpf $i -C $CVS_CO_DIR
			    fi
			done
		elif [ -f $custom_overlay_archive ]; then
			echo " found file, $custom_overlay_archive extracting..."
			tar xzpf $custom_overlay_archive -C $CVS_CO_DIR
		else
			echo " file not found $custom_overlay_archive"
			print_error_pfS
		fi
	fi

	# Enable debug if requested
	if [ ! -z "${PFSENSE_DEBUG:-}" ]; then
		touch ${CVS_CO_DIR}/debugging
	fi
}

setup_livecd_specifics() {
	if [ ! -d $CVS_CO_DIR/tank ]; then
		mkdir $CVS_CO_DIR/tank
	fi
	# Create a copy of this file just in case
	cp $PFSENSEBASEDIR/etc/gettytab $PFSENSEBASEDIR/etc/gettytab.bak
}

# This rotine will overlay $custom_overlay_final when
# the build is 99% completed.  Used to overwrite globals.inc
# and other files when we need to install packages from pfSense
# which would require a normal globals.inc.
install_custom_overlay_final() {
	# Extract custom overlay if it's defined.
	if [ ! -z "${custom_overlay_final:-}" ]; then
		echo -n ">>> Custom overlay defined - "
		if [ -d $custom_overlay_final ]; then
			echo " found directory, $custom_overlay_final copying..."
			for i in $custom_overlay_final/*
			do
		    		if [ -d $i ]; then
		       			echo ">>> Copying dir: $i $PFSENSEBASEDIR ..."
		        		cp -R $i $PFSENSEBASEDIR
		    		else
		        		echo ">>> Copying file: $i $PFSENSEBASEDIR ..."
		        		cp $i $PFSENSEBASEDIR
		    		fi
			done
		elif [ -f $custom_overlay_final ]; then
			echo " found file, $custom_overlay_final extracting..."
			tar xzpf $custom_overlay_final -C $PFSENSEBASEDIR
		else
			echo " file not found $custom_overlay_final"
			print_error_pfS
		fi
	fi

	# Enable debug if requested
	if [ ! -z "${PFSENSE_DEBUG:-}" ]; then
		touch ${CVS_CO_DIR}/debugging
	fi
}

# This is a FreeSBIE specific install ports -> overlay
# and might be going away very shortly.
install_custom_packages() {

	DEVFS_MOUNT=`mount | grep ${BASEDIR}/dev | wc -l | awk '{ print $1 }'`

	if [ "$DEVFS_MOUNT" -lt 1 ]; then
		echo ">>> Mounting devfs ${BASEDIR}/dev ..."
		mount -t devfs devfs ${BASEDIR}/dev
	fi

	PFSDESTNAME="pkginstall.sh"

	# Extra package list if defined.
	if [ ! -z "${custom_package_list:-}" ]; then
		# execute setup script
	else
		# cleanup if file does exist
		if [ -f ${FREESBIE_PATH}/extra/customscripts/${PFSDESTNAME} ]; then
			rm ${FREESBIE_PATH}/extra/customscripts/${PFSDESTNAME}
		fi
	fi

	# Clean up after ourselves.
	umount ${BASEDIR}/dev

}

# Create a base system update tarball
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

	#rm -f ${CVS_CO_DIR}/etc/platform
	rm -f ${CVS_CO_DIR}/etc/*passwd*
	rm -f ${CVS_CO_DIR}/etc/pw*
	rm -f ${CVS_CO_DIR}/etc/ttys

	( cd ${CVS_CO_DIR} && tar czPf ${UPDATESDIR}/${FILENAME} . )

	ls -lah ${UPDATESDIR}/${FILENAME}
	#if [ -e /usr/local/sbin/gzsig ]; then
	#	echo "Executing command: gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}"
	#	gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}
	#fi
}

# Various items that need to be removed
# when creating an update tarball.
fixup_updates() {

	# This step should be the last step before tarring the update, or
	# rolling an iso.

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
	#rm -f ${PFSENSEBASEDIR}/etc/platform 2>/dev/null
	rm -f ${PFSENSEBASEDIR}/root/.* 2>/dev/null

	setup_tcshrc_prompt

	# Setup login environment
	echo > ${PFSENSEBASEDIR}/root/.shrc
	echo "/etc/rc.initial" >> ${PFSENSEBASEDIR}/root/.shrc
	echo "exit" >> ${PFSENSEBASEDIR}/root/.shrc

	mkdir -p ${PFSENSEBASEDIR}/usr/local/livefs/lib/

	if [ -f ${CVS_CO_DIR}/etc/version.buildtime ]; then
		cp ${CVS_CO_DIR}/etc/version.buildtime ${PFSENSEBASEDIR}/etc/version.buildtime
	else
		date > ${PFSENSEBASEDIR}/etc/version.buildtime
	fi

	# Create a copy of this file just in case
	cp $PFSENSEBASEDIR/etc/gettytab $PFSENSEBASEDIR/etc/gettytab.bak

	if [ -d "${PFSENSEBASEDIR}" ]; then
		echo Removing pfSense.tgz used by installer..
		find ${PFSENSEBASEDIR} -name pfSense.tgz -exec rm {} \;
	fi

	cd $PREVIOUSDIR

}

setup_serial_hints() {
    #    When using the serial port as a boot console, be sure to update
    #    /boot/device.hints and /etc/ttys before booting the new kernel.
    #    If you forget to do so, you can still manually specify the hints
    #    at the loader prompt:
	echo 'hint.uart.0.at="isa"' >> $PFSENSEBASEDIR/boot/device.hints
	echo 'hint.uart.0.port="0x3F8"' >> $PFSENSEBASEDIR/boot/device.hints
	echo 'hint.uart.0.flags="0x10"' >> $PFSENSEBASEDIR/boot/device.hints
	echo 'hint.uart.0.irq="4"' >> $PFSENSEBASEDIR/boot/device.hints	
}

# Items that need to be fixed up that are
# specific to nanobsd builds
cust_fixup_nanobsd() {

	FBSD_VERSION=`/usr/bin/uname -r | /usr/bin/cut -d"." -f1`
	
	echo ">>> Fixing up NanoBSD Specific items..."
	[ -z "${NANO_WITH_VGA}" ] \
		&& cp $CVS_CO_DIR/boot/loader.conf_wrap $PFSENSEBASEDIR/boot/loader.conf
	[ -z "${NANO_WITH_VGA}" ] \
		&& cp $CVS_CO_DIR/etc/ttys_wrap $PFSENSEBASEDIR/etc/ttys

	# Be sure loader.conf exists, to avoid errors
	touch $PFSENSEBASEDIR/boot/loader.conf

	if [ "$FBSD_VERSION" -gt "7" -a -z "${NANO_WITH_VGA}" ]; then
		setup_serial_hints
	fi

	if [ -f ${CVS_CO_DIR}/etc/version.buildtime ]; then
		cp ${CVS_CO_DIR}/etc/version.buildtime ${PFSENSEBASEDIR}/etc/version.buildtime
	else
		date > ${PFSENSEBASEDIR}/etc/version.buildtime
	fi
    echo "" > $PFSENSEBASEDIR/etc/motd

    mkdir -p $PFSENSEBASEDIR/cf/conf/backup

    echo /etc/rc.initial > $PFSENSEBASEDIR/root/.shrc
    echo exit >> $PFSENSEBASEDIR/root/.shrc
    rm -f $PFSENSEBASEDIR/usr/local/bin/after_installation_routines.sh 2>/dev/null

    echo "nanobsd" > $PFSENSEBASEDIR/etc/platform
	[ -z "${NANO_WITH_VGA}" ] \
		&& echo "wrap"     > $PFSENSEBASEDIR/boot/kernel/pfsense_kernel.txt \
		|| echo "wrap_vga" > $PFSENSEBASEDIR/boot/kernel/pfsense_kernel.txt

	if [ -z "${NANO_WITH_VGA}" ]; then
		# Tell loader to use serial console early.
		echo "-h" >> $PFSENSEBASEDIR/boot.config

		if [ "$FBSD_VERSION" -gt "7" ]; then
			# Enable getty on console
			sed -i "" -e /ttyd0/s/off/on/ ${PFSENSEBASEDIR}/etc/ttys

			# Disable getty on syscons devices
			sed -i "" -e '/^ttyv[0-8]/s/    on/     off/' ${PFSENSEBASEDIR}/etc/ttys
		fi
	else
		# Empty file to identify nanobsd_vga images
		touch ${PFSENSEBASEDIR}/etc/nano_use_vga.txt
	fi
	
	setup_tcshrc_prompt

}

# Items that should be fixed up that are related
# to embedded aka wrap builds
cust_fixup_wrap() {

	echo "Fixing up Embedded Specific items..."
    	cp $CVS_CO_DIR/boot/device.hints_wrap \
            	$PFSENSEBASEDIR/boot/device.hints
    cp $CVS_CO_DIR/boot/loader.conf_wrap \
            $PFSENSEBASEDIR/boot/loader.conf
    cp $CVS_CO_DIR/etc/ttys_wrap \
            $PFSENSEBASEDIR/etc/ttys

	if [ -f ${CVS_CO_DIR}/etc/version.buildtime ]; then
		cp ${CVS_CO_DIR}/etc/version.buildtime ${PFSENSEBASEDIR}/etc/version.buildtime
	else
		date > ${PFSENSEBASEDIR}/etc/version.buildtime
	fi
    echo "" > $PFSENSEBASEDIR/etc/motd

    mkdir -p $PFSENSEBASEDIR/cf/conf/backup

    echo /etc/rc.initial > $PFSENSEBASEDIR/root/.shrc
    echo exit >> $PFSENSEBASEDIR/root/.shrc
    rm -f $PFSENSEBASEDIR/usr/local/bin/after_installation_routines.sh 2>/dev/null

    echo "embedded" > $PFSENSEBASEDIR/etc/platform
    echo "wrap" > $PFSENSEBASEDIR/boot/kernel/pfsense_kernel.txt

	echo "-h" >> $PFSENSEBASEDIR/boot.config

	FBSD_VERSION=`/usr/bin/uname -r | /usr/bin/cut -d"." -f1`
	if [ "$FBSD_VERSION" -gt "7" ]; then
		# Enable getty on console
		sed -i "" -e /ttyd0/s/off/on/ ${PFSENSEBASEDIR}/etc/ttys

		# Disable getty on syscons devices
		sed -i "" -e '/^ttyv[0-8]/s/    on/     off/' ${PFSENSEBASEDIR}/etc/ttys

		# Tell loader to use serial console early.
		echo " -h" > ${PFSENSEBASEDIR}/boot.config
	fi

	setup_tcshrc_prompt

}

setup_tcshrc_prompt() {
	echo 'set prompt="%{\033[0;1;33m%}[%{\033[0;1;37m%}`cat /etc/version`%{\033[0;1;33m%}]%{\033[0;1;33m%}%B[%{\033[0;1;37m%}%n%{\033[0;1;31m%}@%{\033[0;1;37m%}%M%{\033[0;1;33m%}]%{\033[0;1;32m%}%b%/%{\033[0;1;33m%}(%{\033[0;1;37m%}%h%{\033[0;1;33m%})%{\033[0;1;36m%}%{\033[0;1;31m%}:%{\033[0;40;37m%} "' > ${PFSENSEBASEDIR}/root/.tcshrc
	echo 'set autologout="0"' >> ${PFSENSEBASEDIR}/root/.tcshrc
	echo 'set autolist set color set colorcat' >> ${PFSENSEBASEDIR}/root/.tcshrc
	echo 'setenv CLICOLOR "true"' >> ${PFSENSEBASEDIR}/root/.tcshrc
	echo 'setenv LSCOLORS "exfxcxdxbxegedabagacad"' >> ${PFSENSEBASEDIR}/root/.tcshrc
	echo "alias installer /scripts/lua_installer" >> ${PFSENSEBASEDIR}/root/.tcshrc
}

# Creates a FreeBSD specific updater tarball
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
	#if [ -e /usr/local/sbin/gzsig ]; then
	#	echo ">>> Executing command: gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}"
	#	gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}
	#fi

	cd $PREVIOUSDIR

}

# This routine will verify that PHP is sound and that it
# can open and read config.xml and ensure the hostname
test_php_install() {
	echo -n ">>> Testing PHP installation in ${PFSENSEBASEDIR}:"

	# backup original conf dir
	if [ -d $PFSENSEBASEDIR/conf ]; then
		/bin/mv $PFSENSEBASEDIR/conf $PFSENSEBASEDIR/conf.org
		mkdir -p $PFSENSEBASEDIR/tmp/
		/usr/bin/touch $PFSENSEBASEDIR/tmp/restore_conf_dir
	fi

	# test whether conf dir is already a symlink
	if [ ! -h $PFSENSEBASEDIR/conf ]; then
		# install the symlink as it would exist on a live system
		chroot $PFSENSEBASEDIR /bin/ln -s /conf.default /conf 2>/dev/null
		chroot $PFSENSEBASEDIR /bin/ln -s /conf /cf 2>/dev/null
		/usr/bin/touch $PFSENSEBASEDIR/tmp/remove_conf_symlink
	fi

	# We might need to setup php.ini
	if [ -f "/boot/kernel/ng_socket.so" ]; then
		kldload -v /boot/kernel/ng_socket.ko 2>/dev/null
		echo ">>> Loading ng_socket.ko needed for testing php."
	fi
	if [ -f "$PFSENSEBASEDIR/etc/rc.php_ini_setup" ]; then
		mkdir -p $PFSENSEBASEDIR/usr/local/lib/ $PFSENSEBASEDIR/usr/local/etc/
		chroot $PFSENSEBASEDIR /etc/rc.php_ini_setup
	fi

	cp $BUILDER_SCRIPTS/test_php.php $PFSENSEBASEDIR/
	chmod a+rx $PFSENSEBASEDIR/test_php.php
	HOSTNAME=`env SHELL=/bin/sh chroot $PFSENSEBASEDIR /test_php.php`
	echo -n " $HOSTNAME "
	if [ "$HOSTNAME" != "FCGI-PASSED PASSED" ]; then
		echo
		echo
		echo "An error occured while testing the php installation in $PFSENSEBASEDIR"
		echo
		print_error_pfS
		die
	else
		echo " [OK]"
	fi

	#
	# Cleanup, aisle 7!
	#
	if [ -f $PFSENSEBASEDIR/tmp/remove_platform ]; then
		/bin/rm $PFSENSEBASEDIR/etc/platform
		/bin/rm $PFSENSEBASEDIR/tmp/remove_platform
	fi

	if [ -f $PFSENSEBASEDIR/tmp/remove_conf_symlink ]; then
		/bin/rm $PFSENSEBASEDIR/conf
		if [ -h $PFSENSEBASEDIR/cf ]; then
			/bin/rm $PFSENSEBASEDIR/cf
		fi
		/bin/rm $PFSENSEBASEDIR/tmp/remove_conf_symlink
	fi

	if [ -f $PFSENSEBASEDIR/tmp/restore_conf_dir ]; then
		/bin/mv $PFSENSEBASEDIR/conf.org $PFSENSEBASEDIR/conf
		/bin/rm $PFSENSEBASEDIR/tmp/restore_conf_dir
	fi

	if [ -f /tmp/platform ]; then
		mv $PFSENSEBASEDIR/tmp/platform $PFSENSEBASEDIR/etc/platform
	fi

	if [ -f $PFSENSEBASEDIR/tmp/config.cache ]; then
		/bin/rm $PFSENSEBASEDIR/tmp/config.cache
	fi

	if [ -f $PFSENSEBASEDIR/tmp/php.ini ]; then
		cp /tmp/php.ini $PFSENSEBASEDIR/usr/local/lib/php.ini
		cp /tmp/php.ini $PFSENSEBASEDIR/usr/local/etc/php.ini
	fi

}

# This routine creates a on disk summary of all file
# checksums which could be used to verify that a file
# is indeed how it was shipped.
create_md5_summary_file() {
	echo -n ">>> Creating md5 summary of files present..."
	rm -f $PFSENSEBASEDIR/etc/pfSense_md5.txt
	echo "#!/bin/sh" > $PFSENSEBASEDIR/chroot.sh
	echo "find / -type f | /usr/bin/xargs /sbin/md5 >> /etc/pfSense_md5.txt" >> $PFSENSEBASEDIR/chroot.sh
	chmod a+rx $PFSENSEBASEDIR/chroot.sh
	(chroot $PFSENSEBASEDIR /chroot.sh) 2>&1 | egrep -wi '(^>>>|errors)'
	rm $PFSENSEBASEDIR/chroot.sh
	echo "Done."
}

# Creates a full update file
create_pfSense_Full_update_tarball() {
	mkdir -p $UPDATESDIR

	PREVIOUSDIR=`pwd`

	echo ; echo "Deleting files listed in ${PRUNE_LIST}"
	set +e

	# Ensure that we do not step on /root/ scripts that
	# control auto login, console menu, etc.
	rm -f ${PFSENSEBASEDIR}/root/.* 2>/dev/null

	# Remove loader.conf and friends.  Ticket #560
	rm ${PFSENSEBASEDIR}/boot/loader.conf 2>/dev/null
	rm ${PFSENSEBASEDIR}/boot/loader.conf.local 2>/dev/null

	(cd ${PFSENSEBASEDIR} && sed 's/^#.*//g' ${PRUNE_LIST} | xargs rm -rvf > /dev/null 2>&1)

	install_custom_overlay
	install_custom_overlay_final

	create_md5_summary_file

	echo ; echo Creating ${UPDATES_TARBALL_FILENAME} ...
	cd ${PFSENSEBASEDIR} && tar czPf ${UPDATES_TARBALL_FILENAME} .

	#if [ -e /usr/local/sbin/gzsig ]; then
	#   echo "Signing ${UPDATESDIR}/${FILENAME} update file..."
	#	echo ">>> Executing command: gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}"
	#	gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}
	#fi

	cd $PREVIOUSDIR
}

# Creates a embedded specific update file
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
	#if [ -e /usr/local/sbin/gzsig ]; then
	#	echo "Executing command: gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}"
	#	gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}
	#fi

	cd $PREVIOUSDIR

}

# Creates a "small" update file
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

	#rm -f ${CVS_CO_DIR}/etc/platform
	rm -f ${CVS_CO_DIR}/etc/*passwd*
	rm -f ${CVS_CO_DIR}/etc/pw*
	rm -f ${CVS_CO_DIR}/etc/ttys*

	cd ${CVS_CO_DIR} && tar czPf ${UPDATESDIR}/${FILENAME} .

	ls -lah ${UPDATESDIR}/${FILENAME}

	#if [ -e /usr/local/sbin/gzsig ]; then
	#	echo ">>> Executing command: gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}"
	#	gzsig sign ~/.ssh/id_dsa ${UPDATESDIR}/${FILENAME}
	#fi

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

# Overlays items checked out from GIT on top
# of the staging area.  This is how the bits
# get transfered from rcs to the builder staging area.
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
	#if [ "$FBSD_VERSION" -gt "7" ]; then
		echo ">>> Using TAR to clone clone_system_only()..."
		tar cf - * | ( cd /$FREESBIEISODIR; tar xfp -)
	#else
	#	echo ">>> Using CPIO to clone..."
	#	find . -print -depth | cpio --quiet -pudm $FREESBIEISODIR
	#fi

	umount_devices $MDDEVICES

	trap "" INT

	echo " [DONE]"

	cd $PREVIOUSDIR
}

# Does the work of checking out the specific branch of pfSense
checkout_pfSense_git() {
	echo ">>> Using GIT to checkout ${PFSENSETAG}"
	echo -n ">>> "

	mkdir -p ${GIT_REPO_DIR}/pfSenseGITREPO
	if [ "${PFSENSETAG}" = "RELENG_2_0" ] \
            || [ "${PFSENSETAG}" = 'HEAD' ]; then
        	echo -n 'Checking out tag master...'
        	BRANCH=master
        	(cd ${GIT_REPO_DIR}/pfSenseGITREPO && git checkout master) \
			2>&1 | egrep -wi '(^>>>|error)'
	else
		echo -n "Checking out tag ${PFSENSETAG}..."
		BRANCH="${PFSENSETAG}"
		branch_exists=`(cd ${GIT_REPO_DIR}/pfSenseGITREPO \
			&& git branch | grep "${PFSENSETAG}")`
		if [ -z "$branch_exists" ]; then
			(cd ${GIT_REPO_DIR}/pfSenseGITREPO \
				&& git checkout -b "${PFSENSETAG}" "origin/${PFSENSETAG}") \
				2>&1 | egrep -wi '(^>>>|error)'
		else
			(cd ${GIT_REPO_DIR}/pfSenseGITREPO \
				&& git checkout "${PFSENSETAG}") 2>&1 \
				| egrep -wi '(^>>>|error)'
		fi
	fi
	echo 'Done!'

	echo -n '>>> Making sure we are in the right branch...'
	selected_branch=`cd ${GIT_REPO_DIR}/pfSenseGITREPO && \
		git branch | grep '^\*' | cut -d' ' -f2`
	if [ "${selected_branch}" = "${BRANCH}" ]; then
		echo " [OK] (${BRANCH})"
	else
		echo " [FAILED!] (${BRANCH})"
		print_error_pfS 'Checked out branch differs from configured BRANCH, something is wrong with the build system!'
		kill $$
	fi

	echo -n ">>> Creating tarball of checked out contents..."
	mkdir -p $CVS_CO_DIR
	cd ${GIT_REPO_DIR}/pfSenseGITREPO && tar czpf /tmp/pfSense.tgz .
	cd $CVS_CO_DIR && tar xzpf /tmp/pfSense.tgz
	rm /tmp/pfSense.tgz
	rm -rf ${CVS_CO_DIR}/.git
	echo "Done!"
}

# Invokes the rcs checkout routines
checkout_pfSense() {
	PREVIOUSDIR=`pwd`
	echo ">>> Checking out pfSense version ${PFSENSETAG}..."
	rm -rf $CVS_CO_DIR
	if [ -z "${USE_GIT:-}" ]; then
		(cd $BASE_DIR && cvs -d ${BASE_DIR}/cvsroot co pfSense -r ${PFSENSETAG})
	else
		checkout_pfSense_git
	fi
	cd $PREVIOUSDIR
}

# Outputs various set variables aka env
print_flags() {

	echo
	printf "                 Remove list: %s\n" $CUSTOM_REMOVE_LIST
	printf "                   Copy list: %s\n" $CUSTOM_COPY_LIST
	printf "            MAKEOBJDIRPREFIX: %s\n" $MAKEOBJDIRPREFIX
	printf "           pfSense build dir: %s\n" $SRCDIR
	printf "             pfSense version: %s\n" $PFSENSE_VERSION
	printf "                    CVS User: %s\n" $CVS_USER
	printf "                   Verbosity: %s\n" $BE_VERBOSE
	printf "                    Base dir: %s\n" $BASE_DIR
	printf "                Checkout dir: %s\n" $CVS_CO_DIR
	printf "                 Custom root: %s\n" $CUSTOMROOT
	printf "              CVS IP address: %s\n" $CVS_IP
	printf "                 Updates dir: %s\n" $UPDATESDIR
	printf "                pfS Base dir: %s\n" $PFSENSEBASEDIR
	printf "               FreeSBIE path: %s\n" $FREESBIE_PATH
	printf "               FreeSBIE conf: %s\n" $FREESBIE_CONF
	printf "                  Source DIR: %s\n" $SRCDIR
	printf "                   Clone DIR: %s\n" $CLONEDIR
	printf "              Custom overlay: %s\n" $custom_overlay
	printf "             pfSense version: %s\n" $FREEBSD_VERSION
	printf "              FreeBSD branch: %s\n" $FREEBSD_BRANCH
	printf "                 pfSense Tag: %s\n" $PFSENSETAG
	printf "                       EXTRA: %s\n" $EXTRA
	printf "                BUILDMODULES: %s\n" $MODULES_OVERRIDE
	printf "              Git Repository: %s\n" $GIT_REPO
	printf "                  Git Branch: %s\n" $GIT_BRANCH
	printf "               Custom Config: %s\n" $USE_CONFIG_XML
	printf "                     ISOPATH: %s\n" $ISOPATH
	printf "                     IMGPATH: %s\n" $IMGPATH
	printf "                  KERNELCONF: %s\n" $KERNELCONF
	printf "        TARGET_ARCH_CONF_DIR: %s\n" $TARGET_ARCH_CONF_DIR
	printf "     FREESBIE_COMPLETED_MAIL: %s\n" $FREESBIE_COMPLETED_MAIL
	printf "         FREESBIE_ERROR_MAIL: %s\n" $FREESBIE_ERROR_MAIL
if [ -n "$PFSENSECVSDATETIME" ]; then
	printf "              pfSense TSTAMP: %s\n" "-D \"$PFSENSECVSDATETIME\""
fi
	printf "                    SRC_CONF: %s\n" $SRC_CONF
	printf "CROSS_COMPILE_PORTS_BINARIES: %s\n" $CROSS_COMPILE_PORTS_BINARIES
	printf "            SPLIT_ARCH_BUILD: %s\n" $SPLIT_ARCH_BUILD
	printf "    UPDATES_TARBALL_FILENAME: %s\n" $UPDATES_TARBALL_FILENAME
if [ -n "$SHOW_ENV" ]; then
	for LINE in `env | grep -v "terminal" | grep -v "PASS" | grep -v "NAME" | grep -v "USER" | grep -v "SSH" | grep -v "GROUP" | grep -v "HOST"`; do
		echo "SHOW_ENV: $LINE"
	done
fi
	echo
	
}

# Backs up pfSense repo
backup_pfSense() {
	echo ">>> Backing up pfSense repo"
	cp -R $CVS_CO_DIR $BASE_DIR/pfSense_bak
}

# Restores backed up pfSense repo
restore_pfSense() {
	echo ">>> Restoring pfSense repo"
	cp -R $BASE_DIR/pfSense_bak $CVS_CO_DIR
}

# Shortcut to FreeSBIE make command
freesbie_make() {
	(cd ${FREESBIE_PATH} && make $*)
}

# This updates the pfSense sources from rcs.pfsense.org
update_cvs_depot() {
	if [ -z "${USE_GIT:-}" ]; then
		local _cvsdate
		echo ">>> Launching csup pfSense-supfile..."
		(/usr/bin/csup -b $BASE_DIR/cvsroot pfSense-supfile) 2>&1 | egrep -B3 -A3 -wi '(error)'
		rm -rf pfSense
		echo ">>> Updating ${BASE_DIR}/pfSense..."
		rm -rf $BASE_DIR/pfSense
		if [ -n "$PFSENSECVSDATETIME" ]; then
			_cvsdate="-D $PFSENSECVSDATETIME"
		fi
		(cd ${BASE_DIR} && cvs -d $BASE_DIR/cvsroot co -r ${PFSENSETAG} $_cvsdate pfSense) \
			| egrep -wi "(^\?|^M|^C|error|warning)"
		(cd ${BUILDER_TOOLS}/ && cvs update -d) \
			| egrep -wi "(^\?|^M|^C|error|warning)"
	else
		if [ ! -d "${GIT_REPO_DIR}" ]; then
			echo ">>> Creating ${GIT_REPO_DIR}"
			mkdir -p ${GIT_REPO_DIR}
		fi
		if [ ! -d "${GIT_REPO_DIR}/pfSenseGITREPO" ]; then
			echo -n ">>> Cloning ${GIT_REPO} / ${PFSENSETAG}..."
			(cd ${GIT_REPO_DIR} && /usr/local/bin/git clone ${GIT_REPO} pfSenseGITREPO) 2>&1 | egrep -B3 -A3 -wi '(error)'
			if [ -d "${GIT_REPO_DIR}/pfSenseGITREPO" ]; then
				if [ ! -d "${GIT_REPO_DIR}/pfSenseGITREPO/conf.default" ]; then
					echo
					echo "!!!! An error occured while checking out pfSense"
					echo "     Could not locate ${GIT_REPO_DIR}/pfSenseGITREPO/conf.default"
					echo
					print_error_pfS
					kill $$
				fi
			else
				echo
				echo "!!!! An error occured while checking out pfSense"
				echo "     Could not locate ${GIT_REPO_DIR}/pfSenseGITREPO"
				echo
				print_error_pfS
				kill $$
			fi
			echo "Done!"
		fi
		checkout_pfSense_git
		if [ $? != 0 ]; then
			echo "Something went wrong while checking out GIT."
			print_error_pfS
		fi
	fi
}

# This builds FreeBSD (make buildworld)
make_world() {

	if [ -d $MAKEOBJDIRPREFIX ]; then
		find $MAKEOBJDIRPREFIX/ -name .done_installworld -exec rm {} \;
		find $MAKEOBJDIRPREFIX/ -name .done_buildworld -exec rm {} \;
		find $MAKEOBJDIRPREFIX/ -name .done_extra -exec rm {} \;
		find $MAKEOBJDIRPREFIX/ -name .done_objdir -exec rm {} \;

		# Check if the world and kernel are already built and set
		# the NO variables accordingly
		ISINSTALLED=`find ${MAKEOBJDIRPREFIX}/ -name init | wc -l`
		if [ "$ISINSTALLED" -gt 0 ]; then
			touch ${MAKEOBJDIRPREFIX}/.done_buildworld
			export NO_BUILDWORLD=yo
		fi
	fi

	# Check to see if we have installed to $PFSENSEBASEDIR
	ISINSTALLED=0
	if [ -d ${PFSENSEBASEDIR} ]; then
		ISINSTALLED=`find ${PFSENSEBASEDIR}/ -name init | wc -l`
		if [ "$ISINSTALLED" -gt 0 ]; then
			touch ${MAKEOBJDIRPREFIX}/.done_installworld
			export NO_INSTALLWORLD=yo
		fi
	fi

	# Invoke FreeSBIE's buildworld
	freesbie_make buildworld

	# EDGE CASE #1 btxldr ############################################
	# Sometimes inbetween build_iso runs btxld seems to go missing.
	# ensure that this binary is always built and ready.
	echo ">>> Ensuring that the btxld problem does not happen on subsequent runs..."
	FBSD_VERSION=`/usr/bin/uname -r | /usr/bin/cut -d"." -f1`
	if [ "$FBSD_VERSION" = "7" ]; then
		(cd $SRCDIR/sys/boot && env ARCH=$ARCH TARGET_ARCH=${ARCH} \
			MAKEOBJDIRPREFIX=$MAKEOBJDIRPREFIX make $MAKEJ_WORLD NO_CLEAN=yo) 2>&1 \
			| egrep -wi '(warning|error)'
	fi
	(cd $SRCDIR/usr.sbin/btxld && env ARCH=$ARCH TARGET_ARCH=${ARCH} MAKEOBJDIRPREFIX=$MAKEOBJDIRPREFIX make $MAKEJ_WORLD NO_CLEAN=yo) 2>&1 \
		| egrep -wi '(warning|error)'
	(cd $SRCDIR/usr.sbin/btxld && env ARCH=$ARCH TARGET_ARCH=${ARCH} \
		MAKEOBJDIRPREFIX=$MAKEOBJDIRPREFIX make $MAKEJ_WORLD NO_CLEAN=yo) 2>&1 \
		| egrep -wi '(warning|error)'
	(cd $SRCDIR/sys/boot/$ARCH/btx/btx && env ARCH=$ARCH TARGET_ARCH=${ARCH} \
		MAKEOBJDIRPREFIX=$MAKEOBJDIRPREFIX make $MAKEJ_WORLD NO_CLEAN=yo) 2>&1 \
		| egrep -wi '(warning|error)'
	if [ "$ARCH" = "i386" ]; then
		(cd $SRCDIR/sys/boot/i386/pxeldr && env ARCH=$ARCH TARGET_ARCH=${ARCH} \
			MAKEOBJDIRPREFIX=$MAKEOBJDIRPREFIX make $MAKEJ_WORLD NO_CLEAN=yo) 2>&1 \
			| egrep -wi '(warning|error)'
	fi

	# EDGE CASE #2 yp.h ##############################################
	# Ensure yp.h is built, this commonly has issues for some
	# reason on subsequent build runs and results in file not found.
	if [ ! -f $MAKEOBJDIRPREFIX/$SRCDIR/include/rpcsvc/yp.h ]; then
		rm -rf $MAKEOBJDIRPREFIX/$SRCDIR/lib/libc
		(cd $SRCDIR/lib/libc && env TARGET_ARCH=${ARCH} \
			MAKEOBJDIRPREFIX=$MAKEOBJDIRPREFIX make $MAKEJ_WORLD \
			NO_CLEAN=yo) 2>&1 | egrep -wi '(warning|error)'
	fi

	# EDGE CASE #3 libc_p.a  #########################################

	# Invoke FreeSBIE's installworld
	freesbie_make installworld

	# Ensure home directory exists
	mkdir -p $PFSENSEBASEDIR/home
}

# This routine originated in nanobsd.sh
setup_nanobsd_etc ( ) {
	echo ">>> Configuring NanoBSD /etc"

	cd ${CLONEDIR}

	# Set NanoBSD image size
	echo "$FLASH_SIZE" > etc/nanosize.txt

	# create diskless marker file
	touch etc/diskless
	touch nanobuild

	# Make root filesystem R/O by default
	echo "root_rw_mount=NO" >> etc/defaults/rc.conf

	echo "/dev/ufs/pfsense0 / ufs ro,sync,noatime 1 1" > etc/fstab
	echo "/dev/ufs/cf /cf ufs ro,sync,noatime 1 1" >> etc/fstab

}

# This routine originated in nanobsd.sh
setup_nanobsd ( ) {
	echo ">>> Configuring NanoBSD setup"

	cd ${CLONEDIR}

	# Create /conf directory hier
	for d in etc
	do
		# link /$d under /${CONFIG_DIR}
		# we use hard links so we have them both places.
		# the files in /$d will be hidden by the mount.
		# XXX: configure /$d ramdisk size
		mkdir -p ${CONFIG_DIR}/base/$d ${CONFIG_DIR}/default/$d
		FBSD_VERSION=`/usr/bin/uname -r | /usr/bin/cut -d"." -f1`
		#if [ "$FBSD_VERSION" -gt "7" ]; then
			echo ">>> Using TAR to clone setup_nanobsd()..."
			tar cf - `find $d -print` | ( cd ${CONFIG_DIR}/base/; tar xfp -)
		#else
		#	echo ">>> Using CPIO to clone..."
		#	find $d -print | cpio -dump -l ${CONFIG_DIR}/base/
		#fi
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

	# Ensure updatep1 and updatep1 are present
	if [ ! -d $PFSENSEBASEDIR/root ]; then
		mkdir $PFSENSEBASEDIR/root
	fi
}

# This routine originated in nanobsd.sh
prune_usr() {
	echo ">>> Pruning NanoBSD usr directory..."
	# Remove all empty directories in /usr
}

# This routine originated in nanobsd.sh
FlashDevice () {
	a1=`echo $1 | tr '[:upper:]' '[:lower:]'`
	a2=`echo $2 | tr '[:upper:]' '[:lower:]'`
	case $a1 in
	integral)
		# Source: mich@FreeBSD.org
		case $a2 in
		256|256mb)
			NANO_MEDIASIZE=`expr 259596288 / 512`
			NANO_HEADS=16
			NANO_SECTS=63
			;;
		*)
			echo "Unknown Integral i-Pro Flash capacity"
			exit 2
			;;
		esac
		;;
	memorycorp)
		# Source: simon@FreeBSD.org
		case $a2 in
		512|512mb)
			# MC512CFLS2
			NANO_MEDIASIZE=`expr 519192576 / 512`
			NANO_HEADS=16
			NANO_SECTS=63
			;;
		*)
			echo "Unknown Memory Corp Flash capacity"
			exit 2
			;;
		esac
		;;
	sandisk)
		# Source:
		#	SanDisk CompactFlash Memory Card
		#	Product Manual
		#	Version 10.9
		#	Document No. 20-10-00038
		#	April 2005
		# Table 2-7
		# NB: notice math error in SDCFJ-4096-388 line.
		#
		case $a2 in
		32|32mb)
			NANO_MEDIASIZE=`expr 32112640 / 512`
			NANO_HEADS=4
			NANO_SECTS=32
			;;
		64|64mb)
			NANO_MEDIASIZE=`expr 64225280 / 512`
			NANO_HEADS=8
			NANO_SECTS=32
			;;
		128|128mb)
			NANO_MEDIASIZE=`expr 128450560 / 512`
			NANO_HEADS=8
			NANO_SECTS=32
			;;
		256|256mb)
			NANO_MEDIASIZE=`expr 256901120 / 512`
			NANO_HEADS=16
			NANO_SECTS=32
			;;
		512|512mb)
			NANO_MEDIASIZE=`expr 512483328 / 512`
			NANO_HEADS=16
			NANO_SECTS=63
			;;
		1024|1024mb|1g)
			NANO_MEDIASIZE=`expr 997129664 / 512`
			NANO_HEADS=16
			NANO_SECTS=63
			;;
		2048|2048mb|2g)
			NANO_MEDIASIZE=`expr 2001226112 / 512`
			NANO_HEADS=16
			NANO_SECTS=63
			;;
		4096|4096mb|4g)
			NANO_MEDIASIZE=`expr -e 4007802240 / 512`
			NANO_HEADS=16
			NANO_SECTS=63
			;;
		*)
			echo "Unknown Sandisk Flash capacity"
			exit 2
			;;
		esac
		;;
	siliconsystems)
		case $a2 in
		4096|4g)
			NANO_MEDIASIZE=`expr -e 4224761856 / 512`
			NANO_HEADS=16
			NANO_SECTS=63
			;;
		*)
			echo "Unknown SiliconSystems Flash capacity"
			exit 2
			;;
		esac
		;;
	soekris)
		case $a2 in
		net4526 | 4526 | net4826 | 4826 | 64 | 64mb)
			NANO_MEDIASIZE=125056
			NANO_HEADS=4
			NANO_SECTS=32
			;;
		*)
			echo "Unknown Soekris Flash capacity"
			exit 2
			;;
		esac
		;;
	generic-hdd)
		case $a2 in
		4096|4g)
        	NANO_HEADS=64
        	NANO_SECTS=32
        	NANO_MEDIASIZE="7812500"
			;;
		*)
			echo "Unknwon generic-hdd capacity"
			exit 2
			;;
		esac
		;;
	transcend)
		case $a2 in
		dom064m)
			NANO_MEDIASIZE=125184
			NANO_HEADS=4
			NANO_SECTS=32
			;;
		2048|2g)
			NANO_MEDIASIZE=4061232
			NANO_HEADS=16
			NANO_SECTS=32
			;;
		*)
			echo "Unknown Transcend Flash capacity"
			exit 2
			;;
		esac
		;;
	*)
		echo "Unknown Flash manufacturer"
		exit 2
		;;
	esac
	echo ">>> [nanoo] $1 $2"
	echo ">>> [nanoo] NANO_MEDIASIZE: $NANO_MEDIASIZE"
	echo ">>> [nanoo] NANO_HEADS: $NANO_HEADS"
	echo ">>> [nanoo] NANO_SECTS: $NANO_SECTS"
	echo ">>> [nanoo] NANO_BOOT0CFG: $NANO_BOOT0CFG"
}

pprint() {
	echo $2 >> /tmp/nanobsd_cmds.sh
}

create_mips_diskimage()
{
	echo ">>> building NanoBSD disk image (mips)..."
	echo ">>> Log file can be found in /tmp/nanobsd_cmds.sh"
	echo "`date`" > /tmp/nanobsd_cmds.sh

	NANO_MAKEFS="makefs -B big -o bsize=4096,fsize=512,density=8192,optimization=space"
	NANO_MD_BACKING="file"
	NANO_BOOTLOADER="boot/boot0sio"
	NANO_WORLDDIR=${CLONEDIR}/
	NANO_CFGDIR=${CLONEDIR}/cf

	pprint 2 "build diskimage"
	pprint 3 "log: ${MAKEOBJDIRPREFIXFINAL}/_.di"
	pprint 2 "NANO_MEDIASIZE:	$NANO_MEDIASIZE"
	pprint 2 "NANO_IMAGES:		$NANO_IMAGES"
	pprint 2 "NANO_SECTS:		$NANO_SECTS"
	pprint 2 "NANO_HEADS:		$NANO_HEADS"
	pprint 2 "NANO_CODESIZE:	$NANO_CODESIZE"
	pprint 2 "NANO_CONFSIZE:	$NANO_CONFSIZE"
	pprint 2 "NANO_DATASIZE:	$NANO_DATASIZE"

	echo $NANO_MEDIASIZE \
		$NANO_IMAGES \
		$NANO_SECTS \
		$NANO_HEADS \
		$NANO_CODESIZE \
		$NANO_CONFSIZE \
		$NANO_DATASIZE |
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
	} else if ($7 < 0 && $1 > c) {
		print "p 4 165 " c, $1 - c
	} else if ($1 < c) {
		print "Disk space overcommitted by", \
		    c - $1, "sectors" > "/dev/stderr"
		exit 2
	}

	# Force slice 1 to be marked active. This is necessary
	# for booting the image from a USB device to work.
	print "a 1"
}
	' > ${MAKEOBJDIRPREFIXFINAL}/_.fdisk

	pprint 2 "${MAKEOBJDIRPREFIXFINAL}/_.fdisk"
	pprint 2 "`cat ${MAKEOBJDIRPREFIXFINAL}/_.fdisk`"

	IMG=${MAKEOBJDIRPREFIXFINAL}/nanobsd.full.img
	BS=${NANO_SECTS}b

	if [ "${NANO_MD_BACKING}" = "swap" ] ; then
		pprint 2 "Creating swap backing file ..."
		MD=`mdconfig -a -t swap -s ${NANO_MEDIASIZE} -x ${NANO_SECTS} -y ${NANO_HEADS}`
		pprint 2 "mdconfig -a -t swap -s ${NANO_MEDIASIZE} -x ${NANO_SECTS} -y ${NANO_HEADS}"
	else
		pprint 2 "Creating md backing file ${IMG} ..."
		_c=`expr ${NANO_MEDIASIZE} / ${NANO_SECTS}`
		pprint 2 "dd if=/dev/zero of=${IMG} bs=${BS} count=${_c}"
		dd if=/dev/zero of=${IMG} bs=${BS} count=${_c}
		pprint 2 "mdconfig -a -t vnode -f ${IMG} -x ${NANO_SECTS} -y ${NANO_HEADS}"
		MD=`mdconfig -a -t vnode -f ${IMG} -x ${NANO_SECTS} -y ${NANO_HEADS}`
	fi

	trap "mdconfig -d -u $MD" 1 2 15 EXIT

	pprint 2 "Write partition table ${MAKEOBJDIRPREFIXFINAL}/_.fdisk ..."
	FDISK=${MAKEOBJDIRPREFIXFINAL}/_.fdisk
	pprint 2 "fdisk -i -f ${FDISK} ${MD}"
	fdisk -i -f ${FDISK} ${MD}
	pprint 2 "fdisk ${MD}"
	fdisk ${MD}

	# Create first image
	IMG1=${MAKEOBJDIRPREFIXFINAL}/_.disk.image1
	pprint 2 "Create first image ${IMG1} ..."
	SIZE=`awk '/^p 1/ { print $5 "b" }' ${FDISK}`
	pprint 2 "${NANO_MAKEFS} -s ${SIZE} ${IMG1} ${NANO_WORLDDIR}"
	${NANO_MAKEFS} -s ${SIZE} ${IMG1} ${NANO_WORLDDIR}
	pprint 2 "dd if=${IMG1} of=/dev/${MD}s1 bs=${BS}"
	dd if=${IMG1} of=/dev/${MD}s1 bs=${BS}
	pprint 2 "tunefs -L pfsense0 /dev/${MD}s1"
	tunefs -L pfsense0 /dev/${MD}s1

	if [ $NANO_IMAGES -gt 1 -a $NANO_INIT_IMG2 -gt 0 ] ; then
		IMG2=${MAKEOBJDIRPREFIXFINAL}/_.disk.image2
		pprint 2 "Create second image ${IMG2}..."
		for f in ${NANO_WORLDDIR}/etc/fstab
		do
			sed -i "" "s/${NANO_DRIVE}s1/${NANO_DRIVE}s2/g" $f
		done
		SIZE=`awk '/^p 2/ { print $5 "b" }' ${FDISK}`
		pprint 2 "${NANO_MAKEFS} -s ${SIZE} ${IMG2} ${NANO_WORLDDIR}"
		${NANO_MAKEFS} -s ${SIZE} ${IMG2} ${NANO_WORLDDIR}
		pprint 2 "dd if=${IMG2} of=/dev/${MD}s2 bs=${BS}"
		dd if=${IMG1} of=/dev/${MD}s2 bs=${BS}
	fi

	# Create Config slice
	if [ $NANO_CONFSIZE -gt 0 ] ; then
		CFG=${MAKEOBJDIRPREFIXFINAL}/_.disk.cfg
		pprint 2 "Creating config partition ${CFG}..."
		SIZE=`awk '/^p 3/ { print $5 "b" }' ${FDISK}`
		pprint 2 "${NANO_MAKEFS} -s ${SIZE} ${CFG} ${NANO_CFGDIR}"
		${NANO_MAKEFS} -s ${SIZE} ${CFG} ${NANO_CFGDIR}
		pprint 2 "dd if=${CFG} of=/dev/${MD}s3 bs=${BS}"
		dd if=${CFG} of=/dev/${MD}s3 bs=${BS}
		pprint 2 "tunefs -L cf /dev/${MD}s3"
		tunefs -L cf /dev/${MD}s3
		pprint 2 "rm ${CFG}"
		rm ${CFG}; CFG=			# NB: disable printing below
	else
		pprint 2 ">>> [nanoo] NANO_CONFSIZE is not set. Not adding a /conf partition.. You sure about this??"
	fi

	# Create Data slice, if any.
	# Note the changing of the variable to NANO_CONFSIZE
	# from NANO_DATASIZE.  We also added glabel support
	# and populate the pfSense configuration from the /cf
	# directory located in CLONEDIR
	#if [ $NANO_CONFSIZE -gt 0 ] ; then
	#	DATA=${MAKEOBJDIRPREFIXFINAL}/_.disk.data
	#	echo ""; echo "Creating data partition ${DATA}..."
	#	SIZE=`awk '/^p 4/ { print $5 "b" }' ${FDISK}`
	#	# XXX: fill from where ?
	#	pprint 2 "${NANO_MAKEFS} -s ${SIZE} ${DATA} /var/empty"
	#	${NANO_MAKEFS} -s ${SIZE} ${DATA} /var/empty
	#	pprint 2 "dd if=${DATA} of=/dev/${MD}s4 bs=${BS}"
	#	dd if=${DATA} of=/dev/${MD}s4 bs=${BS}
	#	pprint 2 "rm ${DATA}"
	#	rm ${DATA}; DATA=	# NB: disable printing below
	#else
	#	">>> [nanoo] NANO_CONFSIZE is not set. Not adding a /conf partition.. You sure about this??"
	#fi

	if [ "${NANO_MD_BACKING}" = "swap" ] ; then
		pprint 2 "Writing out ${IMG}..."
		dd if=/dev/${MD} of=${IMG} bs=${BS}
	fi

	pprint 2 "IMG1:             $IMG1"
	pprint 2 "IMG2:             $IMG2"
	pprint 2 "`date`"
	pprint 2 "Full disk:         ${IMG}"
	pprint 2 "Primary partition: ${IMG1}"
	test "${IMG2}" && pprint 2 "2ndary partition:  ${IMG2}"
	test "${CFG}" &&  pprint 2 "/cfg partition:    ${CFG}"
	test "${DATA}" && pprint 2 "/data partition:   ${DATA}"

	#) > ${MAKEOBJDIRPREFIXFINAL}/_.di 2>&1

}

# This routine originated in nanobsd.sh
create_i386_diskimage () {
	echo ">>> building NanoBSD disk image (i386)..."
	echo "" > /tmp/nanobsd_cmds.sh

	TIMESTAMP=`date "+%Y%m%d.%H%M"`
	echo $NANO_MEDIASIZE \
		$NANO_IMAGES \
		$NANO_SECTS \
		$NANO_HEADS \
		$NANO_CODESIZE \
		$NANO_CONFSIZE \
		$NANO_DATASIZE |
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
	} else if ($7 < 0 && $1 > c) {
		print "p 4 165 " c, $1 - c
	} else if ($1 < c) {
		print "Disk space overcommitted by", \
		    c - $1, "sectors" > "/dev/stderr"
		exit 2
	}

	# Force slice 1 to be marked active. This is necessary
	# for booting the image from a USB device to work.
	print "a 1"
}
	' > ${MAKEOBJDIRPREFIXFINAL}/_.fdisk

	mkdir -p $MAKEOBJDIRPREFIXFINAL
	[ -z "${NANO_WITH_VGA}" ] \
		&& IMG=${MAKEOBJDIRPREFIXFINAL}/nanobsd.full.img \
		|| IMG=${MAKEOBJDIRPREFIXFINAL}/nanobsd_vga.full.img
	MNT=${MAKEOBJDIRPREFIXFINAL}/_.mnt
	mkdir -p ${MNT}

	dd if=/dev/zero of=${IMG} bs=${NANO_SECTS}b \
	    count=`expr ${NANO_MEDIASIZE} / ${NANO_SECTS}`

	MD=`mdconfig -a -t vnode -f ${IMG} -x ${NANO_SECTS} -y ${NANO_HEADS}`

	fdisk -i -f ${MAKEOBJDIRPREFIXFINAL}/_.fdisk ${MD}
	fdisk ${MD}
	boot0cfg -B -b ${CLONEDIR}/${NANO_BOOTLOADER} ${NANO_BOOT0CFG} ${MD}
	bsdlabel -m i386 -w -B -b ${CLONEDIR}/boot/boot ${MD}s1
	bsdlabel -m i386 ${MD}s1

	# Create first image
	newfs ${NANO_NEWFS} /dev/${MD}s1a
	tunefs -L pfsense0 /dev/${MD}s1a
	mount /dev/${MD}s1a ${MNT}
	df -i ${MNT}
	( cd ${CLONEDIR} && find . -print | cpio -dump ${MNT} )
	df -i ${MNT}
	( cd ${MNT} && mtree -c ) > ${MAKEOBJDIRPREFIXFINAL}/_.mtree
	( cd ${MNT} && du -k ) > ${MAKEOBJDIRPREFIXFINAL}/_.du
	umount ${MNT}

	# Setting NANO_IMAGES to 1 and NANO_INIT_IMG2 will tell
	# NanoBSD to only create one partition.  We default to 2
	# partitions in case anything happens to the first the
	# operator can boot from the 2nd and should be OK.
	if [ $NANO_IMAGES -gt 1 -a $NANO_INIT_IMG2 -gt 0 ] ; then
		# Duplicate to second image (if present)
		echo ">>> Mounting and duplicating NanoBSD pfsense1 /dev/${MD}s2a ${MNT}"
		dd if=/dev/${MD}s1 of=/dev/${MD}s2 bs=64k
		tunefs -L pfsense1 /dev/${MD}s2a
		mount /dev/${MD}s2a ${MNT}
		df -i ${MNT}
		mkdir -p ${MNT}/conf/base/etc/
		cp ${MNT}/etc/fstab ${MNT}/conf/base/etc/fstab
		for f in ${MNT}/etc/fstab ${MNT}/conf/base/etc/fstab
		do
			sed -i "" "s/pfsense0/pfsense1/g" $f
		done
		umount ${MNT}
		bsdlabel -m i386 -w -B -b ${CLONEDIR}/boot/boot ${MD}s2
		bsdlabel -m i386 -w -B -b ${CLONEDIR}/boot/boot ${MD}s1
	fi

	# Create Data slice ###############################
	# NOTE: This is not used in pfSense and should be #
	#       commented out.  It is left in this file   #
	#       for reference since the NanoBSD code      #
	#       is 99% idential to nanobsd.sh             #
	# newfs ${NANO_NEWFS} /dev/${MD}s3                #
	# tunefs -L cfg /dev/${MD}s3                      #
	###################################################

	# Create Data slice, if any.
	# Note the changing of the variable to NANO_CONFSIZE
	# from NANO_DATASIZE.  We also added glabel support
	# and populate the pfSense configuration from the /cf
	# directory located in CLONEDIR
	if [ $NANO_CONFSIZE -gt 0 ] ; then
		echo ">>> Creating /cf area to hold config.xml"
		newfs ${NANO_NEWFS} /dev/${MD}s3
		tunefs -L cf /dev/${MD}s3
		# Mount data partition and copy contents of /cf
		# Can be used later to create custom default config.xml while building
		mount /dev/${MD}s3 ${MNT}
		( cd ${CLONEDIR}/cf && find . -print | cpio -dump ${MNT} )
		umount ${MNT}
	else
		">>> [nanoo] NANO_CONFSIZE is not set. Not adding a /conf partition.. You sure about this??"
	fi

	echo ">>> [nanoo] Creating NanoBSD upgrade file from first slice..."
	[ -z "${NANO_WITH_VGA}" ] \
		&& IMGUPDATE="${MAKEOBJDIRPREFIXFINAL}/nanobsd.upgrade.img" \
		|| IMGUPDATE="${MAKEOBJDIRPREFIXFINAL}/nanobsd_vga.upgrade.img"
	dd if=/dev/${MD}s1 of=$IMGUPDATE bs=64k

	mdconfig -d -u $MD

	# Check each image and ensure that they are over
	# 3 megabytes.  If either image is under 20 megabytes
	# in size then error out.
	IMGSIZE=`ls -la $IMG | awk '{ print $5 }'`
	IMGUPDATESIZE=`ls -la $IMGUPDATE | awk '{ print $5 }'`
	CHECKSIZE="20040710"
	if [ "$IMGSIZE" -lt "$CHECKSIZE" ]; then
		echo ">>> Something went wrong when building NanoBSD.  The image size is under 20 megabytes!"
		print_error_pfS
	fi
	if [ "$IMGUPDATESIZE" -lt "$CHECKSIZE" ]; then
		echo ">>> Something went wrong when building NanoBSD upgrade image.  The image size is under 20 megabytes!"
		print_error_pfS	
	fi
}

# This routine installs pfSense packages into the staging area.
# Packages such as squid, snort, autoconfigbackup, etc.
pfsense_install_custom_packages_exec() {
	# Function originally written by Daniel S. Haischt
	#	Copyright (C) 2007 Daniel S. Haischt <me@daniel.stefan.haischt.name>
	#   Copyright (C) 2009 Scott Ullrich <sullrich@gmail.com>

	PFSDESTNAME="pkginstall.sh"
	PFSTODIR="${PFSENSEBASEDIR}"

	# Extra package list if defined.
	if [ ! -z "${custom_package_list:-}" ]; then
		# Notes:
		# ======
		# devfs mount is required cause PHP requires /dev/stdin
		# php.ini needed to make PHP argv capable
		#
		/bin/echo ">>> Installing custom packages to: ${PFSTODIR} ..."

		cp ${PFSTODIR}/etc/platform ${PFSTODIR}/tmp/

		/sbin/mount -t devfs devfs ${PFSTODIR}/dev

		/bin/mkdir -p ${PFSTODIR}/var/etc/
		/bin/cp /etc/resolv.conf ${PFSTODIR}/etc/

		/bin/echo ${custom_package_list} > ${PFSTODIR}/tmp/pkgfile.lst

		/bin/cp ${BUILDER_TOOLS}/builder_scripts/pfspkg_installer ${PFSTODIR}/tmp
		/bin/chmod a+x ${PFSTODIR}/tmp/pfspkg_installer

		cp ${PFSTODIR}/usr/local/lib/php.ini /tmp/
		if [ -f /tmp/php.ini ]; then
			cat /tmp/php.ini | grep -v apc > ${PFSTODIR}/usr/local/lib/php.ini
			cat /tmp/php.ini | grep -v apc > ${PFSTODIR}/usr/local/etc/php.ini
		fi

	# setup script that will be run within the chroot env
	/bin/cat > ${PFSTODIR}/${PFSDESTNAME} <<EOF
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
	mkdir -p /usr/local/lib/ /usr/local/etc/
	/etc/rc.php_ini_setup 2>/dev/null
	cat /usr/local/etc/php.ini | grep -v apc > /tmp/php.ini.new
	cp /tmp/php.ini.new /usr/local/etc/php.ini 2>/dev/null
	cp /tmp/php.ini.new /usr/local/lib/php.ini 2>/dev/null
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
		sleep 65535
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
		sleep 65535
	done
fi

# backup original conf dir
if [ -d /conf ]; then
	/bin/mv /conf /conf.org
	/usr/bin/touch /tmp/restore_conf_dir
fi

# test whether conf dir is already a symlink
if [ ! -h /conf ]; then
	# install the symlink as it would exist on a live system
	/bin/ln -s /cf/conf /conf 2>/dev/null
	/usr/bin/touch /tmp/remove_conf_symlink
fi

# now that we do have the symlink in place create
# a backup dir if necessary.
if [ ! -d /conf/backup ]; then
	/bin/mkdir -p /conf/backup
	/usr/bin/touch /tmp/remove_backup
fi

#
# Assemble package list if necessary
#
(/tmp/pfspkg_installer -q -m config -l /tmp/pkgfile.lst -p .:/etc/inc:/usr/local/www:/usr/local/captiveportal:/usr/local/pkg) | egrep -wi '(^>>>|error)'

#
# Exec PHP script which installs pfSense packages in place
#
(/tmp/pfspkg_installer -q -m install -l /tmp/pkgfile.lst -p .:/etc/inc:/usr/local/www:/usr/local/captiveportal:/usr/local/pkg) > /tmp/pfspkg_installer.out 2>&1

rc=\$?

egrep -wi '(^>>>|error)' /tmp/pfspkg_installer.out 2>/dev/null
rm -f /tmp/pfspkg_installer.out

#
# Check if pfspkg_installer returned 0
#
[ "\$rc" != "0" ] && exit 1

# Copy config.xml to conf.default/
cp /conf/config.xml conf.default/

#
# Cleanup, aisle 7!
#
if [ -f /tmp/remove_platform ]; then
	/bin/rm /etc/platform
	/bin/rm /tmp/remove_platform
fi

if [ -f /tmp/remove_backup ]; then
	/bin/rm -rf /conf/backup
	/bin/rm /tmp/remove_backup
fi

if [ -f /tmp/remove_conf_symlink ]; then
	/bin/rm /conf
	if [ -h /cf ]; then
		/bin/rm /cf
	fi
	/bin/rm /tmp/remove_conf_symlink
fi

if [ -f /tmp/restore_conf_dir ]; then
	/bin/mv /conf.org /conf
	/bin/rm /tmp/restore_conf_dir
fi

if [ -f /tmp/platform ]; then
	mv /tmp/platform /etc/platform
fi

/bin/rm /tmp/pfspkg_installer

/bin/rm /tmp/pkgfile.lst

/bin/rm /tmp/*.log /tmp/*.tbz 2>/dev/null

if [ -f /tmp/config.cache ]; then
	/bin/rm /tmp/config.cache
fi

/bin/rm /etc/resolv.conf

/bin/rm /${PFSDESTNAME}

if [ -f /tmp/php.ini ]; then
	cp /tmp/php.ini /usr/local/lib/php.ini
	cp /tmp/php.ini /usr/local/etc/php.ini
fi

EOF

		echo ">>> Installing custom pfSense-XML packages inside chroot ..."
		chmod a+rx ${PFSTODIR}/${PFSDESTNAME}
		chroot ${PFSTODIR} /bin/sh /${PFSDESTNAME}
		rc=$?
		echo ">>> Unmounting ${PFSTODIR}/dev ..."
		umount -f ${PFSTODIR}/dev

		if [ "${rc}" != "0" ]; then
			echo ">>> ERROR: Error installing custom packages"
			exit 1
		fi

	fi
}

# Cleans up previous builds
pfSense_clean_obj_dir() {
	# Clean out directories
	echo ">>> Cleaning up old directories..."
	freesbie_clean_each_run
	echo -n ">>> Cleaning up previous build environment...Please wait..."
	# Allow old CVS_CO_DIR to be deleted later
	if [ "$CVS_CO_DIR" != "" ]; then
		if [ -d "$CVS_CO_DIR" ]; then
			echo -n "."
			chflags -R noschg $CVS_CO_DIR/
			rm -rf $CVS_CO_DIR/* 2>/dev/null
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
		(cd ${CURRENTDIR} && rm -rf ${PFSENSEBASEDIR}/*)
	fi
	if [ -d "$PFSENSEISODIR" ]; then
		echo -n "."
		chflags -R noschg ${PFSENSEISODIR}
		echo -n "."
		(cd ${CURRENTDIR} && rm -rf ${PFSENSEISODIR}/*)
	fi
	echo -n "."
	(cd ${CURRENTDIR} && rm -rf ${MAKEOBJDIRPREFIX}/*)
	(cd ${CURRENTDIR} && rm -rf ${MAKEOBJDIRPREFIX}/.done*)
	echo -n "."
	rm -rf $KERNEL_BUILD_PATH/*
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

# This copies the default config.xml to the location on
# disk as the primary configuration file.
copy_config_xml_from_conf_default() {
	if [ ! -f "${PFSENSEBASEDIR}/cf/conf/config.xml" ]; then
		echo ">>> Copying config.xml from conf.default/ to cf/conf/"
		cp ${PFSENSEBASEDIR}/conf.default/config.xml ${PFSENSEBASEDIR}/cf/conf/
	fi
}

# Rebuilds and installs the BSDInstaller which populates
# the Ports directory sysutils/bsdinstaller, etc.
rebuild_and_install_bsdinstaller() {
	# Add BSDInstaller
	if [ -z "${GIT_REPO_BSDINSTALLER:-}" ]; then
		echo ">>> Fetching BSDInstaller using CVSUP..."
		(csup -b $BASE_DIR ${BUILDER_SCRIPTS}/bsdinstaller-supfile) 2>&1 | egrep -B3 -A3 -wi '(error)'
		${BUILDER_SCRIPTS}/cvsup_bsdinstaller
	else
		echo ">>> Fetching BSDInstaller using GIT..."
		git checkout "${GIT_REPO_BSDINSTALLER}"
		if [ $? != 0 ]; then
			echo "Something went wrong while checking out GIT."
			exit
		fi
	fi

	${BUILDER_SCRIPTS}/rebuild_bsdinstaller.sh

}

# This routine ensures that the $SRCDIR has sources
# and is ready for action / building.
ensure_source_directories_present() {
	# Sanity check
	if [ ! -d "${PFSPATCHDIR}" ]; then
		echo "PFSPATCHDIR=${PFSPATCHDIR} is not a directory -- Please fix."
		print_error_pfS
		kill $$
	fi
	if [ ! -d $SRCDIR ]; then
		echo ">>> Creating $SRCDIR ... We will need to csup the contents..."
		mkdir $SRCDIR
		update_freebsd_sources_and_apply_patches
	fi
}

# This routine ensures any ports / binaries that the builder
# system needs are on disk and ready for execution.
install_required_builder_system_ports() {
	# No ports exist, use portsnap to bootstrap.
	if [ ! -d "/usr/ports/" ]; then
		echo -n  ">>> Grabbing FreeBSD port sources, please wait..."
		(/usr/sbin/portsnap fetch) 2>&1 | egrep -B3 -A3 -wi '(error)'
		(/usr/sbin/portsnap extract) 2>&1 | egrep -B3 -A3 -wi '(error)'
		echo "Done!"
	fi
# Local binary						# Path to port
	NEEDED_INSTALLED_PKGS="\
/usr/local/bin/mkisofs				/usr/ports/sysutils/cdrtools
/usr/local/bin/fastest_cvsup		/usr/ports/sysutils/fastest_cvsup
/usr/local/lib/libpcre.so.0			/usr/ports/devel/pcre
/usr/local/bin/curl					/usr/ports/ftp/curl
/usr/local/bin/rsync				/usr/ports/net/rsync
/usr/local/bin/cpdup				/usr/ports/sysutils/cpdup
/usr/local/bin/git					/usr/ports/devel/git
/usr/local/sbin/grub				/usr/ports/sysutils/grub
/usr/local/bin/screen				/usr/ports/sysutils/screen
"
	oIFS=$IFS
	IFS="
"
	for PKG_STRING in $NEEDED_INSTALLED_PKGS; do			
		PKG_STRING_T=`echo $PKG_STRING | sed "s/		/	/g"`
		CHECK_ON_DISK=`echo $PKG_STRING_T | awk '{ print $1 }'`
		PORT_LOCATION=`echo $PKG_STRING_T | awk '{ print $2 }'`
		if [ "$CHECK_ON_DISK" = "/usr/local/sbin/grub" ]; then
			if [ "$ARCH" = "amd64" ]; then
				# Grub will not build on AMD64
				# Simply set the check to /sbin/init
				# which we know is a valid binary on 
				# any installed machine.
				echo ">>> Grub is not buildable on AMD64.  Skipping."
				CHECK_ON_DISK="/sbin/init"
			fi
			if [ "$ARCH" = "mips" ]; then
				# Grub will not build on mips
				# Simply set the check to /sbin/init
				# which we know is a valid binary on 
				# any installed machine.
				echo ">>> Grub is not buildable on MIPS.  Skipping."
				CHECK_ON_DISK="/sbin/init"
			fi
			if [ "$ARCH" = "powerpc" ]; then
				# Grub will not build on mips
				# Simply set the check to /sbin/init
				# which we know is a valid binary on 
				# any installed machine.
				echo ">>> Grub is not buildable on POWERPC.  Skipping."
				CHECK_ON_DISK="/sbin/init"
			fi
		fi
		if [ ! -f "$CHECK_ON_DISK" ]; then
			echo -n ">>> Building $PORT_LOCATION ..."
			(cd $PORT_LOCATION && make -DBATCH deinstall clean) 2>&1 | egrep -B3 -A3 -wi '(error)'
			(cd $PORT_LOCATION && make ${MAKEJ_PORTS} -DBATCH -DWITHOUT_GUI) 2>&1 | egrep -B3 -A3 -wi '(error)'
			(cd $PORT_LOCATION && make install -DWITHOUT_GUI -DFORCE_PKG_REGISTER -DBATCH) 2>&1 | egrep -B3 -A3 -wi '(error)'
			echo "Done!"
		fi
	done

	IFS=$oIFS
}

# Updates FreeBSD sources and applies any custom
# patches that have been defined.
update_freebsd_sources_and_apply_patches() {
	# No need to obtain sources or patch
	# on subsequent build runs.

	# Detect Subsequent runs if .done_buildworld exists
	if [ -d $SRCDIR ]; then
		if [ -d $MAKEOBJDIRPREFIX ]; then
			COUNT=`find $MAKEOBJDIRPREFIX -name .done_buildworld | wc -l`
			if [ "$COUNT" -gt 0 ]; then
				echo ">>> Subsequent build detected, not updating src or applying patches..."
				echo ">>> IF you would like to force the update of the sources then remove"
				echo "    .done_buildworld from $MAKEOBJDIRPREFIX"
				return
			fi
		fi
	fi

	# If override is in place, use it otherwise
	# locate fastest cvsup host
	if [ ! -z ${OVERRIDE_FREEBSD_CVSUP_HOST:-} ]; then
		echo ">>> Setting CVSUp host to ${OVERRIDE_FREEBSD_CVSUP_HOST}"
		echo $OVERRIDE_FREEBSD_CVSUP_HOST > /var/db/fastest_cvsup
	else
		echo ">>> Finding fastest CVSUp host... Please wait..."
		fastest_cvsup -c tld -q > /var/db/fastest_cvsup
	fi

	# Loop through and remove files
	PFSPATCHFILEBASENAME=`basename $PFSPATCHFILE`
	echo ">>> Removing needed files listed in ${PFSPATCHFILEBASENAME} ${PFSENSETAG}"
	for LINE in `cat ${PFSPATCHFILE}`
	do
		PATCH_RM=`echo $LINE | cut -d~ -f4`
		PATCH_RM_LENGTH=`echo $PATCH_RM | wc -c`
		DIR_CREATE=`echo $LINE | cut -d~ -f5`
		if [ $PATCH_RM_LENGTH -gt "2" ]; then
			rm -rf ${SRCDIR}${PATCH_RM}
		fi
		if [ "$DIR_CREATE" != "" ]; then
			mkdir -p ${SRCDIR}/${DIR_CREATE}
		fi
	done

	# CVSUp freebsd version -- this MUST be after Loop through and remove files
	BASENAMESUPFILE=`basename $SUPFILE`
	echo -n ">>> Obtaining FreeBSD sources ${BASENAMESUPFILE}..."
	(csup -b $SRCDIR -h `cat /var/db/fastest_cvsup` ${SUPFILE}) 2>&1 | \
		grep -v '(\-Werror|ignored|error\.[a-z])' | egrep -wi "(^>>>|error)" \
		| grep -v "error\." | grep -v "opensolaris" | \
		grep -v "httpd-error"
	echo "Done!"

	echo ">>> Removing old patch rejects..."
	find $SRCDIR -name "*.rej" -exec rm {} \;

	echo -n ">>> Applying patches, please wait..."
	# Loop through and patch files
	for LINE in `cat ${PFSPATCHFILE}`
	do
		PATCH_DEPTH=`echo $LINE | cut -d~ -f1`
		PATCH_DIRECTORY=`echo $LINE | cut -d~ -f2`
		PATCH_FILE=`echo $LINE | cut -d~ -f3`
		PATCH_FILE_LEN=`echo $PATCH_FILE | wc -c`
		MOVE_FILE=`echo $LINE | cut -d~ -f4`
		MOVE_FILE_LEN=`echo $MOVE_FILE | wc -c`
		IS_TGZ=`echo $LINE | grep -v grep | grep .tgz | wc -l`
		if [ $PATCH_FILE_LEN -gt "2" ]; then
			if [ $IS_TGZ -gt "0" ]; then
				(cd ${SRCDIR}/${PATCH_DIRECTORY} && tar xzvpf ${PFSPATCHDIR}/${PATCH_FILE}) 2>&1 \
				| egrep -wi '(warning|error)'
			else
				(cd ${SRCDIR}/${PATCH_DIRECTORY} && patch -f ${PATCH_DEPTH} < ${PFSPATCHDIR}/${PATCH_FILE}) 2>&1 \
				| egrep -wi '(warning|error|failed)'
			fi
		fi
		if [ $MOVE_FILE_LEN -gt "2" ]; then
			#cp ${SRCDIR}/${MOVE_FILE} ${SRCDIR}/${PATCH_DIRECTORY}
		fi
	done
	echo "Done!"

	echo ">>> Finding patch rejects..."
	REJECTED_PATCHES=`find $SRCDIR -name "*.rej" | wc -l`
	if [ $REJECTED_PATCHES -gt 0 ]; then
		echo
		echo "WARNING!  Rejected patches found!  Please fix before building!"
		echo
		find $SRCDIR -name "*.rej"
		echo
		if [ "$FREESBIE_ERROR_MAIL" != "" ]; then
			LOGFILE="/tmp/patches.failed.apply"
			find $SRCDIR -name "*.rej" > $LOGFILE
			print_error_pfS

		fi
		print_error_pfS
		kill $$
	fi
}

# Email when an error has occured and FREESBIE_ERROR_MAIL is defined
report_error_pfsense() {
    if [ ! -z ${FREESBIE_ERROR_MAIL:-} ]; then
		HOSTNAME=`hostname`
		IPADDRESS=`ifconfig | grep inet | grep netmask | grep broadcast | awk '{ print $2 }'`
		cat ${LOGFILE} | \
		    mail -s "FreeSBIE (pfSense) build error in ${TARGET} phase ${IPADDRESS} - ${HOSTNAME} " \
		    	${FREESBIE_ERROR_MAIL}
    fi
}

# Email when an operation is completed IE build run
email_operation_completed() {
    if [ ! -z ${FREESBIE_COMPLETED_MAIL:-} ]; then
		HOSTNAME=`hostname`
		IPADDRESS=`ifconfig | grep inet | grep netmask | grep broadcast | awk '{ print $2 }'`
		echo "Build / operation completed ${IPADDRESS} - ${HOSTNAME}" | \
	    mail -s "FreeSBIE (pfSense) operation completed ${IPADDRESS} - ${HOSTNAME}" \
	    	${FREESBIE_COMPLETED_MAIL}
    fi
}

# Sets up a symbolic link from /conf -> /cf/conf on ISO
create_iso_cf_conf_symbolic_link() {
	echo ">>> Creating symbolic link for /cf/conf /conf ..."
	rm -rf ${PFSENSEBASEDIR}/conf
	chroot ${PFSENSEBASEDIR} /bin/ln -s /cf/conf /conf
}

# This ensures the pfsense-fs installer is healthy.
ensure_healthy_installer() {
	echo -n ">>> Checking BSDInstaller health..."
	INSTALLER_ERROR=0
	if [ ! -f "$PFSENSEBASEDIR/usr/local/sbin/dfuife_curses" ]; then
		INSTALLER_ERROR=1
		echo -n " dfuife_curses missing ";
	fi
	if [ ! -d "$PFSENSEBASEDIR/usr/local/share/dfuibe_lua" ]; then
		INSTALLER_ERROR=1
		echo -n " dfuibe_lua missing ";
	fi
	if [ ! -f "$PFSENSEBASEDIR/usr/local/share/dfuibe_lua/conf/pfSense.lua" ]; then
		INSTALLER_ERROR=1
		echo " pfSense_lua missing "
	fi
	if [ "$INSTALLER_ERROR" -gt 0 ]; then
		echo "[ERROR!]"
		print_error_pfS
		kill $$
	else
		echo "[OK]"
	fi
}

# This copies the various pfSense git repos to the DevISO
# staging area.
setup_deviso_specific_items() {
	if [ `mount | grep ${CLONEDIR} | wc -l` -gt 0 ]; then
		MOUNTPOINT=`mount | grep ${CLONEDIR} | awk '{ print $3 }'`
		echo ">>> Attempting umount of $MOUNTPOINT"
		umount -f $MOUNTPOINT
		if [ `mount | grep ${CLONEDIR} | wc -l` -gt 0 ]; then
			echo ">>> ERROR! Could not umount $MOUNTPOINT"
			print_error_pfS
		fi
	fi

	if [ "$OVERRIDE_FREEBSD_CVSUP_HOST" = "" ]; then
		OVERRIDE_FREEBSD_CVSUP_HOST=`fastest_cvsup -c tld -q`
	fi
	echo -n ">>> Setting up DevISO specific bits... Please wait (this will take a while!)..."
	DEVROOT="$PFSENSEBASEDIR/home/pfsense"
	mkdir -p $DEVROOT
	mkdir -p $PFSENSEBASEDIR/home/pfsense/pfSenseGITREPO
	mkdir -p $PFSENSEBASEDIR/home/pfsense/installer
	mkdir -p $PFSENSEBASEDIR/usr/pfSensesrc
	echo "WITHOUT_X11=yo" >> $PFSENSEBASEDIR/etc/make.conf
	if [ "$ARCH" = "mips" ]; then
		echo "WITHOUT_PERL_MALLOC=1" >> $PFSENSEBASEDIR/etc/make.conf
		echo "TARGET_BIG_ENDIAN=yes" >> $PFSENSEBASEDIR/etc/make.conf
	fi
	echo -n "."
	rm $PFSENSEBASEDIR/etc/resolv.conf
	echo "Done!"
	rm -rf $PFSENSEBASEDIR/var/db/pkg/*
	touch $PFSENSEBASEDIR/pfSense_devISO
}

# Check to see if a forced pfPorts run has been requested.
# If so, rebuild pfPorts.  set_version.sh uses this.
check_for_forced_pfPorts_build() {
	if [ -f "/tmp/pfPorts_forced_build_required" ]; then
		# Ensure that we build
		rm -f /tmp/pfSense_do_not_build_pfPorts
		recompile_pfPorts
		# Remove file that could trigger 2 pfPorts
		# builds in one run
		rm /tmp/pfPorts_forced_build_required
	fi
}

# Enables memory disk backing of common builder directories
enable_memory_disks() {
	echo -n ">>> Mounting memory disks: "
	MD1=`mdconfig -l -u md1 | grep md1 | wc -l | awk '{ print $1 }'`
	MD2=`mdconfig -l -u md2 | grep md2 | wc -l | awk '{ print $1 }'`
	MD3=`mdconfig -l -u md3 | grep md3 | wc -l | awk '{ print $1 }'`
	if [ "$MD1" -lt 1 ]; then
		echo -n "/usr/obj.pfSense/ "
		mdconfig -a -t swap -s 1700m -u 1
		(newfs md1) | egrep -wi '(^>>>|error)'
		mkdir -p $MAKEOBJDIRPREFIX
		mount /dev/md1 $MAKEOBJDIRPREFIX
	fi
	if [ "$MD2" -lt 1 ]; then
		echo -n "/usr/pfSensesrc/ "
		mdconfig -a -t swap -s 800m -u 2
		(newfs md2) | egrep -wi '(^>>>|error)'
		mkdir -p $SRCDIR
		mount /dev/md2 $SRCDIR
	fi
	if [ "$MD3" -lt 1 ]; then
		echo -n "$KERNEL_BUILD_PATH/ "
		mdconfig -a -t swap -s 550m -u 3
		(newfs md3) | egrep -wi '(^>>>|error)'
		mkdir -p $KERNEL_BUILD_PATH
		mount /dev/md3 $KERNEL_BUILD_PATH
	fi
	echo "Done!"
	df -h
	update_freebsd_sources_and_apply_patches
}

# Disables memory disk backing of common builder directories
disable_memory_disks() {
	echo -n ">>> Disabling memory disks..."
	(umount $KERNEL_BUILD_PATH $SRCDIR $MAKEOBJDIRPREFIX) | '(^>>>)'
	(mdconfig -d -u 1) | '(^>>>)'
	(mdconfig -d -u 2) | '(^>>>)'
	(mdconfig -d -u 3) | '(^>>>)'
	echo "Done!"
}


# This routine assists with installing various
# freebsd ports files into the pfsenese-fs staging
# area.  The various ports are built prior to install.
install_pkg_install_ports() {
	if [ "$PKG_INSTALL_PORTSPFS" = "" ]; then
		return
	fi
	echo -n ">>> Building ports (this might take a while): "
	PFS_PKG_ALL="/usr/ports/packages/All/"
	mkdir -p /usr/ports/packages/Old/
	mv /usr/ports/packages/All/* /usr/ports/packages/Old/
	mkdir -p $PFS_PKG_ALL
	for PORTDIRPFS in $PKG_INSTALL_PORTSPFS; do
		echo -n "$PORTDIRPFS "
		if [ ! -d $PORTDIRPFS ]; then
			echo "!!!! Could not locate $PORTDIRPFS"
			print_error_pfS
			kill $$
		fi
		(cd $PORTDIRPFS && make clean) # | egrep -wi '(^>>>|error )' 2>&1
		(cd $PORTDIRPFS && make depends BATCH=yo FORCE_PKG_REGISTER=yo) # | egrep -wi '(^>>>|error )' 2>&1
		(cd $PORTDIRPFS && make package-recursive BATCH=yo FORCE_PKG_REGISTER=yo) # | egrep -wi '(^>>>|error )' 2>&1
		(cd $PORTDIRPFS && make clean) #| egrep -wi '(^>>>|error )' 2>&1
	done
	mkdir $PFSENSEBASEDIR/tmp/pkg/
	cp $PFS_PKG_ALL/* $PFSENSEBASEDIR/tmp/pkg/
	echo ">>> Installing built ports (packages) in a chroot..."
        echo "set +e" > $PFSENSEBASEDIR/pkg.sh
        echo "cd /tmp/pkg && ls -l /tmp/pkg/ | sort +5 | awk '{ print \$9 }' | xargs pkg_add 2>/dev/null" >> $PFSENSEBASEDIR/pkg.sh
        echo "set -e" >> $PFSENSEBASEDIR/pkg.sh
	chroot $PFSENSEBASEDIR sh /pkg.sh 
	rm -rf $PFSENSEBASEDIR/tmp/pkg
	rm $PFSENSEBASEDIR/pkg.sh
	mv /usr/ports/packages/Old/* /usr/ports/packages/All/
	echo -n "Done!"
}

# Mildly based on FreeSBIE
freesbie_clean_each_run() {
	echo -n ">>> Cleaning build directories: "
	if [ -d $PFSENSEBASEDIR/tmp/ ]; then
		find $PFSENSEBASEDIR/tmp/ -name "mountpoint*" -exec umount -f {} \;
	fi
	if [ -d "${PFSENSEBASEDIR}" ]; then
		BASENAME=`basename ${PFSENSEBASEDIR}`
		echo -n "$BASENAME "
	    chflags -R noschg ${PFSENSEBASEDIR}
	    rm -rf ${PFSENSEBASEDIR} 2>/dev/null
	fi
	if [ -d "${CLONEDIR}" ]; then
		BASENAME=`basename ${CLONEDIR}`
		echo -n "$BASENAME "
	    chflags -R noschg ${CLONEDIR}
	    rm -rf ${CLONEDIR} 2>/dev/null
	fi
	echo "Done!"
}

# Imported from FreeSBIE
buildworld() {
	if [ -n "${NO_BUILDWORLD:-}" ]; then
	    echo "+++ NO_BUILDWORLD set, skipping build" | tee -a ${LOGFILE}
	    return
	fi
	# Set SRC_CONF variable if it's not already set.
	if [ -z "${SRC_CONF:-}" ]; then
	    if [ -n "${MINIMAL:-}" ]; then
		SRC_CONF=${LOCALDIR}/conf/make.conf.minimal
	    else
		SRC_CONF=${LOCALDIR}/conf/make.conf
	    fi
	fi
	echo ">>> Building world for ${ARCH} architecture..."
	cd $SRCDIR
	unset EXTRA
	makeargs="${MAKEOPT:-} ${MAKEJ_WORLD:-} SRCCONF=${SRC_CONF} TARGET_ARCH=${ARCH}"
	echo ">>> Builder is running the command: env $MAKE_ENV script -aq $LOGFILE make ${makeargs:-} buildworld" > /tmp/freesbie_buildworld_cmd.txt
	(env $MAKE_ENV script -aq $LOGFILE make ${makeargs:-} buildworld || print_error_pfS;) | egrep '^>>>'
	cd $BUILDER_SCRIPTS
}

# Imported from FreeSBIE
installworld() {
	echo ">>> Installing world for ${ARCH} architecture..."
	cd $SRCDIR
	# Set SRC_CONF variable if it's not already set.
	if [ -z "${SRC_CONF:-}" ]; then
	    if [ -n "${MINIMAL:-}" ]; then
			SRC_CONF=${LOCALDIR}/conf/src.conf.minimal
	    else
			SRC_CONF=${LOCALDIR}/conf/src.conf
	    fi
	fi
	mkdir -p ${BASEDIR}
	cd ${SRCDIR}
	makeargs="${MAKEOPT:-} ${MAKEJ_WORLD:-} SRCCONF=${SRC_CONF} TARGET_ARCH=${ARCH} DESTDIR=${BASEDIR}"
	echo ">>> Builder is running the command: env $MAKE_ENV script -aq $LOGFILE make ${makeargs:-} installworld" > /tmp/freesbie_installworld_cmd.txt
	# make installworld
	(env $MAKE_ENV script -aq $LOGFILE make ${makeargs:-} installworld || print_error_pfS;) | egrep '^>>>'
	makeargs="${MAKEOPT:-} SRCCONF=${SRC_CONF} MODULES_OVERRIDE=${MODULES_OVERRIDE:-} TARGET_ARCH=${ARCH} DESTDIR=${BASEDIR}"
	set +e
	echo ">>> Builder is running the command: env $MAKE_ENV script -aq $LOGFILE make ${makeargs:-} distribution"  > /tmp/freesbie_installworld_distribution_cmd.txt
	# make distribution
	(env $MAKE_ENV script -aq $LOGFILE make ${makeargs:-} distribution || print_error_pfS;) | egrep '^>>>'
	set -e
	cd $BUILDER_SCRIPTS
}

# Imported from FreeSBIE
buildkernel() {
	# Set SRC_CONF variable if it's not already set.
	if [ -z "${SRC_CONF:-}" ]; then
	    if [ -n "${MINIMAL:-}" ]; then
			SRC_CONF=${LOCALDIR}/conf/make.conf.minimal
	    else
			SRC_CONF=${LOCALDIR}/conf/make.conf.${FREEBSD_VERSION}
	    fi
	fi
	if [ -n "${KERNELCONF:-}" ]; then
	    export KERNCONFDIR=$(dirname ${KERNELCONF})
	    export KERNCONF=$(basename ${KERNELCONF})
	elif [ -z "${KERNCONF:-}" ]; then
	    export KERNCONFDIR=${LOCALDIR}/conf/${ARCH}
	    export KERNCONF="FREESBIE"
	fi
	if [ -z "${WITH_DTRACE:-}" ]; then
		DTRACE=""
	else
		DTRACE=" WITH_CTF=1"
	fi
	SRCCONFBASENAME=`basename ${SRC_CONF}`
	echo ">>> KERNCONFDIR: ${KERNCONFDIR}"
	echo ">>> ARCH:        ${ARCH}"
	echo ">>> SRC_CONF:    ${SRCCONFBASENAME}"
	if [ "$DTRACE" != "" ]; then
		echo ">>> DTRACE:      ${DTRACE}"
	fi
	unset EXTRA
	makeargs="${MAKEOPT:-} ${MAKEJ_KERNEL:-} SRCCONF=${SRC_CONF} MODULES_OVERRIDE=${MODULES_OVERRIDE:-} TARGET_ARCH=${ARCH} ${DTRACE}"
	echo ">>> Builder is running the command: env $MAKE_ENV script -aq $LOGFILE make $makeargs buildkernel" > /tmp/freesbie_buildkernel_cmd.txt
	cd $SRCDIR
	(env $MAKE_ENV script -aq $LOGFILE make $makeargs buildkernel NO_KERNELCLEAN=yo || print_error_pfS;) | egrep '^>>>'
	cd $BUILDER_SCRIPTS

}

# Imported from FreeSBIE
installkernel() {
	# Set SRC_CONF variable if it's not already set.
	cd $SRCDIR
	if [ -z "${SRC_CONF:-}" ]; then
	    if [ -n "${MINIMAL:-}" ]; then
			SRC_CONF=${LOCALDIR}/conf/make.conf.minimal
	    else
			SRC_CONF=${LOCALDIR}/conf/make.conf.${FREEBSD_VERSION}
	    fi
	fi
	if [ -n "${KERNELCONF:-}" ]; then
	    export KERNCONFDIR=$(dirname ${KERNELCONF})
	    export KERNCONF=$(basename ${KERNELCONF})
	elif [ -z "${KERNCONF:-}" ]; then
	    export KERNCONFDIR=${LOCALDIR}/conf/${ARCH}
	    export KERNCONF="FREESBIE"
	fi
	mkdir -p ${BASEDIR}/boot
	cd ${SRCDIR}
	if [ -z "${WITH_DTRACE:-}" ]; then
		DTRACE=""
	else
		DTRACE=" WITH_CTF=1"
	fi
	makeargs="${MAKEOPT:-} ${MAKEJ_KERNEL:-} SRCCONF=${SRC_CONF} TARGET_ARCH=${ARCH} DESTDIR=${KERNEL_DESTDIR}"
	echo ">>> FreeSBIe2 is running the command: env $MAKE_ENV script -aq $LOGFILE make ${makeargs:-} installkernel ${DTRACE}"  > /tmp/freesbie_installkernel_cmd.txt
	(env $MAKE_ENV script -aq $LOGFILE make ${makeargs:-} installkernel || print_error_pfS;) | egrep '^>>>'
	echo ">>> Executing cd $KERNEL_DESTDIR/boot/kernel"
	if [ "${ARCH}" = "$(uname -p)" -a -z "${DEBUG:-}" ]; then
		echo ">>> Executing strip kernel"
	    strip $KERNEL_DESTDIR/boot/kernel/kernel
	fi
	gzip -f9 $KERNEL_DESTDIR/boot/kernel/kernel
	cd $BUILDER_SCRIPTS
}

# Launch is ran first to setup a few variables that we need
# Imported from FreeSBIE
launch() {

	if [ ! -f /tmp/pfSense_builder_set_time ]; then
		echo ">>> Updating system clock..."
		ntpdate 0.pfsense.pool.ntp.org
		touch /tmp/pfSense_builder_set_time
	fi

	if [ "`id -u`" != "0" ]; then
	    echo "Sorry, this must be done as root."
	    kill $$
	fi

	echo ">>> Operation $0 has started at `date`"

	# just return for now as we integrate
	return

	# If the PFSENSE_DEBUG environment variable is set, be verbose.
	[ ! -z "${PFSENSE_DEBUG:-}" ] && set -x

	# Set the absolute path for the toolkit dir
	LOCALDIR=$TOOLS_DIR

	CURDIR=$1;
	shift;

	TARGET=$1;
	shift;

	# Set LOGFILE.
	LOGFILE=$(mktemp -q /tmp/freesbie.XXXXXX)
	REMOVELOG=0

	cd $CURDIR

	if [ ! -z "${ARCH:-}" ]; then
		ARCH=${ARCH:-`uname -p`}
	fi

	# Some variables can be passed to make only as environment, not as parameters.
	# usage: env $MAKE_ENV make $makeargs
	MAKE_ENV=${MAKE_ENV:-}

	if [ ! -z ${MAKEOBJDIRPREFIX:-} ]; then
	    MAKE_ENV="$MAKE_ENV MAKEOBJDIRPREFIX=${MAKEOBJDIRPREFIX}"
	fi

}

finish() {
	echo ">>> Operation $0 has ended at `date`"
}
