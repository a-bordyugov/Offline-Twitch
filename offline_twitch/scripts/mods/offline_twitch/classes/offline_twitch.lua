local mod = get_mod("offline_twitch")

Offline_Twitch = class(Offline_Twitch)

function Offline_Twitch:init()
    self._is_tw_paused = false
    self._is_server = false
    self._prevent_loop = false
    self._hooks_available = true
    self._state = ""
    self._allowed_tpl_names = {}
    self._allowed_tpl_count = 0
    self._players_voted_skip = {}
    self._tw_user_settings_backup = {}

    self._fake_tw_data = {
        login = "{\"data\":[{\"id\":\"00000000\",\"login\":\"fake_twitch\",\"display_name\":\"Fake Twitch\",\"type\":\"\",\"broadcaster_type\":\"partner\",\"description\":\"Fake Twitch prides itself in supporting rising heroes.\",\"profile_image_url\":\"http://127.0.0.1/0.jpeg\",\"offline_image_url\":\"http://127.0.0.1/0.jpeg\",\"view_count\":34930369,\"created_at\":\"2012-01-15T03:18:08Z\"}]}",
        stream = "{\"data\":[{\"id\":\"44980940476\",\"user_id\":\"00000000\",\"user_login\":\"fake_twitch\",\"user_name\":\"Fake Twitch\",\"game_id\":\"26936\",\"game_name\":\"Music\",\"type\":\"live\",\"title\":\"Fake Twitch\",\"viewer_count\":239,\"started_at\":\"2022-03-16T21:11:55Z\",\"language\":\"en\",\"thumbnail_url\":\"http://127.0.0.1/fake_twitch-{width}x{height}.jpg\",\"tag_ids\":[\"6ea6bca4-4712-4ab9-a906-e3336a9d8039\",\"c5247b10-deec-4d7a-84a5-db6a75cb5908\",\"d81d54c8-d705-4df6-aaf0-01d715c1dbcc\",\"338d7a92-8bcc-429e-a30c-9f1c41a2d79a\",\"9f1b01a8-87b9-4e25-94de-8705c1c1f4dc\"],\"is_mature\":false}],\"pagination\":{}}"
    }

    -- Twitch manager settings for correctly clearing used votes
    self._NUM_ROUNDS_TO_DISABLE_USED_VOTES = 15
    self._MIN_VOTES_LEFT_IN_ROTATION = 2

    -- Contains user changed vote templates
    self._tpl_list = {
        TwitchVoteTemplates = {is_hashed = true, data = {}},
        TwitchVoteTemplatesLookup = {is_hashed = false, data = {}},
        TwitchMultipleChoiceVoteTemplatesLookup = {is_hashed = false, data = {}},
        TwitchStandardVoteTemplatesLookup = {is_hashed = false, data = {}},
        TwitchPositiveVoteTemplatesLookup = {is_hashed = false, data = {}},
        TwitchNegativeVoteTemplatesLookup = {is_hashed = false, data = {}},
        TwitchBossEquivalentSpawnTemplatesLookup = {is_hashed = false, data = {}},
        TwitchBossesSpawnBreedNamesLookup = {is_hashed = true, data = {}},
        TwitchSpecialsSpawnBreedNamesLookup = {is_hashed = true, data = {}},
        TwitchVoteWhitelists = {is_hashed = false, data = {}}
    }
end

--[[
    Destroy all mod changes
    #########################
--]]
function Offline_Twitch:__destroy()
    self._tpl_list.TwitchVoteTemplates.data = {}
    self._tpl_list.TwitchVoteTemplatesLookup.data = {}
    self._tpl_list.TwitchMultipleChoiceVoteTemplatesLookup.data = {}
    self._tpl_list.TwitchStandardVoteTemplatesLookup.data = {}
    self._tpl_list.TwitchPositiveVoteTemplatesLookup.data = {}
    self._tpl_list.TwitchNegativeVoteTemplatesLookup.data = {}
    self._tpl_list.TwitchBossEquivalentSpawnTemplatesLookup.data = {}
    self._tpl_list.TwitchBossesSpawnBreedNamesLookup.data = {}
    self._tpl_list.TwitchSpecialsSpawnBreedNamesLookup.data = {}
    self._tpl_list.TwitchVoteWhitelists.data = {}

    Application.set_user_setting("twitch_disable_positive_votes",
                                 self._tw_user_settings_backup.twitch_disable_positive_votes)
    Application.set_user_setting("twitch_disable_mutators", self._tw_user_settings_backup.twitch_disable_mutators)

    self._tw_user_settings_backup = {}

    self:__disconnect()
end

--[[
    Twitch disconnect
    #########################
--]]
function Offline_Twitch:__disconnect()
    if (not self._is_server) then
        return
    end

    if (self._state == "ingame") then
        mod:echo(mod:localize("tw_destroy_ingame"))
    else
        Managers.twitch = TwitchManager:new()
        mod:echo(mod:localize("tw_ds_msg"))
    end
end

--[[
    What we gonna do now
    #########################
--]]
function Offline_Twitch:__on_change(event)
    if (not mod:is_enabled() and event[1] ~= "unload" and event[1] ~= "disabled") then
        return
    end

    if (event[1] == "loaded" or event[1] == "enabled") then

        -- Unset current voting
        self:unset_current_vote()

        -- Work with vote templates
        self:tpl_update_allowed()
        self:tpl_modify()

        -- Update settings
        self:game_update_settings("tw_settings")

    elseif (event[1] == "settings") then

        local skip_update = {"otwm_fow_enabled", "otwm_cw_enabled", "otwm_weaves_enabled", "otwm_vote_percentage_skip"}

        if (table.contains(skip_update, event[2])) then
            return
        else
            -- Unset current voting
            self:unset_current_vote()

            -- Work with vote templates
            self:tpl_update_allowed()
            self:tpl_modify()
        end

    elseif (event[1] == "game_state_changed") then

        local lvl_name = Managers.state.game_mode and Managers.state.game_mode:level_key()
        local non_game_lvl = {"morris_hub", "inn_level"}
        self._is_server = Managers.player.is_server

        if (not lvl_name or table.contains(non_game_lvl, lvl_name)) then
            self._state = "nongame"
        else
            self._state = "ingame"
        end

        -- Disable/Enable hooks
        if (not self._is_server) then
            if (self._hooks_available) then
                mod:disable_all_hooks()
                self._hooks_available = false
            end
        else
            if (not self._hooks_available) then
                self:game_update_settings("tw_settings")
                mod:enable_all_hooks()
                self._hooks_available = true
            end
        end

    elseif (event[1] == "unload" or event[1] == "disabled") then

        -- Unset current voting
        self:unset_current_vote()

        self:__destroy()

    end
end

--[[
    List of user allowed voting templates
    #########################
--]]
function Offline_Twitch:tpl_update_allowed()
    local unwanted_options = {
        "otwm_difficulty_preset", "otwm_cw_enabled", "otwm_weaves_enabled", "otwm_fow_enabled",
        "otwm_vote_percentage_skip"
    }
    local settings = Application.user_setting()
    settings = settings.mods_settings.offline_twitch

    self._allowed_tpl_count = 0
    self._allowed_tpl_names = {
        -- Add Chaos Wastes names anyway
        twitch_vote_deus_select_level_arena_citadel = true,
        twitch_vote_deus_select_level_arena_ruin = true,
        twitch_vote_deus_select_level_arena_cave = true,
        twitch_vote_deus_select_level_arena_ice = true,
        twitch_vote_deus_select_level_pat_mountain = true,
        twitch_vote_deus_select_level_pat_forest = true,
        twitch_vote_deus_select_level_pat_mines = true,
        twitch_vote_deus_select_level_pat_tower = true,
        twitch_vote_deus_select_level_pat_town = true,
        twitch_vote_deus_select_level_pat_bay = true,
        twitch_vote_deus_select_level_sig_volcano = true,
        twitch_vote_deus_select_level_sig_citadel = true,
        twitch_vote_deus_select_level_sig_mordrek = true,
        twitch_vote_deus_select_level_sig_gorge = true,
        twitch_vote_deus_select_level_sig_snare = true,
        twitch_vote_deus_select_level_sig_crag = true,
        twitch_vote_deus_select_level_shop_harmony = true,
        twitch_vote_deus_select_level_shop_fortune = true,
        twitch_vote_deus_select_level_shop_strife = true
    }

    -- Getting names of user-allowed voting templates
    for a_name, a_allowed in pairs(settings) do
        a_allowed = mod:get(a_name)

        if (a_allowed and not table.contains(unwanted_options, a_name)) then
            -- Updating the number of allowed Twitch templates
            self._allowed_tpl_count = self._allowed_tpl_count + 1

            -- Creating list with allowed Twitch votes
            self._allowed_tpl_names[a_name] = true
        end
    end

    -- Updating used votes counting condition
    if (self._allowed_tpl_count % 2 == 0) then
        self._NUM_ROUNDS_TO_DISABLE_USED_VOTES = self._allowed_tpl_count / 2
        self._MIN_VOTES_LEFT_IN_ROTATION = 2
    else
        self._NUM_ROUNDS_TO_DISABLE_USED_VOTES = math.floor(self._allowed_tpl_count / 2)
        self._MIN_VOTES_LEFT_IN_ROTATION = 1
    end

    if (self._NUM_ROUNDS_TO_DISABLE_USED_VOTES > 15) then
        self._NUM_ROUNDS_TO_DISABLE_USED_VOTES = 15
    elseif (self._NUM_ROUNDS_TO_DISABLE_USED_VOTES < 1) then
        self._NUM_ROUNDS_TO_DISABLE_USED_VOTES = 1
    end
end

--[[
    Replacing original vote templates with custom ones
    #########################
--]]
function Offline_Twitch:tpl_modify()
    local tpl_name = ""

    for a_name, a_content in pairs(self._tpl_list) do
        local tmp_data = {}
        tpl_name = a_name

        if (a_content.is_hashed) then
            for b_name, b_data in pairs(_G[a_name]) do
                if (self._allowed_tpl_names[b_data.name]) then
                    tmp_data[b_name] = b_data
                end
            end
        elseif (a_name == "TwitchVoteWhitelists") then
            tmp_data = {map_deus = {}, deus = {}}

            if (#_G[a_name].map_deus) then
                for _, c_name in ipairs(_G[a_name].map_deus) do
                    if (self._allowed_tpl_names[c_name]) then
                        table.insert(tmp_data.map_deus, c_name)
                    end
                end
            end

            if (#_G[a_name].deus) then
                for _, d_name in ipairs(_G[a_name].deus) do
                    if (self._allowed_tpl_names[d_name]) then
                        table.insert(tmp_data.deus, d_name)
                    end
                end
            end
        else
            for _, e_name in ipairs(_G[a_name]) do
                if (self._allowed_tpl_names[e_name]) then
                    table.insert(tmp_data, e_name)
                end
            end
        end

        self._tpl_list[tpl_name]["data"] = tmp_data
    end
end

--[[
    Unset current vote
    #########################
--]]
function Offline_Twitch:unset_current_vote()
    if (not self._is_server or self._state ~= "ingame" or not Managers.twitch:is_activated()) then
        return
    end

    local tw_manager = Managers.twitch

    if (not self:is_table_empty(tw_manager._votes_lookup_table)) then
        for _, vote_data in pairs(tw_manager._votes_lookup_table) do
            if (vote_data.activated) then
                if Managers.state and Managers.state.event then
                    Managers.state.event:trigger("reset_vote_ui", vote_data["vote_key"])
                end

                tw_manager:unregister_vote(vote_data["vote_key"])
            end
        end
    end
end

--[[
    Updating Game settings
    #########################
--]]
function Offline_Twitch:game_update_settings(event)
    if (event == "tw_settings") then
        if (self:is_table_empty(self._tw_user_settings_backup)) then
            self._tw_user_settings_backup["twitch_disable_positive_votes"] = Application.user_setting(
                                                                                 "twitch_disable_positive_votes")
            self._tw_user_settings_backup["twitch_disable_mutators"] = Application.user_setting(
                                                                           "twitch_disable_mutators")
        end

        Application.set_user_setting("twitch_disable_positive_votes", "enable_positive_votes")
        Application.set_user_setting("twitch_disable_mutators", false)
    end
end

--[[
    Voting from game chat
    #########################
--]]
function Offline_Twitch:add_vote(message)
    if (not self._is_server) then
        return
    end

    local vote_key = self:get_tw_active_vote_key()

    if (not vote_key) then
        mod:chat_broadcast(mod:localize("chat_vote_denied"))

        return
    end

    -- Add user vote to current TW vote
    local vote_data = Managers.twitch._votes_lookup_table[vote_key]

    for idx, option_string in ipairs(vote_data.option_strings) do
        if option_string == message then
            vote_data.options[idx] = vote_data.options[idx] + 1

            message = string.upper(message)
            mod:chat_broadcast(mod:localize("chat_vote_allowed", message))

            break
        end
    end
end

--[[
    Skip current vote from game chat
    #########################
--]]
function Offline_Twitch:skip_vote(message_sender)
    if (not self._is_server) then
        return
    end

    local vote_available = self:get_tw_active_vote_key()

    if (not vote_available) then
        mod:chat_broadcast(mod:localize("chat_vote_denied"))

        return
    end

    local players_voted = self._players_voted_skip
    local players_num = Managers.state.network:lobby():members():get_member_count()
    local skip_allowed = false
    local votes_percentage = nil
    local skip_allowed_percentage = mod:get("otwm_vote_percentage_skip")
    local skip_votes_min = 0

    if (not table.contains(players_voted, message_sender)) then
        table.insert(players_voted, message_sender)
    end

    votes_percentage = (#players_voted * 100 / players_num)
    skip_votes_min = math.ceil(players_num / 2)

    if (skip_votes_min == 1) then
        skip_votes_min = 2
    end

    if (skip_allowed_percentage == "50more" and votes_percentage > 50) then
        skip_allowed = true
    elseif (skip_allowed_percentage == "50" and votes_percentage >= 50) then
        skip_allowed = true
    end

    if (skip_allowed) then
        self:unset_current_vote()
    else
        mod:chat_broadcast(mod:localize("vote_skip_info", #players_voted, players_num, skip_votes_min))
    end
end

--[[
    Function: TW active vote key
    #########################
--]]
function Offline_Twitch:get_tw_active_vote_key()
    local vote_key = nil

    -- Looking for current vote key
    for _, vote_data in pairs(Managers.twitch._votes_lookup_table) do
        if (vote_data.activated) then
            vote_key = vote_data["vote_key"]
        end
    end

    return vote_key
end

--[[
    Function: Table is empty?
    #########################
--]]
function Offline_Twitch:is_table_empty(table)
    for _, _ in pairs(table) do
        return false
    end

    return true
end

--[[
    Initialize mod
    #########################
--]]
TW_Tweaker = Offline_Twitch:new()
