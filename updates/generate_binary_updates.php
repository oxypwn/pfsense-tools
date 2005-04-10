#!/usr/local/bin/php -f

<?php

/*
 *  Generate binary updates
 *  Part of pfSense
 *  (C)2005 Scott Ullrich (sullrich@gmail.com)
 *  All rights reserved
 */

/* location to bsdiff binary */
$path_to_bsdiff		 = "/usr/local/bin/bsdiff";
/* uncomment to enable lots of spamming */
$debug 			 = false;

$previous_version_dir	 = $argv[1];
$new_version_dir	 = $argv[2];
$location_to_bin_patches = "/tmp/patches";

system("mkdir -p {$location_to_bin_patches}");

echo "\npfSense binary patch creation system is now starting.\n";
echo "\nPrevious version dir: {$previous_version_dir}\n";
echo "New version dir:      {$new_version_dir}\n";
echo "New bin patches dir:  {$location_to_bin_patches}\n";
echo "\n";

if($debug == false)
	echo "Debug is off.  Output is surpressed.\n";

/* detect if user passed in a .tgz for previous version dir */
if(stristr($previous_version_dir,".tgz") == true) {
	$dir = str_replace(".tgz","", $previous_version_dir);
	echo "\nTar Gzipped file detected.\nPreparing {$dir} ...";
	system("mkdir -p {$dir}");
	system("tar xzPf {$previous_version_dir} -C {$dir}");
	$previous_version_dir=$dir;
	echo "\n";
}

/* detect if user passed in a .tgz for new version dir */
if(stristr($new_version_dir,".tgz") == true) {
	$dir = str_replace(".tgz","", $new_version_dir);
	echo "\nTar Gzipped file detected.\nPreparing {$dir} ...";
	system("mkdir -p {$dir}");
	system("tar xzPf {$new_version_dir} -C {$dir}");
	$new_version_dir=$dir;
	echo "\n";
}

/* check to make sure that the directories exist */
$error = 0;
if(!file_exists($previous_version_dir)) {
	$error = 1;
	echo "ERROR:  Could not locate previous version directory {$previous_version_dir}.\n\n";
}
if(!file_exists($new_version_dir)) {
	$error = 1;
	echo "ERROR:  Could not locate new version directory {$new_version_dir}.\n\n";
}

if($error == 1)	die;

/*
 *   at this point our previous version and new version
 *   environments should be setup and ready for action
 *
 *   create the target directory if it does not exist.
 *   this is where the binary diffs will be stored in
 *   a similar hierarchy as the original diretory.
 */
if(!is_dir($location_to_bin_patches)) {
	if($debug == true)
		echo "Creating {$location_to_bin_patches} ...\n";
	mkdir($location_to_bin_patches);
}

echo "\nStarting binary diff process ... Please wait ...";

/* startup the routines with the initial passed directories */
create_diffs_for_dir($previous_version_dir, $new_version_dir, $location_to_bin_patches);

/* tar gzip the new patch directory */
exec("cd {$location_to_bin_patches} && tar czpf /tmp/binary_diffs.tgz .");

/* if debug is off, lets cleanup after ourselves */
if($debug == false) system("rm -rf {$previous_version_dir}");
if($debug == false) system("rm -rf {$new_version_dir}");

echo "\n\nCalculating binary diffs update size ...\n";
system("ls -la /tmp/binary_diffs.tgz");
echo "\n";

function create_diffs_for_dir($pvd, $nvd, $ltbp) {
	if($debug == true)
		echo "-> create_diffs_for_dir({$pvd},{$nvd}, {$ltbp});\n";
	global $path_to_bsdiff, $debug;
	$pvda = return_files_and_dirs_as_array($pvd);
	foreach($pvda as $pv) {
		/* if item is directory, lets start recursion */
		echo ".";
		$working_with = $pvd . "/" . $pv;
		$working_with = str_replace("//","/",$working_with);
		if($debug == true)
			echo "Working with " . $working_with . "\n";
		if(is_dir($pvd . "/" . $pv)) {
			if(!is_dir("{$ltbp}/{$pv}"))
				mkdir("{$ltbp}/{$pv}");
		}
		if(is_file($working_with)) {
			$string_to_exec = "{$path_to_bsdiff} {$pvd}/{$pv} {$nvd}/{$pv} {$ltbp}/{$pv}";
			$string_to_exec = str_replace("//","/",$string_to_exec);
			if($debug == true)
				echo "Running {$string_to_exec} ...\n";
			exec("{$string_to_exec}");
			if(file_exists("{$pvd}/{$pv}"))
				$old_md5   = md5_file("{$pvd}/{$pv}");
			if(file_exists("{$nvd}/{$pv}"))
				$new_md5   = md5_file("{$pvd}/{$pv}");
			if(file_exists("{$pvd}/{$pv}"))
				$patch_md5 = md5_file("{$ltbp}/{$pv}");
			//if($old_md5)
			//	system("echo {$old_md5} > {$ltbp}/{$pv}.old_md5");
			//if($new_md5)
			//	system("echo {$new_md5} > {$ltbp}/{$pv}.new_md5");
			//if($patch_md5)
			//	system("echo {$patch_md5} > {$ltbp}/{$pv}.patch_md5");
		}
	}
}

function return_files_and_dirs_as_array($dir) {
	$dir="/{$dir}/";
	$dir = str_replace("//","/",$dir);
	$a = `cd $dir && find .`;
	$files = explode ("\n", $a);
	return $files;
}

?>