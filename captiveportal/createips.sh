#!/usr/local/bin/php

<?php

require("common.php");

exec("ifconfig em1 192.168.1.2/24");

for($x=$starting; $x<$ips; $x++) {
	exec("ifconfig em1 192.168.1.{$x} alias add");
}

?>
