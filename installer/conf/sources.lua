-- $Id$

--
-- Default configuration file for source objects (files and directories)
-- to copy to the HDD during the install.
--
-- Note that this conf file should return a table with two keys, "install"
-- and "upgrade" - each of which is an array of strings.  Each string
-- is a filename or directory name, without any leading root directory
-- specified.  For "install", these files will be copied to the HDD during
-- install, and for "upgrade", they will be copied over as part of upgrade.
--
-- Note that if you (for example) want copy all of /usr/local/ except for
-- /usr/local/share, you will need to specify all subdirs of /usr/local
-- except for /usr/local/share, in the array.
--

-- $Id$

--
-- Default configuration file for source objects (files and directories)
-- to copy to the HDD during the install.
--
-- Note that this conf file should return a table with two keys, "install"
-- and "upgrade" - each of which is a table of elements to copy.  Each
-- element represents a filename or directory name.  It can be either
--   o  a string, in which case the source has the same name as the dest, or
--   o  a table, with "src" and "dest" keys, so that the names may differ.
-- (A table is particularly useful with /etc, which may have configuration
-- files which produce significantly different behaviour on the install
-- medium, compared to a standard HDD boot.)
--
-- Either way, no leading root directory is specified in names of files
-- and directories.
--
-- The files in the "install" table will be copied to the HDD during install,
-- while those in "upgrade" will be copied over as part of upgrade.
--
-- Note that specifying (for example) "usr/local" will only copy all of
-- /usr/local *if* nothing below /usr/local is specified.  For instance,
-- if you want copy all of /usr/local/ *except* for /usr/local/share,
-- you need to specify all subdirs of /usr/local except for /usr/local/share
-- in the table.
--

return {
    install = {
	"boot",
	"COPYRIGHT",
	"bin",
        "conf",
        "conf.default",
	"cdrom",
	"dev",
	"etc",
	{ src = "etc.hdd", dest = "etc" },  -- install media config differs
	"libexec",
	"lib",
	"kernel",
	"modules",
	"root",
	"rescue",
	"sbin",
	"sys",
	"usr/bin",
	"usr/games",
	"usr/include",
	"usr/lib",
	"usr/local",
	"usr/libdata",
	"usr/libexec",
	"usr/sbin",
	"usr/share",
	"usr/src",
	"var"
    },
    upgrade = {
	"COPYRIGHT",
	"bin",
	"boot/beastie.4th",		-- unfortunately, we need to list
	"boot/boot",			-- everything in boot except for
	"boot/boot0",			-- the .conf files, so that we
	"boot/boot1",			-- don't end up overwriting them
	"boot/boot2",
	"boot/cdboot",
	"boot/defaults",
	"boot/frames.4th",
	"boot/loader",
	"boot/loader.4th",
	"boot/loader.help",
	"boot/loader.old",
	"boot/loader.rc",
	"boot/mbr",
	"boot/pxeboot",
	"boot/screen.4th",
	"boot/support.4th",
	"dev",
	{ src = "etc.hdd/mail",     dest = "etc/mail" }, -- icky.
	"libexec",
	"lib",
	"kernel",
	"modules",
	"sbin",
	"sys",
	"usr/bin",
	"usr/games",
	"usr/include",
	"usr/lib",
	"usr/libdata",
	"usr/libexec",
	"usr/sbin",
	"usr/share"
    }
}
