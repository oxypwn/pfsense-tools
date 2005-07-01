#!/usr/bin/env php
<?php
/*
	diffgen.php - the pfSense diff update generator
	Colin Smith
	print $pfSense_license;

	This generates unified diffs that should be applied with -p1
*/

$category = "Firmware";

/* get the dates between the last two releases */
exec(
	"cvs -d /cvsroot/ log pfSense/etc/version | grep 'date:' | cut -d ';' -f 1 | head -n 2 | awk '{ print $2, $3 }'",
	$dates
);

print_r($dates);
/* get the date we'll be passing to cvs rdiff */
$todiff = $dates[1];

/* get the new and old version
exec(
	"cvs -d /cvsroot/ diff -D '{$dates[1]}' -D '{$dates[0]}' pfSense/etc/version",
	$diffout
);

$newver = trim(array_pop(explode('>', array_shift(preg_grep('/\>/i', $diffout)))));
$oldver = trim(array_pop(explode('<', array_shift(preg_grep('/\</i', $diffout)))));
*/

$newver = `cat pfSense/etc/version`;

exec(
	"cvs -d /cvsroot/ diff -u -D '{$todiff}' pfSense/etc/ 2> /dev/null",
	$rdiffout
);
/*
print_r($rdiffout);
$tostrip = array_keys(preg_grep('/^Index:/', $rdiffout));
print_r($tostrip);
for($i = count($tostrip); $i >= 0; $i--) {
	print $tostrip[$i];
	array_splice($rdiffout, $tostrip[$i], 6);
	print_r($rdiffout);
}
*/
$fout = fopen("./pfSense-Diff-{$category}-Update-{$newver}.txt", "w");
foreach($rdiffout as $line) {
	fwrite($fout, $line . "\n");
}
fclose($fout);

?>
