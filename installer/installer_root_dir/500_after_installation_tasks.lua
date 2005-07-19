
--
--  pfSense after installation routines
--
--  Read in /usr/local/bin/after_installation_routines.sh
--  to an array named  routines.   for through this array
--  and add a command to the cmds object then execute.
--

return {
        cmds = CmdChain.new()
        filename = "/usr/local/bin/after_installation_routines.sh";
        mode = "r"
        
        io.open (filename [, mode])
        routines = io.read("*all")         -- read the whole file
        io.close
        
        for spd in routines do
                cmds:add("${spd}")
        end
        
        if cmds:execute() then
                --
                -- success!  
                --
                App.ui:inform(
                    _("pfSense has been installed successfully!" ..
                      "After the reboot surf into 192.168.1.1 " ..
                      "with the username admin and the password " ..
                      "pfsense."))
        end

}
