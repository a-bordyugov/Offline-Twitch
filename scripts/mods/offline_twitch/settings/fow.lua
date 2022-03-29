local mod = get_mod("offline_twitch")

--[[
    Enable/Disable Twitch mode in Fortunes Of War
    #########################
--]]
mod:hook_origin(StateInGameRunning, "_game_actually_starts", function(self)
	print("StateInGameRunning:_game_actually_starts()")

	local loading_context = self.parent.parent.loading_context

	Managers.state.game_mode:local_player_game_starts(self.player, loading_context)
	Managers.transition:fade_out(GameSettings.transition_fade_in_speed)

	self._game_started_current_frame = true
	self._game_has_started = true

	Managers.transition:hide_loading_icon()
	Managers.transition:show_waiting_for_peers_message(false)

	self._waiting_for_peers_message_timer = nil

	Managers.load_time:end_timer()

	if Managers.twitch then
		local level_key = Managers.level_transition_handler:get_current_level_keys()
		local level_settings = LevelSettings[level_key]

		if level_settings and not level_settings.disable_twitch_game_mode then
			Managers.twitch:activate_twitch_game_mode(self.network_event_delegate, Managers.state.game_mode:game_mode_key())
		end

        if (level_settings and level_key == "plaza" and mod:get("otwm_fow_enabled")) then
            Managers.twitch:activate_twitch_game_mode(self.network_event_delegate, Managers.state.game_mode:game_mode_key())
        end
	end

	local network_manager = Managers.state.network
	local profile_synchronizer = network_manager.profile_synchronizer

	profile_synchronizer:set_own_actually_ingame(true)

	self._game_started_timestamp = os.time(os.date("*t"))

	if IS_WINDOWS then
		Managers.account:update_presence()
	end
end)