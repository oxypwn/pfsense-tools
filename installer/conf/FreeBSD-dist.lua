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

mountpoints = function(part_cap, ram_cap)

        --
        -- First, calculate suggested swap size:
        --
        local swap = 2 * ram_cap
        if ram_cap > (part_cap / 2) or part_cap < 4096 then
                swap = ram_cap
        end
        swap = tostring(swap) .. "M"

        --
        -- Now, based on the capacity of the partition,
        -- return an appropriate list of suggested mountpoints.
        --

        --
        -- FreeBSD: We want to only setup / and swap.
        --

        return {
                { mountpoint = "/",     capstring = "*" },
                { mountpoint = "swap",  capstring = swap },
        }

end

cmd_names = cmd_names + {
	DMESG_BOOT = "var/log/dmesg.boot"
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
        "root",
        "sbin",
        "sys",
        "usr",
        "var"
}

booted_from_install_media=true

dir = { root = "/", tmp = "/tmp/" }

limits.part_min = "100M"

offlimits_devices = { "fd%d+", "md%d+", "cd%d+" }

offlimits_mounts  = { "union" }

use_cpdup = true
