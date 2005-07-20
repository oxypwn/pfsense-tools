
-- Default configuration file for general information and parameterization
-- of the BSD Installer.  This configuration file should return a table,
-- with each key set to its own type of value.

return {
        --
        -- Name of the install media in use.
        --
        media_name              = "LiveCD",

        --
        -- Whether crashdumps (to a suitable swap partition) will be
        -- enabled upon installation, or not.
        --
        enable_crashdumps       = true,

        --
        -- Whether the user should be warned about the ramifications
        -- of omitting certain mountpoints such as /tmp, /usr, &c.
        --
        warn_omit_subpartitions = false,
}
