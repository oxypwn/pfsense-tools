#!/usr/local/bin/php

<?php

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
	echo "Usage: ./rebuild_packages_binaries.php <path to pkg xml>.  Example: ./rebuild_packages_binaries.php /home/pfsense/packages/pkg_info.8.xml";
	exit;
}

if(!$argv[1]) 
	usage();

// Set the XML filename that we are processing
$xml_filename = $argv[1];

$pkg = parse_xml_config_pkg($xml_filename, "pfsensepkgs");
if(!$pkg) {
	echo "An error occurred while trying to process {$xml_filename}.  Exiting.";
	exit;
}

exec("clear");

echo ">>> pfSense package binary builder is starting.\n";

if(!is_dir("/usr/ports")) {
	echo "!!! /usr/ports/ not found.   Please run portsnap fetch extract\n";
	exit;
}

if(!is_dir("/usr/ports/packages/All")) 
	mkdir("/usr/ports/packages/All");
	
foreach($pkg['packages']['package'] as $pkg) {
	if($pkg['build_port_path']) {
		foreach($pkg['build_port_path'] as $build) {
			$build_options="";
			echo ">>> Processing {$build}\n";
			if($build['build_options']) 
				$build_options = $build['build_options'];
			if(file_exists("/var/db/ports/{$build['name']}/options")) {
				echo ">>> Using /var/db/ports/{$build['name']}/options";
				$build_options .= str_replace("\n", "", file_get_contents("/var/db/ports/{$build['name']}/options"));
			}
			exec("cd {$build} && make clean package-recursive WITHOUT_X11=yes {$build_options} FORCE_PKG_REGISTER=yes");
		}
	}
}

echo ">>> /usr/ports/packages/All now contains:\n";
exec("ls /usr/ports/packages/All");

echo ">>> Package binary build run ended.\n";

?>