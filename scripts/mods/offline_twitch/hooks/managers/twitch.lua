local mod = get_mod("offline_twitch")

--[[
    Twitch Pause/Unpause when VMF menu is open
    #########################
--]]
mod:hook_origin(TwitchGameMode, "update", function(self, dt, t)
    if (TW_Tweaker._is_tw_paused) then
        return
    end

	self._timer = self._timer - dt

	if self._timer > 0 then
		return
	end

	local game = Managers.state.network and Managers.state.network:game()

	if game then
		self:_trigger_new_vote()
	end
end)

--[[
    Enable/Disable Twitch votes on Holseher's map
    #########################
--]]
mod:hook_origin(TwitchManager, "is_connected", function(self)
    local level_key = Managers.level_transition_handler:get_current_level_keys()

    if (TW_Tweaker._is_server and level_key == "dlc_morris_map" and not mod:get("otwm_cw_enabled")) then
        return false
    end

    return self._connected
end)

--[[
    Fixing an issue when game can not disconnect from Twitch if user used a fake connection
    #########################
--]]
mod:hook_safe(TwitchManager, "disconnect", function(self)
    if (self:user_name() == "fake_twitch") then
        Managers.twitch = TwitchManager:new()
    end
end)

--[[
    Fixing an issue when game got an infinite loop if it can not find a second template
    #########################
--]]
mod:hook_origin(TwitchGameMode, "_next_standard_vote", function(self, template_a)
    local used_vote_templates = self._used_vote_templates
    local template_a_name = template_a.name
    local cost_a = template_a.cost
    local templates = table.clone(TwitchStandardVoteTemplatesLookup)

    table.shuffle(templates)

    local best_template = nil
    local best_diff = math.huge

    for i = 1, #templates, 1 do
        local template_b_name = templates[i]

        if template_a_name ~= template_b_name and not used_vote_templates[template_b_name] then
            local template_b = TwitchVoteTemplates[template_b_name]
            local is_allowed = not template_b.condition_func or template_b.condition_func()

            if is_allowed then
                local invalid_matchup = template_a.boss and not template_b.boss and not template_b.boss_equivalent

                if not invalid_matchup then
                    local cost_b = template_b.cost
                    local vote_cost_diff = math.abs(cost_a - cost_b)

                    if vote_cost_diff <= TwitchSettings.max_a_b_vote_cost_diff and vote_cost_diff < best_diff then
                        best_template = template_b
                        best_diff = vote_cost_diff
                    end
                end
            end
        end
    end

    -- Preventing infinite loop
    if (TW_Tweaker._prevent_loop) then
        best_template = template_a
    end

    if not best_template then
        self:_clear_used_votes(true)
        TW_Tweaker._prevent_loop = true

        return self:_next_standard_vote(template_a)
    end

    -- Making correct calling to the breed package loader
    if template_a == best_template then
        template_a = self:_check_breed_package_loading(template_a)
    else
        template_a = self:_check_breed_package_loading(template_a)
        best_template = self:_check_breed_package_loading(best_template, template_a)
    end

    TW_Tweaker._prevent_loop = false
    
    -- Filling templates and return
    local vote_templates = {template_a.name, best_template.name}

    return "standard_vote", vote_templates, nil
end)

--[[
    Unlock twitch breed packages to avoid game crash
    #########################
--]]
mod:hook_safe(TwitchManager, "_unload_sound_bank", function(self)
    local locked_breeds = self.locked_breed_packages

    for a_name, _ in pairs(locked_breeds) do
        Managers.level_transition_handler.enemy_package_loader:unlock_breed_package(a_name)
        locked_breeds[a_name] = nil
    end
end)

--[[
    Correct clear used votes
    #########################
--]]
-- #########################
mod:hook_origin(TwitchGameMode, "_clear_used_votes", function(self, force_clear)
	local used_vote_templates = self._used_vote_templates
	local game_mode_whitelist = self:_get_game_mode_whitelist()
	local num_available_vote_templates = (game_mode_whitelist and #game_mode_whitelist) or #TwitchVoteTemplatesLookup

	if force_clear or num_available_vote_templates - table.size(used_vote_templates) <= TW_Tweaker._MIN_VOTES_LEFT_IN_ROTATION then
		table.clear(used_vote_templates)
	end
end)

-- #########################
mod:hook_origin(TwitchGameMode, "cb_on_vote_complete", function(self, current_vote)
	Managers.telemetry.events:twitch_poll_completed(current_vote)

	local winning_template = TwitchVoteTemplates[current_vote.winning_template_name]
	self._funds = self._funds + winning_template.cost
	self._used_vote_templates[winning_template.name] = TW_Tweaker._NUM_ROUNDS_TO_DISABLE_USED_VOTES
	self._vote_keys[current_vote.vote_key] = nil
end)

--[[
    Skip an IRC-Manager calling if user are connected to fake twitch
    #########################
--]]
-- #########################
mod:hook_origin(TwitchManager, "unregister_vote", function(self, vote_key)
    local network_manager = Managers.state.network
    local is_server = network_manager and network_manager.is_server

    if (self.user_name ~= "fake_twitch") then
        Managers.irc:unregister_message_callback(vote_key)
    end

    self._votes_lookup_table[vote_key] = nil

    for idx, vote_table in ipairs(self._votes) do
        if vote_table.vote_key == vote_key then
            table.remove(self._votes, idx)

            break
        end
    end

    if is_server then
        local go_id = self._game_object_ids[vote_key]

        if go_id then
            local game = network_manager:game()

            if game then
                GameSession.destroy_game_object(game, go_id)
            end

            self._game_object_ids[vote_key] = nil
        end

        if not self._current_vote or self._current_vote.vote_key == vote_key then
            self._current_vote = nil

            self:_activate_next_vote()
        end
    end
end)

-- #########################
mod:hook_origin(TwitchManager, "register_vote",
                function(self, time, vote_type, validation_func, vote_templates, show_vote_ui, cb)
    local network_manager = Managers.state.network

    fassert(self._connected, "[TwitchManager] You need to be connected to be able to trigger twitch votes")
    fassert(network_manager and network_manager:game(),
            "[TwitchManager] You need to have an active game session to be able to register votes")

    local option_strings = {
        TwitchSettings[vote_type].default_vote_a_str, TwitchSettings[vote_type].default_vote_b_str,
        TwitchSettings[vote_type].default_vote_c_str, TwitchSettings[vote_type].default_vote_d_str,
        TwitchSettings[vote_type].default_vote_e_str
    }
    local expanded_vote_templates = {0, 0, 0, 0}

    for idx, vote_template in ipairs(vote_templates) do
        expanded_vote_templates[idx] = vote_template
    end

    local vote_key = self._vote_key_index
    self._votes[#self._votes + 1] = {
        activated = false,
        timer = time,
        option_strings = option_strings,
        validation_func = validation_func,
        vote_templates = expanded_vote_templates,
        options = {0, 0, 0, 0, 0},
        user_names = {},
        cb = cb,
        vote_key = vote_key,
        vote_type = vote_type,
        show_vote_ui = show_vote_ui
    }
    self._votes_lookup_table[vote_key] = self._votes[#self._votes]

    if (self.user_name ~= "fake_twitch") then
        Managers.irc:register_message_callback(vote_key, Irc.CHANNEL_MSG, callback(self, "on_message_received"))
    end

    if not self._current_vote then
        self:_activate_next_vote()
    end

    self._vote_key_index = 1 + self._vote_key_index % 255

    return vote_key
end)

-- #########################
mod:hook_origin(TwitchManager, "_register_networked_vote", function(self, game_object_id)
    local game = Managers.state.network and Managers.state.network:game()

    fassert(game, "[TwitchManager] You need to have an active game session to be able to register votes")

    local vote_key = GameSession.game_object_field(game, game_object_id, "vote_key")
    local vote_type = NetworkLookup.twitch_vote_types[GameSession.game_object_field(game, game_object_id, "vote_type")]
    local option_strings = {
        TwitchSettings[vote_type].default_vote_a_str, TwitchSettings[vote_type].default_vote_b_str,
        TwitchSettings[vote_type].default_vote_c_str, TwitchSettings[vote_type].default_vote_d_str,
        TwitchSettings[vote_type].default_vote_e_str
    }
    local options = GameSession.game_object_field(game, game_object_id, "options")
    local networked_vote_templates = GameSession.game_object_field(game, game_object_id, "vote_templates")
    local vote_templates = {}

    for idx, template_lookup in ipairs(networked_vote_templates) do
        vote_templates[idx] = rawget(NetworkLookup.twitch_vote_templates, template_lookup) or "none"
    end

    local time = GameSession.game_object_field(game, game_object_id, "time")
    local show_vote_ui = GameSession.game_object_field(game, game_object_id, "show_vote_ui")
    self._votes[#self._votes + 1] = {
        activated = true,
        timer = time,
        option_strings = option_strings,
        options = options,
        vote_templates = vote_templates,
        vote_key = vote_key,
        vote_type = vote_type,
        show_vote_ui = show_vote_ui
    }
    self._votes_lookup_table[vote_key] = self._votes[#self._votes]

    if (self.user_name ~= "fake_twitch") then
        Managers.irc:register_message_callback(vote_key, Irc.CHANNEL_MSG, callback(self, "on_client_message_received"))
    end

    if self._votes[#self._votes].show_vote_ui then
        Managers.state.event:trigger("add_vote_ui", vote_key)
    end
end)

-- #########################
mod:hook_origin(TwitchManager, "rpc_finish_twitch_vote", function(self, channel_id, vote_key, user_name, vote_index, vote_template_id)
	local is_server = Managers.state.network and Managers.state.network.is_server
	local vote_template_name = NetworkLookup.twitch_vote_templates[vote_template_id]

	debug_print("Vote results:", vote_index, vote_template_name)

	local vote_data = self._votes_lookup_table[vote_key]

	if not vote_data then
		Application.error("TwitchManager] Something went wrong. There is no vote with the vote_key: " .. tostring(vote_key))
		self:unregister_vote(vote_key)

		return
	end

	local vote_template = TwitchVoteTemplates[vote_template_name]

	if vote_template then
		vote_template.on_success(is_server, vote_index, vote_template)
	end

	if vote_data.show_vote_ui then
		Managers.state.event:trigger("finish_vote_ui", vote_key, vote_index)
	end

    if (self.user_name ~= "fake_twitch") then
	    Managers.irc:unregister_message_callback(vote_key)
    end

	self._votes_lookup_table[vote_key] = nil

	for idx, vote_table in ipairs(self._votes) do
		if vote_table.vote_key == vote_key then
			table.remove(self._votes, idx)

			break
		end
	end
end)