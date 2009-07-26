#!/bin/sh
DIALOG=${DIALOG=/usr/bin/dialog}

if [ -f ./pfsense-build.conf ]; then
	. ./pfsense-build.conf
fi

get_text() {
	$DIALOG --title "INPUT BOX" --clear \
	        --inputbox "$1" -1 -1 "" \
			2> /tmp/inputbox.tmp.$$
	retval=$?
	input=`cat /tmp/inputbox.tmp.$$`
	get_text_value=`cat /tmp/inputbox.tmp.$$`
	rm -f /tmp/inputbox.tmp.$$
}

get_pfsense_version() {
	$DIALOG --title "pfSense version" --clear \
	        --radiolist "Please select which version you would like to build:\n" -1 -1 3 \
	        "RELENG_1_2"	"Release branch" ON \
	        "RELENG_2_0"	"Development branch RELENG_2_0" OFF \
	        "Custom"		"Enter a custom version" OFF \
			2> /tmp/radiolist.tmp.$$
	retval=$?
	get_pfsense_version_value=`cat /tmp/radiolist.tmp.$$`
	rm -f /tmp/radiolist.tmp.$$
}

if [ "$PFSENSETAG" != "" ]; then 
	TXT=" pfSense TAG: $PFSENSETAG\n"
fi
if [ "$FREEBSD_BRANCH" != "" ]; then 
	TXT="${TXT} FreeBSD Branch: $FREEBSD_BRANCH\n"
fi
if [ "$OVERRIDE_FREEBSD_CVSUP_HOST" != "" ]; then 
	TXT="${TXT} CVSUP Server: $OVERRIDE_FREEBSD_CVSUP_HOST\n"
fi
TXT="${TXT}\n"

while [ /bin/true ]; do
	$DIALOG --clear --title "pfSense builder system" \
		--hline "Press 1-9, Up/Down, first letter or Enter" \
		--menu "Welcome to the pfSense builder system.\n\n\
$TXT\n \
Choose the option you would like:" -1 -1 9 \
			"Exit"				"Exit the pfSense builder system" \
			"Clean"				"Cleanup previous builds" \
			"Sync GIT"			"Synchronize various checked out GIT trees with rcs.pfSense.org" \
	        "Build ISO"			"Build a regular ISO" \
	        "Build DevISO"		"Build a Developers ISO" \
	        "Build NanoBSD"		"Build NanoBSD" \
	        "Build embedded"	"Build old style embedded image" \
			"Set version"		"Set pfSense version information etc" \
			2> /tmp/menu.tmp.$$
	retval=$?
	choice=`cat /tmp/menu.tmp.$$`
	rm -f /tmp/menu.tmp.$$
	case $choice in
		"Exit") 
		exit 0
		;;
		"Clean")
		./clean_build.sh 
		;;
		"Sync GIT")
		./update_git_repos.sh
		;;
		"Build pfPorts")
		./build_pfPorts.sh
		;;
		"Build ISO")
		./build_iso.sh
		;;
		"Build DevISO")
		./build_deviso.sh
		;;
		"Build NanoBSD")
		./build_nano.sh
		;;
		"Build embedded")
		./build_embedded.sh
		;;
		"Set version")
		get_pfsense_version
		PFSENSE_VERSION=$get_pfsense_version_value
		if [ "$PFSENSE_VERSION" = "Custom" ]; then
			get_text "Enter the pfSense version you would like to use"
			PFSENSE_VERSION=$get_text_value
		fi
		get_text "Enter the cvsup server address or hit enter to use the fastest found"
		CVSUP_SOURCE=$get_text_value
		get_text "Enter the E-mail address to send a message to upon operation finish"
		EMAIL_ADDRESS_WHEN_FINISHED=$get_text_value
		get_text "Enter the E-mail address to send a message to upon operation error"
		EMAIL_ADDRESS_WHEN_ERROR=$get_text_value
		get_text "Enter the twitter username to update upon snapshot posting"
		TWITTER_SNAPSHOTS_USERNAME=$get_text_value
		if [ ! "$TWITTER_SNAPSHOTS_USERNAME" = "" ]; then
			get_text "Enter the twitter password to update upon snapshot posting"
			TWITTER_SNAPSHOTS_PASSWORD=$get_text_value
		fi
		./set_version.sh $PFSENSE_VERSION \
$CVSUP_SOURCE \
$EMAIL_ADDRESS_WHEN_FINISHED \
$EMAIL_ADDRESS_WHEN_ERROR \
$TWITTER_SNAPSHOTS_USERNAME \
$TWITTER_SNAPSHOTS_PASSWORD
		;;
		*)
	    [ -z "$choice" ] || echo $choice ;
			exit;
		;;
	esac
	echo
	read -p "Press enter to continue..." opmode
done