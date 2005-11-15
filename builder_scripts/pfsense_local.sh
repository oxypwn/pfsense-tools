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


export SRCDIR=${SRCDIR:-/usr/src}
export FREESBIE_CONF=${FREESBIE_CONF:-${PWD}/conf/pfsense-freesbie.conf}
export FREESBIE_PATH=${FREESBIE_PATH:-/home/pfsense/freesbie2}
export KERNELCONF=${KERNELCONF:-${PWD}/conf/pfSense.6}
export MAKE_CONF=${MAKE_CONF:-$PWD/conf/make.conf}
export MAKEOBJDIRPREFIX=${MAKEOBJDIRPREFIX:-/usr/obj.pfSense}
export ISOPATH=${ISOPATH:-${MAKEOBJDIRPREFIX}/pfSense.iso}
export IMGPATH=${IMGPATH:-${MAKEOBJDIRPREFIX}/pfSense.iso}
export PKGFILE=${PKGFILE:-$PWD/conf/packages}
