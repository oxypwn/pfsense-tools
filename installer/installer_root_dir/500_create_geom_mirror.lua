-- $Id$

if App.conf.os.name == "FreeBSD" then
        --
        -- FreeBSD specific module GEOM/GMirror
        --
        -- If more than two disks are detected, ask if the user wishes
        -- to setup a GEOM/GMirror volume.  The volume will then appear
        -- in the future select disk step.
        --
        if App.state.storage:get_disk_count() > 1 then

                return {
                           id = "setup_gmirror",
                           name = _("Setup GEOM Mirror"),
                           req_state = { "storage" },
                           effect = function(step)

                       -- Ask if user wnats a GEOM mirror to be created
                       local response = App.ui:present{
                           name = _("GEOM Mirror"),
                           short_desc = _("Would you like to setup a GEOM mirror? "),
                                   actions = {
                                       {
                                           id = "ok",
                                           name = _("Yes, setup a GEOM mirror")
                                       },
                                       {
                                           id = "cancel",
                                           accelerator = "ESC",
                                           name = _("No thanks")
                                       }
                           }
                       }

                       if response.action_id ~= "ok" then
                               return Menu.CONTINUE
                       end

                       local DISK1
                       local DISK2

                       -- XXX: switch to a while loop and allow user to add more than 2 disks
                       local dd = StorageUI.select_disk({
                           sd = App.state.storage,
                           short_desc = _(
                               "Select the primary disk %s ",
                               App.conf.product.name),
                           cancel_desc = _("Cancel")
                       })
                       DISK1 = dd:get_name()

                       -- XXX: switch to a while loop and allow user to add more than 2 disks
                       local dd = StorageUI.select_disk({
                           sd = App.state.storage,
                           short_desc = _(
                               "Select the disk on which the mirror of %s ",
                               App.conf.product.name),
                           cancel_desc = _("Cancel")
                       })
                       DISK2 = dd:get_name()

                       -- Make sure disk 1 was selected
                       if not DISK1 then
                               return Menu.CONTINUE
                       end

                       -- Make sure disk 2 was selected
                       if not DISK2 then
                               return Menu.CONTINUE
                       end

                       if DISK1 == DISK2 then
                               App.ui:inform(_(
                                   "You need two unique disks to create a GEOM MIRROR.")
                               )
                               return Menu.CONTINUE
                       end

                       local cmds = CmdChain.new()
                       -- XXX: switch to a while loop and allow user to add more than 2 disks
                           cmds:add{
                           cmdline = "/sbin/gmirror label -v -b split ${OS}Mirror ${DISK1} ${DISK2}",
                           replacements = {
                                            OS = App.conf.product.name,
                                            DISK1 = DISK1,
                                            DISK2 = DISK2
                                      }
                           }

                       -- Finally execute the commands to create the gmirror
                       if cmds:execute() then
                               App.ui:inform(_(
                                   "The GEOM mirror has been created with no errors.  " ..
                                   "The mirror disk will now appear in the select disk step.")
                               )
                               -- Survey disks again, they have changed.
                               App.state.storage:survey()
                       else
                               App.ui:inform(_(
                                   "The GEOM mirror was NOT created due to errors.")
                               )
                       end

                       return Menu.CONTINUE

                   end

                }

        end -- end of device > 1 check

end -- end of FreeBSD check


