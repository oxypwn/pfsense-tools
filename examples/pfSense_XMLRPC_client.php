<?php

/*
 * pfSense XMLRPC example: syncing <shaper> with a remote pfSense system over XMLRPC.
 * Colin Smith
 * *insert pfSense license etc here*
 */
require_once("xmlrpc_client.inc"); // Include client classes from our XMLRPC implementation.
require_once("xmlparse_pkg.inc");  // Include pfSense helper functions.
require_once("config.inc");
require_once("functions.inc");

// Define remote server URL, path to xmlrpc.php, etc.
$url = 'soekris.local';
$path = '/xmlrpc.php';
$user = 'admin';
$password = 'pfsense';

// Create XML_RPC_Value objects containing the method to be called and our arguments.
$section = 'shaper';
$section_xml = backup_config_section($section);
$params = array(new XML_RPC_Value($password, 'string'),
		new XML_RPC_Value($section, 'string'),
	  	new XML_RPC_Value($section_xml, 'string'));

// Create the message that we will be sending the XMLRPC server.
$method = 'pfsense.restore_config_section';
$msg = new XML_RPC_Message($method, $params);

// Create a new client object.
// XXX: SSL is *not* supported yet.
$cli = new XML_RPC_Client($path, $url);

// Print out additional debugging information.
// $cli->setDebug(1);

// Use http basic auth.
$cli->setCredentials($user, $password);

// Send our message and get our response.
$resp = $cli->send($msg);
if($resp) print "Configuration restored on remote system.\n";

/* Uncomment for more debugging.
if (!$resp) {
    echo 'Communication error: ' . $cli->errstr;
    exit;
}

if ($resp->faultCode()) {
    echo 'Fault Code: ' . $resp->faultCode() . "\n";
    echo 'Fault Reason: ' . $resp->faultString() . "\n";
}
*/

// Call filter_configure() after we change the section.
$msg = new XML_RPC_Message('pfsense.filter_configure', array(new XML_RPC_Value($password, 'string')));
$resp = $cli->send($msg);
if($resp) print "filter_configure() run on remote system.\n";
