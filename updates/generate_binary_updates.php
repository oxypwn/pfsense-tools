#!/usr/bin/php -f

<?php

/*
 *  Generate binary updates
 *  Part of pfSense
 */

include("pfsense-utils.inc");

$path_to_bsdiff		 = "/usr/local/sbin/bsdiff";

$previous_version_dir	 = $argv[1];
$new_version_dir	 = $argv[2];
$location_to_bin_patches = $argv[3];

echo "pfSense binary patch creation system is now starting.\n";
echo "Previous version dir: {$previous_version_dir}\n";
echo "New version dir:      {$new_version_dir}\n";
echo "New bin patches dir:  {$location_to_bin_patches}\n";

$error = 0;
if(!file_exists($previous_version_dir)) $error = 1;
if(!file_exists($new_version_dir)) $error = 1;

if($error == 1) {
	echo "ERROR:  Could not locate either previous version or new version directory.";
	die;
}

/*
 * create the target directory if it does not exist.
 * this is where the binary diffs will be stored in
 * a similar hierarchy as the original diretory.
 */
if(!is_dir($location_to_bin_patches)) { 
	echo "Creating {$location_to_bin_patches} ...\n";
	mkdir($location_to_bin_patches);
}

/* startup the routines with the initial passed directories */
create_diffs_for_dir($previous_version_dir, $new_version_dir, $location_to_bin_patches);

function create_diffs_for_dir($pvd, $nvd, $ltbp) {
	global $path_to_bsdiff;
	$pvda = return_files_and_dirs_as_array($pvd);
	foreach($pvda as $pv) {
		/* if item is directory, lets start recursion */
		if(is_dir($pvd . "/" . $pv)) {
			 if(!is_dir("{$ltbp}/{$pv}"))
				 mkdir("{$ltbp}/{$pv}");
			 echo "Starting recurssion ... \n";
			 create_diffs_for_dir($pvd . "/" . $pv, $nvd . "/" . $pv, $ltbp . "/" . $pv);
			 continue;
		}
		$string_to_exec = "{$path_to_bsdiff} {$pvd}/{$pv} {$nvd}/{$pv} {$ltbp}/{$pv}";
		echo "Running {$string_to_exec} ...\n";
		exec("{$string_to_exec}");
	}
}

function return_files_and_dirs_as_array($dir) {
	$new_array = array();
	if ($handle = opendir($dir)) {
		while (false !== ($file = readdir($handle))) { 
			if(stristr($file, ".") == false)
				array_push($new_array, $file);
		}
	}
	closedir($handle); 
	return $new_array;
}

function return_directory_in_string($dir) {
	$dir_split = split("/", $dir);
	$previous_seen = "";
	foreach($dir_split as $ds) {
		if($previous_seen <> "")
			$new_dir .= $previous_seen . "/";
		$previous_seen = $ds;
	}
	return $new_dir;
}

function return_filename_in_string($dir_filename) {
	$dir_split = split("/", $dir_filename);
	$filename = "";
	foreach($dir_split as $ds) 
		$filename = $ds;
	return $filename;
}



?>
