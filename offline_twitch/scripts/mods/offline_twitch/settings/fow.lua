local mod = get_mod("offline_twitch")

--[[
    Enable/Disable Twitch mode in Fortunes Of War
    #########################
--]]
mod:hook_safe(StateInGameRunning, "_game_actually_starts", function(self)
	if (Managers.twitch:is_connected() or Managers.twitch:is_activated()) then
		local level_key = Managers.level_transition_handler:get_current_level_keys()

        if (level_key == "plaza" and mod:get("otwm_fow_enabled")) then
            Managers.twitch:activate_twitch_game_mode(self.network_event_delegate, Managers.state.game_mode:game_mode_key())
        end
	end
end)