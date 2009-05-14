--
-- Copyright (c)2009 Scott Ullrich.  All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
--
-- 1. Redistributions of source code must retain the above copyright
--    notices, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notices, this list of conditions, and the following disclaimer in
--    the documentation and/or other materials provided with the
--    distribution.
-- 3. Neither the names of the copyright holders nor the names of their
--    contributors may be used to endorse or promote products derived
--    from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
-- FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
-- COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
-- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
-- BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
-- LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
-- ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--

-- BEGIN 050_rescue_config.lua --

if not App.conf.booted_from_install_media then
	return nil, "not booted from install media"
end

return {
    id = "rescue_config",
    name = _("Rescue config.xml"),
    short_desc = _("Rescue config.xml from hard device"),
    effect = function()

    local disk1

    local dd = StorageUI.select_disk({
        sd = App.state.storage,
        short_desc = _(
            "Select the disk containing config.xml %s ",
            App.conf.product.name),
        cancel_desc = _("Cancel")
    })
    disk1 = dd:get_name()

    -- Make sure disk 1 was selected
    if not disk1 then
        return Menu.CONTINUE
    end

    local cmds = CmdChain.new()
	   cmds:add("${root}bin/rm -f /tmp/config.cache");
	   cmds:add{
 	   cmdline = "${root}bin/mkdir /tmp/hdrescue ; ${root}sbin/mount ${disk1}s1a /tmp/hdrescue",
 	   replacements = {
	            OS = App.conf.product.name,
	            disk1 = disk1
	          }
	   }
	   cmds:add("${root}etc/rc.reload_all");
	   cmds:add{
 	   cmdline = "${root}sbin/umount ${disk1}s1a /tmp/hdrescue",
 	   replacements = {
	            OS = App.conf.product.name,
	            disk1 = disk1
	          }
	   }

    -- Finally execute the commands to create the gmirror
    if cmds:execute() then
        App.ui:inform(_(
            "The configuration has been rescued.  Please reboot after installation.")
        )
    else
        App.ui:inform(_(
            "config.xml was not rescued due to errors.")
        )
    end

	return Menu.CONTINUE
    end
}


