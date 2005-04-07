#!/usr/local/bin/php
<?php
/* $Id$ */
/*
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

$get_firmware_version_doc = 'Check the current firmware and base system versions against the versions provided. This method must be called with two parameters: a string containing the local system\'s firmware version followed by a string containing the system\'s base version. This method will return a string containing the current firmware version, a string containing the current base version, and a string containing any additional data.';
$get_firmware_version_sig = array(array(string, string, string));

function get_firmware_version($raw_params) {
	$current_firmware_version = trim(file_get_contents('../version'));
	$current_base_version = trim(file_get_contents('../base_version'));
	$response = array(new XML_RPC_Value($current_firmware_version, 'string'),
			  new XML_RPC_Value($current_base_version, 'string')); 
	if(($params[0] != $current_firmware_version) or ($params[1] != $current_base_version)) {
		$response[] = new XML_RPC_Value(file_get_contents('../version_comment'), 'string');
	}
	return new XML_RPC_Response($response);
}
	

$server = new XML_RPC_Server(
        array(
	    'pfsense.check_firmware_version' =>	array('function' => 'get_firmware_version',
							'signature' => $get_firmware_version_sig,
							'docstring' => $get_firmware_version_doc)
        )
);
?>
