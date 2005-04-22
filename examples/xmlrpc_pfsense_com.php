<?php
/*
	$Id$

        xmlrpc_pfsense_com.php
        Copyright (C) 2005 Colin Smith
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

        1. Redistributions of source code must retain the above copyright notice,
           this list of conditions and the following disclaimer.

        2. Redistributions in binary form must reproduce the above copyright
           notice, this list of conditions and the following disclaimer in the
           documentation and/or other materials provided with the distribution.

        THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
        INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
        AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
        AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
        OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
        SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
        INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
        CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
        ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
        POSSIBILITY OF SUCH DAMAGE.

	TODO:
		* Use a loop to handle all of the different update sections (base, kernel, etc.)
		* Return a struct instead on a numerically indexed array.
*/

require_once("xmlrpc_server.inc");
require_once("xmlparse_pkg.inc");
require_once("xmlrpc.inc");

//$get_firmware_version_sig = array(array(array(), array()));
$get_firmware_version_doc = 'Method used to get the current firmware, kernel, and base system versions. This must be called with an array. This method returns an array.';

function get_firmware_version($raw_params) {
	$log = fopen("/home/colin/xmlrpc.log", "w");
	// Variables.
	$path_to_files = './xmlrpc/';
	$toreturn = array();
	$params = array_shift(xmlrpc_params_to_php($raw_params));
	fwrite($log, print_r($params, true));
	// Categories to update
	$categories = array(
				'firmware',
				'kernel',
				'base'
			);

	// Push update categories onto the XML parser.
	global $pkg_listtags;
	$pkg_listtags = array_merge($pkg_listtags, $categories); 

	fwrite($log, print_r($pkg_listtags, true));

	// Version manifest filenames.
	$versions = array(
				'firmware' => 'version',
				'base' => 'version_base',
				'kernel' => array(
							'wrapsoekris' => 'version_wrapsoekris',
							'pfsense' => 'version_pfsense'
						)
			);
	fwrite($log, print_r($versions, true));

	// Load the version manifests into the versions array and initialize our returned struct.
	foreach($versions as $key => $value) {
		$toreturn[$key] = 1;
		if(is_array($value)) {
			foreach($value as $subkey => $subval) {
				fwrite($log, "OMGOMG");
				$versions[$key][$subkey] = parse_xml_config_pkg($path_to_files . $subval, "pfsenseupdates");
			}
		} else {
			$versions[$key] = parse_xml_config_pkg($path_to_files . $value, "pfsenseupdates");
		}
	}

	fwrite($log, print_r($toreturn, true));

	// Loop through our version manifest array and determine whether or not we have a version conflict.
	foreach($versions as $key => $value) {
		foreach($value as $subkey => $subval) {
			if(!stristr($params[$key], $subval[count($subval) - 1]['version'])) {
				for($i = 0; $i < count($subval); $i++) {
					if($params[$key] == $subval[$i]) {
						$toreturn[$key] = array_slice($subval, $i + 1);
					}
				}
			}
		}
	}
	$response = php_value_to_xmlrpc($toreturn);
	fwrite($log, print_r($response, true));
	return new XML_RPC_Response($response);
}

$server = new XML_RPC_Server(
        array(
	    'pfsense.get_firmware_version' =>	array('function' => 'get_firmware_version',
//							'signature' => $get_firmware_version_sig,
							'docstring' => $get_firmware_version_doc)
        )
);
?>
