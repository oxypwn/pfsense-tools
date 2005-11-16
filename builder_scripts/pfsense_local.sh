# This is the base working directory for all builder
# operations
export BASE_DIR=${BASE_DIR:-/home/pfsense}

# This is the directory where the latest pfSense cvs co
# is checked out to.
export CVS_CO_DIR=${CVS_CO_DIR:-${BASE_DIR}/pfSense}

export CUSTOMROOT=${CUSTOMROOT:-${CVS_CO_DIR}}

# This is the user that has access to the pfSense repo
export CVS_USER=${CVS_USER:-sullrich}

# pfSense repo IP address. Tipically cvs.pfsense.org,
# but somebody could use a ssh tunnel and specify
# a different one
export CVS_IP=${CVS_IP:-cvs.pfsense.org}

export UPDATESDIR=${UPDATESDIR:-$BASE_DIR/updates}

export PFSENSEBASEDIR=${PFSENSEBASEDIR:-/usr/local/pfsense-fs}

export PFSENSEISODIR=${PFSENSEISODIR:-/usr/local/pfsense-clone}

# pfSense cvs tag to build
export PFSENSETAG=${PFSENSETAG:-RELENG_1}

# FreeSBIE 2 toolkit path
export FREESBIE_PATH=${FREESBIE_PATH:-/home/pfsense/freesbie2}

# export variables used by freesbie2
export FREESBIE_CONF=${FREESBIE_CONF:-/dev/null} # No configuration file should be override our variables
export SRCDIR=${SRCDIR:-/usr/src}
export BASEDIR=${PFSENSEBASEDIR:-/usr/local/pfsense-fs}
export CLONEDIR=${PFSENSEISODIR:-/usr/local/pfsense-clone}
export MAKE_CONF=${MAKE_CONF:-$PWD/conf/make.conf}
export MAKEOBJDIRPREFIX=${MAKEOBJDIRPREFIX:-/usr/obj.pfSense}
export ISOPATH=${ISOPATH:-${MAKEOBJDIRPREFIX}/pfSense.iso}
export IMGPATH=${IMGPATH:-${MAKEOBJDIRPREFIX}/pfSense.img}
export PKGFILE=${PKGFILE:-$PWD/conf/packages}
export FREESBIE_LABEL=pfSense
export EXTRA="customroot buildmodules"
export BUILDMODULES="netgraph acpi ndis if_ndis padlock geom ipfw dummynet"
