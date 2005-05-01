#!/usr/local/bin/php
<?php
/*
 * XML version manifest manager
 * part of pfSense (http://www.pfsense.com)
 * Colin Smith
 */

include("xmlparse_pkg.inc");

// Tweakables
$pkg_listtags = array_merge($pkg_listtags, array("firmware", "kernel", "base"));
print_r($pkg_listtags);
$xml_rootobj = "pfsenseupdates";

if($argc == 1) {
	$usage = <<<USAGE
Usage:
manifest_handler.php filename [-i] [-a version name -d/f -p platform]

filename - path to manifest
i - interactive mode (add, edit, delete)
a - add a new version
	version 	- desired version number
	name		- release name
	d	 	- (optional) binary diffs must be used
	f		- (optional) full update must be used
	p platform	- (optional) this update is only usable on a certain platform.
USAGE;
	print $usage;
	exit;
} elseif(stristr($argv[2], "a")) {
	if(file_exists($argv[1])) {
		$xml = parse_xml_config_pkg($argv[1], $xml_rootobj);
	} else {
		die("Couldn't open XML file for parsing.\n");
	}
	foreach($xml as $axmlobj => $axmlval) {
		if($argv[3] != "" and $argv[4] != "") {
			$toarray = array(
						"version" => $argv[3],
						"name"	  => $argv[4]
					);
			if($argv[5] == "-d") $toarray["diffonly"] = "";
			if($argv[5] == "-f") $toarray["fullonly"] = "";
			if($argv[5] == "-p" and $argv[6] != "") $toarray["platform"] = $argv[6];
			$xml[$axmlobj][] = $toarray;
		} else {
			die("Missing arguments.\n");
		}
	}
	$fout = fopen($argv[1], "w");
	fwrite($fout, dump_xml_config_pkg($xml, $xml_rootobj));
	fclose($fout);
}

?>
