<?php

//  Debug mode?
$debug = false;

// Interface that captive portal tests will be occuring on
$nic = "em1";

// Number of IP addresses to add.
$ips = "250";

// IP address of aliases that are going to be added (testing client ips)
$ip = "192.168.1.";

// IP to start requests from
$starting = "3";

// URL of captive portal management
$url = "http://192.168.1.1:8000";

// Number of iterations to run before exiting test script
$iterations = "5";

// Sleep time between iterations
$sleep_between_iterations = "0";

// Number of wget retries if failure
$tries = "1"; // wget tries
$timeout = "4"; // wget timeout 

// Sleep between captive portal requests
//$sleep_between = "30";

// Post data used to auth w/ captive portal
$post_data = "auth_user=&auth_pass=&redirurl=http%3A%2F%2Fgoogle.com%2F&accept=Continue";

?>