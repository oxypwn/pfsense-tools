--
-- pfSense lua download routines.
--
require "socket"

ip = socket.dns.toip("www.pfsense.com")
if not ip then
    return
end

function download (host, file, outputfile)
  local c = socket.connect(host, 80)
  local pr
  local calcprog = 1
  if not c then
    -- error connecting to target
    -- lets return nil
    return
  end
  pr = App.ui:new_progress_bar{
      title = _("Downloading Updates...")
  }
  pr:start()  
  local count = 0    -- counts number of bytes read
  c:send("GET " .. file .. " HTTP/1.0\r\n\r\n")
  handle = io.open(outputfile, "wb")
  while true do
    local s, status = receive(c)
    handle:write(s)
    if status == "closed" then break end
    count = count + string.len(s)
    calcprog = count / 1000000
    pr:set_amount(calcprog)
    pr:update()    
  end
  c:close()
  handle:close()
  -- return the number of bytes read
  pr:stop()
  return count
end

function receive (connection)
	return connection:receive(2^10)
end

return {
    id = "upgrade_pfsense",
    name = _("Upgrade pfSense"),
    effect = function(step)
	local response = App.ui:present{
	    name = _("Upgrade pfSense?"),
	    short_desc =
	        _("Would you like to upgrade pfSense to the latest version?  The system will pause while downloading the updates."),
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
                local host = "www.pfSense.com"
                local file = "/updates/latest.tgz"
		local status = 0
                -- XXX: intergrate progress bar during download.
                local outputfile = "/FreeSBIE/mnt/usr/latest.tgz"
                status = download(host, file, outputfile)
		if not status then
		    App.ui:inform(
			_("There was an error connecting to the pfSense update site." ..
			  "Please upgrade pfSense manually from the webConfigurator"))
		    return step:next()
		end
		file = "/updates/latest.tgz.md5"
		outputfile = "/FreeSBIE/mnt/usr/latest.tgz.md5"
		status = download(host, file, outputfile)
		if not status then
		    App.ui:inform(
			_("There was an error connecting to the pfSense update site." ..
			  "Please upgrade pfSense manually from the webConfigurator"))
		    return step:next()
		end
		-- XXX: Verify MD5 before proceeding
                cmds = CmdChain.new()
                cmds:add("tar xzpf /FreeSBIE/mnt/usr/latest.tgz -U -C /FreeSBIE/mnt/")
                -- XXX: integrate progress bar somehow for execute command
                cmds:execute()
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
