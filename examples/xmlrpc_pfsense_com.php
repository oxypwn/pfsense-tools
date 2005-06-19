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
require_once("xmlparse.inc");
require_once("xmlrpc.inc");

//$get_firmware_version_sig = array(array(array(), array()));
$get_firmware_version_doc = 'Method used to get the current firmware, kernel, and base system versions. This must be called with an array. This method returns an array.';

function get_firmware_version($raw_params) {
	// Variables.
	$path_to_files = './xmlrpc/';
	$toreturn = array();
	$working = array();
	$toparse = array();
	$params = array_shift(xmlrpc_params_to_php($raw_params));
	
	// Categories to update
	$categories = array(
				'firmware',
				'kernel',
				'base'
			);

	// Branches to track
	$branches = array(
				'stable' => array('stable'),
				'beta' => array('stable', 'beta')
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
		if(isset($versions[$key])) { // Filter out other params like "platform"
			$toreturn[$key] = 1;
			$versions[$key] = parse_xml_config($path_to_files . $versions[$key], "pfsenseupdates");
			$versions[$key] = $versions[$key][$key];
			if(is_array($versions[$key])) { // If we successfully parsed the XML, start processing versions
				if(!stristr($params[$key]['version'], $versions[$key][count($versions[$key]) - 1]['version'])) {
					for($i = 0; $i < count($versions[$key]); $i++) {
						if(stristr($params[$key]['version'], $versions[$key][$i]['version']) != "") {
							$toreturn[$key] = array_slice($versions[$key], $i + 1);
							foreach($toreturn[$key] as $aindex => $akey)
								if(array_key_exists('full', $akey))
									$toreturn[$key] = array_slice($versions[$key], $aindex + 1);
						}
					}
					if(!is_array($toreturn[$key][0]))
						$toreturn[$key] = $versions[$key];
				} else {
					$toreturn[$key] = true;
				}
			}
		}
	}

	// Now that we have our base array, process branches.
	foreach($toreturn as $key => $val) {
		if($params[$key]['branch'] != "") {
			$toparse = array();
			foreach($val as $aval) {
				$branch = $params[$key]['branch'];
				$branch = $branches[$branch];
				if(in_array($aval['branch'], $branch)) $toparse[] = $aval;
			}
			$toreturn[$key] = $toparse;
			if(!is_array($toreturn[$key][0])) $toreturn[$key] = true;
		}
	}

	$response = php_value_to_xmlrpc($toreturn);
	return new XML_RPC_Response($response);
}

function get_pkgs($raw_params) {
	$path_to_files = '../packages/';
	$pkg_rootobj = 'pfsensepkgs';
	$apkgs = array();
	$toreturn = array();
	
	$params = array_shift(xmlrpc_params_to_php($raw_params));

	$pkg_config = parse_xml_config($path_to_files . 'pkg_config.xml', $pkg_rootobj);
	if($params['pkg'] != 'all') {
		foreach($pkg_config['packages']['package'] as $pkg) {
			if(in_array($pkg['name'], $params['pkg']))
				$apkgs[$pkg['name']] = $pkg;
		}
	} else {
		foreach($pkg_config['packages']['package'] as $key => $pkg) {
			$apkgs[$pkg['name']] = $pkg;
		}
	}
	if($params['info'] != 'all') {
		foreach($apkgs as $pkgname => $pkg) {
			foreach($pkg as $pkgkey => $pkgent) {
				if(in_array($pkgkey, $params['info'])) $toreturn[$pkgname][$pkgkey] = $pkgent;
			}
		}
		$response = php_value_to_xmlrpc($toreturn);
	} else {
		$response = php_value_to_xmlrpc($apkgs);
	}
	return new XML_RPC_Response($response);
}

function get_pkg_sizes($raw_params) {
	$path_to_files = '../packages/';
	$cache_name = 'pkg_depends.cache';
	$params = array_shift(xmlrpc_params_to_php($raw_params));
	$sizes = unserialize(file_get_contents($path_to_files . $cache_name));
	if($params['pkg'] != 'all') {
		foreach($sizes as $pkg => $sizes) {
			if(in_array($pkg, $params['pkg'])) {
				$toreturn[$pkg] = $sizes;
			}
		}
		return new XML_RPC_Response(php_value_to_xmlrpc($toreturn));
	} else {
		return new XML_RPC_Response(php_value_to_xmlrpc($sizes));
	}
	return new XML_RPC_Response(new XML_RPC_Value('error', 'string'));
}

$server = new XML_RPC_Server(
        array(
	    'pfsense.get_firmware_version' =>	array('function' => 'get_firmware_version'),
	    'pfsense.get_pkgs'		   =>   array('function' => 'get_pkgs'),
	    'pfsense.get_pkg_sizes'	   =>   array('function' => 'get_pkg_sizes')
        )
);
?>
