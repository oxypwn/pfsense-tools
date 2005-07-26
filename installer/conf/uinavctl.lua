-- $Id$

-- This is a configuration file which allows a particular distribution
-- of the BSD Installer to configure its individual user-interface
-- navigation elements in broad fashion, globally.

-- Extra Flow.Steps and Menu.Items can always be added by adding Lua
-- scriptlets to their container directories; however, it is more awkward to
-- delete existing Steps and Items which may be inapplicable in a particular
-- distribution.  So, this file can be used to globally ignore (or otherwise
-- alter the meaning of) individual Steps and Items.

-- This configuration file should return a table.  Each key in this list
-- should be a regular expression which will match the id of the Step or
-- Item; the associated value is a control datum which indicates what do
-- with all Steps and Items so matched.

-- The only supported control datum, at present, is "ignore", indicating
-- that the Step or Item should be skipped; this is, not be executed as
-- part of the Flow, or not be displayed as part of the menu.

-- NOTE!  Ignoring Flow.Steps properly is more problematic than ignoring
-- Menu.Items, because Steps often rely on a change of state caused by a
-- previous Step.  Configure this file (and write your own Steps) with
-- that fact in mind.

return {

	["*/welcome"] = "ignore",		  -- no "welcome" items at all
	
	["*/pit/*load_kernel_modules*"] = "ignore", --do not ask about loading kernel modules
	
	["*/pit/configure_console"] = "ignore",

	--["*/install/format_disk"] = "ignore",	  -- do not do the "Format Disk" step on install

	["*/install/select_packages"] = "ignore", -- do not do the "Select Packages" step on install

	["*/configure/*"] = "ignore", 		  -- do not configure, we've already did it.

	["*/install/confirm_install_os"] = "ignore",

	["*/install/warn_omitted_subpartitions"] = "ignore",

	["*/install/finished"] = "ignore",
	
	["*/install/select_additional_filesystems"] = "ignore", 
	
	["*/configure_installed_system"] = "ignore",
	
	["*/upgrade_installed_system"] = "ignore",
	
	["*/*netboot*"] = "ignore",

--						  -- examples follow:
	
--	["*/install/partition_disk"] = "ignore",  -- Don't show the Partition
--      ["*/install/select_part"] = "ignore",     -- Editor or selection.
--                                                -- Used in combination with
--                                                -- "Format Disk" step in
--                                                -- embedded apps, etc.

}
