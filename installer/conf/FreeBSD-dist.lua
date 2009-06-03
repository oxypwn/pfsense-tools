--
-- conf/FreeBSD.lua
-- $Id$
--
-- This file contains FreeBSD-specific overrides to BSDInstaller.lua.
--

product = {
	name = "FreeBSD",
	version = "8.0-CURRENT"
}

install_items = {
        "boot",
        "COPYRIGHT",
        "bin",
        "dev",
        "etc",
		"kernels",
        "libexec",
        "lib",
        "media",
        "root",
		"rescue",
        "sbin",
        "sys",
        "usr",
        "var"
}

cmd_names = cmd_names + {
	DISKLABEL = "sbin/bsdlabel",
	CPDUP = "usr/local/bin/cpdup -vvv -I",
	DHCPD = "usr/local/sbin/dhcpd",
	RPCBIND = "usr/sbin/rpcbind",
	MOUNTD = "usr/sbin/mountd",
	NFSD = "usr/sbin/nfsd",
	MODULES_DIR = "boot/kernel",
	DMESG_BOOT = "var/log/dmesg.boot"
}

sysids = {
	{ "FreeBSD",		165 },
	{ "OpenBSD",		166 },
	{ "NetBSD",		169 },
	{ "MS-DOS",		 15 },
	{ "Linux",		131 },
	{ "Plan9",		 57 }
}

default_sysid = 165
package_suffix = "tbz"
num_subpartitions = 8
has_raw_devices = false
disklabel_on_disk = false
has_softupdates = true
window_subpartitions = { "c" }
use_cpdup = true

--
-- Offlimits mount points.  BSDInstaller will ignore these mount points
--
-- example: offlimits_mounts  = { "unionfs" }
offlimits_mounts  = { "union" }

booted_from_install_media=true

dir = { root = "/", tmp = "/tmp/" }

limits.part_min = "100M"

offlimits_devices = { "fd%d+", "md%d+", "cd%d+" }
