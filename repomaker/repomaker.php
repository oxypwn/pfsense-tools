#!/usr/bin/env php
<?php
/*
 * repomaker.php - a script to create and update package repositories
 * Created by Colin Smith for the pfSense project.
 */

include("xmlparse.inc");
include("repomaker.inc");

$flags = array(
				"verbose" => false,
				"quiet"	=> false
		);
$xmlout = array();
$info =& $xmlout['info'];
$mirrors =& $xmlout['mirrors']['mirror'];
$packages =& $xmlout['packages']['package'];
$pkgdb =& $xmlout['pkgdb'];

if($argc == 1) {
	/* print basic usage statement */
	print_usage();
	exit;
} else {
	/* let's handle arguments */
	array_shift($argv);
	while($arg = array_shift($argv)) {
		switch($arg) {
		case "-n":
			$info['name'] = array_shift($argv);
			break;
		case "-h":
			$info['host'] = array_shift($argv);
			break;
		case "-d":
			$info['desc'] = array_shift($argv);
			break;
		case "-m":
			$mirrors = get_mirrors(array_shift($argv));
			break;
		case "-f":
			$pkglist = array_merge($pkglist, file(array_shift($argv)));
			break;
		case "-p":
			$flags['pkgdir'] = array_shift($argv);
			break;
		default:
			$pkglist[] = $arg;
		}
	}
	if((!$info['name']) or (!$info['host'])) {
		fwrite(STDERR, "WARNING: No information set for this repository!\n");
	}

	list($packages, $pkgdb) = get_packages($pkglist);
	print dump_xml_config_pkg($xmlout, "pkgrepo");
}

?>
