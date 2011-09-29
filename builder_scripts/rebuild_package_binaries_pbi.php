#!/usr/local/bin/php -q
<?php
/* 
 *  rebuild_package_binaries.sh
 *  Copyright (C) 2010, 2011 Scott Ullrich <sullrich@gmail.com>
 *  Copyright (C) 2010, 2011 Jim Pingle <jim@pingle.org>
 *  All rights reserved.
 *  
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *  
 *  1. Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *  
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  
 *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 *  AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *  AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 *  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
 */


$DCPUS=`sysctl kern.smp.cpus | cut -d' ' -f2`;
$CPUS=`expr $DCPUS '*' 2`;

if(!file_exists("/usr/local/bin/svn")) 
	die("Could not find subversion");

$preq_txt = <<<EOF
#!/bin/sh

# pbi installation for pfSense
cd /usr/ports/devel/xdg-utils && make install clean
cd /root
svn co svn://svn.pcbsd.org/pcbsd/current
cd current
cd src-sh
cd pbi-manager
./install.sh
EOF;

echo ">>> Checking out pfSense sources...\n";
if(file_exists("/home/pfsense/tools/builder_scripts/checkout_pfsense_sources.sh")) 
	exec("cd /home/pfsense/tools/builder_scripts && /home/pfsense/tools/builder_scripts/checkout_pfsense_sources.sh");

if(file_exists("/etc/inc/")) {
	require("/etc/inc/functions.inc");
	require("/etc/inc/util.inc");
	require("/etc/inc/xmlparse.inc");
	$handled = true;
}

if(file_exists("/home/pfsense/pfSense/etc/inc") && !$handled) {
	require("/home/pfsense/pfSense/etc/inc/functions.inc");
	require("/home/pfsense/pfSense/etc/inc/util.inc");
	require("/home/pfsense/pfSense/etc/inc/xmlparse.inc");
	$handled = true;
}

if(file_exists("/usr/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc") && !$handled) {
	require("/usr/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc/functions.inc");
	require("/usr/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc/util.inc");
	require("/usr/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc/xmlparse.inc");
	$handled = true;
}

function create_pbi_conf($port_path,$MAKEOPTS="") {
	
	$PROGNAME=trim(`cat $port_path/Makefile | grep PORTNAME | cut -d'=' -f2'`);
	$MAINTAINER=trim(`cat $port_path/Makefile | grep MAINTAINER | cut -d'=' -f2'`);
	$PROGWEB=trim(`cat $port_path/Makefile | grep MASTER_SITES | cut -d'=' -f2'`);
	
	$PBI_CONF = <<<EOF
# Program Name
# The name of the PBI file being built
PROGNAME="$PROGNAME"
 
# Program Website
# Website of the program the module is building
PROGWEB="$PROGWEB"
 
# Program Author
# Who created / maintains the program being built
PROGAUTHOR="$MAINTAINER"
 
# Default Icon
# Relative to overlay-dir, the main icon you want to show up for this PBI
PROGICON="share/pixmaps/FireFox-128.png"
 
# Port we want to build
# The port the server will track to determine when it's time for a rebuild
PBIPORT="$port_path"
 
# Set to "Auto or NONE" to have the PBI creator auto-populate libs or not
# This allows you to also use the autolibs/ directory in your overlay-dir as a location for extra
# library files
PROGLIBS="Auto"
 
# PBI Update URL set to "" or the http:// URL of update checker
# Leave this as update.pbidir.com normally
PBIUPDATE="http://files.pfsense.org"
 
# Other Ports we need built
# One per line, any additional ports that need to be built for this PBI
OTHERPORT=""
 
# Enter your custom make options here
# Options that will be put into the make.conf for the build of this port
# Options get inserted into the build's /etc/make.conf file and effect all the ports built for that PBI
MAKEOPTS="$MAKEOPTS"
 
# FBSD7BASE - (7.1 or 7.2)
# This variable can be used to set the specific version of FreeBSD this port needs to be compiled
# under. Use this is a port is known to not build / work when compiled on FreeBSD 7.0 (the default)
FBSD7BASE="7.2"; export FBSD7BASE
 
# This option determines if the pbi-builder will auto-copy files from the target port
# Can be set to YES/NO/FULL
# YES - Copy only target port files automatically
# No - Don't copy any target port files (will need to use copy-files config instead)
# FULL - Copy target port files, and recursive dependency files as well (Makes very large PBI)
PBIAUTOPOPULATE="YES" ; export PBIAUTOPOPULATE
 
# Can be set to OFF/NO to disable copying all files from ports made with the OTHERPORT variable
# Leaving this unset will have the builder auto-copy all files from OTHERPORT targets
PBIAUTOPOPULATE_OTHERPORT="" ; export PBIAUTOPOPULATE_OTHERPORT
 
# Set this variable to any target ports you want to autopopulate files from, in addition to
# the main target port
# List additional ports one-per-line
PBIAUTOPOPULATE_PORTS="/usr/ports/www/mplayer-plugin/" ; export PBIAUTOPOPULATE_PORTS
 
# By default the PBI will remove any xorg-fonts, and create a symlink to the the users system fonts
# Setting this to YES keeps the PBIs internal fonts and doesn't create a link
# PBIDISABLEFONTLINK="" ; export PBIDISABLEFONTLINK
 
# By default the libGL* libraries will be removed from a PBI in order to use the systems libGL
# Set this to YES to keep the PBIs libGL* libraries, and not use the system's
# PBIKEEPGL="" ; export PBIKEEPGL
 
# By default we prune any include/ files used for building,
# Set this to NO to keep any include/ directories in the resulting PBI
# PBIPRUNEINCLUDE="" ; export PBIPRUNEINCLUDE
 
# By default we prune the python files used for building,
# Set this to NO to keep any python files in the resulting PBI
# PBIPRUNEPYTHON="" ; export PBIPRUNEPYTHON
 
# By default we prune any perl files used for building,
# Set this to NO to keep any perl files in the resulting PBI
# PBIPRUNEPERL="" ; export PBIPRUNEPERL
 
# By default we prune any doc files (such as man, info, share/doc)
# Set this to NO to keep any doc files in the resulting PBI
# PBIPRUNEDOC="" ; export PBIPRUNEDOC
 
# Build Key - Change this to anything else to trigger a rebuild
#           - The rebuild will take place even if port is still the same ver
BUILDKEY="01"
	
EOF;
	return($PBI_CONF);
}

function usage() {
	global $argv;
	echo "Usage: {$argv[0]} -x <path to pkg xml> [-p <package name>] [-d]\n";
	echo "  Flags:\n";
	echo "    -c csup hostname\n";
	echo "    -d Use DESTDIR when building.\n";
	echo "    -p Package name to build a single package and its dependencies.\n";
	echo "    -q quiet mode - surpresses command output\n";
	echo "    -r remove chroot contents on each builder run.\n";
	echo "    -s pfSense version to pass to set_version.sh during chroot build\n";
	echo "    -x XML file containing package data.\n";
	echo "  Examples:\n";
	echo "     {$argv[0]} -x /home/pfsense/packages/pkg_info.8.xml\n";
	echo "     {$argv[0]} -x /home/pfsense/packages/pkg_info.8.xml -p squid\n";
	echo "     {$argv[0]} -x /home/pfsense/packages/pkg_info.8.xml -j -l/usr/local/pkgchroot -ccvsup.livebsd.com\n";
	exit;
}

function csup($csup_host, $supfile, $chrootchroot = "", $quiet_mode = "") {
	echo ">>> Update sources from file {$supfile}\n";
	if($chrootchroot) 
		system("/usr/sbin/chroot {$chrootchroot} csup -L0 -h {$csup_host} {$supfile} {$quiet_mode}");
	else
		system("/usr/bin/csup -h {$csup_host} {$supfile} {$quiet_mode}");
}

$options = getopt("x:p::d::j::l::c::r::q::s::");

if(!isset($options['x']))
	usage();

// Bootstrap
if(!file_exists("/usr/local/sbin/pbi_create")) {
	file_put_contents("/tmp/preq.sh", $preq_txt);
	exec("chmod a+rx /tmp/preq.sh");
	echo ">>> Bootstrapping PBI...\n";
	exec("/tmp/preq.sh");
}

// Set the XML filename that we are processing
$xml_filename = $options['x'];

$pkg = parse_xml_config_pkg($xml_filename, "pfsensepkgs");
if(!$pkg) {
	echo "!!! An error occurred while trying to process {$xml_filename}.  Exiting.\n";
	exit;
}

// Set csup hostname
if($options['c'] <> "") {
	echo ">>> Setting csup hostname to {$options['c']} \n";
	$csup_host = $options['c'];
} else {
	echo ">>> Setting csup hostname to cvsup.livebsd.com \n";
	$csup_host = "cvsup.livebsd.com";
}

if(isset($options['q'])) 
	$quiet_mode = "</dev/null 2>&1";

if($options['s'] <> "") 
	$set_version = $options['s'];

// Set and ouput initial flags
if($pkg['copy_packages_to_host_ssh_port'] && 
	$pkg['copy_packages_to_host_ssh'] &&
	$pkg['copy_packages_to_folder_ssh']) {
	$copy_packages_to_folder_ssh = $pkg['copy_packages_to_folder_ssh'];
	$copy_packages_to_host_ssh = $pkg['copy_packages_to_host_ssh'];
	$copy_packages_to_host_ssh_port = $pkg['copy_packages_to_host_ssh_port'];
	echo ">>> Setting the following RSYNC/SSH parameters: \n";
	echo "    copy_packages_to_folder_ssh:    $copy_packages_to_folder_ssh\n";
	echo "    copy_packages_to_host_ssh:      $copy_packages_to_host_ssh\n";
	echo "    copy_packages_to_host_ssh_port: $copy_packages_to_host_ssh_port\n";
}

// Invoke csup and populate /usr/ports on host (non-chroot)
$file_system_root = "/";
exec("rm -rf /tmp/pf*");
echo ">>> Applying kernel patches...\n";
if($set_version)
	exec("cd /home/pfsense/tools/builder_scripts && ./set_version.sh {$set_version}");
exec("cd /home/pfsense/tools/builder_scripts && ./apply_kernel_patches.sh");
echo ">>> Running make includes...\n";
exec("cd /usr/pfSensesrc/src && make includes");

echo ">>> pfSense package binary builder is starting.\n";

// Safety check - should no fail since we sync ports above with csup
if(!is_dir("{$file_system_root}/usr/ports")) {
	echo "!!! {$file_system_root}/usr/ports/ not found.   Please run portsnap fetch extract\n";
	exit;
}

// Ensure that the All directory exists in packages staging area
if(!is_dir("{$file_system_root}/usr/ports/packages/All")) 
	system("mkdir -p {$file_system_root}/usr/ports/packages/All");

// Loop through all packages and build pacakge with 
// build_options if the port/package has this defined.
foreach($pkg['packages']['package'] as $pkg) {
	if (isset($options['p']) && ($options['p'] != $pkg['name']))
		continue;
	$processes = 0;
	$counter = 0;
	if($pkg['build_port_path']) {
		foreach($pkg['build_port_path'] as $build) {
			$buildname = basename($build);
			if(isset($options['d'])) {
				$DESTDIR="DESTDIR=/usr/pkg/{$buildname}";
				echo ">>> Using $DESTDIR \n";
			} else 	
				$DESTDIR="";
			$build_options="";
			if($pkg['build_options']) 
				$build_options = $pkg['build_options'];
			if(file_exists("/var/db/ports/{$buildname}/options")) {
				echo ">>> Using /var/db/ports/{$buildname}/options \n";
				$portopts = split("\n", file_get_contents("/var/db/ports/{$buildname}/options"));
				foreach ($portopts as $po) {
					if (substr($po, 0, 1) != '#')
						$build_options .= " " . $po;
				}
			}
			echo ">>> Processing {$build}\n";
			$category = trim(`echo \"$build\" | cut -d'/' -f4`);
			$port = trim(`echo \"$build\" | cut -d'/' -f5 | cut -d'"' -f1`);
			echo ">>> Category: $category/$port \n";
			if($build_options) 
				if(!isset($options['q'])) 
					echo " BUILD_OPTIONS: {$build_options}\n";
			$pbi_conf = create_pbi_conf($build,$build_options);
			if(!is_dir("/pbi-build/modules/{$category}/{$port}"))
				exec("mkdir -p /pbi-build/modules/{$category}/{$port}");
			file_put_contents("/pbi-build/modules/{$category}/{$port}/pbi.conf", $pbi_conf);
			$processes = intval(trim(`ps awwwux | grep -v grep | grep pbi_makeport | wc -l`));
			while($processes >= $DCPUS) {
				echo ">>> Waiting for previous build processes to finish...";
				$processes = intval(trim(`ps awwwux | grep -v grep | grep pbi_makeport | wc -l`));
				sleep(1);
				$counter++;
				if($counter > 60) {
					$counter = 0;
					echo ".";
				}
			}
			echo ">>> Executing /usr/local/sbin/pbi_makeport -o /usr/ports/packages/All/ {$category}/{$port}\n";
			mwexec_bg("/usr/local/sbin/pbi_makeport -o /usr/ports/packages/All/ {$category}/{$port}");
		}
	}
}

$processes = intval(trim(`ps awwwux | grep -v grep | grep pbi_makeport | wc -l`));
while($processes >= $DCPUS) {
	$processes = intval(trim(`ps awwwux | grep -v grep | grep pbi_makeport | wc -l`));
	sleep(1);
	$counter++;
	if($counter > 60) {
		$counter = 0;
		echo ".";
	}
	
}

echo ">>> {$file_system_root}/usr/ports/packages/All now contains:\n";
system("ls {$file_system_root}/usr/ports/packages/All");

// Copy created packages to the package server via rsync
if($copy_packages_to_folder_ssh) {
	echo ">>> Copying packages to {$copy_packages_to_host_ssh}\n";
	system("/usr/local/bin/rsync -ave ssh --timeout=60 --rsh='ssh -p{$copy_packages_to_host_ssh_port}' {$file_system_root}/usr/ports/packages/All/* {$copy_packages_to_host_ssh}:{$copy_packages_to_folder_ssh}/");
}

echo ">>> Package binary build run ended.\n";

?>