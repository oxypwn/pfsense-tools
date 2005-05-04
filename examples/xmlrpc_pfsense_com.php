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
	// Variables.
	$path_to_files = './xmlrpc/';
	$toreturn = array();
	$params = array_shift(xmlrpc_params_to_php($raw_params));
	
	// Categories to update
	$categories = array(
				'firmware',
				'kernel',
				'base'
			);

	// Push update categories onto the XML parser.
	global $pkg_listtags;
	$pkg_listtags = array_merge($pkg_listtags, $categories); 

	// Version manifest filenames.
	if($params['platform'] == "") $params['platform'] = "pfSense";
	$versions = array(
				'firmware'	=> 'version',
				'base'		=> 'version_base',
				'kernel'	=> 'version_' . $params['platform']
			);

	// Load the version manifests into the versions array and initialize our returned struct.
	foreach($params as $key => $value) {
		if(isset($versions[$key])) {
			$toreturn[$key] = 1;
			$versions[$key] = parse_xml_config_pkg($path_to_files . $versions[$key], "pfsenseupdates");
			$versions[$key] = $versions[$key][$key];
			if(is_array($versions[$key])) {
				if(!stristr($versions[$key][count($versions[$key]) - 1]['version'], $params[$key]['version'])) {
					for($i = 0; $i < count($versions[$key]); $i++) {
						if(stristr($versions[$key][$i]['version'], $params[$key]['version'])) {
							$toreturn[$key] = array_slice($versions[$key], $i + 1);
							foreach($toreturn[$key] as $aindex => $akey) if(array_key_exists('full', $akey)) $toparse = $aindex;
							$toreturn[$key] = array_slice($versions[$key], $toparse + 1);
						}
					}
					if(!is_array($toreturn[$key][0])) $toreturn[$key] = $versions[$key];
				} else {
					$toreturn[$key] = true;
				}
			}
		}
	}
	$response = php_value_to_xmlrpc($toreturn);
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
