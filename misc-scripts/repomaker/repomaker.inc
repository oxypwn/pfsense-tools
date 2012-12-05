<?php
/*
 * repomaker.inc - helper functions for repomaker.php
 */

function print_usage() {
	print <<<EOD
Usage: repomaker.php [-q] [-v] -n <name> -h <host> [-d <descr>] [-p <dir>] [-m <file>] [-f <file>] [packages...]

  -q		Suppress output.
  -v		Be verbose.
  -n		Set repository name to <name>.
  -h		Set repository host to <host>. This will be used as the default repo URL.
  -d		Set repository description to <descr>.
  -p		Set offline package path to <dir>. This will be checked for packages before fetching.
  -m		Include mirrors listed in <file> (expects pfSense mirrors.txt format).
  -f		Include packages listed in <file>.

EOD;
}

function split_pkg($string) {
	$toks = explode("-", $string);
	$version = array_pop($toks);
	return array(implode("-", $toks), $version);
}

function get_pkg_contents($url) {
	global $flags;
	if(file_exists($flags['pkgdir'] . '/' . basename($url))) {
		/* this is by far the preferred way to fetch package contents */
		exec("tar -j --fast-read -O -f " . $flags['pkgdir'] . '/' . basename($url) . " -x +CONTENTS", $contents);
	} else { 
		/* this doesn't want to stop fetching after reading +CONTENTS */
		exec("fetch -q -o - {$url} | tar -O -f - -x +CONTENTS", $contents);
	}
	return $contents;
}

function get_pkg_depends($url) {
	$contents = get_pkg_contents($url);
	/* this could probably be done more quickly using a foreach and preg_match() */
	$rawdeps = preg_grep('/\@pkgdep/i', $contents);
	if(count($rawdeps)) {
		foreach($rawdeps as $rawdep) {
			$deps[] = trim(array_pop(explode(" ", $rawdep)));
		}
	}
	return $deps;
}

function get_mirrors($filename) {
	$file = file($filename);
	foreach($file as $line) {
		$mirror = preg_split('/\t+/', $line, -1, PREG_SPLIT_NO_EMPTY);
		if($mirror[4] == "enabled") {
			$toreturn[] = array(
						"host" => $mirror[0],
						"url" => $mirror[2]
				);
		}
	}
	return $toreturn;
}

function get_pkg_filesize($url_file) {
	global $flags, $file_size, $ch;
	if(file_exists($flags['pkgdir'] . '/' . basename($url_file))) {
		return filesize($flags['pkgdir'] . '/' . basename($url_file));
	} else {
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url_file);
      		curl_setopt($ch, CURLOPT_HEADERFUNCTION, 'read_header');
      		curl_setopt($ch, CURLOPT_NOBODY, true);
		curl_exec($ch);
		curl_close($ch);
		return $file_size;
	}
}

function read_header($ch, $string) {
        global $file_size, $fout;
        $length = strlen($string);
        ereg("(Content-Length:) (.*)", $string, $regs);
        if($regs[2] <> "") {
                $file_size = intval($regs[2]);
        }
        return $length;
}


function remove_ext($str) {
	return preg_replace('/(.+)\..*$/', '$1', $str);
}

function get_packages($pkglist) {
	$pkgdb = array();
	$packages = array();
	foreach($pkglist as $pkg) {
		$extdeps = array();
		/* load this package's config */
		$pkgconf = parse_xml_config_pkg(trim($pkg), "extension");
		$toput = $pkgconf['info'];
		if(is_array($pkgconf['files']['file'])) {
			foreach($pkgconf['files']['file'] as $depend) {
				/* do we have a package dependency? */
				if($depend['type'] == "package") {
					$extdeps[] = array_shift(split_pkg(remove_ext(basename($depend['location']))));
					$pkgs[] = $depend['location'];
					/* handle base depend as well as any additional deps */
					while($pkg = array_shift($pkgs)) {
						$deps = array();
						$baseurl = dirname($pkg);
						/* hack together the package's true name and version */
						list($pkgname, $pkgver) = split_pkg(remove_ext(basename($pkg)));
						/* do we have a new version? we currently leave only one
						   entry per package - this may or may not be a good thing */
						if(strcmp($pkgver, $pkgdb[$pkgname]['version']) > 0) {
							$pkgdb[$pkgname]['version'] = $pkgver;
							$pkgdb[$pkgname]['size'] = get_pkg_filesize($pkg);
							/* add further package deps if they exist */
							if($rawdeps = get_pkg_depends($pkg)) {
								foreach($rawdeps as $rawdep) {
									$pkgs[] = $baseurl . '/' . $rawdep . ".tbz";
									list($depname, $depver) = split_pkg($rawdep);
									$deps[] = $depname;
								}
							}
							/* toss deps onto pkgdb if needed */
							if(count($deps)) $pkgdb[$pkgname]['depends'] = implode(",", $deps);
						}
					}
				}
			}
		}
		if(count($extdeps)) $toput['pkgdepends'] = implode(",", $extdeps);
		$packages[] = $toput;
	}
	return array($packages, $pkgdb);
}

?>
