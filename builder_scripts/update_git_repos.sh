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
		(/usr/local/bin/git fetch) 2>&1 | egrep -B3 -A3 -wi '(error)'
		(/usr/local/bin/git reset --hard) 2>&1 | egrep -B3 -A3 -wi '(error)'
		(/usr/local/bin/git rebase origin) 2>&1 | egrep -B3 -A3 -wi '(error)'
		(/usr/local/bin/git reset --hard) 2>&1 | egrep -B3 -A3 -wi '(error)'
		(/usr/local/bin/git rebase origin) 2>&1 | egrep -B3 -A3 -wi '(error)'
		cd $BASE_DIR
		echo "Done!"
	fi
done

if [ ! -z "${REVERT_TOOLS_COMMITS:-}" ]; then
	for revert in $REVERT_TOOLS_COMMITS; do
		echo ">>> Reverting tools commit $revert"
		(cd $TOOLS_DIR && git revert $revert --no-edit)
	done
fi

cd $PWD

set -e

