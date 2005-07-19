
--
--  pfSense after installation routines
--
--  Read in /usr/local/bin/after_installation_routines.sh
--  to an array named  routines.   for through this array
--  and add a command to the cmds object then execute.
--

return {
    id = "pfsense_after_install",
    name = _("pfSense After Installation Routines"),
    effect = function(step)
        local cmds = CmdChain.new()
        local filename = "/usr/local/bin/after_installation_routines.sh"
	local line
        
        for line in io.lines(filename) do
		cmds:set_replacements{
		    line = line,
		    base = App.state.target:get_base()
		}
                cmds:add("${line}")
        end
        
	cmds:execute()
	
        return step:next()

}
