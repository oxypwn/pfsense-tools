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
	    id = "install_kernel",
	    name = _("Install Kernel(s)"),
	    short_desc = _(
		"You may now wish to install a custom Kernel configuration. ",
		App.conf.product.name, App.conf.product.name),
	    long_desc = _(
	        "Selecting a custom kernel will help you get the most out of your hardware.  For example most hardware these days comes in multiple cores.  Pick the SMP option if your hardware supports this. ",
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
		cmds:add("cp /kernels/kernel_SMP.gz /mnt/boot/kernel/kernel.gz")
		cmds:add("echo SMP > /mnt/boot/kernel/pfsense_kernel.txt")
		cmds:execute()
	end

	if response.action_id == "Embedded" then
		local cmds = CmdChain.new()
		cmds:add("cp /kernels/kernel_wrap.gz /mnt/boot/kernel/kernel.gz")
		cmds:add("cp /etc/ttys_wrap /mnt/etc/ttys")
		cmds:add("echo wrap > /mnt/boot/kernel/pfsense_kernel.txt")
		-- turn on serial console
		cmds:add("echo -D >> /mnt/boot.config")
		cmds:add("echo console=\"comconsole\" >> /mnt/boot/loader.conf")
		cmds:add("echo \"serial --unit=0 --speed=9600\" > /mnt/boot/grub/menu.lst")
		cmds:add("echo \"terminal serial\" >> /mnt/boot/grub/menu.lst")
		cmds:add("echo \"default=0\" >> /mnt/boot/grub/menu.lst")
		cmds:add("echo \"timeout=5\" >> /mnt/boot/grub/menu.lst")
		cmds:add("echo \"title pfSense\" >> /mnt/boot/grub/menu.lst")
		cmds:add("echo \"       root (hd0,0,a)\" >> /mnt/boot/grub/menu.lst")
		cmds:add("echo \"       kernel /boot/loader\" >> /mnt/boot/grub/menu.lst")
		cmds:execute()
	end

	if response.action_id == "Developers" then
		local cmds = CmdChain.new()
		cmds:add("cp /kernels/kernel_Dev.gz /mnt/boot/kernel/kernel.gz")
		cmds:add("echo Developers > /mnt/boot/kernel/pfsense_kernel.txt")
		cmds:execute()
	end

	return step:next()

    end
}
