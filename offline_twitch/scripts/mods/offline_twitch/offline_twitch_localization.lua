return {
    --[[
		Mod info
		#########################
	--]]
    mod_name = {
        en = "Offline Twitch",
        ru = "Offline Twitch",
        zh = "Offline Twitch [译者: KabutackMonster]"
    },
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
        ru = "Включить в Превратностях Войны",
        zh = "战争财富"
    },
    set_tw_fow_descr = {
        en = "Enable Twitch integration on Fortunes of War",
        ru = "Разрешает использование Твича на секретной карте \"Превратности Войны\"",
        zh = "启动战争财富TW"
    },
    set_tw_weaves_title = {en = "Enable on Weaves", ru = "Включить в \"Cплетениях\"", zh = "魔网"},
    set_tw_weaves_descr = {
        en = "Enable Twitch integration on Weaves(I am not sure you want it)",
        ru = "Разрешает использование Твича в режиме \"Сплетений\"(Для любителей жесткого обращения с собой)",
        zh = "魔网TW已开启(打不过去找青蛙带吧)"
    },
    set_tw_cw_title = {
        en = "Enable on Chaos Wastes",
        ru = "Включить в \"Пустошах Хаоса\"",
        zh = "混沌荒原"
    },
    set_tw_cw_descr = {
        en = "Enable votes on \"Holseher's map\"",
        ru = "Включает голосования на \"Карте Хольсгера\"",
        zh = "启用地图自主选择"
    },
    set_tw_vote_percentage_skip_title = {
        en = "Skip current voting",
        ru = "Пропуск текущего голосования",
        zh = "跳过当前投票"
    },
    set_tw_vote_percentage_skip_descr = {
        en = [[
Players can vote to skip the current twitch vote.
To do this, send a command to the chat: (#skip or #SKIP) or (#tws or #TWS).

There are 2 options available:
">= 50" - Voting will be skipped if the percentage of voters is EQUAL or GREATER than 50
"> 50" - Voting will be skipped if the percentage of voters EXCEEDS 50
        ]],
        ru = [[
Игроки могут проголосовать за пропуск текущего твич голосования.
Для этого необходимо отправить команду в чат: (#skip или #SKIP) или (#tws или #TWS).

Доступно 2 опции:
">= 50" - Голосование будет пропущено если процент проголосовавших РАВЕН или ПРЕВЫШАЕТ 50
"> 50" - Голосование будет пропущено если процент проголосовавших ПРЕВЫШАЕТ 50
        ]],
        zh = [[
玩家可以通过投票来跳过TW投票:
首先，需要在聊天框中输入：(#skip 或 #SKIP) 或者 (#tws 或 #TWS).

有两种选项供选择：
">=50" 如果投票结果大于或等于百分之五十投票将被跳过
">50" 如果投票结果大于百分之五十投票将被跳过
        ]]
    },
    set_tw_vote_skip_greater_than_50 = {en = "> 50"},
    set_tw_vote_skip_equal_50 = {en = ">= 50"},
    set_tw_difficulty_preset_title = {
        en = "Difficulty presets",
        ru = "Пресеты сложности",
        zh = "难度设置"
    },
    set_tw_difficulty_preset_descr = {
        en = [[
Difficulty settings for game choosing Twitch votes.

Hard: Positive votes have low priority. Most often you will get: curses, bosses, etc.
Normal: Positive and negative votes are balanced by the game developers.
        ]],
        ru = [[
Настройки сложности для выборки голосований Твича.

Сложно: Положительные голосования имеют низкий приоритет. Чаще всего вам будут выпадать: проклятья, боссы и т.п.
Нормально: Положительные и негативные голосования сбалансированы разработчиками игры.
		]],
        zh = [[
为您的TW设置难度.

“困难”: 这个难度下基本不会出现祝福，你会不停的受到诅咒，特感的贴贴，和来自怪物的关爱.
“正常”: 这是一个诅咒和祝福平均出现的难度 (和开祝福的官服TW一个难度).
        ]]
    },
    set_tw_difficulty_preset_descr_hardest = {en = "Very hard", ru = "Очень сложно", zh = "非常困难"},
    set_tw_difficulty_preset_descr_hard = {en = "Hard", ru = "Сложно", zh = "困难"},
    set_tw_difficulty_preset_descr_normal = {en = "Normal", ru = "Нормально", zh = "正常"},
    set_tw_difficulty_preset_descr_easy = {en = "Easy", ru = "Легко", zh = "新手"},
    --[[
		Section names
		#########################
	--]]
    otwm_tw_buffs_title = {en = "Buffs", ru = "Бафы", zh = "buff祝福"},
    otwm_tw_items_title = {en = "Items", ru = "Предметы", zh = "道具祝福"},
    otwm_tw_mutators_title = {en = "Mutators", ru = "Мутаторы", zh = "每周事件"},
    otwm_tw_spawning_title = {
        en = "Heavy/Specials/Elite enemies",
        ru = "Тяжелые/Особые/Элитные противники",
        zh = "潮/特感/精英"
    },
    --[[
		Information which can be typed in chat
		#########################
	--]]
    vote_skip_info = {
        en = [[
Voted: %s/%s
Required votes to skip: %s
        ]],
        ru = [[
Проголосовало: %s/%s
Необходимый минимум: %s
        ]],
        zh = [[
总票数: %s/%s
所需的最低票数: %s
        ]]
    },
    settings_undone = {
        en = "[Offline Twitch] Some settings can't be changed: Twitch Weekly Events, Twitch Blessings",
        ru = "[Offline Twitch] Некоторые настройки не могут быть изменены: Твич Еженедельные события, Твич Благословения",
        zh = "[Offline Twitch] 有一些设置不能改： 每周事件，祝福"
    },
    mod_disable_msg = {
        en = "Offline Twitch mod disabled",
        ru = "Мод Offline Twitch выключен",
        zh = "Offline Twitch 已关闭"
    },
    mod_enable_msg = {
        en = "Offline Twitch mod enabled",
        ru = "Мод Offline Twitch включен",
        zh = "Offline Twitch 已启动"
    },
    con_irc_skip_msg = {
        en = "Skipping IRC-connection",
        ru = "Пропуск IRC-подключения",
        zh = "绕过IRC连接"
    },
    con_fake_login_msg = {
        en = "Throwing a fake login inormation",
        ru = "Возврат фейковой информации о подключении #1",
        zh = "绕过与TW#1服务器的连接"
    },
    con_fake_stream_msg = {
        en = "Throwing a fake stream information",
        ru = "Возврат фейковой информации о подключении #2",
        zh = "绕过与TW#2服务器的连接"
    },
    tw_ds_msg = {en = "Twitch disabled", ru = "Twitch отключен", zh = "Twitch 已禁用"},
    tw_destroy_ingame = {
        en = "Original Twitch settings has been restored. Offline Twitch is disabled. Twitch mode can be disabled in Taal's Horn Keep.",
        ru = "Оригинальные настройки твича восстановлены. Offline Twitch отключен. Твич можно отключить в Цитадели Рога Таала.",
        zh = "原来的TW设置已恢复, 已关闭Offline Twitch. 你可以在塔尔之角要塞关闭TW模式."
    },
    tw_con_msg = {
        en = "Offline Twitch connected",
        ru = "Offline Twitch подключен",
        zh = "Offline Twitch 已连接"
    },
    chat_vote_denied = {
        en = "There is currently no active vote to vote for",
        ru = "Сейчас нет активного голосования",
        zh = "目前没有活动可以投票"
    },
    chat_vote_allowed = {
        en = "You voted for option %s",
        ru = "Вы проголосовали за: %s",
        zh = "你投票给 %s"
    },
    chat_vote_error = {
        en = "Couldn't voting for: %s",
        ru = "Не удалось проголосовать за: %s",
        zh = "不能投票给 %s"
    }
}
