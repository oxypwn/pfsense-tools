<?php

function time_left($integer)
{ /* Returns a string of the amount of time the integer (in seconds) refers to. 

$timeleft=time_left(86400); 
$timeleft='1 day'. 

Will not return anything higher than weeks. False if $integer=0 or fails. 
*/

$seconds=$integer; 
if ($seconds/60 >=1) 
	{ 
	$minutes=floor($seconds/60); 
	if ($minutes/60 >= 1) 
		{ # Hours 
		$hours=floor($minutes/60); 
		if ($hours/24 >= 1) 
			{ #days 
			$days=floor($hours/24); 
			if ($days/7 >=1) 
				{ #weeks 
				$weeks=floor($days/7); 
				if ($weeks>=2) $return="$weeks Weeks"; 
				else $return="$weeks Week"; 
				} #end of weeks 
			$days=$days-(floor($days/7))*7; 
			if ($weeks>=1 && $days >=1) $return="$return, "; 
			if ($days >=2) $return="$return $days days";
			if ($days ==1) $return="$return $days day";
			} #end of days
		$hours=$hours-(floor($hours/24))*24; 
		if ($days>=1 && $hours >=1) $return="$return, "; 
		if ($hours >=2) $return="$return $hours hours";
		if ($hours ==1) $return="$return $hours hour";
		} #end of Hours
	$minutes=$minutes-(floor($minutes/60))*60; 
	if ($hours>=1 && $minutes >=1) $return="$return, "; 
	if ($minutes >=2) $return="$return $minutes minutes";
	if ($minutes ==1) $return="$return $minutes minute";
	} #end of minutes 
$seconds=$integer-(floor($integer/60))*60; 
if ($minutes>=1 && $seconds >=1) $return="$return, "; 
if ($seconds >=2) $return="$return $seconds seconds";
if ($seconds ==1) $return="$return $seconds second";
$return="$return."; 
return $return; 
}

$mirrors = file('mirrors.txt');
$stampfile = "tracker-timestamp";
$now = time();
$i = 0;

print "<table border=1>\n";
foreach ($mirrors as $line_num => $line) {
	print "<tr>\n";	
	if( $i > 0 ) {
		$mirror =  preg_split("/\t/", $line, -1, PREG_SPLIT_NO_EMPTY);
		$mirror_status = $mirror[4];

		if ("$mirror_status" == "enabled") {

			$mirror_url = $mirror[2];
			$mirror_contact = $mirror[3];

			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, "{$mirror_url}/{$stampfile}");
			curl_setopt($ch, CURLOPT_HEADER, 0);
			curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
			curl_setopt($ch, CURLOPT_TIMEOUT, 4);
			$mirror_timestamp = curl_exec($ch);
			curl_close($ch);

			$update = "";
			$timediff = "";
			$difference = "";
			$ts = "";

			if($mirror_timestamp == "") {
				$bgcolor = "bgcolor=coral";
			} else {
				$ts = split(" ", $mirror_timestamp);

				$update = strtotime("$ts[0] $ts[1] $ts[2] $ts[3] $ts[5] $ts[4]");
				$bgcolor = "bgcolor=lightgreen";

				$difference = $now - $update;
				$timediff = time_left($difference);

				if($difference > 86400) $bgcolor = "bgcolor=coral";
				if($difference < 86400) $bgcolor = "bgcolor=khaki";
				if($difference < 28800) $bgcolor = "bgcolor=lightgreen";
			}

			print "<td>{$line_num}</td>\n";
			print "<td><a href=\"$mirror_url/$stampfile\">$mirror_url/$stampfile</a></td>\n";
			print "<td><a mailto=". htmlspecialchars($mirror_contact) ." >". htmlspecialchars($mirror_contact) ."</a></td>\n";
			print "<td $bgcolor >". htmlspecialchars($timediff) ."</td>\n";
		}
	} else {
		print "<td>Number</td><td>URL</td><td>Contact</td><td>Status</td>\n";
	}
	$i++;
	print "</tr>\n";	
}
print "</table>\n";

?>
