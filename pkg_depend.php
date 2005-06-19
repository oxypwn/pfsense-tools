#!/usr/bin/env php
<?php

include("xmlparse.inc");
$listtags = array_merge($listtags, array("depend", "onetoone", "queue", "rule", "servernat", "alias", "additional_files_needed", "tab", "template", "menu", "rowhelperfield", "service", "step", "package", "columnitem", "option", "item", "field", "package"));

$pkg_config = parse_xml_config("./pkg_config.xml", "pfsensepkgs");

function pkg_fetch_recursive($pkgname, $filename, $dependlevel = 0, $base_url = 'http://ftp2.freebsd.org/pub/FreeBSD/ports/i
386/packages-5.4-release/Latest', $depends = "") { 
        global $dirname, $fd_log;
	if(!is_dir("./packages/{$dirname}")) mkdir("./packages/{$dirname}");
        $pkg_extension = strrchr($filename, '.');
        $static_output .= "\n" . str_repeat(" ", $dependlevel * 2) . $pkgname . " ";
        $fetchto = "./packages/{$dirname}/" . $pkgname . $pkg_extension;
        if(!file_exists($fetchto)) exec("/usr/bin/fetch -o {$fetchto} {$base_url}/{$filename}");
	if($pkg_extension == ".tbz") {
		$tarflags = "-y";
	} else {
		$tarflags = "-z";
	}
	exec("tar xvj -C ./extmp -f {$fetchto} > /dev/null 2>&1");
	exec("du -hc ./extmp/* | awk '{ print $1 }'", $sizeout);
	exec("rm -rf ./extmp/*");
	$size = array_pop($sizeout);
        exec("/usr/bin/tar --fast-read {$tarflags} -O -f {$fetchto} -x +CONTENTS", $slaveout);
        $workingdir = preg_grep("/instmp/", $slaveout);
        $workingdir = $workingdir[0];
        $raw_depends_list = array_values(preg_grep("/\@pkgdep/", $slaveout));
	if($pkgent['exclude_dependency'] != "")
                        $raw_depends_list = array_values(preg_grep($pkent['exclude_dependency'], PREG_GREP_INVERT));
        if($raw_depends_list != "") {
                foreach($raw_depends_list as $adepend) {
                        $working_depend = explode(" ", $adepend);
                        //$working_depend = explode("-", $working_depend[1]);
                        $depend_filename = $working_depend[1] . $pkg_extension;
			$pkg_depends["depend"][] = pkg_fetch_recursive($working_depend[1], $depend_filename, $dependlevel + 1, $base_url);
		}
        }
	$pkg_depends["size"] = $size;
	return array($filename => $pkg_depends);
}

function reverse_strrchr($haystack, $needle){
	return strrpos($haystack, $needle) ? substr($haystack, 0, strrpos($haystack, $needle) +1 ) : false;
}

foreach($pkg_config['packages']['package'] as $pkg_info) {
	print $pkg_info['name'] . "\n";
	$dirname = $pkg_info['name'];
	$pkg_name = substr(reverse_strrchr($pkg_info['depends_on_package'], "."), 0, -1);
	$depends[$pkg_info['name']] = pkg_fetch_recursive($pkg_name, $pkg_info['depends_on_package'], 0, $pkg_info['depends_on_package_base_url']);
}

print_r($depends);

$fout = fopen("./dependout.cache", "w");
fwrite($fout, serialize($depends));
fclose($fout);

$fout = fopen("./dependout.xml", "w");
fwrite($fout, dump_xml_config($depends, "pkgdepends"));
fclose($fout);
