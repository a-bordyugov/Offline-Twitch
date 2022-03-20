local mod = get_mod("offline_twitch")

return {
    name = "Offline Twitch",
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "otwm_fow_enabled",
                type = "checkbox",
                title = "set_tw_fow_title",
                tooltip = "set_tw_fow_descr",
                default_value = true
            }, {
                setting_id = "otwm_weaves_enabled",
                type = "checkbox",
                title = "set_tw_weaves_title",
                tooltip = "set_tw_weaves_descr",
                default_value = true
            }, {
                setting_id = "otwm_difficulty_preset",
                type = "dropdown",
                title = "set_tw_difficulty_preset_title",
                tooltip = "set_tw_difficulty_preset_descr",
                default_value = "normal",
                options = {
                    {text = "set_tw_difficulty_preset_descr_hardest", value = "hardest"},
                    {text = "set_tw_difficulty_preset_descr_hard", value = "hard"},
                    {text = "set_tw_difficulty_preset_descr_normal", value = "normal"},
                    {text = "set_tw_difficulty_preset_descr_easy", value = "easy"}
                }
            }, {
                setting_id = "otwm_tw_buffs",
                type = "group",
                title = "otwm_tw_buffs_title",
                sub_widgets = {
                    {
                        setting_id = "twitch_add_speed_potion_buff",
                        type = "checkbox",
                        title = Localize("twitch_vote_speed_potion_buff_all"),
                        default_value = true
                    }, {
                        setting_id = "twitch_add_damage_potion_buff",
                        type = "checkbox",
                        title = Localize("twitch_vote_damage_potion_buff_all"),
                        default_value = true
                    }, {
                        setting_id = "twitch_add_cooldown_potion_buff",
                        type = "checkbox",
                        title = Localize("twitch_vote_cooldown_potion_buff_all"),
                        default_value = true
                    }, {
                        setting_id = "twitch_grimoire_health_debuff",
                        type = "checkbox",
                        title = Localize("twitch_vote_grimoire_health_debuff_all"),
                        default_value = true
                    }, {
                        setting_id = "twitch_no_overcharge_no_ammo_reloads",
                        type = "checkbox",
                        title = Localize("twitch_vote_twitch_no_overcharge_no_ammo_reloads_all"),
                        default_value = true
                    }, {
                        setting_id = "twitch_health_regen",
                        type = "checkbox",
                        title = Localize("twitch_vote_health_regen_all"),
                        default_value = true
                    }, {
                        setting_id = "twitch_health_degen",
                        type = "checkbox",
                        title = Localize("twitch_vote_health_degen_all"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_activate_root_all",
                        type = "checkbox",
                        title = Localize("display_name_twitch_root_all"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_activate_root",
                        type = "checkbox",
                        title = Localize("display_name_twitch_root"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_hemmoraghe",
                        type = "checkbox",
                        title = Localize("display_name_hemmoraghe"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_full_temp_hp",
                        type = "checkbox",
                        title = Localize("display_name_twitch_full_temp_hp"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_critical_strikes",
                        type = "checkbox",
                        title = Localize("display_name_twitch_critical_strikes"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_infinite_bombs",
                        type = "checkbox",
                        title = Localize("display_name_twitch_infinite_bombs"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_invincibility",
                        type = "checkbox",
                        title = Localize("display_name_twitch_invincibility"),
                        default_value = true
                    }
                }
            }, {
                setting_id = "otwm_tw_items",
                type = "group",
                title = "otwm_tw_items_title",
                sub_widgets = {
                    {
                        setting_id = "twitch_give_first_aid_kit",
                        type = "checkbox",
                        title = Localize("healthkit_first_aid_kit_01"),
                        tooltip = Localize("twitch_give_first_aid_kit_one"),
                        default_value = true
                    }, {
                        setting_id = "twitch_give_healing_draught",
                        type = "checkbox",
                        title = Localize("potion_healing_draught_01"),
                        tooltip = Localize("twitch_give_healing_draught_one"),
                        default_value = true
                    }, {
                        setting_id = "twitch_give_damage_boost_potion",
                        type = "checkbox",
                        title = Localize("potion_damage_boost_01"),
                        tooltip = Localize("twitch_give_damage_boost_potion_one"),
                        default_value = true
                    }, {
                        setting_id = "twitch_give_speed_boost_potion",
                        type = "checkbox",
                        title = Localize("potion_speed_boost_01"),
                        tooltip = Localize("twitch_give_speed_boost_potion_one"),
                        default_value = true
                    }, {
                        setting_id = "twitch_give_cooldown_reduction_potion",
                        type = "checkbox",
                        title = Localize("potion_cooldown_reduction_01"),
                        tooltip = Localize("twitch_give_cooldown_reduction_potion_one"),
                        default_value = true
                    }, {
                        setting_id = "twitch_give_frag_grenade_t1",
                        type = "checkbox",
                        title = Localize("grenade_frag"),
                        tooltip = Localize("twitch_give_frag_grenade_t1_one"),
                        default_value = true
                    }, {
                        setting_id = "twitch_give_fire_grenade_t1",
                        type = "checkbox",
                        title = Localize("grenade_fire"),
                        tooltip = Localize("twitch_give_fire_grenade_t1_one"),
                        default_value = true
                    }
                }
            }, {
                setting_id = "otwm_tw_mutators",
                type = "group",
                title = "otwm_tw_mutators_title",
                sub_widgets = {
                    {
                        setting_id = "twitch_vote_activate_splitting_enemies",
                        type = "checkbox",
                        title = Localize("display_name_mutator_splitting_enemies"),
                        tooltip = Localize("description_mutator_splitting_enemies"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_activate_leash",
                        type = "checkbox",
                        title = Localize("display_name_mutator_leash"),
                        tooltip = Localize("description_mutator_leash"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_activate_slayer_curse",
                        type = "checkbox",
                        title = Localize("display_name_mutator_slayer_curse"),
                        tooltip = Localize("description_mutator_slayer_curse"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_activate_bloodlust",
                        type = "checkbox",
                        title = Localize("display_name_mutator_bloodlust"),
                        tooltip = Localize("description_mutator_bloodlust"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_activate_realism",
                        type = "checkbox",
                        title = Localize("display_name_mutator_realism"),
                        tooltip = Localize("description_mutator_realism"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_activate_darkness",
                        type = "checkbox",
                        title = Localize("display_name_mutator_darkness"),
                        tooltip = Localize("description_mutator_darkness"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_activate_ticking_bomb",
                        type = "checkbox",
                        title = Localize("display_name_mutator_ticking_bomb"),
                        tooltip = Localize("description_mutator_ticking_bomb"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_activate_lightning_strike",
                        type = "checkbox",
                        title = Localize("display_name_lightning_strike"),
                        tooltip = Localize("description_mutator_lightning_strike"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_activate_chasing_spirits",
                        type = "checkbox",
                        title = Localize("display_name_chasing_spirits"),
                        tooltip = Localize("description_mutator_chasing_spirits"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_activate_flames",
                        type = "checkbox",
                        title = Localize("display_name_flames"),
                        tooltip = Localize("description_mutator_flames"),
                        default_value = true
                    }
                }
            }, {
                setting_id = "otwm_tw_spawning",
                type = "group",
                title = "otwm_tw_spawning_title",
                sub_widgets = {
                    {
                        setting_id = "twitch_spawn_rat_ogre",
                        type = "checkbox",
                        title = Localize("skaven_rat_ogre"),
                        tooltip = Localize("twitch_vote_spawn_rat_ogre"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_stormfiend",
                        type = "checkbox",
                        title = Localize("skaven_stormfiend"),
                        tooltip = Localize("twitch_vote_spawn_stormfiend"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_chaos_troll",
                        type = "checkbox",
                        title = Localize("chaos_troll"),
                        tooltip = Localize("twitch_vote_spawn_chaos_troll"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_chaos_spawn",
                        type = "checkbox",
                        title = Localize("chaos_spawn"),
                        tooltip = Localize("twitch_vote_spawn_chaos_spawn"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_minotaur",
                        type = "checkbox",
                        title = Localize("beastmen_minotaur"),
                        tooltip = Localize("twitch_vote_spawn_minotaur"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_corruptor_sorcerer",
                        type = "checkbox",
                        title = Localize("chaos_corruptor_sorcerer"),
                        tooltip = Localize("twitch_vote_spawn_corruptor_sorcerer"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_vortex_sorcerer",
                        type = "checkbox",
                        title = Localize("chaos_vortex_sorcerer"),
                        tooltip = Localize("twitch_vote_spawn_vortex_sorcerer"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_gutter_runner",
                        type = "checkbox",
                        title = Localize("skaven_gutter_runner"),
                        tooltip = Localize("twitch_vote_spawn_gutter_runner"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_pack_master",
                        type = "checkbox",
                        title = Localize("skaven_pack_master"),
                        tooltip = Localize("twitch_vote_spawn_pack_master"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_poison_wind_globadier",
                        type = "checkbox",
                        title = Localize("skaven_poison_wind_globadier"),
                        tooltip = Localize("twitch_vote_spawn_poison_wind_globadier"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_ratling_gunner",
                        type = "checkbox",
                        title = Localize("skaven_ratling_gunner"),
                        tooltip = Localize("twitch_vote_spawn_ratling_gunner"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_warpfire_thrower",
                        type = "checkbox",
                        title = Localize("skaven_warpfire_thrower"),
                        tooltip = Localize("twitch_vote_spawn_warpfire_thrower"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_horde_vector_blob",
                        type = "checkbox",
                        title = Localize("twitch_vote_spawn_horde"),
                        tooltip = Localize("morris_bay_fight_horde"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_explosive_loot_rats",
                        type = "checkbox",
                        title = Localize("display_name_explosive_loot_rats"),
                        tooltip = Localize("description_explosive_loot_rats"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_plague_monks",
                        type = "checkbox",
                        title = Localize("skaven_plague_monk"),
                        tooltip = Localize("twitch_vote_spawn_plague_monks"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_berzerkers",
                        type = "checkbox",
                        title = Localize("chaos_berzerker"),
                        tooltip = Localize("twitch_vote_spawn_berzerkers"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_death_squad_storm_vermin",
                        type = "checkbox",
                        title = Localize("skaven_storm_vermin"),
                        tooltip = Localize("twitch_vote_spawn_death_squad_storm_vermin"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_death_squad_chaos_warrior",
                        type = "checkbox",
                        title = Localize("chaos_warrior"),
                        tooltip = Localize("twitch_vote_spawn_death_squad_chaos_warrior"),
                        default_value = true
                    }, {
                        setting_id = "twitch_spawn_loot_rat_fiesta",
                        type = "checkbox",
                        title = Localize("skaven_loot_rat"),
                        tooltip = Localize("twitch_vote_spawn_loot_rat_fiesta"),
                        default_value = true
                    }
                }
            }, {
                setting_id = "otwm_tw_chaos_wastes",
                type = "group",
                title = "otwm_tw_chaos_wastes_title",
                sub_widgets = {
                    {
                        setting_id = "twitch_vote_deus_select_level_arena_citadel",
                        type = "checkbox",
                        title = Localize("arena_citadel_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_arena_ruin",
                        type = "checkbox",
                        title = Localize("arena_ruin_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_arena_cave",
                        type = "checkbox",
                        title = Localize("arena_cave_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_arena_ice",
                        type = "checkbox",
                        title = Localize("arena_ice_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_pat_mountain",
                        type = "checkbox",
                        title = Localize("pat_mountain_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_pat_forest",
                        type = "checkbox",
                        title = Localize("pat_forest_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_pat_mines",
                        type = "checkbox",
                        title = Localize("pat_mines_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_pat_tower",
                        type = "checkbox",
                        title = Localize("pat_tower_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_pat_town",
                        type = "checkbox",
                        title = Localize("pat_town_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_pat_bay",
                        type = "checkbox",
                        title = Localize("pat_bay_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_sig_volcano",
                        type = "checkbox",
                        title = Localize("sig_volcano_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_sig_citadel",
                        type = "checkbox",
                        title = Localize("sig_citadel_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_sig_mordrek",
                        type = "checkbox",
                        title = Localize("sig_mordrek_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_sig_gorge",
                        type = "checkbox",
                        title = Localize("sig_gorge_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_sig_snare",
                        type = "checkbox",
                        title = Localize("sig_snare_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_sig_crag",
                        type = "checkbox",
                        title = Localize("sig_crag_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_shop_harmony",
                        type = "checkbox",
                        title = Localize("shop_harmony_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_shop_fortune",
                        type = "checkbox",
                        title = Localize("shop_fortune_title"),
                        default_value = true
                    }, {
                        setting_id = "twitch_vote_deus_select_level_shop_strife",
                        type = "checkbox",
                        title = Localize("shop_strife_title"),
                        default_value = true
                    }
                }
            }
        }
    }
}
