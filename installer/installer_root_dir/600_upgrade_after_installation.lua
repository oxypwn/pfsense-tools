--
-- lua download routines.  download the files.
--
require "socket"
function download (host, file, outputfile)
  local c = socket.connect(host, 80)
  if not c then
    return
  end
  local count = 0    -- counts number of bytes read
  c:send("GET " .. file .. " HTTP/1.0\r\n\r\n")
  io.open (outputfile, "w")
  while true do
    local s, status = receive(c)
    count = count + string.len(s)
    if status == "closed" then break end
    io.write(s)
  end
  c:close()
  io.close()
  return 1
end

return {
    id = "upgrade_pfsense",
    name = _("Upgrade pfSense"),
    effect = function(step)
	local response = App.ui:present{
	    name = _("Upgrade pfSense?"),
	    short_desc =
	        _("Would you like to upgrade pfSense to the latest version? "),
	    actions = {
		{
		    id = "ok",
		    name = _("Upgrade pfSense")
		},
		{
		    id = "cancel",
		    accelerator = "ESC",
		    name = _("No thanks")
		}
	    }
	}
	if response.action_id == "ok" then
                --- lets upgrade pfsense!
                local host = "http://www.pfSense.com"
                local file = "/updates/latest.tgz"
		local status = 0
                -- XXX: how do we output a notice .. Downloading... Bleh.
                outputfile = "/mnt/tmp/latest.tgz"
                status = download(host, file, outputfile)
		if not status then
		    App.ui:inform(
			_("There was an error connecting to the pfSense update site." ...
			  "Please upgrade pfSense manually from the webConfigurator"))
		    return step:next()
		end
                cmds = CmdChain.new()
                cmds:add("tar xzpf /mnt/tmp/latest.tgz -U -C /mnt/")
                -- XXX: how do we output a notice "Extracing update..."
                cms:execute()
        end        
	-- success!
	App.ui:inform(
	    _("pfSense has been installed successfully!" ..
	      "After the reboot surf into 192.168.1.1 " ..
	      "with the username admin and the password " ..
	      "pfsense."))
        return step:next()
    end
}
