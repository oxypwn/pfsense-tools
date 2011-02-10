#!/usr/local/bin/php -q
<?php
/* 
 *  rebuild_package_binaries.sh
 *  Copyright (C) 2010, 2011 Scott Ullrich
 *  Copyright (C) 2010, 2011 Jim Pingle
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
	include("/etc/inc/functions.inc");
	include("/etc/inc/util.inc");
	include("/etc/inc/xmlparse.inc");
}

if(file_exists("/usr/home/pfsense/pfSenseGITREPO/pfSenseGITREPO")) {
	include("/usr/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc/functions.inc");
	include("/usr/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc/util.inc");
	include("/usr/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/etc/inc/xmlparse.inc");
}

function usage() {
	global $argv;
	echo "Usage: {$argv[0]} -x <path to pkg xml> [-p <package name>] [-d]\n";
	echo "  Flags:\n";
	echo "    -x XML file containing package data.\n";
	echo "    -p Package name to build a single package and its dependencies.\n";
	echo "    -d Use DESTDIR when building.\n";
	echo "    -j Use a fresh jail for building each invocation\n";
	echo "    -l Location of fresh jail for building.\n";
	echo "    -c csup hostname\n";
	echo "  Examples:\n";
	echo "     {$argv[0]} -x /home/pfsense/packages/pkg_info.8.xml\n";
	echo "     {$argv[0]} -x /home/pfsense/packages/pkg_info.8.xml -p squid\n";
	exit;
}

$options = getopt("x:p::d::j::l::c::");

if(!isset($options['x']))
	usage();

// Set csup hostname
if($options['c'] <> "") {
	echo "Setting csup hostname to {$options['c']} \n";
	$csup_host = $options['c'];
} else {
	echo "Setting csup hostname to cvsup.livebsd.com \n";
	$csup_host = "cvsup.livebsd.com";
}

function csup($csup_host, $supfile, $jailchroot = "") {
	if($jailchroot) 
		exec("chroot {$jailchroot} csup -h {$csup_host} {$supfile}");
	else
		exec("csup -h {$csup_host} {$supfile}");
}

// Handle jail building
if(isset($options['j']) && $options['l'] <> "") {
	if(!file_exists("/usr/src/COPYRIGHT")) {
		echo ">>> /usr/src/ is not populated.  Populating, please wait...\n";
		csup($csup_host, "/usr/share/examples/cvsup/standard-supfile");
	}
	$file_system_root = "{$options['l']}";
	echo ">>> Preparing jail {$options['l']} ...\n";	
	// Nuke old jail
	if(is_dir($options['l'])) {
		if(is_dir("{$options['l']}/dev")) {
			echo ">>> Unmounting {$options['l']}/dev";
			exec("umount {$options['l']}/dev");
		}
		echo ">>> Removing {$options['l']}";
		exec("rm -rf {$options['l']}");
	}
	echo ">>> Creating jail structure...\n";
	exec("cd /usr/src && mkdir -p {$options['l']}");
	exec("cd /usr/src && make world DESTDIR={$options['l']}");
	exec("cd /usr/src && make distribution DESTDIR={$options['l']}");
	exec("mount -t devfs devfs {$options['l']}/dev");
	csup($csup_host, "/usr/share/examples/cvsup/ports-supfile", $options['l']);
} else {
	$file_system_root = "/";
	csup($csup_host, "/usr/share/examples/cvsup/ports-supfile");
}

// Set the XML filename that we are processing
$xml_filename = $options['x'];

$pkg = parse_xml_config_pkg($xml_filename, "pfsensepkgs");
if(!$pkg) {
	echo "An error occurred while trying to process {$xml_filename}.  Exiting.";
	exit;
}

echo ">>> pfSense package binary builder is starting.\n";

if(!is_dir("{$file_system_root}/usr/ports")) {
	echo "!!! {$file_system_root}/usr/ports/ not found.   Please run portsnap fetch extract\n";
	exit;
}

if(!is_dir("{$file_system_root}/usr/ports/packages/All")) 
	exec("mkdir -p {$file_system_root}/usr/ports/packages/All");

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

foreach($pkg['packages']['package'] as $pkg) {
	if (isset($options['p']) && ($options['p'] != $pkg['name']))
		continue;
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
			if($build_options) 
				echo " BUILD_OPTIONS: {$build_options}\n";
			else 
				echo "\n";
			// Build in jail if defined.
			if(isset($options['p']) && $options['l']) 
				`chroot {$file_system_root} cd {$build} && make clean depends package-recursive {$DESTDIR} BATCH=yes WITHOUT_X11=yes {$build_options} FORCE_PKG_REGISTER=yes clean </dev/null 2>&1`;
			else
				`cd {$build} && make clean depends package-recursive {$DESTDIR} BATCH=yes WITHOUT_X11=yes {$build_options} FORCE_PKG_REGISTER=yes clean </dev/null 2>&1`;
		}
	}
}

echo ">>> {$file_system_root}/usr/ports/packages/All now contains:\n";
system("ls {$file_system_root}/usr/ports/packages/All");

if($copy_packages_to_folder_ssh) {
	echo ">>> Copying packages to {$copy_packages_to_host_ssh}\n";
	system("/usr/local/bin/rsync -ave ssh --timeout=60 --rsh='ssh -p{$copy_packages_to_host_ssh_port}' {$file_system_root}/usr/ports/packages/All/* {$copy_packages_to_host_ssh}:{$copy_packages_to_folder_ssh}/");
}

echo ">>> Package binary build run ended.\n";

?>