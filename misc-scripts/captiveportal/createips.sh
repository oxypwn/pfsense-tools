#!/usr/local/bin/php

<?php

require("common.php");

echo "Assigning {$ip}{$starting}/24\n";
exec("ifconfig {$nic} {$ip}{$starting}/24");

for($x=$starting+1; $x<$ips; $x++) {
	exec("ifconfig {$nic} {$ip}{$x}/24 alias add");
}

?>
