#!/bin/sh

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

set +e

PWD=`pwd`

cd $BASE_DIR
for FILE in `ls`; do
	if [ -d $FILE/.git ]; then
		# Make absolute sure we are on current repo.
		echo -n ">>> Updating GIT REPO $FILE..."
		cd $FILE
		(git fetch) 2>&1 | egrep -B3 -A3 -wi '(error)'
		(git reset --hard) 2>&1 | egrep -B3 -A3 -wi '(error)'
		(git rebase origin) 2>&1 | egrep -B3 -A3 -wi '(error)'
		(git reset --hard) 2>&1 | egrep -B3 -A3 -wi '(error)'
		(git rebase origin) 2>&1 | egrep -B3 -A3 -wi '(error)'
		cd $BASE_DIR
		echo "Done!"
	fi
done

cd $PWD

set -e

