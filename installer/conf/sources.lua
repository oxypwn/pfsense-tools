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

return {
    install = {
        "COPYRIGHT",
        "bin",
        "conf",
        "conf.default"
        "boot",
        "cdrom",
        "dev",
        "etc",
        "libexec",
        "lib",
        "kernel",
        "modules",
        "root",
        "sbin",
        "sys",
        "tmp",
        "usr/bin",
        "usr/games",
        "usr/include",
        "usr/lib",
        "usr/local",    -- No need to copy these two, since we use mtree to
        "usr/libdata",
        "usr/libexec",
        "usr/obj",
        "usr/sbin",
        "usr/share",
        "usr/src",
        "var"
    },
    upgrade = {
        "COPYRIGHT",
        "bin",
        "boot/beastie.4th",             -- unfortunately, we need to list
        "boot/boot",                    -- everything in boot except for
        "boot/boot0",                   -- the .conf files, so that we
        "boot/boot1",                   -- don't end up overwriting them
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
        "libexec",
        "lib",
        "kernel",
        "modules",
        "sbin",
        "sys",
        "usr/bin",
        "usr/games",
        "usr/local",
        "usr/include",
        "usr/lib",
        "usr/libdata",
        "usr/libexec",
        "usr/sbin",
        "usr/share"
    }
}
