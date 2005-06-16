#!/usr/bin/env php
<?php
/*
 * A simple recursive syntax checker for PHP
 * Colin Smith
 * Whipped up for pfSense
 */

if($argc == 1) exit;

$tocheck = array(
			'.php',
			'.inc'
		);

$dirs = glob($argv[1]);
if(!is_array($dirs)) $dirs = array($dirs);

function check_dir($dir) {
	global $tocheck, $exitabnormal;
	if(is_dir($dir)) {
		if($dh = opendir($dir)) {
			while (($file = readdir($dh)) !== false) {
				if(($file == '.') or ($file == '..') or ($file == 'CVS')) continue;
				if(is_dir($dir . '/' . $file . '/')) {
					check_dir($dir . '/' . $file . '/');
				} else {
					if(in_array(strrchr($file, '.'), $tocheck)) {
						$phpout = "";
						exec("/usr/bin/env php -l {$dir}/{$file} 2>&1", $phpout);
						if(!stristr($phpout[0], "No syntax errors detected in")) {
							$exitabnormal = true;
							print "{$dir}{$file}\n-----";
							foreach($phpout as $errline) {
								print "{$errline}\n";
							}
							print "\n";
						}
					}
				}
			}
		}
	}
	return;
}

foreach($dirs as $todo) {
	check_dir($todo);
}

if($exitabnormal) {
	exit(-1);
} else {
	exit(0);
}
