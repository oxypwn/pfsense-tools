#!/bin/sh

# Suck in local vars
if [ -f ./pfsense_local.sh ]; then
	. ./pfsense_local.sh
elif [ -f ../pfsense_local.sh]; then
	. ../pfsense_local.sh
else
	echo "You are calling this script from wrong location"
	exit 1
fi

# Suck in script helper functions
if [ -f ./builder_common.sh ]; then
        . ./builder_common.sh
elif [ -f ../builder_common.sh]; then
        . ../builder_common.sh
else
        echo "You are calling this script from wrong location"
        exit 1
fi

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

if [ ! -z "${REVERT_PFSENSE_COMMITS:-}" ]; then
	for revert in $REVERT_PFSENSE_COMMITS; do
		echo ">>> Reverting PFSENSE commit $revert"
		(cd $CVS_CO_DIR && git revert $revert --no-edit) 2>&1 | grep Revert
	done
fi

if [ ! -z "${REVERT_TOOLS_COMMITS:-}" ]; then
	for revert in $REVERT_TOOLS_COMMITS; do
		echo ">>> Reverting tools commit $revert"
		(cd $TOOLS_DIR && git revert $revert --no-edit) 2>&1 | grep Revert
	done
fi

cd $PWD

set -e

