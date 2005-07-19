-- $Id$

-- Default configuration file for suggested mountpoints.
--
-- Note that this file should return a function which takes two
-- numbers (the capacity of the partition and the capacity of
-- RAM, both in megabytes) and should return a list of tables,
-- each like:
--
-- {
--   mountpoint = "/foo",    -- name of mountpoint
--   capstring  = "123M"     -- suggested capacity
-- }
--
-- Note that the capstring can be "*" to indicate 'use the
-- rest of the partition.')
--
-- Typically this function may return a different list of
-- mountpoint descriptions based on the supported capacity of
-- the device.
--
-- As a somewhat special case, this function may return {}
-- (an empty list) to indicate that there simply is not enough
-- space on the device to install anything at all.

return function(part_cap, ram_cap)

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
