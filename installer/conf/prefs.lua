-- $Id$

-- Default configuration file for general information and parameterization
-- of the BSD Installer.  This configuration file should return a table,
-- with each key set to its own type of value.

--
-- Make an initial guess at the package suffix.  This can be overridden.
--
local package_suffix = "tgz"
if App.os.name == "FreeBSD" then
	package_suffix = "tbz"
end

return {
	--
	-- Name of the install media in use.
	--
	media_name		= "LiveCD",

	--
	-- Whether crashdumps (to a suitable swap partition) will be
	-- enabled upon installation, or not.
	--
	enable_crashdumps	= true,

	--
	-- The filename suffix for package files, apropos to the
	-- current operating system and/or package system in use.
	-- XXX This should be organized better in the future.
	--
	package_suffix = package_suffix,
}