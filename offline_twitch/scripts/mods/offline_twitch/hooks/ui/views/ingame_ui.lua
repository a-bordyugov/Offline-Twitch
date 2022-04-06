local mod = get_mod("offline_twitch")

--[[
    Pausing Twitch while VMF menu is open
    #########################
--]]
mod:hook_safe(IngameUI, "post_update", function(self)
    TW_Tweaker._is_tw_paused = (self.current_view == "vmf_options_view")
end)
