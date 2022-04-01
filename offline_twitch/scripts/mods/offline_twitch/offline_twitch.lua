local mod = get_mod("offline_twitch")

-- Classes
dofile("scripts/mods/offline_twitch/classes/offline_twitch")

-- Managers
dofile("scripts/mods/offline_twitch/hooks/managers/curl")
dofile("scripts/mods/offline_twitch/hooks/managers/irc")
dofile("scripts/mods/offline_twitch/hooks/managers/twitch")
dofile("scripts/mods/offline_twitch/hooks/managers/chat")

-- UI
dofile("scripts/mods/offline_twitch/hooks/ui/hud/vote_ui")
dofile("scripts/mods/offline_twitch/hooks/ui/views/ingame_ui")
dofile("scripts/mods/offline_twitch/hooks/ui/autofill_username")

-- Settings
dofile("scripts/mods/offline_twitch/settings/fow")
dofile("scripts/mods/offline_twitch/settings/weaves")
dofile("scripts/mods/offline_twitch/settings/options")

function mod.on_all_mods_loaded()
    TW_Tweaker:__on_change({"loaded"})
end

function mod.on_enabled()
    TW_Tweaker:__on_change({"enabled"})
end

function mod.on_game_state_changed()
    TW_Tweaker:__on_change({"game_state_changed"})
end

function mod.on_setting_changed(setting_name)
    TW_Tweaker:__on_change({"settings", setting_name})
end

function mod.on_disabled()
    TW_Tweaker:__on_change({"disabled"})
end

function mod.on_unload()
    TW_Tweaker:__on_change({"unload"})
end