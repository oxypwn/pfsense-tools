#/bin/sh
# Instructions (as root)-- make a directory and put this script inside it.
# chmod +x workon.sh
# Download or copy an image file into the directory
# ./workon.sh wrap-1.11.img
# This will start your SHELL inside the mounted image.
# When you are done, type exit.  This exits your SHELL and lets
# this script proceed (umount, gzip, etc).
# The image file now contains your changes (and is no longer signed).

# Set your shell -- /bin/csh will always work
SHELL=/usr/local/bin/bash
[ ! -x $SHELL ] && echo "${SHELL} not executable (try /bin/csh)" && exit 1

# No more edits

IMAGE=$1

# Make dirs
mkdir -p tmp; mkdir -p mnt1; mkdir -p mnt2

# Decompress IMAGE
gzip -dc < ${IMAGE} > tmp/${IMAGE}

# Mount IMAGE
mdconfig -a -t vnode -f tmp/${IMAGE} -u 90
mount /dev/md90 mnt1

# Decompress mfsroot
gzip -dc < mnt1/mfsroot.gz > tmp/${IMAGE}-mfsroot

# Mount mfsroot
mdconfig -a -t vnode -f tmp/${IMAGE}-mfsroot -u 91
mount /dev/md91 mnt2

# cd to 2nd mount and exec SHELL
cd mnt2
${SHELL}

# SHELL has exited -- clean up and compress
for vtmp in `find . | grep '~$'`; do
	echo Removing: ${vtmp}
	rm -f ${vtmp}
done
cd ../

umount mnt2
mdconfig -d -u 91

gzip -c9 < tmp/${IMAGE}-mfsroot > mnt1/mfsroot.gz
rm -f tmp/${IMAGE}-mfsroot

umount mnt1
mdconfig -d -u 90

gzip -c9 < tmp/${IMAGE} > ${IMAGE}
rm -f tmp/${IMAGE}

#/bin/sh
# Instructions (as root)-- make a directory and put this script inside it.
# chmod +x workon.sh
# Download or copy an image file into the directory
# ./workon.sh wrap-1.11.img
# This will start your SHELL inside the mounted image.
# When you are done, type exit.  This exits your SHELL and lets
# this script proceed (umount, gzip, etc).
# The image file now contains your changes (and is no longer signed).

# Set your shell -- /bin/csh will always work
SHELL=/usr/local/bin/bash
[ ! -x $SHELL ] && echo "${SHELL} not executable (try /bin/csh)" && exit 1

# No more edits

IMAGE=$1

# Make dirs
mkdir -p tmp; mkdir -p mnt1; mkdir -p mnt2

# Decompress IMAGE
gzip -dc < ${IMAGE} > tmp/${IMAGE}

# Mount IMAGE
mdconfig -a -t vnode -f tmp/${IMAGE} -u 90
mount /dev/md90 mnt1

# Decompress mfsroot
gzip -dc < mnt1/mfsroot.gz > tmp/${IMAGE}-mfsroot

# Mount mfsroot
mdconfig -a -t vnode -f tmp/${IMAGE}-mfsroot -u 91
mount /dev/md91 mnt2

# cd to 2nd mount and exec SHELL
cd mnt2
${SHELL}

# SHELL has exited -- clean up and compress
for vtmp in `find . | grep '~$'`; do
	echo Removing: ${vtmp}
	rm -f ${vtmp}
done
cd ../

umount mnt2
mdconfig -d -u 91

gzip -c9 < tmp/${IMAGE}-mfsroot > mnt1/mfsroot.gz
rm -f tmp/${IMAGE}-mfsroot

umount mnt1
mdconfig -d -u 90

gzip -c9 < tmp/${IMAGE} > ${IMAGE}
rm -f tmp/${IMAGE}

