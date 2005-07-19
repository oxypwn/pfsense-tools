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
                host = "http://www.pfSense.com"
                file = "/updates/latest.tgz"
                -- XXX: how do we output a notice .. Downloading... Bleh.
                outputfile = "/mnt/tmp/latest.tgz"
                download(host, file, outputfile)
                cmds = CmdChain.new()
                cmds:add("tar xzpf /mnt/tmp/latest.tgz -U -C /mnt/")
                -- XXX: how do we output a notice "Extracing update..."
                cms:execute()
        end

        --- lua download routines.  download the files.

        function download (host, file, outputfile)
          local c = assert(socket.connect(host, 80))
          local count = 0    -- counts number of bytes read
          c:send("GET " .. file .. " HTTP/1.0\r\n\r\n")
          mode = "w"
          io.open (outputfile [, mode])
          while true do
            local s, status = receive(c)
            count = count + string.len(s)
            if status == "closed" then break end
            io.write(s)
          end
          c:close()
          io.close
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

        return step:next()

}
