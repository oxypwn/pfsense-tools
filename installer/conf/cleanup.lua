-- $Id$

-- Configuration file which names files to remove from the HDD immediately
-- following an installation.  These may be files that are simply unwanted,
-- or may impede the functioning of the system (because they came from the
-- installation system, which may have a different configuration in place.)

--
-- On the DragonFlyBSD LiveCD, /boot/loader.conf contains
--   kernel_options="-C"
-- i.e., boot from CD-ROM.  This is clearly inapplicable to a HDD boot.
--

return {
    "/boot/loader.conf"
}
