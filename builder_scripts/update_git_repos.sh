#!/bin/sh

# Suck in local vars
. ./pfsense_local.sh

# Suck in script helper functions
. ./builder_common.sh

PWD=`pwd`

cd $BASE_DIR
for FILE in `ls`; do
	if [ -d $FILE/.git ]; then
		# Make absolute sure we are on current repo.
		echo ">>> Updating GIT REPO $FILE"
		cd $FILE
		git fetch
		git rebase origin
		git reset --hard
		git rebase origin 
		git reset --hard
		cd $BASE_DIR
	fi
done

cd $PWD
