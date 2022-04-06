local mod = get_mod("offline_twitch")

--[[
    Use custom TW templates
    #########################
--]]
mod:hook_origin(TwitchGameMode, "_next_standard_vote", function(self, template_a)
    local used_vote_templates = self._used_vote_templates
    local template_a_name = template_a.name
    local cost_a = template_a.cost
    local templates = table.clone(TW_Tweaker._tpl_list.TwitchStandardVoteTemplatesLookup.data)

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

-- #########################
mod:hook_origin(TwitchGameMode, "_get_next_vote", function(self)
	self:_update_used_votes()

	local funds = self._funds
	local used_vote_templates = self._used_vote_templates
	local best_template = nil

	if TwitchSettings.cutoff_for_guaranteed_positive_vote <= funds and not TwitchSettings.disable_positive_votes then
		local templates = table.clone(TW_Tweaker._tpl_list.TwitchPositiveVoteTemplatesLookup.data)

		table.shuffle(templates)

		local best_diff = -math.huge

		for i = 1, #templates, 1 do
			local template_name = templates[i]

			if not used_vote_templates[template_name] then
				local template = TW_Tweaker._tpl_list.TwitchVoteTemplates.data[template_name]
				local in_whitelist = self:_in_whitelist(template_name)
				local is_allowed = in_whitelist and (not template.condition_func or template.condition_func())

				if is_allowed then
					local cost = template.cost
					local diff = funds - cost

					if best_diff < diff then
						best_template = template
						best_diff = diff
					end
				end
			end
		end
	elseif funds <= TwitchSettings.cutoff_for_guaranteed_negative_vote then
		local templates = table.clone(TW_Tweaker._tpl_list.TwitchNegativeVoteTemplatesLookup.data)

		table.shuffle(templates)

		local best_diff = math.huge

		for i = 1, #templates, 1 do
			local template_name = templates[i]

			if not used_vote_templates[template_name] then
				local template = TW_Tweaker._tpl_list.TwitchVoteTemplates.data[template_name]
				local in_whitelist = self:_in_whitelist(template_name)
				local is_allowed = in_whitelist and (not template.condition_func or template.condition_func())

				if is_allowed then
					local cost = template.cost
					local diff = funds + cost

					if best_diff > diff then
						best_template = template
						best_diff = diff
					end
				end
			end
		end
	end

	if best_template == nil then
		local templates = table.clone(TW_Tweaker._tpl_list.TwitchVoteTemplatesLookup.data)

		table.shuffle(templates)

		for i = 1, #templates, 1 do
			local template_name = templates[i]

			if not used_vote_templates[template_name] then
				local template = TW_Tweaker._tpl_list.TwitchVoteTemplates.data[template_name]
				local in_whitelist = self:_in_whitelist(template_name)
				local is_allowed = in_whitelist and (not template.condition_func or template.condition_func())

				if is_allowed then
					best_template = template

					break
				end
			end
		end
	end

	if best_template == nil then
		return nil
	end

	if best_template.multiple_choice then
		return self:_next_multiple_choice_vote(best_template)
	else
		return self:_next_standard_vote(best_template)
	end
end)

-- #########################
mod:hook_origin(TwitchGameMode, "_get_game_mode_whitelist", function(self)
	local game_mode_key = Managers.state.game_mode:game_mode_key()

	return TW_Tweaker._tpl_list.TwitchVoteWhitelists.data[game_mode_key]
end)

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

    if (level_key == "dlc_morris_map" and not mod:get("otwm_cw_enabled")) then
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