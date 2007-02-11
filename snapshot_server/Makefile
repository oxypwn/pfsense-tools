#-*- mode: makefile; tab-width: 4; -*-
# ex:ts=4
#
# $Id$
#
#	Makefile - Copyright (C) 2007,	Scott Ullrich
#							Daniel S. Haischt <me@daniel.stefan.haischt.name>.
#	This file is placed under the BSD License, 2 clause.
#
# Please view me with 4 column tabs!

#
# Local variables that are used by builder scripts
#
WEBDATAROOT?=			/usr/local/www/data
WEBROOT?=				/usr/local/www
TOOLDIR?=				/home/pfsense/tools
BUILDERSCRIPTS?=		/home/pfsense/tools/builder_scripts
SNAPSHOTSCRIPTSDIR?=	/root/
PFSENSEUPDATESDIR?=		/home/pfsense/updates/
PFSENSEOBJDIR?=			/usr/obj.pfSense/
STAGINGAREA?=			/tmp/staging
CVSROOT?=				/home/pfsense/cvsroot
GZIP?=					-9
GZIP_CMD?=				/usr/bin/gzip -nf ${GZIP}
BZIP2_CMD?=				/usr/bin/bzip2
UPTIME_CMD?=			/usr/bin/uptime
IOSTAT?=				-C
IOSTAT_CMD?=			/usr/sbin/iostat ${IOSTAT}
CAT?=					/bin/cat
MKDIR?=					/bin/mkdir -p
TOUCH?=					/usr/bin/touch
TOUCH_FLAGS?=			-f
ECHO_CMD?=				echo # Shell builtin
CD_CMD?=				cd # Shell builtin
RM_CMD?=				/bin/rm
ECHO_MSG?=				${ECHO_CMD}
DATE_CMD?=				/bin/date
MD5?=					-md5
MD5_CMD?=				/sbin/md5 ${MD5}
CP_CMD?=				/bin/cp

make_dirs:
	@${MKDIR} ${CVSROOT}
	@${MKDIR} ${WEBDATAROOT}/FreeBSD6/RELENG_1/updates \
		 ${WEBDATAROOT}/FreeBSD6/RELENG_1/iso \
		 ${WEBDATAROOT}/FreeBSD6/RELENG_1/embedded \
		 ${WEBDATAROOT}/FreeBSD6/head/updates \
		 ${WEBDATAROOT}/FreeBSD6/head/iso \
		 ${WEBDATAROOT}/FreeBSD6/head/embedded
	@${MKDIR} ${WEBDATAROOT}/FreeBSD7/RELENG_1/iso/ \
		 ${WEBDATAROOT}/FreeBSD7/RELENG_1/embedded/ \
		 ${WEBDATAROOT}/FreeBSD7/RELENG_1/updates/ \
		 ${WEBDATAROOT}/FreeBSD7/head/iso/ \
		 ${WEBDATAROOT}/FreeBSD7/head/embedded/ \
		 ${WEBDATAROOT}/FreeBSD7/head/updates/
	@${MKDIR} /tmp/staging

touch_status_files: make_dirs
	@${TOUCH} ${TOUCH_FLAGS} ${WEBROOT}/-RELENG_1ISOSTATUS.txt \
	  ${WEBROOT}/-RELENG_1UPDATESSTATUS.txt \
	  ${WEBROOT}/-RELENG_1EMBEDDEDSTATUS.txt \
	  ${WEBROOT}/-RELENG_1STATUS.txt \
	  ${WEBROOT}/-HEADISOSTATUS.txt \
	  ${WEBROOT}/-HEADUPDATESSTATUS.txt \
	  ${WEBROOT}/-HEADEMBEDDEDSTATUS.txt \
	  ${WEBROOT}/-HEADSTATUS.txt

set_pfsense_source: touch_status_files set_version
	@${ECHO_CMD} $WITH_PFSENSE_VERSION > ${WEBROOT}/CURRENTLY_BUILDING_PLATFORM.txt

set_freebsd_source: touch_status_files set_version
	@${ECHO_CMD} $WITH_FREEBSD_VERSION > ${WEBROOT}/FREEBSD_PLATFORM.txt

set_pfsense_version:
.if defined(WITH_PFSENSE_VERSION)
	WITH_PFSENSE_VERSION="RELENG_1"
.endif

set_freebsd_version:
.if defined(WITH_FREEBSD_VERSION)
	WITH_FREEBSD_VERSION="RELENG_6_2"
.endif

set_version: set_pfsense_version set_freebsd_version

install_pfsense_local_sh:
	FREEBSD_PLATFORM=`cat ${WEBROOT}/FREEBSD_PLATFORM.txt`
	PFSENSE_PLATFORM=`cat ${WEBROOT}/CURRENTLY_BUILDING_PLATFORM.txt`
	@${CAT} <<EOF >${BUILDERSCRIPTS}/pfsense_local.sh

#!/bin/sh

# This is the base working directory for all builder
# operations
export BASE_DIR=\${BASE_DIR:-/home/pfsense}

# This is the directory where the latest pfSense cvs co
# is checked out to.
export CVS_CO_DIR=\${CVS_CO_DIR:-\${BASE_DIR}/pfSense}

export CUSTOMROOT=\${CUSTOMROOT:-\${CVS_CO_DIR}}

# This is the user that has access to the pfSense repo
export CVS_USER=\${CVS_USER:-sullrich}

# pfSense repo IP address. Typically cvs.pfsense.org,
# but somebody could use a ssh tunnel and specify
# a different one
export CVS_IP=\${CVS_IP:-cvs.pfsense.org}

export UPDATESDIR=\${UPDATESDIR:-\$BASE_DIR/updates}

export PFSENSEBASEDIR=\${PFSENSEBASEDIR:-/usr/local/pfsense-fs}

export PFSENSEISODIR=\${PFSENSEISODIR:-/usr/local/pfsense-clone}

# pfSense cvs tag to build
export PFSENSETAG="${PFSENSE_PLATFORM}"

# FreeSBIE 2 toolkit path
export FREESBIE_PATH=\${FREESBIE_PATH:-/home/pfsense/freesbie2}

# export variables used by freesbie2
export FREESBIE_CONF=\${FREESBIE_CONF:-/dev/null}
export SRCDIR=\${SRCDIR:-/usr/src}
export BASEDIR=\${PFSENSEBASEDIR:-/usr/local/pfsense-fs}
export CLONEDIR=\${PFSENSEISODIR:-/usr/local/pfsense-clone}
export MAKEOBJDIRPREFIX=\${MAKEOBJDIRPREFIX:-/usr/obj.pfSense}
export ISOPATH=\${ISOPATH:-\${MAKEOBJDIRPREFIX}/pfSense.iso}
export IMGPATH=\${IMGPATH:-\${MAKEOBJDIRPREFIX}/pfSense.img}
export PKGFILE=\${PKGFILE:-\$PWD/conf/packages}
export FREESBIE_LABEL=pfSense
export EXTRA="\${EXTRA:-"customroot buildmodules"}"
export BUILDMODULES="netgraph acpi ndis if_ndis padlock ipfw dummynet fdescfs"

MAKEJ=" "

# FreeBSD version.  6 or 7
export pfSense_version="6"
export freebsd_branch="${FREEBSD_PLATFORM}"

# Used by non pfSense developers
export SKIP_RSYNC=yes

# Custom overlay for people building or extending pfSense images.
# The custom overlay tar gzipped file will be extracted over the root
# of the prepared image allowing for customization.
#
# Note: It is also possible to specify a directory instead of a
#       gezipped tarball.
# export custom_overlay="/home/pfsense/custom_overlay.tgz"

export OVERRIDE_FREEBSD_CVSUP_HOST="cvsup.livebsd.com"

EOF

setstatus:
	CURRENTLY_BUILDING=`cat ${WEBROOT}/CURRENTLY_BUILDING_PLATFORM.txt`
	STATUS=`cat ${WEBDATAROOT}/status_msg.txt`
	@${ECHO_CMD} ${STATUS} > ${WEBDATAROOT}/status.txt
	@${UPTIME_CMD} >> ${WEBDATAROOT}/status.txt
	@${ECHO_CMD} >> ${WEBDATAROOT}/status.txt
	@${IOSTAT_CMD} >> ${WEBDATAROOT}/status.txt
	@${ECHO_CMD} >> ${WEBDATAROOT}/status.txt
	@${DATE_CMD} >> ${WEBDATAROOT}/status.txt
	@${ECHO_CMD} >> ${WEBDATAROOT}/status.txt
	@${ECHO_CMD} $1 >> ${WEBDATAROOT}/status.txt
	@${ECHO_CMD} >> ${WEBDATAROOT}/status.txt
	@${ECHO_CMD} "-RELENG_1 last known build status" \
				>> ${WEBDATAROOT}/status.txt
	@${ECHO_CMD} \
				>> ${WEBDATAROOT}/status.txt
	@${CAT} ${WEBROOT}/-RELENG_1ISOSTATUS.txt \
				>> ${WEBDATAROOT}/status.txt
	@${CAT} ${WEBROOT}/-RELENG_1UPDATESSTATUS.txt \
				>> ${WEBDATAROOT}/status.txt
	@${CAT} ${WEBROOT}/-RELENG_1EMBEDDEDSTATUS.txt \
				>> ${WEBDATAROOT}/status.txt
	@${CAT} ${WEBROOT}/-RELENG_1STATUS.txt \
				>> ${WEBDATAROOT}/status.txt
	@${ECHO} \
				>> ${WEBDATAROOT}/status.txt
	@${ECHO} "-HEAD last known build status" \
				>> ${WEBDATAROOT}/status.txt
	@${ECHO} \
				>> ${WEBDATAROOT}/status.txt
	@${CAT} ${WEBROOT}/-HEADISOSTATUS.txt \
				>> ${WEBDATAROOT}/status.txt
	@${CAT} ${WEBROOT}/-HEADUPDATESSTATUS.txt \
				>> ${WEBDATAROOT}/status.txt
	@${CAT} ${WEBROOT}/-HEADEMBEDDEDSTATUS.txt \
				>> ${WEBDATAROOT}/status.txt
	@${CAT} ${WEBROOT}/-HEADSTATUS.txt \
				>> ${WEBDATAROOT}/status.txt
	@${RM_CMD} ${WEBDATAROOT}/status_msg.txt

update_sources_status:
	STATUS="Updating sources and building ${CURRENTLY_BUILDING} ISO..."
	@${ECHO_CMD} ${STATUS} > ${WEBDATAROOT}/status_msg.txt
	
update_sources: update_sources_status setstatus
	CURRENTLY_BUILDING=`cat ${WEBROOT}/CURRENTLY_BUILDING_PLATFORM.txt`
	@${CD_CMD} ${BUILDERSCRIPTS}
	./cvsup_current
	ISO_FILE=${PFSENSEOBJDIR}/pfSense.iso
.if defined(USE_BZIP2)
	@${BZIP2_CMD} ${ISO_FILE}
	@${MD5_CMD} ${ISO_FILE} > ${ISO_FILE}.bz2.md5
.else
	@${GZIP_CMD} ${ISO_FILE}
	@${MD5_CMD} ${ISO_FILE} > ${ISO_FILE}.gz.md5
.endif
	@${ECHO_CMD} "Sources updated for ${CURRENTLY_BUILDING} last completed at `date`" \
				> ${WEBROOT}/${CURRENTLY_BUILDINGSTATUS}.txt

build_embedded_status:
	STATUS="Building embedded ${CURRENTLY_BUILDING} ..."
	@${ECHO_CMD}${STATUS} > ${WEBDATAROOT}/status_msg.txt

build_embedded: build_embedded_status setstatus
	CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
	@${CD_CMD} $BUILDERSCRIPTS
	./build_embedded.sh
	STATUS="Compressing embedded $CURRENTLY_BUILDING ..."
	IMAGE_FILE=${PFSENSEOBJDIR}/pfSense.img
.if defined(USE_BZIP2)
	@${RM_CMD} -f $PFSENSEOBJDIR/${IMAGE_FILE}.bz2
	@${BZIP2_CMD} ${IMAGE_FILE}
	@${MD5_CMD} ${IMAGE_FILE}.bz2 > ${IMAGE_FILE}.bz2.md5
.else
	@${RM_CMD} -f $PFSENSEOBJDIR/${IMAGE_FILE}.gz
	@${GZIP_CMD} ${IMAGE_FILE}
	@${MD5_CMD} ${IMAGE_FILE}.gz > ${IMAGE_FILE}.gz.md5
.endif
	@${ECHO_CMD} "Embedded for ${CURRENTLY_BUILDING} last completed at `date`" \
				> ${WEBROOT}/${CURRENTLY_BUILDINGEMBEDDEDSTATUS}.txt

build_updates_status:
	STATUS="Building updates..."
	@${ECHO_CMD}${STATUS} > ${WEBDATAROOT}/status_msg.txt

build_updates: build_updates_status setstatus update_sources
	CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
	@${CD_CMD} ${BUILDERSCRIPTS}
	./build_updates.sh
	for filename in ${PFSENSEUPDATESDIR}/*.tgz
	do
			@${MD5_CMD} ${filename} > ${filename}.md5
	done
	@${ECHO_CMD} "Updates for ${CURRENTLY_BUILDING last completed at `date`" \
				> ${WEBROOT}/${CURRENTLY_BUILDINGUPDATESSTATUS}.txt

build_iso_status:
	STATUS="Building ISO..."
	@${ECHO_CMD}${STATUS} > ${WEBDATAROOT}/status_msg.txt

build_iso: build_iso_status setstatus
	CURRENTLY_BUILDING=`cat $WEBROOT/CURRENTLY_BUILDING_PLATFORM.txt`
	@${CD_CMD} $BUILDERSCRIPTS
	./build_iso.sh
	@${ECHO_CMD} "FULL ISO for ${CURRENTLY_BUILDING} last completed at `date`" \
				> ${WEBROOT}/${CURRENTLY_BUILDINGISOSTATUS}.txt
				
all: set_pfsense_source set_freebsd_source copy_files
	
dobuilds: update_sources
	CURRENTLY_BUILDING=`cat ${WEBROOT}/CURRENTLY_BUILDING_PLATFORM.txt`
	@${CD_CMD} ${BUILDERSCRIPTS}

copy_iso_files: build_updates
	# Copy files before embedded, it wipes out usr.obj*
	@${CP_CMD} ${PFSENSEOBJDIR}/pfSense.iso.* ${STAGINGAREA}/

copy_embedded_files: build_embedded
	@${CP_CMD} ${PFSENSEOBJDIR}/pfSense.img.* ${STAGINGAREA}/

copy_files_status:
	STATUS="Copying files for -RELENG_1 build..."
	@${ECHO_CMD}${STATUS} > ${WEBDATAROOT}/status_msg.txt

copy_files: copy_files_status setstatus copy_iso_files copy_embedded_files
	@${CP_CMD} ${PFSENSEUPDATESDIR}/*.tgz ${STAGINGAREA}/
	@${CP_CMD} ${PFSENSEUPDATESDIR}/*.tgz.md5 ${STAGINGAREA}/

clean:
	@${RM_CMD} -rf /usr/obj*
	@${RM_CMD} ${PFSENSEUPDATESDIR}/*  # Keep updates dir slimmed down
