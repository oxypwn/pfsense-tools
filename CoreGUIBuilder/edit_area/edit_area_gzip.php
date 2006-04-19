<?php
/**
 * $RCSfile$
 * $Revision$
 * $Date$
 *
 * @version 1.07
 * @author Moxiecode
 * @copyright Copyright © 20052006, Moxiecode Systems AB, All rights reserved.
 *
 * This file compresses the Editarea JavaScript using GZip and
 * enables the browser to do one request for all javascript instead of one for each .js file.
**/
 
/**
 * Original file modified for Edit area
**/

	// General options
	$suffix = "";							// Set to "_src" to use source version
	$expiresOffset = 3600 * 24 * 10;		// 10 days util client cache expires
	$diskCache = true;						// If you enable this option gzip files will be cached on disk.
	$cacheDir = realpath(".");				// Absolute directory path to where cached gz files will be stored
	$debug = false;							// Enable this option if you need debuging info
	$use_gzip= true;						// Enable gzip compression
	
	//$headers = apache_request_headers();
	$scriptsToLoad= array("area_template.js", "manage_area.js", "resize_area.js", "edit_area_functions.js", "elements_functions.js", "reg_syntax.js", "regexp.js", "highlight.js", "keyboard.js", "search_replace.js");
	
	// Headers
	header("Content-type: text/javascript; charset: UTF-8");
	header("Vary: Accept-Encoding"); // Handle proxies
	header("Expires: " . gmdate("D, d M Y H:i:s", time() + $expiresOffset) . " GMT");
	
	// Get data to load	
	$cacheFile=  $cacheDir == "" ? "" : $cacheDir . "/" . "edit_area_gzip.js";
	$cacheData = "";
	$cacheDate= filemtime(realpath("edit_area" . $suffix . ".js"));
	
	
	// Patch older versions of PHP < 4.3.0
	if (!function_exists('file_get_contents')) {
		function file_get_contents($filename) {
			$fd = fopen($filename, 'rb');
			$content = fread($fd, filesize($filename));
			fclose($fd);
			return $content;
		}
	}
	
	// Security check function, can only contain a-z 0-9 , _ - and whitespace.
	function TinyMCE_cleanInput($str) {
		return preg_replace("/[^0-9a-z\-_,]+/i", "", $str); // Remove anything but 0-9,a-z,-_
	}
	
	function TinyMCE_echo($str) {
		global $cacheData;
	
		$cacheData .= $str;
	
	}
	
	// Only gzip the contents if clients and server support it
	$encodings = array();

	if (isset($_SERVER['HTTP_ACCEPT_ENCODING']))
		$encodings = explode(',', strtolower(preg_replace("/\s+/", "", $_SERVER['HTTP_ACCEPT_ENCODING'])));

	// Check for gzip header or northon internet securities
	if ($use_gzip && (in_array('gzip', $encodings) || isset($_SERVER['---------------'])) && function_exists('ob_gzhandler') && !ini_get('zlib.output_compression')) {
		// Use cached file if it exists but not in debug mode
		if (file_exists($cacheFile) && !$debug) {
			// check if chache file must be update
			foreach($scriptsToLoad as $key => $value){
				$cacheDate= max($cacheDate, filemtime(realpath($value)));
			}
			if(filemtime($cacheFile) > $cacheDate){
				// if cache file is up to date
				$last_modified = gmdate("D, d M Y H:i:s",filemtime($cacheFile))." GMT";
				if (strcasecmp($_SERVER["HTTP_IF_MODIFIED_SINCE"], $last_modified) === 0)
				{
					header("HTTP/1.1 304 Not Modified");
					header("Last-modified: ".$last_modified);
					header("Cache-Control: Public"); // Tells HTTP 1.1 clients to cache
					header("Pragma:"); // Tells HTTP 1.0 clients to cache
				}
				else
				{
					header("Last-modified: ".$last_modified);
					header("Cache-Control: Public"); // Tells HTTP 1.1 clients to cache
					header("Pragma:"); // Tells HTTP 1.0 clients to cache
					header("Content-Encoding: gzip");
					header('Content-Length: '.filesize($cacheFile));
					echo file_get_contents($cacheFile);
				}
				die;
			}
		}
	
		//if (!$diskCache)
			//ob_start("ob_gzhandler");
	} else{
		$diskCache = false;
		$use_gzip = false;
	}


	// Write script 	
	TinyMCE_echo(file_get_contents(realpath("edit_area" . $suffix . ".js")));
	foreach($scriptsToLoad as $key => $value){
		TinyMCE_echo(file_get_contents(realpath($value)));
	}

		
	if($use_gzip){
		header("Content-Encoding: gzip");			
		
		$gzip_datas=  gzencode($cacheData, 9, FORCE_GZIP);			
		if ($debug) {
			$ratio = round(100 - strlen($gzip_datas) / strlen($cacheData) * 100.0);
			TinyMCE_echo("alert('Editarea was compressed by " . $ratio . "%.\\nOutput cache file: " . $cacheFile . "');");
			$gzip_datas=  gzencode($cacheData, 9, FORCE_GZIP);
			
		}elseif($diskCache){	
			$fp = @fopen($cacheFile, "wb");
			if ($fp) {
				fwrite($fp, $gzip_datas);
				fclose($fp);
			}
		}			
		echo $gzip_datas;
	}else{
		echo $cacheData;
	}
	
	
	die;
?>