#!/bin/sh
#
#  set_version.sh
#  Copyright (C) 2004-2010 Scott Ullrich
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

if [ $# -lt 1 ]; then
	cat <<END_OF_USAGE 1>&2
Usage  : $0 BRANCH [SUP_HOST] [ERROR_EMAIL_ADDRESS] \\
         [COMPLETED_EMAIL_ADDRESS] [TWITTER_USERNAME] [TWITTER_PASSWORD] \\
         [REMOVE_PHP]
Example: $0 HEAD cvsup.example.com \\
         errors@example.com notify@example.com

BRANCH is required.

If SUP_HOST is omitted, fastest_cvsup will be used to select a CVSUp server
for you.  To omit SUP_HOST without omitting the following arguments, pass
'' in that position on the command line.

All other arguments may be omitted; when not present, that action will not
be taken.

END_OF_USAGE
	exit 127
fi

# Source pfsense-build.conf variables
. ./pfsense_local.sh
if [ -f ./pfsense-build.conf ]; then
	. ./pfsense-build.conf
fi

# Default SUPHOST
if [ "$2" != "" ]; then
	SUPHOST="$2"
else
	if [ -n "${USE_SVNUP}" ]; then
		echo "WARNING: If /usr/local/etc/svnup.conf is not configured, svnup will fail!"
		echo
		echo "Either set a server in /usr/local/etc/svnup.conf or pass in a svn server as the second parameter"
		sleep 2
	elif [ -f /usr/local/bin/fastest_cvsup ]; then
		echo "One moment please, finding the best cvsup server to use..."
		SUPHOST=`fastest_cvsup -c tld -q`
	else
		echo "WARNING:  Setting CVSUP host to cvsup.livebsd.org.  You must have firewall access for this to work on pfSense.org!"
		echo
		echo "You may install the fastest_cvsup port to automatically select a server: "
		echo "          cd  /usr/ports/sysutils/fastest_cvsup && make install"
		SUPHOST="cvsup.livebsd.org"
		sleep 2
	fi
fi

# Default EMAIL
if [ "$3" != "" ]; then
	FREESBIE_ERROR_MAIL="$3"
fi

if [ "$4" != "" ]; then
	FREESBIE_COMPLETED_MAIL="$4"
fi

if [ "$5" != "" ]; then
	TWITTER_USERNAME="$5"
fi

if [ "$6" != "" ]; then
	TWITTER_PASSWORD="$6"
fi

if [ "$7" != "" ]; then
	REMOVE_PHP="$7"
fi

HANDLED=false

# Ensure file exists
rm -f pfsense-build.conf
touch pfsense-build.conf

export BUILDER_SCRIPTS=`pwd`
export BUILDER_TOOLS=${BUILDER_SCRIPTS}/..
export BASE_DIR=${BUILDER_TOOLS}/..

strip_pfsense_local() {
	# Strip dynamic values
	cat $BUILDER_SCRIPTS/pfsense-build.conf | \
		grep -v BASE_DIR | \
		grep -v BUILDER_TOOLS | \
		grep -v BUILDER_SCRIPTS | \
		grep -v FREEBSD_VERSION | \
		grep -v FREEBSD_BRANCH | \
		grep -v PFSENSETAG | \
		grep -v "set_version.sh" | \
		grep -v PFSPATCHFILE | \
		grep -v PFSENSE_VERSION | \
		grep -v SUPFILE | \
		grep -v PFSPATCHDIR | \
		grep -v TWITTER_USERNAME | \
		grep -v TWITTER_PASSWORD | \
		grep -v PFSENSE_VERSION | \
		grep -v FREESBIE_COMPLETED_MAIL | \
		grep -v PFSPORTSFILE | \
		grep -v CUSTOM_COPY_LIST | \
		grep -v FREESBIE_ERROR_MAIL | \
		grep -v REMOVE_PHP | \
		grep -v EXTRA_DEVICES | \
		grep -v OVERRIDE_FREEBSD_CVSUP_HOST > /tmp/pfsense-build.conf
	mv /tmp/pfsense-build.conf $BUILDER_SCRIPTS/pfsense-build.conf
}

set_items() {
	strip_pfsense_local
	# Add our custom dynamic values
	echo "# set_version.sh generated defaults" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export PFSENSE_VERSION="${PFSENSE_VERSION}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export FREEBSD_VERSION="${FREEBSD_VERSION}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export FREEBSD_BRANCH="${FREEBSD_BRANCH}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export PFSENSETAG="${PFSENSETAG}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export PFSPATCHFILE="${PFSPATCHFILE}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export PFSPATCHDIR="${PFSPATCHDIR}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export SUPFILE="${SUPFILE}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export CUSTOM_COPY_LIST="${CUSTOM_COPY_LIST}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo "# Comment out the following line if you would like to automatically select an update server." >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export OVERRIDE_FREEBSD_CVSUP_HOST="${SUPHOST}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export BASE_DIR="${BASE_DIR}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export BUILDER_TOOLS="${BUILDER_TOOLS}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export BUILDER_SCRIPTS="${BUILDER_SCRIPTS}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	echo export EXTRA_DEVICES="${EXTRA_DEVICES}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	if [ -n "${USE_GIT}" ]; then
		echo "export USE_GIT=${USE_GIT}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	fi
	if [ -n "${FREEBSD_REPO_BASE}" ]; then
		echo "export FREEBSD_REPO_BASE=${FREEBSD_REPO_BASE}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	fi
	if [ -n "${SVN_BRANCH}" ]; then
		echo "export SVN_BRANCH=${SVN_BRANCH}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	fi
	if [ "$FREESBIE_ERROR_MAIL" != "" ]; then
		echo "export FREESBIE_ERROR_MAIL=${FREESBIE_ERROR_MAIL}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	fi
	if [ "$FREESBIE_COMPLETED_MAIL" != "" ]; then
		echo "export FREESBIE_COMPLETED_MAIL=${FREESBIE_COMPLETED_MAIL}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	fi
	if [ "$PFSPORTSFILE" != "" ]; then
		echo "export PFSPORTSFILE=${PFSPORTSFILE}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	fi
	if [ "$TWITTER_USERNAME" != "" ]; then
		echo "export TWITTER_USERNAME=${TWITTER_USERNAME}" >> $BUILDER_SCRIPTS/pfsense-build.conf
		echo "export TWITTER_PASSWORD=${TWITTER_PASSWORD}" >> $BUILDER_SCRIPTS/pfsense-build.conf
	fi
	if [ "$REMOVE_PHP" != "" ]; then
		echo "export REMOVE_PHP=true" >> $BUILDER_SCRIPTS/pfsense-build.conf
	fi
	UNAME=`uname -m`
	if [ "$UNAME" = "amd64" ]; then
		echo "export ARCH=amd64" >> $BUILDER_SCRIPTS/pfsense-build.conf
		echo "export TARGETARCH=amd64" >> $BUILDER_SCRIPTS/pfsense-build.conf
	fi
	if [ "$UNAME" = "mips" ]; then
		echo "export ARCH=mips" >> $BUILDER_SCRIPTS/pfsense-build.conf
		echo "export TARGETARCH=mips" >> $BUILDER_SCRIPTS/pfsense-build.conf
	fi

	# For developers debugging on builders.
	echo "#export PFSENSE_WITH_FULL_GIT_CHECKOUT=\"true\"" >> $BUILDER_SCRIPTS/pfsense-build.conf

	# Output pfsense-build.conf
	echo
	echo ">>> Custom pfsense-build.conf contains:"
	echo "---------------------------------------------------------------------------------------"
	cat pfsense-build.conf
	echo "---------------------------------------------------------------------------------------"
	echo
	echo " NOTE: pfsense-build.conf values updated.  These values override pfsense_local.sh !!"
	echo
	echo "NOTE2: pfPorts will be rebuilt!"
	echo "       remove /tmp/pfPorts_forced_build_required to cancel"
	echo
	HANDLED=true
	touch /tmp/pfPorts_forced_build_required
}

echo

case $1 in
RELENG_10_0)
	echo ">>> Setting builder environment to use HEAD/RELENG_10_0 ..."
	export FREEBSD_VERSION="10"
	export FREEBSD_BRANCH="RELENG_10_0"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/conf/csup/RELENG_10_0-supfile"
	export PFSENSE_VERSION=2.2-DEVELOPMENT
	export PFSENSETAG=HEAD
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_10_0
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/conf/patchlist/patches.RELENG_10_0
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/conf/copylist/copy.list.RELENG_2_2"
	export PFSPORTSFILE=buildports.RELENG_2_2
	export EXTRA_DEVICES=${EXTRA_DEVICES:-"siba_bwn,bwn"}
	export USE_GIT=yes
	export FREEBSD_REPO_BASE=https://github.com/freebsd/freebsd.git
	export SVN_BRANCH=releng/10.0
	set_items
;;

HEAD)
	echo ">>> Setting builder environment to use HEAD/RELENG_10_0 ..."
	export FREEBSD_VERSION="10"
	export FREEBSD_BRANCH="RELENG_10_0"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/conf/csup/RELENG_10_0-supfile"
	export PFSENSE_VERSION=2.2-DEVELOPMENT
	export PFSENSETAG=HEAD
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_10_0
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/conf/patchlist/patches.RELENG_10_0
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/conf/copylist/copy.list.RELENG_2_2"
	export PFSPORTSFILE=buildports.RELENG_2_2
	export EXTRA_DEVICES=${EXTRA_DEVICES:-"siba_bwn,bwn"}
	export USE_GIT=yes
	export FREEBSD_REPO_BASE=https://github.com/freebsd/freebsd.git
	export SVN_BRANCH=releng/10.0
	set_items
;;

RELENG_8_3)
	echo ">>> Setting builder environment to use HEAD/RELENG_8_3 ..."
	export FREEBSD_VERSION="8"
	export FREEBSD_BRANCH="RELENG_8_3"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/conf/csup/RELENG_8_3-supfile"
	export PFSENSE_VERSION=2.1-RELEASE
	export PFSENSETAG=RELENG_2_1
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_8_3
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/conf/patchlist/patches.RELENG_8_3
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/conf/copylist/copy.list.RELENG_2_1"
	export PFSPORTSFILE=buildports.RELENG_2_1
	export EXTRA_DEVICES=${EXTRA_DEVICES:-"siba_bwn,bwn,run"}
	set_items
;;

RELENG_2_1)
	echo ">>> Setting builder environment to use head + RELENG_8_3 ..."
	export FREEBSD_VERSION="8"
	export FREEBSD_BRANCH="RELENG_8_3"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/conf/csup/RELENG_8_3-supfile"
	export PFSENSE_VERSION=2.1-RELEASE
	export PFSENSETAG=RELENG_2_1
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_8_3
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/conf/patchlist/patches.RELENG_8_3
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/conf/copylist/copy.list.RELENG_2_1"
	export PFSPORTSFILE=buildports.RELENG_2_1
	export EXTRA_DEVICES=${EXTRA_DEVICES:-"siba_bwn,bwn,run"}
	set_items
;;

RELENG_2_0)
	echo ">>> Setting builder environment to use RELENG_2_0 + RELENG_8_1 ..."
	export FREEBSD_VERSION="8"
	export FREEBSD_BRANCH="RELENG_8_1"
	export SUPFILE="${BUILDER_TOOLS}/builder_scripts/conf/csup/RELENG_8_1-supfile"
	export PFSENSE_VERSION=2.0-RELEASE
	export PFSENSETAG=RELENG_2_0
	export PFSPATCHDIR=${BUILDER_TOOLS}/patches/RELENG_8_1
	export PFSPATCHFILE=${BUILDER_TOOLS}/builder_scripts/conf/patchlist/patches.RELENG_8_1
	export CUSTOM_COPY_LIST="${BUILDER_TOOLS}/builder_scripts/conf/copylist/copy.list.RELENG_8_0"
	export PFSPORTSFILE=buildports.RELENG_2_0
	export EXTRA_DEVICES=${EXTRA_DEVICES:-"siba_bwn,bwn,run"}
	set_items
;;

esac

./apply_kernel_patches.sh
./clean_build.sh

if [ "$HANDLED" = "false" ]; then
	echo "Invalid verison."
fi
