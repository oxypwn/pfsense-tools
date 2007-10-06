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

PLATFORM=`cat $CVS_CO_DIR/etc/platform`

#
# Note: This function prepares the environment needed by the script pfspkg_installer
#       The Freesbie system its finall executing pfspkg_installer in a chroot env.
#
install_custom_packages_setup() {
	TODIR="${BASEDIR}"
	DESTNAME="pkginstall.sh"

	# Extra package list if defined.
	if [ ! -z "${custom_package_list:-}" ]; then
		# Notes:
		# ======
		# /etc/platform is required cause some scripts are demanding for its existence
		# devfs mount is required cause PHP requires /dev/stdin
		# tried to fake symlink /conf
		# php.ini needed to make PHP argv capable
		#
		echo "Installing custom packages to: ${TODIR} using platform type ${PLATFORM} ..."

#		if [ ! -f ${TODIR}/etc/platform ]; then
#			echo "installing temporary platform file to ${TODIR}/etc ..."	
#			touch ${TODIR}/etc/platform
#			touch ${TODIR}/tmp/remove_platform
#		else
#			echo "Using existing platform file from ${TODIR}/etc ..."
#		fi

		echo "Mounting temporary devfs filesystem to ${TODIR} ..."
		mount -t devfs devfs ${TODIR}/dev

		echo "Copying resolv.conf to ${TODIR} to enable pkg manager to resolve DNS names ..."
		cp /etc/resolv.conf ${TODIR}/etc

		if [ ${PLATFORM} != "embedded" ]; then
			# test whether conf dir is already a symlink
			if [ ! -f ${TODIR}/conf ]; then
				# backup original conf dir
				if [ -d ${TODIR}/conf ]; then
					echo "Backing up conf dir to ${TODIR}/conf.org ..."
					chroot ${TODIR} /bin/mv /conf /conf.org
					touch ${TODIR}/tmp/restore_conf_dir
				fi

				# install the symlink as it would exist on a live system
				echo "Symlinking ${TODIR}/cf/conf to ${TODIR}/conf ..."
				chroot ${TODIR} /bin/ln -s /cf/conf /conf
				touch ${TODIR}/tmp/remove_conf_symlink
			else
				# seems like we are already working with a conf dir that is a symlink
				echo "Using existing conf dir from ${TODIR} ..."
			fi

			# now that we do have the symlink in place create
			# a backup dir if necessary.
			if [ ! -d ${TODIR}/cf/conf/backup ]; then
				echo "Creating backup dir in ${TODIR}/cf/conf ..."
				chroot ${TODIR} /bin/mkdir -p /cf/conf/backup
				touch ${TODIR}/tmp/remove_backup
			else
				echo "Using existing backup dir from ${TODIR}/cf/conf ..."
			fi
		fi

		echo "Installing temporary php.ini to ${TODIR}/tmp ..."
		echo "register_argc_argv=1" > ${TODIR}/tmp/php.ini

		echo "Installing custom pfSense package installer to ${TODIR}/tmp ..."
		cp ./pfspkg_installer ${TODIR}/tmp
		chmod a+x ${TODIR}/tmp/pfspkg_installer
	fi
}

install_custom_packages_exec() {
	DESTNAME="pkginstall.sh"

	# setup script that will be run within the chroot env
	cat > ${FREESBIE_PATH}/extra/customscripts/${DESTNAME} <<EOF
#!/bin/sh
#
# Assemble package list if necessary
#
/tmp/pfspkg_installer -q -m config -l /tmp/pkgfile.lst -p .:/etc/inc:/usr/local/www:/usr/local/captiveportal:/usr/local/pkg
#
# Exec PHP script which installs pfSense packages in place
#
/tmp/pfspkg_installer -q -m install -l /tmp/pkgfile.lst -p .:/etc/inc:/usr/local/www:/usr/local/captiveportal:/usr/local/pkg

#
# Cleanup
#
echo "Deleting temporary php.ini from /tmp"
rm /tmp/php.ini

if [ -f /tmp/remove_platform ]; then
	echo "Removing temporary platform file from /etc ..."
	rm /etc/platform
	rm /tmp/remove_platform
fi

if [ -f /tmp/remove_backup ]; then
	echo "Removing temporary backup dir from /conf ..."
	rm -rf /cf/conf/backup
	rm /tmp/remove_backup
fi

if [ -f /tmp/remove_conf_symlink ]; then
	echo "Removing temporary conf dir ..."
	rm /conf
	rm /tmp/remove_conf_symlink
	
	if [ -f /tmp/restore_conf_dir ]; then
		echo "Restoring original conf dir ..."
		mv /conf.org /conf
		rm /tmp/restore_conf_dir
	fi
fi

echo "Removing temporary resolv.conf from /etc ..."
rm /etc/resolv.conf

EOF

}

install_custom_packages_setup
install_custom_packages_exec

