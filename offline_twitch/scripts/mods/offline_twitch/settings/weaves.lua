local mod = get_mod("offline_twitch")

--[[
	Enable/Disable Twitch mode in Weaves
    Prevent to show any message about unsupported Twitch mode in weaves
    #########################
--]]
local function _fulfill_requirements_for_weave()
	if script_data.unlock_all_levels then
		return true
	end

	local player_manager = Managers.player
	local statistics_db = player_manager:statistics_db()
	local player = player_manager:local_player()
	local stats_id = player:stats_id()

	for _, level_key in pairs(HelmgartLevels) do
		local level_settings = LevelSettings[level_key]

		if level_settings.mechanism == "adventure" and statistics_db:get_persistent_stat(stats_id, "completed_levels", level_key) < 1 then
			return false
		end
	end

	local scorpion_dlc_levels = GameActs.act_scorpion

	for _, level_key in pairs(scorpion_dlc_levels) do
		local level_settings = LevelSettings[level_key]

		if level_settings.mechanism == "adventure" and statistics_db:get_persistent_stat(stats_id, "completed_levels", level_key) < 1 then
			return false
		end
	end

	return true
end

mod:hook_origin(InteractionDefinitions.weave_level_select_access.client, "stop", function(world, interactor_unit, interactable_unit, data, config, t, result)
	data.start_time = nil

	if result == InteractionResult.SUCCESS and not data.is_husk then
		local dlc_name = "scorpion"
		local has_dlc = Managers.unlock:is_dlc_unlocked(dlc_name)

		if not has_dlc then
			Managers.state.event:trigger("ui_show_popup", dlc_name, "upsell")

			return
		end

        if (not mod:get("otwm_weaves_enabled")) then
            local twitch_connection = Managers.twitch and (Managers.twitch:is_connected() or Managers.twitch:is_activated())

            if twitch_connection then
                Managers.state.event:trigger("weave_tutorial_message", WeaveUITutorials.twitch_not_supported_for_weaves)

                return
            elseif not Managers.player.is_server then
                local lobby = Managers.state.network:lobby()

                if lobby:lobby_data("twitch_enabled") == "true" then
                    Managers.state.event:trigger("weave_tutorial_message", WeaveUITutorials.twitch_not_supported_for_weaves_client)

                    return
                end
            end
        end

		local fulfill_requirements_for_weave_levels = _fulfill_requirements_for_weave()

		if fulfill_requirements_for_weave_levels then
			Managers.ui:handle_transition("start_game_view_force", {
				menu_sub_state_name = "weave_quickplay",
				menu_state_name = "play",
				use_fade = true
			})
			Unit.flow_event(interactable_unit, "lua_interaction_success")
		else
			Managers.state.event:trigger("weave_tutorial_message", WeaveUITutorials.requirements_not_met)
		end
	end
end)