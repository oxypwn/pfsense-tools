#!/usr/local/bin/php
<?php

require("common.php");

for($y=$iterations; $y<$iterations; $y++) {
	for($x=$starting; $x<$ips; $x++) {
		$handle = tempnam("/tmp", "FOO");
		$address = "{$ip}{$x}";
		echo "Working on $address...\n";
		exec("wget -qO {$handle} --tries {$tries} --timeout ${timeout} --post-data '{$post_data}' '{$url}' --bind-address {$address}");
		if($sleep_between > 0) 
			sleep($sleep_between);
		unset($handle);
	}
	if($sleep_between_iterations>0) 
		sleep($sleep_between_iterations);
}

?>
