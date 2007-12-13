#!/usr/local/bin/php
<?php
require("common.php");

for($x=$starting; $x<$ips; $x++) {
	$handle = tempnam("/tmp", "FOO");
	$post_data = "auth_user=&auth_pass=&redirurl=http%3A%2F%2Fgoogle.com%2F&accept=Continue";
	$address = "{$ip}{$x}";
	echo "Working on $address...\n";
	exec("wget -qO {$handle} --tries 1 --timeout 5 --post-data '{$post_data}' '{$url}' --bind-address {$address}");
	if($sleep_between > 0) 
		sleep($sleep_between);
	unset($handle);
}
?>
