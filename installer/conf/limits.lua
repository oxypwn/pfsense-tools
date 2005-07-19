-- $Id$

-- Default configuration file for limiting values specified by
-- the installation.

-- Most significant among these is the minimum disk space required
-- to install the software.

return {
	part_min =	  "300M",	-- Minimum size of partition or disk.
	subpart_min = {
	    ["/"]	=  "70M",	-- Minimum size of each subpartition.
	    ["/var"]	=   "8M",	-- If a subpartition has no particular
	    ["/usr"]	= "174M"	-- minimum, it can be omitted here.
	},
	waste_max	=   8192	-- Maximum number of sectors to allow
					-- to go to waste when carving out
					-- partitions and subpartitions.
}
