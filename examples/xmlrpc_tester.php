<?php

/*
 * $Id$
 * pfSense XMLRPC test program.
 * Colin Smith
 * *insert pfSense license etc here*
 */

require_once("xmlrpc_client.inc");
require_once("config.inc");
require_once("functions.inc");
require_once("xmlparse.inc");

$user = 'admin';
$password = 'pfsense';

$protocol = 'http://'; // https is currently not supported.
$address = '192.168.1.2';
$path = '/xmlrpc.php';

$method = 'pfsense.backup_config_section';

$params = array(new XML_RPC_Value($password, 'string'), new XML_RPC_Value('system', 'string'));
$msg = new XML_RPC_Message($method, $params);
print "XML objects made...\n";
$cli = new XML_RPC_Client($path, $protocol . $address);
print "Client opened...\n";
$cli->setDebug(1);
print "Debug bit set...\n";
$cli->setCredentials ($user, $password);
print "Credentials set...\n";
$resp = $cli->send($msg);
print "Message sent.\n";

if (!$resp) {
    echo 'Communication error: ' . $cli->errstr;
    exit;
}

if (!$resp->faultCode()) {
    $val = $resp->value();
    print $val->scalarval();
//    restore_config_section('system', $val->scalarval());
} else {
    /*
     * Display problems that have been gracefully cought and
     * reported by the xmlrpc.php script.
     */
    echo 'Fault Code: ' . $resp->faultCode() . "\n";
    echo 'Fault Reason: ' . $resp->faultString() . "\n";
}
?>


