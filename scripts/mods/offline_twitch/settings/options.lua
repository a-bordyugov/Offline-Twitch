local mod = get_mod("offline_twitch")

--[[
    It's can be changed only from VMF menu
    #########################
--]]
mod:hook_safe(OptionsView, "apply_changes", function(self)
    TW_Tweaker:game_update_settings("tw_settings")
    mod:echo(mod:localize("settings_undone"))
end)