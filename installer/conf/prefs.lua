-- $Id$

-- Default configuration file for general information and parameterization
-- of the BSD Installer.  This configuration file should return a table,
-- with each key set to its own type of value.

return {
	--
	-- Name of the install media in use.
	--
	media_name		= "pfSense",

	--
	-- Whether crashdumps (to a suitable swap partition) will be
	-- enabled upon installation, or not.
	--
	enable_crashdumps	= true,
}
