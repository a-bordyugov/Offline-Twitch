local mod = get_mod("offline_twitch")

Offline_Twitch = class(Offline_Twitch)

function Offline_Twitch:init()
    self._is_tw_paused = false
    self._initialized = false
    self._is_server = false
    self._prevent_loop = false
    self._state = ""
    self._allowed_tpl_names = {}
    self._allowed_tpl_count = 0
    self._players_voted_skip = {}
    self._tw_user_settings_backup = {}

    self._fake_tw_data = {
        login = "{\"data\":[{\"id\":\"00000000\",\"login\":\"fake_twitch\",\"display_name\":\"Fake Twitch\",\"type\":\"\",\"broadcaster_type\":\"partner\",\"description\":\"Fake Twitch prides itself in supporting rising heroes.\",\"profile_image_url\":\"http://127.0.0.1/0.jpeg\",\"offline_image_url\":\"http://127.0.0.1/0.jpeg\",\"view_count\":34930369,\"created_at\":\"2012-01-15T03:18:08Z\"}]}",
        stream = "{\"data\":[{\"id\":\"44980940476\",\"user_id\":\"00000000\",\"user_login\":\"fake_twitch\",\"user_name\":\"Fake Twitch\",\"game_id\":\"26936\",\"game_name\":\"Music\",\"type\":\"live\",\"title\":\"Fake Twitch\",\"viewer_count\":239,\"started_at\":\"2022-03-16T21:11:55Z\",\"language\":\"en\",\"thumbnail_url\":\"http://127.0.0.1/fake_twitch-{width}x{height}.jpg\",\"tag_ids\":[\"6ea6bca4-4712-4ab9-a906-e3336a9d8039\",\"c5247b10-deec-4d7a-84a5-db6a75cb5908\",\"d81d54c8-d705-4df6-aaf0-01d715c1dbcc\",\"338d7a92-8bcc-429e-a30c-9f1c41a2d79a\",\"9f1b01a8-87b9-4e25-94de-8705c1c1f4dc\"],\"is_mature\":false}],\"pagination\":{}}"
    }

    --[[
        Twitch manager settings for correctly clearing used votes
        #########################
    --]]
    self._NUM_ROUNDS_TO_DISABLE_USED_VOTES = 15
    self._MIN_VOTES_LEFT_IN_ROTATION = 2

    --[[
        Contains origin vote templates
        #########################
    --]]
    self._tpl_origin_data = {
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
    TwitchVoteTemplates = self._tpl_origin_data.TwitchVoteTemplates.data
    TwitchVoteTemplatesLookup = self._tpl_origin_data.TwitchVoteTemplatesLookup.data
    TwitchMultipleChoiceVoteTemplatesLookup = self._tpl_origin_data.TwitchMultipleChoiceVoteTemplatesLookup.data
    TwitchStandardVoteTemplatesLookup = self._tpl_origin_data.TwitchStandardVoteTemplatesLookup.data
    TwitchPositiveVoteTemplatesLookup = self._tpl_origin_data.TwitchPositiveVoteTemplatesLookup.data
    TwitchNegativeVoteTemplatesLookup = self._tpl_origin_data.TwitchNegativeVoteTemplatesLookup.data
    TwitchBossEquivalentSpawnTemplatesLookup = self._tpl_origin_data.TwitchBossEquivalentSpawnTemplatesLookup.data
    TwitchBossesSpawnBreedNamesLookup = self._tpl_origin_data.TwitchBossesSpawnBreedNamesLookup.data
    TwitchSpecialsSpawnBreedNamesLookup = self._tpl_origin_data.TwitchSpecialsSpawnBreedNamesLookup.data
    TwitchVoteWhitelists = self._tpl_origin_data.TwitchVoteWhitelists.data

    self._tpl_origin_data.TwitchVoteTemplates.data = {}
    self._tpl_origin_data.TwitchVoteTemplatesLookup.data = {}
    self._tpl_origin_data.TwitchMultipleChoiceVoteTemplatesLookup.data = {}
    self._tpl_origin_data.TwitchStandardVoteTemplatesLookup.data = {}
    self._tpl_origin_data.TwitchPositiveVoteTemplatesLookup.data = {}
    self._tpl_origin_data.TwitchNegativeVoteTemplatesLookup.data = {}
    self._tpl_origin_data.TwitchBossEquivalentSpawnTemplatesLookup.data = {}
    self._tpl_origin_data.TwitchBossesSpawnBreedNamesLookup.data = {}
    self._tpl_origin_data.TwitchSpecialsSpawnBreedNamesLookup.data = {}
    self._tpl_origin_data.TwitchVoteWhitelists.data = {}

    self._initialized = false

    Application.set_user_setting("twitch_disable_positive_votes",
                                 self._tw_user_settings_backup.twitch_disable_positive_votes)
    Application.set_user_setting("twitch_disable_mutators", self._tw_user_settings_backup.twitch_disable_mutators)

    self._tw_user_settings_backup = {}

    if (self._is_server) then
        if (self._state == "ingame") then
            mod:echo(mod:localize("tw_destroy_ingame"))
            return
        end

        self:__disconnect()
    end
end

--[[
    Twitch disconnect
    #########################
--]]
function Offline_Twitch:__disconnect()
    Managers.twitch = TwitchManager:new()
    mod:echo(mod:localize("tw_ds_msg"))
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

        if (self._initialized or not self._is_server) then
            return
        end

        -- Unset current voting
        self:unset_current_vote()

        -- Work with vote templates
        self:tpl_clone()
        self:tpl_update_allowed()
        self:tpl_modify_origin()

        -- Update settings
        self:game_update_settings("tw_settings")

        self._initialized = true

    elseif (event[1] == "settings") then

        if (not self._is_server) then
            return
        end

        local skip_update = {"otwm_fow_enabled", "otwm_cw_enabled", "otwm_weaves_enabled", "otwm_vote_percentage_skip"}
        local tw_settings_update_required = {"otwm_difficulty_preset"}

        if (table.contains(skip_update, event[2])) then
            return
        elseif (table.contains(tw_settings_update_required, event[2])) then

            -- Unset current voting
            self:unset_current_vote()

        else
            -- Unset current voting
            self:unset_current_vote()

            -- Work with vote templates
            self:tpl_update_allowed()
            self:tpl_modify_origin()

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

        if (self._state == "ingame") then
            if (not self._is_server) then
                -- Disable mod if client
                self:__on_change({"disabled"})
                mod:disable_all_hooks()
            else
                -- Enable mod if server
                self:__on_change({"enabled"})
                mod:enable_all_hooks()
            end
        end

    elseif (event[1] == "unload" or event[1] == "disabled") then

        if (not self._initialized) then
            return
        end

        -- Unset current voting
        self:unset_current_vote()

        self:__destroy()

    end
end

--[[
    Original templates help to update the settings
    #########################
--]]
function Offline_Twitch:tpl_clone() --
    --[[
        ** This table contains data of all Twitch votes, including maps and shops from Chaos Wastes.
        ** 69 positions in Patch 4.5.1

        @name TwitchVoteTemplates|table
        ---
        @param text|string
        @param on_success|function
        @param texture_id|string
        @param texture_size|table
        @param name|string
        @param cost|number
        @param description|string?
        @param level_name|string?
        @param breed_name|string?
        @param special|boolean?
        @param boss|boolean?
        @param boss_equivalent|boolean?
        @param use_frame_texture|boolean?
        @param condition_func|function?
        @param multiple_choice|boolean?
        ---
        @return %TwitchVoteTemplateName|table
    ]]
    self._tpl_origin_data.TwitchVoteTemplates.data = TwitchVoteTemplates
    --

    --[[
        ** This table contains the names of Twitch votes, including maps and shops from Chaos Wastes.
        ** 69 positions in Patch 4.5.1

        @name TwitchVoteTemplatesLookup|table
        ---
        @param %TableIndex|number
        @param %TwitchVoteTemplateName|string
        ---
        @return %TwitchVoteTemplateName|string
    ]]
    self._tpl_origin_data.TwitchVoteTemplatesLookup.data = TwitchVoteTemplatesLookup
    --

    --[[
        ** This table contains the names of Twitch votes which have @param multiple_choice, @see TwitchVoteTemplates.
        ** 12 positions in Patch 4.5.1

        @name TwitchMultipleChoiceVoteTemplatesLookup|table
        ---
        @param %TableIndex|number
        @param %TwitchVoteTemplateName|string
        ---
        @return %TwitchVoteTemplateName|string
    ]]
    self._tpl_origin_data.TwitchMultipleChoiceVoteTemplatesLookup.data = TwitchMultipleChoiceVoteTemplatesLookup
    --

    --[[
        ** This table contains the names of Twitch votes, including maps and shops from Chaos Wastes but lost some names.
        ** 57 positions in Patch 4.5.1
        ** Lost positions:
        1.  twitch_spawn_berzerkers
        2.  twitch_spawn_death_squad_chaos_warrior
        3.  twitch_vote_activate_splitting_enemies
        4.  twitch_vote_deus_select_level_pat_tower
        5.  twitch_no_overcharge_no_ammo_reloads
        6.  twitch_spawn_corruptor_sorcerer
        7.  twitch_vote_deus_select_level_sig_citadel
        8.  twitch_vote_deus_select_level_pat_mines
        9.  twitch_spawn_warpfire_thrower
        10. twitch_spawn_chaos_troll
        11. twitch_spawn_ratling_gunner
        12. twitch_vote_activate_leash

        @name TwitchStandardVoteTemplatesLookup|table
        ---
        @param %TableIndex|number
        @param %TwitchVoteTemplateName|string
        ---
        @return %TwitchVoteTemplateName|string
    ]]
    self._tpl_origin_data.TwitchStandardVoteTemplatesLookup.data = TwitchStandardVoteTemplatesLookup
    --

    --[[
        ** This table contains the names of Twitch votes which are in the list of positive votes.
        ** 16 positions in Patch 4.5.1

        @name TwitchPositiveVoteTemplatesLookup|table
        ---
        @param %TableIndex|number
        @param %TwitchVoteTemplateName|string
        ---
        @return %TwitchVoteTemplateName|string
    ]]
    self._tpl_origin_data.TwitchPositiveVoteTemplatesLookup.data = TwitchPositiveVoteTemplatesLookup
    --

    --[[
        ** This table contains the names of Twitch votes which are in the list of negative votes, including votes from Chaos Wastes.
        ** 53 positions in Patch 4.5.1

        @name TwitchNegativeVoteTemplatesLookup|table
        ---
        @param %TableIndex|number
        @param %TwitchVoteTemplateName|string
        ---
        @return %TwitchVoteTemplateName|string
    ]]
    self._tpl_origin_data.TwitchNegativeVoteTemplatesLookup.data = TwitchNegativeVoteTemplatesLookup
    --

    --[[
        ** This table contains the names of two Twitch votes which called as: "twitch_spawn_death_squad_storm_vermin" and "twitch_spawn_death_squad_chaos_warrior".
        ** 2 positions in Patch 4.5.1

        @name TwitchBossEquivalentSpawnTemplatesLookup|table
        ---
        @param %TableIndex|number
        @param %TwitchVoteTemplateName|string
        ---
        @return %TwitchVoteTemplateName|string
    ]]
    self._tpl_origin_data.TwitchBossEquivalentSpawnTemplatesLookup.data = TwitchBossEquivalentSpawnTemplatesLookup
    --

    --[[
        ** This table contains data of all Twitch votes about bosses.
        ** 5 positions in Patch 4.5.1

        @name TwitchBossesSpawnBreedNamesLookup|table
        ---
        @param name|string
        @param on_success|function
        @param text|string
        @param texture_id|string
        @param texture_size|table
        @param cost|number
        @param boss|boolean?
        @param breed_name|string?
        @param condition_func|function?
        ---
        @return %TwitchVoteTemplateName|table
    ]]
    self._tpl_origin_data.TwitchBossesSpawnBreedNamesLookup.data = TwitchBossesSpawnBreedNamesLookup
    --

    --[[
        ** This table contains data of all Twitch votes about specials.
        ** 7 positions in Patch 4.5.1

        @name TwitchSpecialsSpawnBreedNamesLookup|table
        ---
        @param name|string
        @param on_success|function
        @param text|string
        @param texture_id|string
        @param texture_size|table
        @param cost|number
        @param special|boolean?
        @param breed_name|string?
        ---
        @return %TwitchVoteTemplateName|table
    ]]
    self._tpl_origin_data.TwitchSpecialsSpawnBreedNamesLookup.data = TwitchSpecialsSpawnBreedNamesLookup
    --

    --[[
        ** This table contains the names of Twitch white lists votes.
        ** Random count positions in Patch 4.5.1

        @name TwitchVoteWhitelists|table
        ---
        @param %TableIndex|number
        @param %TwitchVoteTemplateName|string
        ---
        @return %TwitchVoteTemplateName|string
    ]]
    self._tpl_origin_data.TwitchVoteWhitelists.data = TwitchVoteWhitelists
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
function Offline_Twitch:tpl_modify_origin()
    for a_name, a_content in pairs(self._tpl_origin_data) do
        local tmp_data = {}

        if (a_content.is_hashed) then
            for b_name, b_data in pairs(a_content.data) do
                if (self._allowed_tpl_names[b_data.name]) then
                    tmp_data[b_name] = b_data
                end
            end
        elseif (a_name == "TwitchVoteWhitelists") then
            tmp_data = {map_deus = {}, deus = {}}

            if (a_content.data["map_deus"] and #a_content.data.map_deus) then
                for _, c_name in ipairs(a_content.data.map_deus) do
                    if (self._allowed_tpl_names[c_name]) then
                        table.insert(tmp_data.map_deus, c_name)
                    end
                end
            end

            if (a_content.data["deus"] and #a_content.data.deus) then
                for _, d_name in ipairs(a_content.data.deus) do
                    if (self._allowed_tpl_names[d_name]) then
                        table.insert(tmp_data.deus, d_name)
                    end
                end
            end
        else
            for _, e_name in ipairs(a_content.data) do
                if (self._allowed_tpl_names[e_name]) then
                    table.insert(tmp_data, e_name)
                end
            end
        end

        _G[a_name] = tmp_data
    end
end

--[[
    Unset current vote
    #########################
--]]
function Offline_Twitch:unset_current_vote()
    if (not self._is_server or not Managers.twitch) then
        return
    end

    local tw_manager = Managers.twitch

    if (self._is_server and not self:is_table_empty(tw_manager._votes_lookup_table)) then
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
    local vote_key = nil

    -- Looking for current vote key
    for _, vote_data in pairs(Managers.twitch._votes_lookup_table) do
        if (vote_data.activated) then
            vote_key = vote_data["vote_key"]
        end
    end

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
