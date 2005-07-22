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
  while 1 do
        l = c:receive()
        if l == "" then break end
  end  
  while true do
    local s, status = c:receive(2^10)
    if s then
        handle:write(s)
    end
    if not status then break end
    if status == "closed" then break end
    if s then
        count = count + string.len(s)
        calcprog = count / 1000000
        pr:set_amount(calcprog)
        pr:update()
    end
  end
  c:close()
  handle:close()
  -- return the number of bytes read
  pr:stop()
  return count
end



-- Concat the contents of the parameter list,
-- separated by the string delimiter (just like in pertl)
-- example: strjoin(", ", {"Anna", "Bob", "Charlie", "Dolores"})
function strjoin(delimiter, list)
  local len = getn(list)
  if len == 0 then 
    return "" 
  end
  local string = list[1]
  for i = 2, len do 
    string = string .. delimiter .. list[i] 
  end
  return string
end

-- Split text into a list consisting of the strings in text,
-- separated by strings matching delimiter (which may be a pattern). 
-- example: strsplit(",%s*", "Anna, Bob, Charlie,Dolores")
function strsplit(delimiter, text)
  local list = {}
  local pos = 1
  if strfind("", delimiter, 1) then -- this would result in endless loops
    error("delimiter matches empty string!")
  end
  while 1 do
    local first, last = strfind(text, delimiter, pos)
    if first then -- found?
      tinsert(list, strsub(text, pos, first-1))
      pos = last+1
    else
      tinsert(list, strsub(text, pos))
      break
    end
  end
  return list
end

function select_mirror(filename)
        local actions, ni, ifname
        if not tab then tab = {} end
        local ui = tab.ui or App.ui
        local id = tab.id or "select_mirror"
        local name = tab.name or _("Select Mirror")
        local short_desc = tab.short_desc or _(
            "Please select a mirror closest to you."
        )
        actions = {}
        for line in io.lines(outputfile) do
                splititems = strsplit("\t%s*", line)
                table.insert(actions, {
                    id = line,
                    name = ""
                })
        end
        table.insert(actions, {
            id = "cancel",
            name = _("Cancel"),
            accelerator = "ESC"
        })

        ifname = App.ui:present({
            id = id,
            name =  name,
            short_desc = short_desc,
            role = "menu",
            actions = actions
        }).action_id

        if ifname == "cancel" then
                return nil
        else
                return nis:get(ifname)
        end
end

return {
    id = "upgrade_pfsense",
    name = _("Upgrade pfSense"),
    effect = function(step)
	local response = App.ui:present{
	    name = _("Upgrade pfSense?"),
	    short_desc =
	        _("Installation completed.\n\n" ..
                  "Would you like to upgrade pfSense to the latest version?"),
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
                --- download mirrors file
                local host = "www.pfSense.com"
                local file = "mirrors.txt"
		local status = 0
                local outputfile = "/FreeSBIE/mnt/usr/mirrors.txt"
                host = select_mirror("/FreeSBIE/mnt/usr/mirrors.txt")                
                --- lets upgrade pfsense!
                host = "www.pfSense.com"
                file = "/updates/latest.tgz"
		status = 0
                outputfile = "/FreeSBIE/mnt/usr/latest.tgz"
                -- XXX: intergrate progress bar during download.
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
