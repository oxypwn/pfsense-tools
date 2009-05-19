-- $Id: 597_install_kernel.lua,v 1.7 2007/08/02 17:54:49 sullrich Exp $

-- (C)2007 Scott Ullrich
-- All rights reserved.

--
-- Install custom kernel 
--

return {
    id = "install_kernel",
    name = _("Install Kernel"),
    req_state = { "storage" },
    effect = function(step)
	local datasets_list = {}
	
	print("\nInstalling SMP kernel...\n")

	local cmds = CmdChain.new()
	cmds:add("cp /kernels/kernel_SMP.gz /mnt/boot/kernel/kernel.gz")
	cmds:add("echo SMP > /mnt/boot/kernel/pfsense_kernel.txt")
	cmds:execute()

	return step:next()
    end
}
