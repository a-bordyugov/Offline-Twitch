return {
    --[[
		Mod info
		#########################
	--]]
    mod_description = {
        en = "Allows you to start Twitch mode without being connected to Twitch services",
        ru = "Позволяет запустить Твич мод без подключения к их серверам",
        zh = "允许您在不连接到Twitch服务的情况下启动Twitch模式"
    },
    --[[
		Mod settings
		#########################
	--]]
    set_tw_fow_title = {
        en = "Enable on Fortunes of War",
        ru = "Включить на Превратностях Войны",
        zh = ""
    },
    set_tw_fow_descr = {
        en = "Enable Twitch integration on Fortunes of War",
        ru = "Разрешает использование Твича на секретной карте \"Превратности Войны\"",
        zh = ""
    },
    set_tw_weaves_title = {en = "Enable on Weaves", ru = "Включить в \"Cплетениях\"", zh = ""},
    set_tw_weaves_descr = {
        en = "Enable Twitch integration on Weaves(I am not sure you want it)",
        ru = "Разрешает использование Твича в режиме \"Сплетений\"(Для любителей жесткого обращения с собой)",
        zh = ""
    },
    set_tw_difficulty_preset_title = {en = "Difficulty presets", ru = "Пресеты сложности", zh = ""},
    set_tw_difficulty_preset_descr = {
        en = "Descr",
        ru = [[
Настройки сложности для выборки голосований Твича.
Опция "Нормально" восстанавливает настройки, которые были установлены разработчиками игры.
-----------
Очень сложно: Положительные голосования имеют низкий приоритет. Чаще всего вам будут выпадать: проклятья, боссы и т.п.

Сложно: Положительные голосования имеют средне-низкий приоритет.

Нормально: Положительные и негативные голосования сбалансированы разработчиками игры.

Легко: Положительные голосования имеют высокий приоритет. Чаще всего вам будут выпадать: аптечки, зелья и т.п.
		]],
        zh = ""
    },
    set_tw_difficulty_preset_descr_hardest = {en = "Very hard", ru = "Очень сложно", zh = ""},
    set_tw_difficulty_preset_descr_hard = {en = "Hard", ru = "Сложно", zh = ""},
    set_tw_difficulty_preset_descr_normal = {en = "Normal", ru = "Нормально", zh = ""},
    set_tw_difficulty_preset_descr_easy = {en = "Easy", ru = "Легко", zh = ""},
    --[[
		Section names
		#########################
	--]]
    otwm_tw_buffs_title = {en = "Buffs", ru = "Бафы", zh = ""},
    otwm_tw_items_title = {en = "Items", ru = "Предметы", zh = ""},
    otwm_tw_mutators_title = {en = "Mutators", ru = "Мутаторы", zh = ""},
    otwm_tw_spawning_title = {
        en = "Heavy/Specials/Elite enemies",
        ru = "Тяжелые/Особые/Элитные противники",
        zh = ""
    },
    otwm_tw_chaos_wastes_title = {en = "Chaos Wastes", ru = "Пустоши Хаоса", zh = ""},
    --[[
		Information which can be typed in chat
		#########################
	--]]
    mod_disable_msg = {
        en = "Offline Twitch mod is now disabled...",
        ru = "Мод Offline Twitch выключен...",
        zh = ""
    },
    mod_enable_msg = {
        en = "Offline Twitch mod is now enabled...",
        ru = "Мод Offline Twitch включен...",
        zh = ""
    },
    con_irc_skip_msg = {
        en = "Skipping IRC-connection...",
        ru = "Пропуск IRC-подключения...",
        zh = "绕过IRC连接。。。"
    },
    con_fake_login_msg = {
        en = "Throwing a fake login inormation...",
        ru = "Возврат фейковой информации о подключении #1...",
        zh = "绕过与TW#1服务器的连接。。。"
    },
    con_fake_stream_msg = {
        en = "Throwing a fake stream information...",
        ru = "Возврат фейковой информации о подключении #2...",
        zh = "绕过与TW#2服务器的连接。。。"
    },
    tw_ds_msg = {
        en = "Offline Twitch is disabled now...",
        ru = "Offline Twitch отключен...",
        zh = "Offline Twitch 已禁用。。。"
    },
    tw_destroy_ingame = {
        en = "Origin Twitch settings has been restored. Mod Offline Twitch is disabled now. Twitch game can be disabled in Keep.",
        ru = "Оригинальные настройки твича восстановлены. Мод Offline Twitch отключен. Твич можно отключить в цитадели.",
        zh = ""
    },
    tw_con_msg = {
        en = "Offline Twitch is enabled now...",
        ru = "Offline Twitch подключен...",
        zh = "Offline Twitch 已连接。。。"
    },
    chat_vote_denied = {
        en = "There is currently no active vote to vote for",
        ru = "Сейчас нет активного голосования",
        zh = "目前没有活跃的投票可以投票"
    },
    chat_vote_allowed = {
        en = "You voted successfully for option %s",
        ru = "Вы проголосовали за: %s",
        zh = "你投票给 %s"
    },
    chat_vote_error = {
        en = "Couldn't get vote data for vote %s",
        ru = "Не удалось проголосовать за: %s",
        zh = "%s 投票失败"
    },
    --[[
		Chat voting
		#########################
	--]]
    cmd_vote_a_descr = {
        en = "Vote for option A",
        ru = "Проголосовать за вариант A",
        zh = "投票给选项 A"
    },
    cmd_vote_b_descr = {
        en = "Vote for option B",
        ru = "Проголосовать за вариант B",
        zh = "投票给选项 B"
    },
    cmd_vote_c_descr = {
        en = "Vote for option C",
        ru = "Проголосовать за вариант C",
        zh = "投票给选项 C"
    },
    cmd_vote_d_descr = {
        en = "Vote for option D",
        ru = "Проголосовать за вариант D",
        zh = "投票给选项 D"
    },
    cmd_vote_e_descr = {
        en = "Vote for option E",
        ru = "Проголосовать за вариант E",
        zh = "投票给选项 E"
    }
}
