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

function usage() {
	global $argv;
	echo "Usage: {$argv[0]} -x <path to pkg xml> [-p <package name>] [-d]\n";
	echo "  Flags:\n";
	echo "    -c csup hostname\n";
	echo "    -d Use DESTDIR when building.\n";
	echo "    -j Use a chroot for building each invocation\n";
	echo "    -l Location of chroot for building.\n";
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

function overlay_pfPort($package_name, $port_path) {
	$pfports = "/home/pfsense/tools/pfPorts";
	// If a pfport by $package_name exists, overlay that folder onto $port_path
	if (file_exists("{$pfports}/{$package_name}") && is_dir("{$pfports}/{$package_name}")) {
		echo ">>> Overelaying pfPort {$package_name} onto {$port_path} ... ";
		if (file_exists($port_path) && is_dir($port_path)) {
			echo "Preserving old port in {$port_path}.orig ...";
			system("/bin/rm -rf {$port_path}.orig");
			system("/bin/mv {$port_path} {$port_path}.orig");
		}
		system("/bin/mkdir -p {$port_path}");
		system("/bin/cp -R {$pfports}/{$package_name}/ {$port_path}");
		echo "Done.\n";
	}
}

function csup($csup_host, $supfile, $chrootchroot = "", $quiet_mode = "") {
	echo ">>> Update sources from file {$supfile}\n";
	if($chrootchroot) 
		system("/usr/sbin/chroot {$chrootchroot} csup -L0 -h {$csup_host} {$supfile} {$quiet_mode}");
	else
		system("/usr/bin/csup -h {$csup_host} {$supfile} {$quiet_mode}");
}

function chroot_command($chroot_location, $command_to_run) {
	file_put_contents("{$chroot_location}/cmd.sh", $command_to_run);
	exec("/bin/chmod a+rx {$chroot_location}/cmd.sh");
	`/usr/sbin/chroot {$chroot_location} /cmd.sh`;
}

$options = getopt("x:p::d::j::l::c::r::q::s::");

if(!isset($options['x']))
	usage();

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

// Handle chroot building
if(isset($options['j']) && $options['l'] <> "") {
	if(!file_exists("/usr/src/COPYRIGHT")) {
		echo ">>> /usr/src/ is not populated.  Populating, please wait...\n";
		csup($csup_host, "/usr/share/examples/cvsup/standard-supfile", $quiet_mode);
	}
	$file_system_root = "{$options['l']}";
	echo ">>> Preparing chroot {$options['l']} ...\n";	
	// Nuke old chroot
	if(is_dir($options['l'])) {
		if(is_dir("{$options['l']}/dev")) {
			echo ">>> Unmounting {$options['l']}/dev\n";
			system("umount {$options['l']}/dev 2>/dev/null");
		}
		if(isset($options['r'])) {
			echo ">>> Removing {$options['l']}\n";
			system("chflags -R noschg {$options['l']}/*");
			system("rm -rf {$options['l']}");
		}
	}
	// Create new chroot structure
	echo ">>> Creating chroot structure...\n";
	system("cd /usr/src && mkdir -p {$options['l']}");
	system("cd /usr/src && mkdir -p {$options['l']}/etc");
	system("cd /usr/src && mkdir -p {$options['l']}/dev");
	system("mkdir -p {$options['l']}/home/pfsense");
	echo ">>> Building world...\n";
	exec("cd /usr/src && make world NO_CLEAN=yes DESTDIR={$options['l']} {$quiet_mode}");
	echo ">>> Building distribution...\n";
	exec("cd /usr/src && make distribution NO_CLEAN=yes DESTDIR={$options['l']} {$quiet_mode}");
	// Mount devs and populate resolv.conf
	system("mount -t devfs devfs {$options['l']}/dev");
	system("cp /etc/resolv.conf {$options['l']}/etc/");
	system("cp -R /home/pfsense/tools {$options['l']}/home/pfsense/");
	// Invoke csup and populate /usr/ports inside chroot
	csup($csup_host, "/usr/share/examples/cvsup/ports-supfile", $options['l'], $quiet_mode);
	echo ">>> Applying kernel patches and make includes...\n";
	exec("rm -rf {$options['l']}/tmp/pf*");
	$command_to_run = "#!/bin/sh\n";
	if($set_version)
		$command_to_run .= "cd /home/pfsense/tools/builder_scripts && ./set_version.sh {$set_version}\n";
	$command_to_run .= "cd /home/pfsense/tools/builder_scripts && ./apply_kernel_patches.sh\n";
	$command_to_run .= "cd /usr/pfSensesrc/src && make includes\n";
	chroot_command($options['l'], $command_to_run);
} else {
	// Invoke csup and populate /usr/ports on host (non-chroot)
	$file_system_root = "/";
	exec("rm -rf /tmp/pf*");
	csup($csup_host, "/usr/share/examples/cvsup/ports-supfile", $quiet_mode);
	echo ">>> Applying kernel patches...\n";
	if($set_version)
		exec("cd /home/pfsense/tools/builder_scripts && ./set_version.sh {$set_version}");
	exec("cd /home/pfsense/tools/builder_scripts && ./apply_kernel_patches.sh");
	echo ">>> Running make includes...\n";
	exec("cd /usr/pfSensesrc/src && make includes");
}

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
	if (isset($options['p']) && strtolower(($options['p']) != strtolower($pkg['name'])))
		continue;
	if($pkg['build_port_path']) {
		foreach($pkg['build_port_path'] as $build) {
			overlay_pfPort(strtolower($pkg['name']), $build);
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
			if($build_options) 
				if(!isset($options['q'])) 
					echo " BUILD_OPTIONS: {$build_options}\n";
			// Build in chroot if defined.
			if(isset($options['j']) && $options['l']) {
				$command_to_run  = "#!/bin/sh\n";
				$command_to_run .= "if [ ! -L /usr/home ]; then\n";
				$command_to_run .= "	 ln -s /home/ /usr/home\n";
				$command_to_run .= "fi\n";
				$command_to_run .= "cd {$build} && make clean depends package-recursive {$DESTDIR} BATCH=yes WITHOUT_X11=yes {$build_options} FORCE_PKG_REGISTER=yes clean {$quiet_mode}\n";
				chroot_command($options['l'], $command_to_run);
			} else
				`cd {$build} && make clean depends package-recursive {$DESTDIR} BATCH=yes WITHOUT_X11=yes {$build_options} FORCE_PKG_REGISTER=yes clean {$quiet_mode}`;
		}
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