CONVERSIONDIR=/home/${USER}/conversion
CVSMODULE=pfSense
CVSSRC=cvs.pfsense.org:/cvsroot/
CVSDST=${CONVERSIONDIR}/cvsroot/
PROJECT=pfsense-import-test-minus-binaries
PROJNAME="pfSense import test minus binaries"
HEADPROJECT=pfsense-deprecated-HEAD
HEADPROJNAME="pfSense deprecated HEAD"
GITDST=git@rcs.pfsense.org:${PROJECT}/mainline.git
GITHEADDST=git@rcs.pfsense.org:${HEADPROJECT}/mainline.git

# sync over the repo
sync_from_cvs() {
	rsync -avz --delete ${CVSSRC} ${CVSDST}
}

# Remove cruft that's been deleted
purge_repo() {
	find ${CONVERSIONDIR}/cvsroot/${CVSMODULE} -name "Attic" -type d -exec rm -rf {} \;
}

cvs_to_git() {
	git cvsimport -k -i -a -d ${CONVERSIONDIR}/cvsroot -C ${CVSMODULE}-git -A ${CONVERSIONDIR}/author-conf-file ${CVSMODULE}
}

update_pfSense_gitorious() {
	cd ${CONVERSIONDIR}/pfSense-git
	git push --mirror origin
}

init_pfSense_gitorious() {
        cd /usr/local/www/gitorious
        RAILS_ENV="production" rake pfsense:recreate_project projname="${PROJNAME}" projslug=${PROJECT}
        RAILS_ENV="production" rake pfsense:recreate_project projname="${HEADPROJNAME}" projslug=${HEAD-PROJECT}
	RAILS_ENV="production" rake pfsense:add_committers projslug=${PROJECT}

	cd ${CONVERSIONDIR}/pfSense-git
	# This shouldn't be pushed, we'll just delete it
	# It's Ermal's old dev branch
	git branch -D RELENG_1_2_RELEASE_BRANCH
	# There are a few deletable branches that we should rm here
	git branch -D RELENG_1_MULTI_ANYTHING
	git branch -D avendor
	git branch -D Package-Reorg-2005
	# Swap branches around
	# Preserve HEAD
	git push ${GITHEADDST} master
	git branch -M master oldHEAD
	git branch -M RELENG_1 master
	# Remove stale tags
	git tag -d arelease
	git tag -d PFSENSE_0_80
	git tag -d RELENG_1_2_1_RC2
	git tag -d RELENG_1_2_BETA_2
	git tag -d RELENG_1_2_RC1
	#
	# Any other config changes needed before pushing?
	# What about that utf thingy?
	# You may want to amend it after fixing the message, or set the config
	# variable i18n.commitencoding to the encoding your project uses.
	# 
	# Repack repo and purge unreferenced stuff removed when we deleted branches
	git repack -Ad
	git prune
	# Garbage collect out all the crap we're purging before we push the repo
	git gc --aggressive 
	#
	# And perform a repo check
	git fsck --unreachable HEAD \
		$(git for-each-ref --format="%(objectname)" refs/heads)
	#
	# Push the two branches we care about
	git push ${GITDST} master
	git push ${GITDST} RELENG_1_2
	# Push our tags
	git push --tags${GITDST}
}
