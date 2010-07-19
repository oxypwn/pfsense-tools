#!/usr/local/bin/php

<?php

if(file_exists("/etc/inc/")) {
	include("/etc/inc/functions.inc");
	include("/etc/inc/xmlparse.inc");
}

if(file_exists("/usr/home/pfsense/pfSenseGITREPO/pfSenseGITREPO")) {
	include("/usr/home/pfsense/pfSenseGITREPO/pfSenseGITREPO/functions.inc");	
	include("/etc/inc/xmlparse.inc");
}

function usage() {
	echo "Usage: ./rebuild_packages_binaries.php <path to pkg xml>.  Example: ./rebuild_packages_binaries.php /home/pfsense/packages/pkg_info.8.xml";
	exit;
}

if(!$argv[1]) 
	usage();

// Set the XML filename that we are processing
$xml_filename = $argv[1];

$pkg = parse_xml_config_pkg($xml_filename, "packagegui");
if(!$pkg) {
	echo "An error occurred while trying to process {$xml_filename}.  Exiting.";
	exit;
}

if(is_dir("/usr/ports")) {
	echo ">>> /usr/ports not found.  Fetching...";
	exec("portsnap fetch extract");
}

if(is_dir("/usr/ports/packages/All")) 
	mkdir("/usr/ports/packages/All");
	
foreach($pkg['packages']['package'] as $pkg) {
	if($pkg['build_port_path']) {
		echo ">>> Processing {$pkg['build_port_path']}\n";
		exec("cd {$pkg['build_port_path']} && make clean package-recursive FORCE_PKG_REGISTER=yes");
	}
}

echo ">>> Package binary build run ended.\n";

?>
