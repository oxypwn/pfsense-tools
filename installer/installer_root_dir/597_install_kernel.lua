-- $Id$

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
	
	local response = App.ui:present({
	    id = "install_bootstrap",
	    name = _("Install Bootblock(s)"),
	    short_desc = _(
		"You may now wish to install a custom Kernel configuration. ",
		App.conf.product.name, App.conf.product.name),
	    long_desc = _(
	        " ",
		App.conf.product.name
	    ),
	    special = "bsdinstaller_install_kernel",

	    actions = {
		{
		    id = "Default",
			accelerator = "ESC",
		    name = _("Uniprocessor kernel (one processor)")
		},
		{
		    id = "SMP",
		    name = _("Symmetric multiprocessing kernel (more than one processor)")
		},
		{
		    id = "Embedded",
		    name = _("Embedded kernel (no vga console, keyboard")
		},
		{
		    id = "Developers",
		    name = _("Developers kernel (includes GDB, etc)")
		}
	    },

	    datasets = datasets_list,
	    multiple = "true",
	    extensible = "false"
	})

	if response.action_id == "SMP" then
		local cmds = CmdChain.new()
		cmds:add("cp /mnt/boot/kernel/kernel_SMP.gz /boot/kernel/kernel.gz")
		cmds:add("echo SMP > /mnt/boot/kernel/pfsense_kernel.txt")
		cmds:execute()
	end

	if response.action_id == "Embedded" then
		local cmds = CmdChain.new()
		cmds:add("cp /mnt/boot/kernel/kernel_wrap.gz /boot/kernel/kernel.gz")
		cmds:add("echo wrap > /mnt/boot/kernel/pfsense_kernel.txt")
		cmds:execute()
	end

	if response.action_id == "Developers" then
		local cmds = CmdChain.new()
		cmds:add("cp /mnt/boot/kernel/kernel_Dev.gz /boot/kernel/kernel.gz")
		cmds:add("echo Developers > /mnt/boot/kernel/pfsense_kernel.txt")
		cmds:execute()
	end

	return step:next()

    end
}
