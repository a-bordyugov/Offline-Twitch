local mod = get_mod("offline_twitch")

Offline_Twitch = class(Offline_Twitch)

function Offline_Twitch:init()
    self._is_server = true
    self._state = ""
    self._allowed_tpl_names = {}
    self._allowed_tpl_count = 0
    self._choosen_preset_name = mod:get("otwm_difficulty_preset")

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

    --[[
        Difficulty presets
        #########################
    --]]
    self._presets = {
        --[[
            KILL EVERYTHING!!!!!!!!
            #########################
        --]]
        hardest = {
            tw_settings = {
                max_negative = -450,
                max_positive = 150,
                funds = 350,
                max_diff = 200,
                max_vote_cost_diff = 100,
                init_time = 20
            },
            cost = {
                -- Items giving
                twitch_give_cooldown_reduction_potion = -50,
                twitch_give_damage_boost_potion = -50,
                twitch_give_speed_boost_potion = -50,
                twitch_give_fire_grenade_t1 = -100,
                twitch_give_frag_grenade_t1 = -100,
                twitch_give_healing_draught = -100,
                twitch_give_first_aid_kit = -100,
                -- Buffs
                twitch_add_cooldown_potion_buff = -200,
                twitch_add_damage_potion_buff = -200,
                twitch_add_speed_potion_buff = -200,
                twitch_vote_critical_strikes = -200,
                twitch_vote_activate_root_all = 200,
                twitch_vote_infinite_bombs = -200,
                twitch_vote_invincibility = -200,
                twitch_vote_activate_root = 100,
                twitch_vote_full_temp_hp = -200,
                twitch_vote_hemmoraghe = 200,
                twitch_no_overcharge_no_ammo_reloads = -200,
                twitch_grimoire_health_debuff = 200,
                twitch_health_regen = -200,
                twitch_health_degen = 100,
                -- Spawning
                twitch_spawn_chaos_spawn = 180,
                twitch_spawn_chaos_troll = 180,
                twitch_spawn_stormfiend = 180,
                twitch_spawn_minotaur = 180,
                twitch_spawn_rat_ogre = 180,
                twitch_spawn_death_squad_chaos_warrior = 250,
                twitch_spawn_death_squad_storm_vermin = 250,
                twitch_spawn_plague_monks = 100,
                twitch_spawn_berzerkers = 100,
                twitch_spawn_poison_wind_globadier = 100,
                twitch_spawn_explosive_loot_rats = 100,
                twitch_spawn_corruptor_sorcerer = 150,
                twitch_spawn_warpfire_thrower = 100,
                twitch_spawn_vortex_sorcerer = 100,
                twitch_spawn_ratling_gunner = 100,
                twitch_spawn_gutter_runner = 150,
                twitch_spawn_pack_master = 150,
                twitch_spawn_horde_vector_blob = 100,
                twitch_spawn_loot_rat_fiesta = 0,
                -- Mutators
                twitch_vote_activate_splitting_enemies = 200,
                twitch_vote_activate_lightning_strike = 100,
                twitch_vote_activate_chasing_spirits = 100,
                twitch_vote_activate_slayer_curse = 200,
                twitch_vote_activate_ticking_bomb = 100,
                twitch_vote_activate_bloodlust = 200,
                twitch_vote_activate_darkness = 200,
                twitch_vote_activate_realism = 200,
                twitch_vote_activate_flames = 100,
                twitch_vote_activate_leash = 200,
                -- Chaos Wastes maps and shops
                twitch_vote_deus_select_level_arena_citadel = 0,
                twitch_vote_deus_select_level_arena_ruin = 0,
                twitch_vote_deus_select_level_arena_cave = 0,
                twitch_vote_deus_select_level_arena_ice = 0,
                twitch_vote_deus_select_level_pat_mountain = 0,
                twitch_vote_deus_select_level_pat_forest = 0,
                twitch_vote_deus_select_level_pat_mines = 0,
                twitch_vote_deus_select_level_pat_tower = 0,
                twitch_vote_deus_select_level_pat_town = 0,
                twitch_vote_deus_select_level_pat_bay = 0,
                twitch_vote_deus_select_level_sig_volcano = 0,
                twitch_vote_deus_select_level_sig_citadel = 0,
                twitch_vote_deus_select_level_sig_mordrek = 0,
                twitch_vote_deus_select_level_sig_gorge = 0,
                twitch_vote_deus_select_level_sig_snare = 0,
                twitch_vote_deus_select_level_sig_crag = 0,
                twitch_vote_deus_select_level_shop_harmony = 0,
                twitch_vote_deus_select_level_shop_fortune = 0,
                twitch_vote_deus_select_level_shop_strife = 0
            }
        },
        --[[
            Good choice for true heroes
            #########################
        --]]
        hard = {
            tw_settings = {
                max_negative = -400,
                max_positive = 200,
                funds = 100,
                max_diff = 200,
                max_vote_cost_diff = 100,
                init_time = 60
            },
            cost = {
                -- Items giving
                twitch_give_cooldown_reduction_potion = -50,
                twitch_give_damage_boost_potion = -50,
                twitch_give_speed_boost_potion = -50,
                twitch_give_fire_grenade_t1 = -100,
                twitch_give_frag_grenade_t1 = -100,
                twitch_give_healing_draught = -100,
                twitch_give_first_aid_kit = -100,
                -- Buffs
                twitch_add_cooldown_potion_buff = -200,
                twitch_add_damage_potion_buff = -200,
                twitch_add_speed_potion_buff = -200,
                twitch_vote_critical_strikes = -200,
                twitch_vote_activate_root_all = 200,
                twitch_vote_infinite_bombs = -200,
                twitch_vote_invincibility = -200,
                twitch_vote_activate_root = 100,
                twitch_vote_full_temp_hp = -200,
                twitch_vote_hemmoraghe = 200,
                twitch_no_overcharge_no_ammo_reloads = -200,
                twitch_grimoire_health_debuff = 200,
                twitch_health_regen = -200,
                twitch_health_degen = 100,
                -- Spawning
                twitch_spawn_chaos_spawn = 180,
                twitch_spawn_chaos_troll = 180,
                twitch_spawn_stormfiend = 180,
                twitch_spawn_minotaur = 180,
                twitch_spawn_rat_ogre = 180,
                twitch_spawn_death_squad_chaos_warrior = 250,
                twitch_spawn_death_squad_storm_vermin = 250,
                twitch_spawn_plague_monks = 100,
                twitch_spawn_berzerkers = 100,
                twitch_spawn_poison_wind_globadier = 100,
                twitch_spawn_explosive_loot_rats = 100,
                twitch_spawn_corruptor_sorcerer = 150,
                twitch_spawn_warpfire_thrower = 100,
                twitch_spawn_vortex_sorcerer = 100,
                twitch_spawn_ratling_gunner = 100,
                twitch_spawn_gutter_runner = 150,
                twitch_spawn_pack_master = 150,
                twitch_spawn_horde_vector_blob = 100,
                twitch_spawn_loot_rat_fiesta = 0,
                -- Mutators
                twitch_vote_activate_splitting_enemies = 200,
                twitch_vote_activate_lightning_strike = 100,
                twitch_vote_activate_chasing_spirits = 100,
                twitch_vote_activate_slayer_curse = 200,
                twitch_vote_activate_ticking_bomb = 100,
                twitch_vote_activate_bloodlust = 200,
                twitch_vote_activate_darkness = 200,
                twitch_vote_activate_realism = 200,
                twitch_vote_activate_flames = 100,
                twitch_vote_activate_leash = 200,
                -- Chaos Wastes maps and shops
                twitch_vote_deus_select_level_arena_citadel = 0,
                twitch_vote_deus_select_level_arena_ruin = 0,
                twitch_vote_deus_select_level_arena_cave = 0,
                twitch_vote_deus_select_level_arena_ice = 0,
                twitch_vote_deus_select_level_pat_mountain = 0,
                twitch_vote_deus_select_level_pat_forest = 0,
                twitch_vote_deus_select_level_pat_mines = 0,
                twitch_vote_deus_select_level_pat_tower = 0,
                twitch_vote_deus_select_level_pat_town = 0,
                twitch_vote_deus_select_level_pat_bay = 0,
                twitch_vote_deus_select_level_sig_volcano = 0,
                twitch_vote_deus_select_level_sig_citadel = 0,
                twitch_vote_deus_select_level_sig_mordrek = 0,
                twitch_vote_deus_select_level_sig_gorge = 0,
                twitch_vote_deus_select_level_sig_snare = 0,
                twitch_vote_deus_select_level_sig_crag = 0,
                twitch_vote_deus_select_level_shop_harmony = 0,
                twitch_vote_deus_select_level_shop_fortune = 0,
                twitch_vote_deus_select_level_shop_strife = 0
            }
        },
        --[[
            Default developers values
            #########################
        --]]
        normal = {
            tw_settings = {
                max_negative = -300,
                max_positive = 300,
                funds = 0,
                max_diff = 200,
                max_vote_cost_diff = 100,
                init_time = 30
            },
            cost = {
                -- Items giving
                twitch_give_cooldown_reduction_potion = -50,
                twitch_give_damage_boost_potion = -50,
                twitch_give_speed_boost_potion = -50,
                twitch_give_fire_grenade_t1 = -100,
                twitch_give_frag_grenade_t1 = -100,
                twitch_give_healing_draught = -100,
                twitch_give_first_aid_kit = -100,
                -- Buffs
                twitch_add_cooldown_potion_buff = -200,
                twitch_add_damage_potion_buff = -200,
                twitch_add_speed_potion_buff = -200,
                twitch_vote_critical_strikes = -200,
                twitch_vote_activate_root_all = 200,
                twitch_vote_infinite_bombs = -200,
                twitch_vote_invincibility = -200,
                twitch_vote_activate_root = 100,
                twitch_vote_full_temp_hp = -200,
                twitch_vote_hemmoraghe = 200,
                twitch_no_overcharge_no_ammo_reloads = -200,
                twitch_grimoire_health_debuff = 200,
                twitch_health_regen = -200,
                twitch_health_degen = 100,
                -- Spawning
                twitch_spawn_chaos_spawn = 180,
                twitch_spawn_chaos_troll = 180,
                twitch_spawn_stormfiend = 180,
                twitch_spawn_minotaur = 180,
                twitch_spawn_rat_ogre = 180,
                twitch_spawn_death_squad_chaos_warrior = 250,
                twitch_spawn_death_squad_storm_vermin = 250,
                twitch_spawn_plague_monks = 100,
                twitch_spawn_berzerkers = 100,
                twitch_spawn_poison_wind_globadier = 100,
                twitch_spawn_explosive_loot_rats = 100,
                twitch_spawn_corruptor_sorcerer = 150,
                twitch_spawn_warpfire_thrower = 100,
                twitch_spawn_vortex_sorcerer = 100,
                twitch_spawn_ratling_gunner = 100,
                twitch_spawn_gutter_runner = 150,
                twitch_spawn_pack_master = 150,
                twitch_spawn_horde_vector_blob = 100,
                twitch_spawn_loot_rat_fiesta = 0,
                -- Mutators
                twitch_vote_activate_splitting_enemies = 200,
                twitch_vote_activate_lightning_strike = 100,
                twitch_vote_activate_chasing_spirits = 100,
                twitch_vote_activate_slayer_curse = 200,
                twitch_vote_activate_ticking_bomb = 100,
                twitch_vote_activate_bloodlust = 200,
                twitch_vote_activate_darkness = 200,
                twitch_vote_activate_realism = 200,
                twitch_vote_activate_flames = 100,
                twitch_vote_activate_leash = 200,
                -- Chaos Wastes maps and shops
                twitch_vote_deus_select_level_arena_citadel = 0,
                twitch_vote_deus_select_level_arena_ruin = 0,
                twitch_vote_deus_select_level_arena_cave = 0,
                twitch_vote_deus_select_level_arena_ice = 0,
                twitch_vote_deus_select_level_pat_mountain = 0,
                twitch_vote_deus_select_level_pat_forest = 0,
                twitch_vote_deus_select_level_pat_mines = 0,
                twitch_vote_deus_select_level_pat_tower = 0,
                twitch_vote_deus_select_level_pat_town = 0,
                twitch_vote_deus_select_level_pat_bay = 0,
                twitch_vote_deus_select_level_sig_volcano = 0,
                twitch_vote_deus_select_level_sig_citadel = 0,
                twitch_vote_deus_select_level_sig_mordrek = 0,
                twitch_vote_deus_select_level_sig_gorge = 0,
                twitch_vote_deus_select_level_sig_snare = 0,
                twitch_vote_deus_select_level_sig_crag = 0,
                twitch_vote_deus_select_level_shop_harmony = 0,
                twitch_vote_deus_select_level_shop_fortune = 0,
                twitch_vote_deus_select_level_shop_strife = 0
            }
        },
        --[[
            Difficulty for a little heroes
            #########################
        --]]
        easy = {
            tw_settings = {
                max_negative = -300,
                max_positive = 300,
                funds = -250,
                max_diff = 150,
                max_vote_cost_diff = 100,
                init_time = 60
            },
            cost = {
                -- Items giving
                twitch_give_cooldown_reduction_potion = 0,
                twitch_give_damage_boost_potion = 0,
                twitch_give_speed_boost_potion = 0,
                twitch_give_fire_grenade_t1 = 0,
                twitch_give_frag_grenade_t1 = 0,
                twitch_give_healing_draught = 0,
                twitch_give_first_aid_kit = 0,
                -- Buffs
                twitch_add_cooldown_potion_buff = -250,
                twitch_add_damage_potion_buff = -250,
                twitch_add_speed_potion_buff = -250,
                twitch_vote_critical_strikes = -100,
                twitch_vote_activate_root_all = 250,
                twitch_vote_infinite_bombs = 0,
                twitch_vote_invincibility = 0,
                twitch_vote_activate_root = 50,
                twitch_vote_full_temp_hp = 0,
                twitch_vote_hemmoraghe = 100,
                twitch_no_overcharge_no_ammo_reloads = -250,
                twitch_grimoire_health_debuff = 150,
                twitch_health_regen = -100,
                twitch_health_degen = 200,
                -- Spawning
                twitch_spawn_chaos_spawn = 250,
                twitch_spawn_chaos_troll = 250,
                twitch_spawn_stormfiend = 250,
                twitch_spawn_minotaur = 250,
                twitch_spawn_rat_ogre = 250,
                twitch_spawn_death_squad_chaos_warrior = 250,
                twitch_spawn_death_squad_storm_vermin = 250,
                twitch_spawn_plague_monks = 120,
                twitch_spawn_berzerkers = 120,
                twitch_spawn_poison_wind_globadier = 150,
                twitch_spawn_explosive_loot_rats = 150,
                twitch_spawn_corruptor_sorcerer = 200,
                twitch_spawn_warpfire_thrower = 150,
                twitch_spawn_vortex_sorcerer = 150,
                twitch_spawn_ratling_gunner = 150,
                twitch_spawn_gutter_runner = 250,
                twitch_spawn_pack_master = 250,
                twitch_spawn_horde_vector_blob = 50,
                twitch_spawn_loot_rat_fiesta = 0,
                -- Mutators
                twitch_vote_activate_splitting_enemies = 200,
                twitch_vote_activate_lightning_strike = 200,
                twitch_vote_activate_chasing_spirits = 200,
                twitch_vote_activate_slayer_curse = 250,
                twitch_vote_activate_ticking_bomb = 50,
                twitch_vote_activate_bloodlust = 200,
                twitch_vote_activate_darkness = 300,
                twitch_vote_activate_realism = 200,
                twitch_vote_activate_flames = 250,
                twitch_vote_activate_leash = 200,
                -- Chaos Wastes maps and shops
                twitch_vote_deus_select_level_arena_citadel = 0,
                twitch_vote_deus_select_level_arena_ruin = 0,
                twitch_vote_deus_select_level_arena_cave = 0,
                twitch_vote_deus_select_level_arena_ice = 0,
                twitch_vote_deus_select_level_pat_mountain = 0,
                twitch_vote_deus_select_level_pat_forest = 0,
                twitch_vote_deus_select_level_pat_mines = 0,
                twitch_vote_deus_select_level_pat_tower = 0,
                twitch_vote_deus_select_level_pat_town = 0,
                twitch_vote_deus_select_level_pat_bay = 0,
                twitch_vote_deus_select_level_sig_volcano = 0,
                twitch_vote_deus_select_level_sig_citadel = 0,
                twitch_vote_deus_select_level_sig_mordrek = 0,
                twitch_vote_deus_select_level_sig_gorge = 0,
                twitch_vote_deus_select_level_sig_snare = 0,
                twitch_vote_deus_select_level_sig_crag = 0,
                twitch_vote_deus_select_level_shop_harmony = 0,
                twitch_vote_deus_select_level_shop_fortune = 0,
                twitch_vote_deus_select_level_shop_strife = 0
            }
        }
    }
end

--[[
    Destroy all mod changes
    #########################
--]]
function Offline_Twitch:__destroy()
    self:tw_update_settings("normal")

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

    if (self._state == "ingame") then
        mod:echo(mod:localize("tw_destroy_ingame"))
        return
    end

    self:__disconnect()
end

--[[
    Force Twitch Manager re-init
    #########################
--]]
function Offline_Twitch:__disconnect()
    local twitch_manager = Managers.twitch

    if (twitch_manager._connected and twitch_manager._twitch_game_mode) then
        Managers.twitch = TwitchManager:new()
        mod:echo(mod:localize("tw_ds_msg"))
    end
end

--[[
    What we gonna do now
    #########################
--]]
function Offline_Twitch:__on_change(event)
    if (not mod:is_enabled()) then
        return
    end

    if (event[1] == "loaded" or event[1] == "enabled") then
        self:tpl_clone()
        self:tpl_update_allowed()
        self:tpl_modify_origin()
        self:game_update_settings("tw_settings")
    elseif (event[1] == "settings") then
        local game_settings_update_required = {"otwm_fow_enabled", "otwm_weaves_enabled"}
        local tw_settings_update_required = {"otwm_difficulty_preset"}

        if (table.contains(game_settings_update_required, event[2])) then
            self:game_update_settings(event[2])
        elseif (table.contains(tw_settings_update_required, event[2])) then
            self:tw_update_settings(event[2])
        else
            self:tpl_update_allowed()
            self:tpl_modify_origin()
        end
    elseif (event[1] == "unload" or event[1] == "disabled") then
        self:__destroy()
    end
end

--[[
    Origin templates help to update the settings
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
    Replacing templates from developers with custom ones
    #########################
--]]
function Offline_Twitch:tpl_modify_origin()
    -- Unset current voting
    self:unset_current_vote()

    for a_name, a_content in pairs(self._tpl_origin_data) do
        local tmp_data = {}

        if (a_content.is_hashed) then
            for b_name, b_data in pairs(a_content.data) do
                if (self._allowed_tpl_names[b_name] ~= nil) then
                    tmp_data[b_name] = b_data
                end
            end
        elseif (a_name == "TwitchVoteWhitelists") then
            tmp_data = {map_deus = {}, deus = {}}

            if (#a_content.data.map_deus) then
                for _, c_name in ipairs(a_content.data.map_deus) do
                    if (self._allowed_tpl_names[c_name] ~= nil) then
                        table.insert(tmp_data.map_deus, c_name)
                    end
                end
            end

            if (#a_content.data.deus) then
                for _, d_name in ipairs(a_content.data.deus) do
                    if (self._allowed_tpl_names[d_name] ~= nil) then
                        table.insert(tmp_data.deus, d_name)
                    end
                end
            end
        else
            for _, e_name in ipairs(a_content.data) do
                if (self._allowed_tpl_names[e_name] ~= nil) then
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
    --[[local tw_manager, current_vote = Managers.twitch, Managers.twitch._current_vote

    if (self._is_server and current_vote) then
        if Managers.state and Managers.state.event then
            Managers.state.event:trigger('reset_vote_ui', current_vote.vote_key)
        end

        tw_manager:unregister_vote(current_vote.vote_key)
    end--]]
end

--[[
    Updating costs values for votes
    #########################
--]]
function Offline_Twitch:tpl_update_cost()
    -- Unset current voting
    self:unset_current_vote()

    -- Updating costs
    for a_is_hashed, a_data in pairs(self._tpl_origin_list_names) do
        if (a_is_hashed) then
            for b_name, b_data in pairs(a_data) do
                local cost = _G[b_name].cost
                local new_cost = self._presets[self._choosen_preset_name].cost[b_name]

                if (cost) then
                    cost = new_cost
                end
            end
        end
    end
end

--[[
    List of user allowed voting templates
    #########################
--]]
function Offline_Twitch:tpl_update_allowed()
    local unwanted_options = {"otwm_difficulty_preset", "otwm_weaves_enabled", "otwm_fow_enabled"}
    local settings = Application.user_setting()
    settings = settings.mods_settings.offline_twitch

    self._allowed_tpl_count = 0
    self._allowed_tpl_names = {}

    -- Getting names of user-allowed voting templates
    for a_name, a_allowed in pairs(settings) do
        a_allowed = mod:get(a_name)

        if (a_allowed and not table.contains(unwanted_options, a_name)) then
            -- Updating the number of allowed Twitch templates
            self._allowed_tpl_count = self._allowed_tpl_count + 1

            -- Creating a list with allowed Twitch votes
            self._allowed_tpl_names[a_name] = true
        end
    end

    -- Updating used votes counting condition
    --[[    if (self._allowed_tpl_count % 2 == 0) then
        self._NUM_ROUNDS_TO_DISABLE_USED_VOTES = self._allowed_tpl_count / 2
        self._MIN_VOTES_LEFT_IN_ROTATION = 2
    else
        self._NUM_ROUNDS_TO_DISABLE_USED_VOTES = math.ceil(self._allowed_tpl_count / 2)
        self._MIN_VOTES_LEFT_IN_ROTATION = 2
        --self._MIN_VOTES_LEFT_IN_ROTATION = 1
    end

    if (self._NUM_ROUNDS_TO_DISABLE_USED_VOTES > 15) then
        self._NUM_ROUNDS_TO_DISABLE_USED_VOTES = 15
    elseif (self._NUM_ROUNDS_TO_DISABLE_USED_VOTES < 1) then
        self._NUM_ROUNDS_TO_DISABLE_USED_VOTES = 1
    end
    --]]
end

--[[
    Updating Twitch settings
    #########################
--]]
function Offline_Twitch:tw_update_settings(preset_name)
    preset_name = preset_name or self._choosen_preset_name

    -- Updating Twitch Settings
    local tw_settings = self._presets[preset_name].tw_settings

    TwitchSettings.cutoff_for_guaranteed_negative_vote = tw_settings.max_negative
    TwitchSettings.cutoff_for_guaranteed_positive_vote = tw_settings.max_positive
    TwitchSettings.initial_downtime = tw_settings.init_time
    TwitchSettings.starting_funds = tw_settings.funds
    TwitchSettings.max_diff = tw_settings.max_diff
    TwitchSettings.max_a_b_vote_cost_diff = tw_settings.max_vote_cost_diff

    -- Updating votes cost
    self:tpl_update_cost()
end

--[[
    Updating Game settings
    #########################
--]]
function Offline_Twitch:game_update_settings(event)
    if (event == "tw_settings") then
        Application.set_user_setting("twitch_disable_positive_votes", "enable_positive_votes")
        Application.set_user_setting("twitch_disable_mutators", false)
    end
end

--[[
    Calculate max diff cost
    #########################
--]]
function Offline_Twitch:calc_max_diff()

end

--[[
    Initialize mod
    #########################
--]]
TW_Tweaker = Offline_Twitch:new()
