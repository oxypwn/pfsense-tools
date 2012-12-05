#!/usr/local/bin/php
<?php

require("common.php");

for($y=$iterations; $y>0; $y--) {
	for($x=$starting; $x<$ips; $x++) {
		// Grab a temporary file handle
		if(!$fastmode)
			$handle = tempnam("/tmp", "FOO");
		// Setup the IP address for this request
		$address = "{$ip}{$x}";
		// Login to the captive portal
		echo "Working on $address ($handle)\n";
		if($fastmode)
			exec("wget -q -O /dev/null --tries {$tries} --timeout {$timeout} --post-data '{$post_data}' '{$url}' --bind-address {$address} &");
		else
			exec("wget -q -O {$handle} --tries {$tries} --timeout {$timeout} --post-data '{$post_data}' '{$url}' --bind-address {$address}");
		// Grab the logout_id after we auth
		if($sleep_between > 0) 
			sleep($sleep_between);
		// Clean up
		if($debug) 
			exec("cat {$handle}\n");
		if(!$fastmode)
			unset($handle);
	}
	if($sleep_between_iterations>0) 
		sleep($sleep_between_iterations);
}

?>
