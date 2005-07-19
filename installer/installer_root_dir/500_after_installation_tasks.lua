
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
                -- success!  we should output a bunch
                --           of instructions here via a input box
                --           telling them to surf into 192.168.1.1
                --           with a username of root and password
                --           of pfsense
                --
        end
}
