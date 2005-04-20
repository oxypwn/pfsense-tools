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

	TODO: Use a loop to handle all of the different update sections (base, kernel, etc.) instead of using an individual block for each. This will leave us room to expand our update system in the future if necessary.

*/

require_once("xmlrpc_server.inc");

/*
 *   xmlrpc_params_to_php: Convert params array passed from XMLRPC server into a PHP array and return it.
 *
 *   XXX: This function does not currently handle XML_RPC_Value objects of type "struct".
 */
function xmlrpc_params_to_php($params) {
        $array = array();
        for($i = 0; $i < $params->getNumParams(); $i++) {
                $value = $params->getParam($i);
                if($value->kindOf() == "scalar") {
                        $array[] = $value->scalarval();
                } elseif($value->kindOf() == "array") {
                        $array[] = xmlrpc_array_to_php($value);
                }
        }
        return $array;
}

/*
 *   xmlrpc_array_to_php: Convert an XMLRPC array into a PHP array and return it.
 */
function xmlrpc_array_to_php($array) {
        $return = array();
        $array_length = $array->arraysize();
        for($i = 0; $i < $array->arraysize(); $i++) {
                $value = $array->arraymem($i);
                if($value->kindOf() == "scalar") {
                        $return[] = $value->scalarval();
                } elseif($value->kindOf() == "array") {
                        $return[] = xmlrpc_array_to_php($value);
                }
        }
        return $return;
}

/*
 *   php_value_to_xmlrpc: Convert a PHP scalar or array into its XMLRPC equivalent.
 */
function php_value_to_xmlrpc($value, $force_array = false) {
	if(gettype($value) == "array") {
		$xmlrpc_type = "array";
		$toreturn = array();
		foreach($value as $key => $val) {
			if(is_string($key)) $xmlrpc_type = "struct";
			$toreturn[$key] = php_value_to_xmlrpc($val);
                }
		return new XML_RPC_Value($toreturn, $xmlrpc_type);
	} else {
		if($force_array == true) {
			return new XML_RPC_Value(array(new XML_RPC_Value($value, gettype($value))), "array");
		} else {
			return new XML_RPC_Value($value, gettype($value));
		}
	}
}

$get_firmware_version_sig = array(array(array(), string, string, string, string));
$get_firmware_version_doc = 'Method used to get the current firmware, kernel, and base system versions. This must be called with four strings - a valid pfSense platform and the caller\'s current firmware, kernel, and base versions, respectively. This method returns the current firmware version, the current kernel version, the current base version, and any additional data.';

function get_firmware_version($raw_params) {
	// Variables.
	$path_to_version_files = './xmlrpc/';
	$return_comments = false;

	$log = fopen("/tmp/4newxmlrpclog.log", "w");

	// Locations of version manifest files.
	$path_to_firmware_manifest = $path_to_version_files . 'version';			// pfSense firmware version
	$path_to_base_manifest = $path_to_version_files . 'version_base';			// base system version
	$path_to_wrapsoekris_manifest = $path_to_version_files . 'version_wrapsoekris';		// wrapsoekris kernel version
	$path_to_pfsense_manifest = $path_to_version_files . 'version_pfsense';			// pfsense kernel version
	$path_to_comments = $path_to_version_files . 'version_comment';				// pfSense comments

	fwrite($log, "Parsed version manifest paths.\n");
	
	$params = xmlrpc_params_to_php($raw_params);
	fwrite($log, "Converted params.\n");
	if($current_firmware_versions = file($path_to_firmware_manifest)) $gotfirmware = true;
	if($current_base_versions = file($path_to_base_version)) $gotbase = true;
	fwrite($log, "Parsed first version manifests.\n");

	if($params[0] == 'wrap+soekris') {
		if($current_kernel_versions = file($path_to_wrapsoekris_manifest)) $gotkernel = true;
	} else {
		if($current_kernel_versions = file($path_to_pfsense_manifest)) $gotkernel = true;
	}
	
	// Assume the client is up to date before running checks.
	$firmware_to_download = array(1);
	$kernel_to_download = array(1);
	$base_to_download = array(1);

	if($gotfirmware == true) {
		if($current_firmware_versions[count($current_firmware_versions) - 1] != $params[1]) { // The client isn't running the latest firmware.
			for($i = 0; $i < count($current_firmware_versions); $i++) {
				if($params[1] == trim($current_firmware_versions[$i])) {
					$firmware_to_download = array_slice($current_firmware_versions, $i + 1);
					$version_mismatch = true;
				}
			}
		}
	} else {
		$firmware_to_download = array(-1);
	}
	
	if($gotkernel == true) {
		if($current_kernel_versions[count($current_kernel_versions) - 1] != $params[2]) { // The client isn't running the latest kernel.
			for($i = 0; $i < count($current_kernel_versions); $i++) {
				if($params[2] == trim($current_kernel_versions[$i])) {
					$kernel_to_download = array_slice($current_kernel_versions, $i + 1);
					$version_mismatch = true;
				}
			}
		}
	} else {
		$kernel_to_download = array(-1);
	}

	if($gotbase = true) {
		if($current_base_versions[count($current_base_versions) -1] != $params[3]) { // The client isn't running the latest base.
			for($i = 0; $i < count($current_base_versions); $i++) {
				if($params[3] == trim($current_base_versions[$i])) {
					$base_to_download = array_slice($current_base_versions, $i + 1);
        				$version_mismatch = true;
				}
			}
		}
	} else {
		$base_to_download = array(-1);
	}

	if($return_comments == true && $version_mismatch == true) {
		$comments = trim(file_get_contents($path_to_comments));
		$response = new XML_RPC_Value(array(new XML_RPC_Value($version_mismatch, 'boolean'),
						    php_value_to_xmlrpc($firmware_to_download),
						    php_value_to_xmlrpc($kernel_to_download),
						    php_value_to_xmlrpc($base_to_download),
						    new XML_RPC_Value($comments, 'string')
					     ), 'array'
			    );
	} elseif($version_mismatch == true) {
		$response = new XML_RPC_Value(array(new XML_RPC_Value($version_mismatch, 'boolean'),
						    php_value_to_xmlrpc($firmware_to_download),     
                                                    php_value_to_xmlrpc($kernel_to_download),
                                                    php_value_to_xmlrpc($base_to_download)
					     ), 'array'
			    );
	} else {
		$response = new XML_RPC_Value(array(new XML_RPC_Value($version_mismatch, 'boolean')
					     ), 'array'
			    );
	}
	fclose($log);
	return new XML_RPC_Response($response);
}

$server = new XML_RPC_Server(
        array(
	    'pfsense.get_firmware_version' =>	array('function' => 'get_firmware_version',
							'signature' => $get_firmware_version_sig,
							'docstring' => $get_firmware_version_doc)
        )
);
?>
