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

$get_firmware_version_sig = array(array(array(), string, string, string, string));
$get_firmware_version_doc = 'Method used to get the current firmware, kernel, and base system versions. This must be called with four strings - a valid pfSense platform and the caller\'s current firmware, kernel, and base versions, respectively. This method returns the current firmware version, the current kernel version, the current base version, and any additional data.';

function get_firmware_version($raw_params) {
	// Variables.
	$path_to_version_files = './';
	$return_comments = false;

	// Locations of version files.
	$path_to_firmware_version = $path_to_version_files . 'version';
	$path_to_base_version = $path_to_version_files . 'version_base';
	$path_to_wrapsoekris_version = $path_to_version_files . 'version_wrapsoekris';
	$path_to_pfsense_version = $path_to_version_files . 'version_pfsense';
	$path_to_comments = $path_to_version_files . 'version_comment';
	
	$params = xmlrpc_params_to_php($raw_params);
	$current_firmware_version = trim(file_get_contents($path_to_firmware_version));
	$current_base_version = trim(file_get_contents($path_to_base_version));

	if($params[0] == 'wrap+soekris') {
		$current_kernel_version = trim(file_get_contents($path_to_wrapsoekris_version));
	} else {
		$current_kernel_version = trim(file_get_contents($path_to_pfsense_version));
	}
	if($params[1] != $current_firmware_version || $params[2] != $current_kernel_version || $params[3] != $current_base_version) {
			$version_mismatch = true;
	}
	if(($version_mismatch == true) and ($return_comments == true)) {
		$comments = file_get_contents($path_to_comments);
		$response = new XML_RPC_Value(array(new XML_RPC_Value($version_mismatch, 'boolean'),
						    new XML_RPC_Value($current_firmware_version, 'string'),
						    new XML_RPC_Value($current_kernel_version, 'string'),
						    new XML_RPC_Value($current_base_version, 'string'),
						    new XML_RPC_Value($comments, 'string')
					     ), 'array'
			    );
	} elseif($version_mismatch == true) {
		$response = new XML_RPC_Value(array(new XML_RPC_Value($version_mismatch, 'boolean'),
						    new XML_RPC_Value($current_firmware_version, 'string'),
						    new XML_RPC_Value($current_kernel_version, 'string'),
                                                    new XML_RPC_Value($current_base_version, 'string')
					     ), 'array'
			    );
	} else {
		$response = new XML_RPC_Value(array(new XML_RPC_Value(false, 'boolean')
					     ), 'array'
			    );
	}
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
