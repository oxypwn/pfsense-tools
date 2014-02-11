#!/usr/local/bin/php-cli -q
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

/* TODO:
	* Add prefetch_distfiles so we can grab source from wherever we want before building, in case ports can't get it
	* Add support for multiple manual port builds instead of either a full run or a single port
	* Add pbi_autobuild support
	* Add support for more PBI variables such as the build key, exclude list, and so on.
*/

echo "PBI Build run started at " . date(DATE_RFC822) . "\n";
$full_start_time = time();

echo ">>> [" . date("H:i:s") . "] Forcing bootstrap of PBI tools...\n";
if(file_exists("/usr/local/sbin/pbi_create"))
	exec("rm /usr/local/sbin/pbi_create");

$DCPUS=trim(`sysctl -n kern.smp.cpus`);
$CPUS=$DCPUS * 2;

$preq_txt = <<<EOF
#!/bin/sh

# pbi installation for pfSense
cd /usr/ports/devel/xdg-utils && make install clean
PBI_SRC_DIR=/home/pfsense/pcbsd
if [ -d \${PBI_SRC_DIR} ]; then
	cd \${PBI_SRC_DIR}
	(/usr/local/bin/git fetch) 2>&1 | egrep -B3 -A3 -wi '(error)'
	(/usr/local/bin/git reset --hard) 2>&1 | egrep -B3 -A3 -wi '(error)'
	(/usr/local/bin/git rebase origin) 2>&1 | egrep -B3 -A3 -wi '(error)'
	(/usr/local/bin/git reset --hard) 2>&1 | egrep -B3 -A3 -wi '(error)'
	(/usr/local/bin/git rebase origin) 2>&1 | egrep -B3 -A3 -wi '(error)'
else
	cd `/usr/bin/dirname \${PBI_SRC_DIR}`
	/usr/local/bin/git clone https://github.com/pcbsd/pcbsd.git \${PBI_SRC_DIR}
fi
cd \${PBI_SRC_DIR}/src-sh/libsh
make install 2>/dev/null
cd \${PBI_SRC_DIR}/src-sh/pbi-manager
./install.sh 2>/dev/null
EOF;

echo ">>> [" . date("H:i:s") . "] Checking out pfSense sources...\n";
if(file_exists("/home/pfsense/tools/builder_scripts/checkout_pfsense_sources.sh"))
	exec("cd /home/pfsense/tools/builder_scripts && /home/pfsense/tools/builder_scripts/checkout_pfsense_sources.sh");

if(file_exists("/etc/inc/")) {
	require_once("/etc/inc/functions.inc");
	require_once("/etc/inc/util.inc");
	require_once("/etc/inc/xmlparse.inc");
	$handled = true;
}

if(file_exists("/home/pfsense/pfSense/etc/inc") && !$handled) {
	require_once("/home/pfsense/pfSense/etc/inc/functions.inc");
	require_once("/home/pfsense/pfSense/etc/inc/util.inc");
	require_once("/home/pfsense/pfSense/etc/inc/xmlparse.inc");
	$handled = true;
}

if(file_exists("/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc") && !$handled) {
	require_once("/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc/functions.inc");
	require_once("/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc/util.inc");
	require_once("/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc/xmlparse.inc");
	$handled = true;
}

function create_pbi_conf($port_path,$custom_name="",$MAKEOPTS="",$portsbefore="",$portsafter="") {

	if (!empty($custom_name)) {
		$PROGNAME = $custom_name;
	} else {
		$PROGNAME=trim(`grep ^PORTNAME= /usr/ports/$port_path/Makefile | cut -d'=' -f2`);
		// $port_path Format should be, e.g. www/squid so we can grab the port name there if the makefile is empty.
		$PROGNAME = empty($PROGNAME) ? substr($port_path, strpos($port_path, '/')+1) : $PROGNAME;
		// If it's still empty, comment it out
		$usepn = empty($PROGNAME) ? "#" : "";
	}

	$MAINTAINER=trim(`grep ^MAINTAINER= /usr/ports/$port_path/Makefile | cut -d'=' -f2`);
	// $PROGWEB=trim(`grep ^MASTER_SITES= /usr/ports/$port_path/Makefile | cut -d'=' -f2`);

	$MAKEOPTS = str_replace(";", "\n", $MAKEOPTS);

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
PBI_MAKEOPTS="OPTIONS_UNSET_FORCE=X11 DOCS EXAMPLES MAN INFO
$MAKEOPTS"

# Ports to build before / after
{$portsbefore}
{$portsafter}

# Exclude List
PBI_EXCLUDELIST="./share/doc ./man ./*/man ./*/*/man ./*/*/*/man ./*/*/*/*/man"

# Increment to trigger rebuild of PBI on build servers
PBI_BUILDKEY="01"

# This app needs to install as root
PBI_REQUIRESROOT="YES"

# Set the priority of this build
PBI_AB_PRIORITY="10"

# Set the files we want to exclude from the shared hashdir
# PBI_HASH_EXCLUDES="lib/firefox/firefox"

# Do not use system fonts
PBI_USESYSFONTS="NO"

# Keep the world around after building in case we need to check on it
PBI_DELETE_BUILD=0

export PBI_PROGNAME PBI_PROGWEB PBI_PROGAUTHOR PBI_PROGICON PBI_MAKEPORT PBI_MAKEOPTS PBI_MKPORTBEFORE PBI_MKPORTAFTER PBI_BUILDKEY PBI_REQUIRESROOT PBI_EXCLUDELIST PBI_USESYSFONTS PBI_DELETE_BUILD

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
	echo "    -v Show PBI build output.\n";
	echo "    -S Sign PBI using this key.\n";
	echo "    -a Choose arch (amd64|i386|all).\n";
	echo "  Examples:\n";
	echo "     {$argv[0]} -x /home/pfsense/packages/pkg_info.8.xml\n";
	echo "     {$argv[0]} -x /home/pfsense/packages/pkg_info.8.xml -p squid\n";
	echo "     {$argv[0]} -x /home/pfsense/packages/pkg_info.8.xml -ccvsup.livebsd.com\n";
	exit;
}

function overlay_pfPort($port_path) {
	if (empty($port_path))
		return;
	$pfports = "/home/pfsense/tools/pfPorts";
	// If a pfport exists, overlay that folder onto $port_path
	$port_name = basename($port_path);
	$port_path = "/usr/ports/" . $port_path;
	if (file_exists("{$pfports}/{$port_name}") && is_dir("{$pfports}/{$port_name}") && is_file("{$pfports}/{$port_name}/Makefile")) {
		echo ">>> [" . date("H:i:s") . "] Overelaying pfPort {$port_name} onto {$port_path} ... ";
		if (file_exists($port_path) && is_dir($port_path)) {
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
	global $counter;
	$processes = get_procs_count();
	if($counter == 0)
		echo ">>> [" . date("H:i:s") . "] Waiting for previous build processes to finish...";
	while($processes >= 1) {
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
	system("/usr/local/bin/rsync -ave ssh --timeout=60 --rsh='ssh -p{$copy_packages_to_host_ssh_port}' {$file_system_root}/usr/ports/packages/All/*.pbi {$copy_packages_to_host_ssh}:{$copy_packages_to_folder_ssh}/");
}

function format_elapsed_time($seconds) {
	$days = (int)($seconds / 86400);
	$seconds %= 86400;
	$hours = (int)($seconds / 3600);
	$seconds %= 3600;
	$mins = (int)($seconds / 60);
	$seconds %= 60;
	$secs = (int)($seconds);

	$timestr = "";
	if ($days > 1)
		$timestr .= "{$days} Days ";
	else if ($days > 0)
		$timestr .= "1 Day ";

	$hourspl = ($hours != 1) ? "s" : "";
	$minspl = ($mins != 1) ? "s" : "";
	$secspl = ($mins != 1) ? "s" : "";

	$timestr .= "{$days}{$hours} Hour{$hourspl} {$mins} Minute$minspl {$secs} Second{$secspl}";
	return $timestr;
}

$opts  = "x:"; // Path to XML file
$opts .= "p:"; // Package name to build (optional)
$opts .= "d:"; // DESTDIR for packages (optional)
$opts .= "j:"; // jail use (not currently implemented/needed)
$opts .= "l:"; // chroot location (not currently implemented/needed)
$opts .= "c:"; // csup hostname (not fully active)
$opts .= "r";  // remove chroot before run (not currently implemented/needed)
$opts .= "q";  // quiet mode
$opts .= "s:"; // pfSense version to pass to set_version.sh
$opts .= "P";  // Skip applying kernel patches before the run
$opts .= "I";  // Skip make includes
$opts .= "u";  // Upload after every port, not just at the end.
$opts .= "U";  // Skip uploading compiled binaries
$opts .= "v";  // Verbose, show PBI build output
$opts .= "S:"; // Key used to sign PBIs
$opts .= "a:"; // Arch

$options = getopt($opts);

if(!isset($options['x']))
	usage();

$host_arch = php_uname("m");
if (empty($options['a'])) {
	if ($host_arch == "amd64")
		$options['a'] = 'all';
	else
		$options['a'] = 'i386';
}

if ($host_arch == "i386" && $options['a'] == "amd64") {
	echo "!!! You cannot build an amd64 binary on i386 host.  Exiting.\n";
	exit;
}

if(!empty($options['S']) && !file_exists($options['S'])) {
	echo "!!! Sign key file does not exist";
	exit;
}

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
		exec("cd /home/pfsense/tools/builder_scripts && ./set_version.sh {$set_version}");
	exec("cd /home/pfsense/tools/builder_scripts && ./apply_kernel_patches.sh");
}

if (!isset($options['I'])) {
	echo ">>> [" . date("H:i:s") . "] Running make includes...\n";
	$freebsd_version = explode(".", php_uname("r"));
	exec("cd /usr/pfSensesrc/src && env __MAKE_CONF=/home/pfsense/tools/builders_scripts/conf/src/src.conf.{$freebsd_version[0]} make includes");
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
		$build = $pkg['build_pbi']['port'];
		if (array_key_exists($build, $build_list)) {
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

		$build_list[$build]['custom_name']    = isset($pkg['build_pbi']['custom_name']) ? $pkg['build_pbi']['custom_name'] : "";
		$build_list[$build]['ports_before']   = isset($pkg['build_pbi']['ports_before']) ? $pkg['build_pbi']['ports_before'] : "";
		$build_list[$build]['ports_after']    = isset($pkg['build_pbi']['ports_after']) ? $pkg['build_pbi']['ports_after'] :  "";
		$build_list[$build]['only_for_archs'] = isset($pkg['only_for_archs']) ? preg_split("/\s+/", trim($pkg['only_for_archs'])) : array();
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
			$build_list[$build]['build_options']  = isset($pkg['build_options']) ? $pkg['build_options'] : "";
			$build_list[$build]['only_for_archs'] = isset($pkg['only_for_archs']) ? preg_split("/\s+/", trim($pkg['only_for_archs'])) : array();
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
	if (!empty($pbi_options['ports_before'])) {
		$overlay_list = explode(" ", $pbi_options['ports_before']);
		foreach ($overlay_list as $ol) {
			overlay_pfPort($ol);
		}
	}
	if (!empty($pbi_options['ports_after'])) {
		$overlay_list = explode(" ", $pbi_options['ports_after']);
		foreach ($overlay_list as $ol) {
			overlay_pfPort($ol);
		}
	}
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
	$port_start_time = time();

	if ($host_arch == "amd64" && $options['a'] == "i386") {
		$build_32 = "-32 ";
		$message_32 = "32-bit ";
		$main_build_arch = "i386";
	} else {
		$build_32 = "";
		$message_32 = "";
		$main_build_arch = $host_arch;
	}

	// Kill /usr/ports/ if it's there
	$build = str_replace("/usr/ports/", "", $build);
	list($category, $port) = explode('/', $build);
	if($pbi_options['build_options'])
		if(!isset($options['q']))
			echo ">>> [" . date("H:i:s") . "] BUILD_OPTIONS: {$pbi_options['build_options']}\n";
	$pbi_conf = create_pbi_conf("{$category}/{$port}",$pbi_options['custom_name'],$pbi_options['build_options'],$pbi_options['ports_before'],$pbi_options['ports_after']);
	if(!is_dir("/pbi-build/modules/{$category}/{$port}"))
		exec("mkdir -p /pbi-build/modules/{$category}/{$port}");
	$pbi_confdir = "/pbi-build/modules/{$category}/{$port}";
	file_put_contents("{$pbi_confdir}/pbi.conf", $pbi_conf);
	$sign = "";
	if (!empty($options['S']))
		$sign = "--sign {$options['S']} ";
	$redirbg = isset($options['v']) ? "": " > {$pbi_confdir}/pbi.log 2>&1 &";

	if (empty($pbi_options['only_for_archs']) || in_array($main_build_arch, $pbi_options['only_for_archs'])) {
		echo ">>> [" . date("H:i:s") . "] Processing {$build} {$message_32}({$j}/{$total_to_build})\n";
		echo ">>> [" . date("H:i:s") . "] Executing /usr/local/sbin/pbi_makeport -o /usr/ports/packages/All/ -c {$pbi_confdir} {$build_32}{$sign}{$category}/{$port}\n";
		system("/usr/local/sbin/pbi_makeport -o /usr/ports/packages/All/ -c {$pbi_confdir} {$build_32}{$sign}{$category}/{$port}{$redirbg}");
		wait_for_procs_finish();
		echo ">>> [" . date("H:i:s") . "] Finished building {$build} {$message_32}- Elapsed time: " . format_elapsed_time(time() - $port_start_time) . "\n";
	} else {
		echo ">>> [" . date("H:i:s") . "] Skipping {$build} for {$main_build_arch}\n";
	}

	if ($host_arch == "amd64" && $options['a'] == 'all') {
		if (empty($pbi_options['only_for_archs']) || in_array("i386", $pbi_options['only_for_archs'])) {
			echo ">>> [" . date("H:i:s") . "] Processing {$build} 32-bit ({$j}/{$total_to_build})\n";
			echo ">>> [" . date("H:i:s") . "] Executing /usr/local/sbin/pbi_makeport -o /usr/ports/packages/All/ -c {$pbi_confdir} -32 {$sign}{$category}/{$port}\n";
			system("/usr/local/sbin/pbi_makeport -o /usr/ports/packages/All/ -c {$pbi_confdir} -32 {$sign}{$category}/{$port}{$redirbg}");
			wait_for_procs_finish();
			echo ">>> [" . date("H:i:s") . "] Finished building {$build} 32-bit - Elapsed time: " . format_elapsed_time(time() - $port_start_time) . "\n";
		} else {
			echo ">>> [" . date("H:i:s") . "] Skipping {$build} for i386\n";
		}
	}

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

echo ">>> Package binary build run ended at " . date(DATE_RFC822) . ".\n";
echo ">>> Total time: " . format_elapsed_time(time() - $port_start_time) . "\n";

?>
