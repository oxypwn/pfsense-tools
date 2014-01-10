#!/bin/sh

#set -e
#set -x
#set -u

# Keep track of build failures
rm -f /tmp/pfPort_build_failures
touch /tmp/pfPort_build_failures

# Keep track of items already built (dependencies)
rm -f /tmp/pfPort_alreadybuilt
touch /tmp/pfPort_alreadybuilt

# Individual logs here
mkdir -p /tmp/pfPort/buildlogs

BASEDIR=$(cd $(dirname $0)/../..; pwd)
PFPORTSDIR="${BASEDIR}/pfPorts"

BUILD_ONEPORT=""
MAKEJ_PORTS=""
CHECK_INSTALLED=""
PORTS_LIST=""
MAKE_CONF=""

while getopts P:J:l:m:c o; do
	case "${o}" in
		P)	BUILD_ONEPORT="${OPTARG}"
			echo ">>> Building a single port: '${BUILD_ONEPORT}'"
			;;
		J)	MAKEJ_PORTS="${OPTARG}"
			echo ">>> Setting MAKEJ_PORTS (-j) to '${MAKEJ_PORTS}'"
			;;
		l)	PORTS_LIST="${OPTARG}"
			echo ">>> Setting ports list: '${PORTS_LIST}'"
			;;
		m)	MAKE_CONF="${OPTARG}"
			echo ">>> Setting ports make.conf: '${MAKE_CONF}'"
			;;
		c)	CHECK_INSTALLED="check_installed"
			;;
	esac
done

if [ -z "${MAKE_CONF}" -o ! -f "${MAKE_CONF}" ]; then
	MAKE_CONF="${BASEDIR}/builder_scripts/conf/pfPorts/make.conf"
fi

MAKE_CONF="__MAKE_CONF=${MAKE_CONF}"

if [ -z "${PORTS_LIST}" -o ! -f "${PORTS_LIST}" ]; then
	echo ">>> ERROR! Invalid Port list"
	exit 1
fi

if [ -f ./pfsense-build.conf ]; then
	if grep -q '^export REMOVE_PHP=true' pfsense-build.conf; then
		echo ">>> Removing previous PHP environment..."
		pkg delete -y -R -f -q -g php* 2>/dev/null
		find /usr/local/include /usr/local/man/ /usr/local/bin /usr/local/sbin /usr/local/lib /usr/local/etc -name "*php*" -exec rm -rf {} \; 2>/dev/null
		find /usr/local -name extensions.ini -delete
	fi
fi

if [ -z "${MAKEJ_PORTS}" ]; then
	if [ -f pfsense_local.sh ]; then
		MAKEJ_PORTS=$(grep MAKEJ_PORTS pfsense_local.sh | cut -d'"' -f2)
	fi
fi

# Remove blank and commented out lines
PORTSTOBUILD=$(cat ${PORTS_LIST} | sed -e '/^[[:blank:]]*$/d; /^[[:blank:]]#/d')

overlay_port() {
	local PORTPATH
	local PORTNAME

	PORTPATH="${1}"
	PORTNAME=$(basename $PORTPATH)

	if [ -d ${PFPORTSDIR}/$PORTNAME ]; then
		echo ">>> Overlaying pfPorts ${PFPORTSDIR}/$PORTNAME to ${PORTPATH} and building..."
		rm -rf $PORTPATH
		mkdir -p $PORTPATH
		rm -rf ${PFPORTSDIR}/$PORTNAME/work 2>/dev/null
		cp -R ${PFPORTSDIR}/$PORTNAME/* $PORTPATH/
	fi
}

clean_make_install() {
	# Architecture, supported ARCH values are:
	#  Tier 1: i386, AMD64, and PC98
	#  Tier 2: ARM, PowerPC, ia64, Sparc64 and sun4v
	#  Tier 3: MIPS and S/390
	#  Tier 4: None at the moment
	#  Source: http:/www.freebsd.org/doc/en/articles/committers-guide/archs.html
	# Default is i386
	local PORTA
	local VERIFY
	local _PORTNAME
	local PKGNAME
	local _PKGNAME
	local BUILDLIST

	PORTA="${1}"
	VERIFY="${2}"

	_PORTNAME=$(basename $PORTA)
	PKGNAME=$(make -C $PORTA -V PKGNAME)

	# Check to see if item is already built
	if grep -q "$PKGNAME" /tmp/pfPort_alreadybuilt; then
		if [ -z "$VERIFY" -o -f $VERIFY ]; then
			echo ">>> $_PORTNAME(${PKGNAME})...already built on this run.  Skipping."
			return
		fi
	fi

	# Complete dependency chain first
	BUILDLIST=$(make -C ${PORTA} build-depends-list 2>/dev/null)
	for BUILD in $BUILDLIST; do
		# Check to see if item is already built
		overlay_port ${BUILD}
		local _PKGNAME=$(make -C $PORTA -V PKGNAME)
		SKIP=0
		if grep -q "$_PKGNAME" /tmp/pfPort_alreadybuilt; then
			SKIP=1
			echo "    Dependency $BUILD of $PORTA already built on this run.  Skipping."
		elif [ "${CHECK_INSTALLED}" = "check_installed" ]; then
			if pkg query %n ${_PKGNAME} >/dev/null 2>&1; then
				if [ -z "$VERIFY" -o -f $VERIFY ]; then
					echo "$_PKGNAME" >> /tmp/pfPort_alreadybuilt
					SKIP=1
				fi
			fi
		fi

		if [ ${SKIP} -eq 0 ]; then
			echo "    Building dependency $BUILD of $PORTA"
			clean_build_install_clean $BUILD
		fi
	done
	unset BUILD
	unset BUILDLIST

	echo -n ">>> Building $_PORTNAME(${PKGNAME})..."
	if [ "${BUILD_ONEPORT}" = "" -a "${CHECK_INSTALLED}" = "check_installed" ]; then
		if pkg query %n ${PKGNAME} >/dev/null 2>&1; then
			if [ -z "$VERIFY" -o -f $VERIFY ]; then
				echo "$PKGNAME" >> /tmp/pfPort_alreadybuilt
				echo "already built.  Skipping."
				return
			fi
		fi
	fi

	if ! script /tmp/pfPort/buildlogs/$_PORTNAME make ${MAKE_CONF} -C $PORTA \
	    TARGET_ARCH=${ARCH} ${MAKEJ_PORTS} BATCH=yes FORCE_PKG_REGISTER=yes \
	    clean build deinstall install clean 2>&1 1>/dev/null; then
		echo ">>> Building $_PORTNAME(${PKGNAME})...ERROR!" >> /tmp/pfPort_build_failures
		echo "Failed to build. Error log in /tmp/pfPort/buildlogs/$_PORTNAME."
	else
		mv /tmp/pfPort/buildlogs/$_PORTNAME /tmp/pfPort/$PKGNAME
		echo "$PKGNAME" >> /tmp/pfPort_alreadybuilt
		echo "Done."
	fi

}

clean_build_install_clean() {
	local PORTPATH
	local VERIFYPORT
	local PORTNAME

	PORTPATH="${1}"
	VERIFYPORT="${2}"
	PORTNAME=$(basename $PORTPATH)

	if [ ! -d $PORTPATH ]; then
		echo ">>> Port PATH does not exist: '${PORTPATH}'"
		return
	fi

	clean_make_install $PORTPATH $VERIFYPORT
}

# Change the for seperator to use C/R instead of whitespace
oIFS=$IFS
IFS="
"

for PORT in $PORTSTOBUILD; do
	PORT_NAME=$(echo $PORT | awk '{ print $1 }')
	if [ "$BUILD_ONEPORT" != "" -a "$PORT_NAME" != "$BUILD_ONEPORT" ]; then
		continue
	fi
	PORT_LOCATION=$(echo $PORT | awk '{ print $2 }')
	PORT_VERIFY_INSTALL_FILE=$(echo $PORT | awk '{ print $3 }')
	MIPS_DO_NOT_BUILD="beep
"
	for DONOTBUILD in $MIPS_DO_NOT_BUILD; do
		if [ "$PORT_NAME" = "$DONOTBUILD" ]; then
			if [ "$ARCH" = "mips" ]; then
				echo ">>> Skipping $PORT_NAME on MIPS platform..."
				continue 2
			fi
			if [ "$ARCH" = "powerpc" ]; then
				echo ">>> Skipping $PORT_NAME on POWERPC platform..."
				continue 2
			fi
		fi
	done

	PORTSUFFIX=$(echo $PORT_LOCATION | cut -d'/' -f4-5)
	if [ "$PORTSUFFIX" != "" ]; then
		# Return the seperator back to its original value
		IFS=$oIFS
		overlay_port ${PORT_LOCATION}
		clean_build_install_clean $PORT_LOCATION $PORT_VERIFY_INSTALL_FILE
		# Change the for seperator to use C/R instead of whitespace
		IFS="
"
	else
		echo ">>> Could not Locate PORTSUFFIX for $PORT_LOCATION"
	fi
	# If the file is not found, log it.
	if [ ! -f $PORT_VERIFY_INSTALL_FILE ]; then
		echo ">>> File not found $PORT - $PORT_VERIFY_INSTALL_FILE" >> /tmp/pfPort_build_failures
	fi

	if [ "$BUILD_ONEPORT" != "" -a "$PORT_NAME" = "$BUILD_ONEPORT" ]; then
		break
	fi
done

echo ">>> Ports with failures: $(cat /tmp/pfPort_build_failures | wc -l)"
cat /tmp/pfPort_build_failures
echo

sleep 1

# Restore
IFS=$oIFS
