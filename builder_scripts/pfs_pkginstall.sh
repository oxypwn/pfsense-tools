#!/bin/sh
#
# $Id$ 
#========================================================================== 
#
# pfspkg_installer
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

install_custom_packages() {
	# Extra package list if defined.
	if [ ! -z "${custom_package_list:-}" ]; then
		# Notes:
		# ======
		# /etc/platform is required cause some scripts are demanding for its existence
		# devfs mount is required cause PHP requires /dev/stdin
		# tried to fake symlink /conf
		# php.ini needed to make PHP argv capable
		#
		touch /etc/platform && \
		mount -t devfs devfs ${BASEDIR}/dev && \
		chroot ${BASEDIR} ln -s /cf/conf /conf && \
		chroot ${BASEDIR} echo "register_argc_argv=1" > /tmp/php.ini
		PHP_INC_PATH="${CVS_CO_DIR}/etc/inc:${CVS_CO_DIR}/usr/local/www:${CVS_CO_DIR}/usr/local/captiveportal:${CVS_CO_DIR}/usr/local/pkg"
		${FREESBIE_PATH}/scripts/custom/pfspkg_installer -q -m config -p ${PHP_INC_PATH} -l ${custom_package_list} && \
		chroot ${BASEDIR} /tmp/pfspkg_installer -q -m install -l /tmp/pkgfile.lst -p .:/etc/inc:/usr/local/www:/usr/local/captiveportal:/usr/local/pkg
		# cleanup
		chroot ${PFSENSEBASEDIR} /tmp/php.ini && \
		chroot ${PFSENSEBASEDIR} rm /conf && \
		umount  ${PFSENSEBASEDIR}/dev && \
		rm /etc/platform
	fi
}

. ${FREESBIE_PATH}/scripts/pkginstall.sh && \
install_custom_packages
