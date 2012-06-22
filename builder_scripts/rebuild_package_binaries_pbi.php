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

echo ">>> [" . date("H:i:s") . "] Forcing bootstrap of PBI tools...\n";
if(file_exists("/usr/local/sbin/pbi_create"))
	exec("rm /usr/local/sbin/pbi_create");

$DCPUS=trim(`sysctl -n kern.smp.cpus`);
$CPUS=$DCPUS * 2;

if(!file_exists("/usr/local/bin/svn"))
	die("Could not find subversion");

$preq_txt = <<<EOF
#!/bin/sh

# pbi installation for pfSense
cd /usr/ports/devel/xdg-utils && make install clean
cd /root
if [ -d current ]; then
	svn up
else
	svn co svn://svn.pcbsd.org/pcbsd/current
fi
cd current
cd src-sh
cd pbi-manager
./install.sh 2>/dev/null
EOF;

echo ">>> [" . date("H:i:s") . "] Checking out pfSense sources...\n";
if(file_exists("/usr/home/pfsense/tools/builder_scripts/checkout_pfsense_sources.sh"))
	exec("cd /usr/home/pfsense/tools/builder_scripts && /usr/home/pfsense/tools/builder_scripts/checkout_pfsense_sources.sh");

if(file_exists("/etc/inc/")) {
	require("/etc/inc/functions.inc");
	require("/etc/inc/util.inc");
	require("/etc/inc/xmlparse.inc");
	$handled = true;
}

if(file_exists("/usr/home/pfsense/pfSense/etc/inc") && !$handled) {
	require("/usr/home/pfsense/pfSense/etc/inc/functions.inc");
	require("/usr/home/pfsense/pfSense/etc/inc/util.inc");
	require("/usr/home/pfsense/pfSense/etc/inc/xmlparse.inc");
	$handled = true;
}

if(file_exists("/usr/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc") && !$handled) {
	require("/usr/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc/functions.inc");
	require("/usr/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc/util.inc");
	require("/usr/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc/xmlparse.inc");
	$handled = true;
}

function create_pbi_conf($port_path,$MAKEOPTS="",$portsbefore="",$portsafter="") {

	$PROGNAME=trim(`grep ^PORTNAME= /usr/ports/$port_path/Makefile | cut -d'=' -f2`);
	// $port_path Format should be, e.g. www/squid so we can grab the port name there if the makefile is empty.
	$PROGNAME = empty($PROGNAME) ? substr($port_path, strpos($port_path, '/')+1) : $PROGNAME;
	// If it's still empty, comment it out
	$usepn = empty($PROGNAME) ? "#" : "";

	$MAINTAINER=trim(`grep ^MAINTAINER= /usr/ports/$port_path/Makefile | cut -d'=' -f2`);
	// $PROGWEB=trim(`grep ^MASTER_SITES= /usr/ports/$port_path/Makefile | cut -d'=' -f2`);

	$MAKEOPTS = str_replace(" ", "\n", $MAKEOPTS);

	$portsbefore = empty($portsbefore) ? "" : "PBI_MKPORTBEFORE=\"$portsbefore\"";
	$portsafter  = empty($portsafter) ? "" : "PBI_MKPORTAFTER=\"$portsafter\"";

	$PBI_CONF = <<<EOF
# Format of this file changed, new example: http://wiki.pcbsd.org/index.php/PBI_Module_Builder_Guide
# Program Name
{$usepn}PBI_PROGNAME="$PROGNAME"

# Program Website
# PBI_PROGWEB="$PROGWEB"

# Program Author / Vendor
PBI_PROGAUTHOR="$MAINTAINER"

# The target port we are building
PBI_MAKEPORT="$port_path"

# Enter your custom make options here
# Options that will be put into the make.conf for the build of this port
# Options get inserted into the build's /etc/make.conf file and effect all the ports built for that PBI
PBI_MAKEOPTS="WITHOUT_X11=true
$MAKEOPTS"

# Ports to build before / after
{$portsbefore}
{$portsafter}

# Exclude List
PBI_EXCLUDELIST="./share/doc"

# Increment to trigger rebuild of PBI on build servers
PBI_BUILDKEY="01"

# This app needs to install as root
PBI_REQUIRESROOT="YES"

# Set the priority of this build
PBI_AB_PRIORITY="10"

# Set the files we want to exclude from the shared hashdir
# PBI_HASH_EXCLUDES="lib/firefox/firefox"

export PBI_PROGNAME PBI_PROGWEB PBI_PROGAUTHOR PBI_PROGICON PBI_MAKEPORT PBI_MAKEOPTS PBI_MKPORTBEFORE PBI_MKPORTAFTER PBI_BUILDKEY PBI_REQUIRESROOT PBI_EXCLUDELIST

# Format of this file changed, these don't seem to be used any longer. Still needed?
PBIAUTOPOPULATE="YES" ; export PBIAUTOPOPULATE
PBIAUTOPOPULATE_OTHERPORT="" ; export PBIAUTOPOPULATE_OTHERPORT
EOF;
	return($PBI_CONF);
}

function usage() {
	global $argv;
	echo "Usage: {$argv[0]} -x <path to pkg xml> [-p <package name>] [-d]\n";
	echo "  Flags:\n";
	echo "    -c csup hostname\n";
	echo "    -p Package name to build a single package and its dependencies.\n";
	echo "    -q quiet mode - surpresses command output\n";
	echo "    -r remove chroot contents on each builder run.\n";
	echo "    -s pfSense version to pass to set_version.sh during chroot build\n";
	echo "    -x XML file containing package data.\n";
	echo "    -P Skip applying kernel patches before build run.\n";
	echo "    -I Skip 'make includes' operation.\n";
	echo "    -u Upload after each port is built rather than at the end.\n";
	echo "    -U Skip uploading of packages.\n";
	echo "  Examples:\n";
	echo "     {$argv[0]} -x /usr/home/pfsense/packages/pkg_info.8.xml\n";
	echo "     {$argv[0]} -x /usr/home/pfsense/packages/pkg_info.8.xml -p squid\n";
	echo "     {$argv[0]} -x /usr/home/pfsense/packages/pkg_info.8.xml -ccvsup.livebsd.com\n";
	exit;
}

function overlay_pfPort($port_path) {
	$pfports = "/home/pfsense/tools/pfPorts";
	// If a pfport exists, overlay that folder onto $port_path
	$port_name = basename($port_path);
	if (file_exists("{$pfports}/{$port_name}") && is_dir("{$pfports}/{$port_name}")) {
		echo ">>> [" . date("H:i:s") . "] Overelaying pfPort {$port_name} onto {$port_path} ... ";
		if (file_exists($port_path) && is_dir($port_path)) {
			echo "Preserving old port in {$port_path}.orig ...";
			system("/bin/rm -rf {$port_path}.orig");
			system("/bin/mv {$port_path} {$port_path}.orig");
		}
		system("/bin/cp -R {$pfports}/{$port_name} {$port_path}");
		echo "Done.\n";
	}
}

function csup($csup_host, $supfile, $chrootchroot = "", $quiet_mode = "") {
	echo ">>> [" . date("H:i:s") . "] Update sources from file {$supfile}\n";
	if($chrootchroot)
		system("/usr/sbin/chroot {$chrootchroot} csup -L0 -h {$csup_host} {$supfile} {$quiet_mode}");
	else
		system("/usr/bin/csup -h {$csup_host} {$supfile} {$quiet_mode}");
}

function get_procs_count() {
	$processes = intval(trim(`ps awwwux | grep -v grep | grep pbi_makeport | wc -l`));
	return($processes);
}

function wait_for_procs_finish() {
	global $counter, $DCPUS;
	$processes = get_procs_count();
	if($counter == 0)
		echo ">>> [" . date("H:i:s") . "] Waiting for previous build processes to finish...";
	while($processes >= $DCPUS) {
		$processes = get_procs_count();
		$counter++;
		if($counter > 120) {
			$counter = 0;
			echo ".";
		}
		sleep(1);
	}
	echo "\n";
}

function copy_packages($copy_packages_to_host_ssh, $copy_packages_to_host_ssh_port, $file_system_root, $copy_packages_to_folder_ssh) {
	echo ">>> [" . date("H:i:s") . "] Copying packages to {$copy_packages_to_host_ssh}\n";
	system("/usr/local/bin/rsync -ave ssh --timeout=60 --rsh='ssh -p{$copy_packages_to_host_ssh_port}' {$file_system_root}/usr/ports/packages/All/* {$copy_packages_to_host_ssh}:{$copy_packages_to_folder_ssh}/");
}

$opts  = "x:";  // Path to XML file
$opts .= "p::"; // Package name to build (optional)
$opts .= "d::"; // DESTDIR for packages (optional)
$opts .= "j::"; // jail use (not currently implemented/needed)
$opts .= "l::"; // chroot location (not currently implemented/needed)
$opts .= "c::"; // csup hostname (not fully active)
$opts .= "r::"; // remove chroot before run (not currently implemented/needed)
$opts .= "q::"; // quiet mode
$opts .= "s::"; // pfSense version to pass to set_version.sh
$opts .= "P::"; // Skip applying kernel patches before the run
$opts .= "I::"; // Skip make includes
$opts .= "u::"; // Upload after every port, not just at the end.
$opts .= "U::"; // Skip uploading compiled binaries

$options = getopt($opts);

if(!isset($options['x']))
	usage();

// Bootstrap
if(!file_exists("/usr/local/sbin/pbi_create")) {
	file_put_contents("/tmp/preq.sh", $preq_txt);
	exec("chmod a+rx /tmp/preq.sh");
	echo ">>> [" . date("H:i:s") . "] Bootstrapping PBI...\n";
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
	echo ">>> [" . date("H:i:s") . "] Setting csup hostname to {$options['c']} \n";
	$csup_host = $options['c'];
} else {
	echo ">>> [" . date("H:i:s") . "] Setting csup hostname to cvsup.livebsd.com \n";
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
	echo ">>> [" . date("H:i:s") . "] Setting the following RSYNC/SSH parameters: \n";
	echo "    copy_packages_to_folder_ssh:    $copy_packages_to_folder_ssh\n";
	echo "    copy_packages_to_host_ssh:      $copy_packages_to_host_ssh\n";
	echo "    copy_packages_to_host_ssh_port: $copy_packages_to_host_ssh_port\n";
}

// Invoke csup and populate /usr/ports on host (non-chroot)
$file_system_root = "/";
exec("rm -rf /tmp/pf*");

if (!isset($options['P'])) {
	echo ">>> [" . date("H:i:s") . "] Applying kernel patches...\n";
	if($set_version)
		exec("cd /usr/home/pfsense/tools/builder_scripts && ./set_version.sh {$set_version}");
	exec("cd /usr/home/pfsense/tools/builder_scripts && ./apply_kernel_patches.sh");
}

if (!isset($options['I'])) {
	echo ">>> [" . date("H:i:s") . "] Running make includes...\n";
	exec("cd /usr/pfSensesrc/src && make includes");
}
echo ">>> [" . date("H:i:s") . "] pfSense package binary builder is starting.\n";

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
echo ">>> [" . date("H:i:s") . "] Creating port build list...\n";
$skipped=0;
$build_list = array();
foreach($pkg['packages']['package'] as $pkg) {
	if (isset($options['p']) && (strtolower($options['p']) != strtolower($pkg['name'])))
		continue;
	if ($pkg['build_pbi']) {
		if (empty($pkg['build_pbi']['port']))
			continue;
		if (array_key_exists($pkg['build_pbi']['port'], $build_list)) {
			echo ">>> [" . date("H:i:s") . "] Skipping {$build} - already in build list.\n";
			$skipped++;
			continue;
		}

		if (isset($pkg['build_pbi']['build_options']))
			$build_list[$build]['build_options'] = $pkg['build_pbi']['build_options'];
		elseif (isset($pkg['build_options']))
			$build_list[$build]['build_options'] = $pkg['build_options'];
		else
			$build_list[$build]['build_options'] = "";
		$build_list[$build]['ports_before']  = isset($pkg['build_pbi']['ports_before']) ? $pkg['build_pbi']['ports_before'] : "";
		$build_list[$build]['ports_after']   = isset($pkg['build_pbi']['ports_after']) ? $pkg['build_pbi']['ports_after'] :  "";
	} elseif ($pkg['build_port_path']) {
		foreach($pkg['build_port_path'] as $build) {
			if (!is_dir($build) && !is_dir("/home/pfsense/tools/pfPorts/" . basename($build))) {
				echo ">>> [" . date("H:i:s") . "] Skipping {$build} - port does not exist and no pfPort to use instead.\n";
				continue;
			}
			if (array_key_exists($build, $build_list)) {
				echo ">>> [" . date("H:i:s") . "] Skipping {$build} - already in build list.\n";
				$skipped++;
				continue;
			}
			$build_list[$build]['build_options'] = isset($pkg['build_options']) ? $pkg['build_options'] : "";
		}
	}
}
$total_to_build = count($build_list);
$skipped = ($skipped > 0) ? " (skipped {$skipped})" : "";
$plur = ($total_to_build == 1) ? "" : "s";
echo ">>> [" . date("H:i:s") . "] Found {$total_to_build} unique port{$plur} to build{$skipped}.\n";
$j = 0;
foreach ($build_list as $build => $pbi_options) {
	$processes = 0;
	$counter = 0;
	$j++;
	overlay_pfPort($build);
	$buildname = basename($build);
	if(isset($options['d'])) {
		$DESTDIR="DESTDIR=/usr/pkg/{$buildname}";
		echo ">>> [" . date("H:i:s") . "] Using $DESTDIR \n";
	} else
		$DESTDIR="";
/*
	if(file_exists("/var/db/ports/{$buildname}/options")) {
		echo ">>> Using /var/db/ports/{$buildname}/options \n";
		$portopts = split("\n", file_get_contents("/var/db/ports/{$buildname}/options"));
		foreach ($portopts as $po) {
			if (substr($po, 0, 1) != '#')
				$pbi_options['build_options'] .= " " . $po;
		}
	}
*/
	$start_time = time();
	echo ">>> [" . date("H:i:s") . "] Processing {$build} ({$j}/{$total_to_build})\n";
	$category = trim(`echo \"$build\" | cut -d'/' -f4`);
	$port = trim(`echo \"$build\" | cut -d'/' -f5 | cut -d'"' -f1`);
	//echo ">>> Category: $category/$port \n";
	if($pbi_options['build_options'])
		if(!isset($options['q']))
			echo ">>> [" . date("H:i:s") . "] BUILD_OPTIONS: {$pbi_options['build_options']}\n";
	$pbi_conf = create_pbi_conf("{$category}/{$port}",$pbi_options['build_options'],$pbi_options['ports_before'],$pbi_options['ports_after']);
	if(!is_dir("/pbi-build/modules/{$category}/{$port}"))
		exec("mkdir -p /pbi-build/modules/{$category}/{$port}");
	$pbi_confdir = "/pbi-build/modules/{$category}/{$port}";
	file_put_contents("{$pbi_confdir}/pbi.conf", $pbi_conf);
	echo ">>> [" . date("H:i:s") . "] Executing /usr/local/sbin/pbi_makeport -o /usr/ports/packages/All/ -c {$pbi_confdir} {$category}/{$port}\n";
	mwexec_bg("/usr/local/sbin/pbi_makeport -o /usr/ports/packages/All/ -c {$pbi_confdir} {$category}/{$port}");
	wait_for_procs_finish();
	echo ">>> [" . date("H:i:s") . "] Finished building {$build} - Elapsed time: " . gmdate("H:i:s", time() - $start_time);
	if($copy_packages_to_folder_ssh && isset($options['u']) && !isset($options['U'])) {
		copy_packages($copy_packages_to_host_ssh, $copy_packages_to_host_ssh_port, $file_system_root, $copy_packages_to_folder_ssh);
	}
}

echo ">>> {$file_system_root}/usr/ports/packages/All now contains:\n";
system("ls {$file_system_root}/usr/ports/packages/All");

// Copy created packages to the package server via rsync
if($copy_packages_to_folder_ssh && !isset($options['U'])) {
	copy_packages($copy_packages_to_host_ssh, $copy_packages_to_host_ssh_port, $file_system_root, $copy_packages_to_folder_ssh);
}

echo ">>> Package binary build run ended.\n";

?>