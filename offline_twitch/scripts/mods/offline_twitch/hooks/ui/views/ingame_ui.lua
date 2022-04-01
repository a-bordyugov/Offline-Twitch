local mod = get_mod("offline_twitch")

--[[
    Pausing Twitch while VMF menu is open
    #########################
--]]
mod:hook_safe(IngameUI, "post_update", function(self)
    local current_view = self.current_view

    if (current_view == "vmf_options_view") then
        TW_Tweaker._is_tw_paused = true
    else
        TW_Tweaker._is_tw_paused = false
    end
end)
