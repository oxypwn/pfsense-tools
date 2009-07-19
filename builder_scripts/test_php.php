#!/usr/local/bin/php -f

<?php

/*
     This script will chroot via the builder system to test
     the local php setup.  If we can perform a series of 
     small tests to ensure the php environment is sane.
*/

require_once("globals.inc");
require_once("config.inc");
require_once("functions.inc");

$config = parse_config(true);

$passed_tests = true;

// Test config.inc
if($config['system']['hostname'] <> "pfSense") {
	$passed_tests = false;
}

echo $config['system']['hostname'] . " ";

if($passed_tests) 
	exit(0);

// Tests failed.
exit(1);

?>