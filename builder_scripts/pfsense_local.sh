# This is the base working directory for all builder
# operations
export BASE_DIR=/home/pfsense

export CUSTOMROOT=${BASE_DIR}/tools/builder_scripts/customroot

# This is the directory where the latest pfSense cvs co
# is checked out to.
export CVS_CO_DIR=$BASE_DIR/pfSense

# This is the user that has access to the pfSense repo
export CVS_USER=satu

# pfSense repo IP address. Tipically cvs.pfsense.org,
# but somebody could use a ssh tunnel and specify
# a different one
export CVS_IP=127.0.0.1

export UPDATESDIR=$BASE_DIR/updates

export PFSENSEBASEDIR=/usr/local/pfsense-fs

export PFSENSEISODIR=/usr/local/pfsense-clone

export SRCDIR=/usr/src
export FREESBIE_CONF=$PWD/conf/pfsense-freesbie.conf
export FREESBIE_PATH=/home/satu/cvs/freesbie2
export KERNELCONF=$PWD/conf/pfSense.6
export MAKE_CONF=$PWD/conf/make.conf
export MAKEOBJDIRPREFIX=/usr/obj.pfSense
