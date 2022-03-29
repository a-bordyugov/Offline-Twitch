local mod = get_mod("offline_twitch")

--[[
    Pausing Twitch while VMF menu is open
    #########################
--]]
mod:hook_safe(IngameUI, "handle_transition", function(self, new_transition)
    if (new_transition == "vmf_options_view_open") then
        TW_Tweaker._is_tw_paused = true
    elseif (new_transition == "vmf_options_view_close") then
        TW_Tweaker._is_tw_paused = false
    end
end)
