#!/bin/sh
#
# $Id$ 
#========================================================================== 
#
# pfs_custom_pkginstaller.sh
# part of pfSense (http://www.pfSense.com)
# Copyright (C) 2007 Daniel S. Haischt <me@daniel.stefan.haischt.name>
# All rights reserved.
#
#========================================================================== 
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#  1. Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#                                                                            
#========================================================================== 

#
# Uncomment to debug this script standalone
#
#. ./pfsense_local.sh

#
# Note: This function prepares the environment needed by the script pfspkg_installer
#       The Freesbie system its finall executing pfspkg_installer in a chroot env.
#
pfsense_install_custom_packages_setup() {
	TODIR="${BASEDIR}"
	DESTNAME="pkginstall.sh"

	# Extra package list if defined.
	if [ ! -z "${custom_package_list:-}" ]; then
		# Notes:
		# ======
		# devfs mount is required cause PHP requires /dev/stdin
		# php.ini needed to make PHP argv capable
		#
		/bin/echo "Installing custom packages to: ${TODIR} ..."

		/bin/echo "Mounting temporary devfs filesystem to ${TODIR} ..."
		/sbin/mount -t devfs devfs ${TODIR}/dev

		/bin/echo "Copying resolv.conf to ${TODIR} to enable pkg manager to resolve DNS names ..."
		/bin/cp /etc/resolv.conf ${TODIR}/etc

		/bin/echo "Installing temporary php.ini to ${TODIR}/tmp ..."
		/bin/cp ${CVS_CO_DIR}/usr/local/lib/php.ini ${TODIR}/tmp
		/bin/echo "register_argc_argv=1" >> ${TODIR}/tmp/php.ini

		/bin/echo "Dumping contents of custom_package_list to ${TODIR}/tmp/pkgfile.lst ..."
		/bin/echo ${custom_package_list} > ${TODIR}/tmp/pkgfile.lst

		/bin/echo "Installing custom pfSense package installer to ${TODIR}/tmp ..."
		/bin/cp ./pfspkg_installer ${TODIR}/tmp
		/bin/chmod a+x ${TODIR}/tmp/pfspkg_installer
	fi
}

pfsense_install_custom_packages_exec() {
	DESTNAME="pkginstall.sh"

	# setup script that will be run within the chroot env
	/bin/cat > ${FREESBIE_PATH}/extra/customscripts/${DESTNAME} <<EOF
#!/bin/sh
#
# ------------------------------------------------------------------------
# ATTENTION: !!! This script is supposed to be run within a chroot env !!!
# ------------------------------------------------------------------------
#
#
# Setup
#
# backup original conf dir
if [ -d /conf ]; then
	/bin/echo "Backing up conf dir to /conf.org ..."
	/bin/mv /conf /conf.org
	/usr/bin/touch /tmp/restore_conf_dir
fi

# test whether conf dir is already a symlink
if [ ! -f /conf ]; then
	# install the symlink as it would exist on a live system
	/bin/echo "Symlinking /conf.default to /conf ..."
	/bin/ln -s /conf.default /conf
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

install_custom_packages_clean() {
	#
	# Cleanup
	#
	/bin/echo "Deleting temporary php.ini from /tmp"
	/bin/rm /tmp/php.ini

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
		/bin/rm /tmp/remove_conf_symlink
	
		if [ -f /tmp/restore_conf_dir ]; then
			/bin/echo "Restoring original conf dir ..."
			/bin/mv /conf.org /conf
			/bin/rm /tmp/restore_conf_dir
		fi
	fi

	/bin/echo "Removing temporary resolv.conf from /etc ..."
	/bin/rm /etc/resolv.conf

	/bin/echo "Removing pfspkg_installer script from /tmp ..."
	/bin/rm /tmp/pfspkg_installer

	/bin/echo "Removing custom packages list file from /tmp ..."
	/bin/rm /tmp/pkgfile.lst

	/bin/echo "Removing possible package install leftover (*.tbz, *.log) ..."
	/bin/rm /tmp/*.log /tmp/*.tbz

	/bin/echo "Removing config.cache which was generating during package install ..."
	/bin/rm /tmp/*.cache
}

#
# Comment this line if you do not want to clean files from your system
#
install_custom_packages_clean

EOF

}

pfsense_install_custom_packages_setup
pfsense_install_custom_packages_exec

