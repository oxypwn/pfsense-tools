-- $Id: 050_welcome.lua,v 1.10 2005/08/26 04:25:25 cpressey Exp $

--
-- Confirmation message
--

return {
    id = "centipede_confirm_basic",
    name = _("Confirmation Message"),
    effect = function(step)

	if App.state.is_basic then
		if App.ui:confirm(_(
			"WARNING: This will erase all contents in your first hard disk! "	..
			"This action is irreversible. Do you really want to continue?\n\n"	..
			"If you wish to have more control on your setup, "			..
			"choose Advanced Installation from the Main Menu."
		)) then
			os.execute("/sbin/kldload splash_bmp")
			os.execute("(/usr/sbin/vidcontrol -t 1 -s 1 < /dev/ttyv0) && /bin/sleep 3")
			return step:next()
		else
			return step:prev()
		end
	else
		return step:next()
	end

    end
}
