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
$debug 			 = true;

$previous_version_dir	 = $argv[1];
$new_version_dir	 = $argv[2];
$location_to_bin_patches = $argv[3];

echo "\npfSense binary patch creation system is now starting.\n";
echo "\nPrevious version dir: {$previous_version_dir}\n";
echo "New version dir:      {$new_version_dir}\n";
echo "New bin patches dir:  {$location_to_bin_patches}\n";
echo "\n";

if($debug == false)
	echo "Debug is off.  Output is supressed.\n\n";

/* detect if user passed in a .tgz for previous version dir */
if(stristr($previous_version_dir,".tgz") == true) {
	$dir = str_replace(".tgz","", $previous_version_dir);
	echo "Tar Gzipped file detected.  Preparing /tmp/{$dir}\n";
	system("mkdir -p /tmp/{$dir}");
	ststen("cd /tmp/{$dir} && tar xzPf {$previous_version_dir}");
	$previous_version_dir=$dir;
}

/* detect if user passed in a .tgz for new version dir */
if(stristr($new_version_dir,".tgz") == true) {
	$dir = str_replace(".tgz","", $new_version_dir);
	echo "Tar Gzipped file detected.  Preparing /tmp/{$dir}\n";
	system("mkdir -p /tmp/{$dir}");
	ststen("cd /tmp/{$dir} && tar xzPf {$new_version_dir}");
	$new_version_dir=$dir;
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

/* startup the routines with the initial passed directories */
create_diffs_for_dir($previous_version_dir, $new_version_dir, $location_to_bin_patches);

/* tar gzip the new patch directory */
exec("cd {$location_to_bin_patches} && tar czvpf /tmp/binary_diffs.tgz .");

function create_diffs_for_dir($pvd, $nvd, $ltbp) {
	if($debug == true)
		echo "-> create_diffs_for_dir({$pvd},{$nvd}, {$ltbp});\n";
	global $path_to_bsdiff, $debug;
	$pvda = return_files_and_dirs_as_array($pvd);
	foreach($pvda as $pv) {
		/* if item is directory, lets start recursion */
		$working_with = $pvd . "/" . $pv;
		$working_with = str_replace("//","/",$working_with);
		if($debug == true)
			echo "Working with " . $working_with . "\n";
		if(is_dir($pvd . "/" . $pv)) {
			if(!is_dir("{$ltbp}/{$pv}"))
				mkdir("{$ltbp}/{$pv}");
			$first_arg  = $pvd  . "/" . $pv . "/";
			$second_arg = $nvd  . "/" . $pv . "/";
			$third_arg  = $ltbp . "/" . $pv . "/";
			$first_arg = str_replace("//","/",$first_arg);
			$second_arg = str_replace("//","/",$second_arg);
			$third_arg = str_replace("//","/",$third_arg);
			$spawning = "{$first_arg}, {$second_arg}, {$third_arg}\n";
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
			if($old_md5)
				system("echo {$old_md5} > {$ltbp}/{$pv}.old_md5");
			if($new_md5)
				system("echo {$new_md5} > {$ltbp}/{$pv}.new_md5");
			if($patch_md5)
				system("echo {$patch_md5} > {$ltbp}/{$pv}.patch_md5");
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