--
-- conf/pfSense.lua
-- $Id$
--
-- This file contains pfSense-specific overrides to BSDInstaller.lua.
--

product = {
	name = "pfSense",
	version = "0.83.whatever"
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
        -- pfSense: We want to only setup / and swap.
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
        "conf",
        "conf.default",
        "dev",
        "etc",
        "libexec",
        "lib",
--        "kernel",
--        "modules",
        "root",
--        "rescue",
        "sbin",
        "sys",
        "usr",
        "var"
}

ui_nav_control = {
	["*/welcome"] = "ignore",                 -- do not show any "welcome" items

	["*/configure_installed_system"] = "ignore", -- don't put these on
	["*/upgrade_installed_system"] = "ignore",   -- the main menu...
	["*/*netboot*"] = "ignore",

	["*/load_kernel_modules"] = "ignore", -- do not ask about loading kernel modules
	["*/pit/configure_console"] = "ignore",   -- do not ask about console
	["*/pit/configure_network"] = "ignore",   -- do not ask about network

	["*/install/format_disk"] = "ignore",     -- do not do the "Format Disk" step on install
	["*/install/select_packages"] = "ignore", -- do not do the "Select Packages" step on install
	["*/install/confirm_install_os"] = "ignore",
	["*/install/warn_omitted_subpartitions"] = "ignore",
	["*/install/finished"] = "ignore",
	["*/install/select_additional_filesystems"] = "ignore", 

	["*/configure/*"] = "ignore",             -- do not configure, we've already did it.
}

booted_from_install_media=true

dir = { root = "/FreeSBIE/", tmp = "/tmp/" }

use_cpdup = true
