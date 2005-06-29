#!/usr/bin/env php
<?php
/*
	diffgen.php - the pfSense diff update generator
	Colin Smith
	print $pfSense_license;

	This generates unified diffs that should be applied with -p2
*/

$category = "Firmware";

/* get the dates between the last two releases */
exec(
	"cvs -d /cvsroot/ log pfSense/etc/version | grep 'date:' | cut -d ';' -f 1 | head -n 2 | awk '{ print $2, $3 }'",
	$dates
);

/* get the date we'll be passing to cvs rdiff */
$todiff = $dates[1];

/* get the new and old version */
exec(
	"cvs -d /cvsroot/ diff -D '{$dates[1]}' -D '{$dates[0]}' pfSense/etc/version",
	$diffout
);

/* parse cvs diff output */
$newver = trim(array_pop(explode('>', array_shift(preg_grep('/\>/i', $diffout)))));
$oldver = trim(array_pop(explode('<', array_shift(preg_grep('/\</i', $diffout)))));

exec(
	"cvs -d /cvsroot/ rdiff -D {$todiff} pfSense",
	$rdiffout
);

$fout = fopen("./pfSense-Diff-{$category}-Update-{$newver}.txt", "w");
foreach($rdiffout as $line) {
	fwrite($fout, $line . "\n");
}
fclose($fout);

?>
