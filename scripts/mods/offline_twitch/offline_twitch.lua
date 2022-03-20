local mod = get_mod("offline_twitch")

-- Classes
dofile("scripts/mods/offline_twitch/classes/offline_twitch")

-- Managers
dofile("scripts/mods/offline_twitch/hooks/managers/curl")
dofile("scripts/mods/offline_twitch/hooks/managers/irc")
dofile("scripts/mods/offline_twitch/hooks/managers/twitch")

-- UI
dofile("scripts/mods/offline_twitch/hooks/ui/legacy")
dofile("scripts/mods/offline_twitch/hooks/ui/unified")

-- Voting
dofile("scripts/mods/offline_twitch/hooks/vote/chat")

-- Settings
dofile("scripts/mods/offline_twitch/settings/fow")
dofile("scripts/mods/offline_twitch/settings/weaves")
dofile("scripts/mods/offline_twitch/settings/options")

function mod.on_all_mods_loaded()
    TW_Tweaker:__on_change({"loaded"})
end

--[[
function mod.on_enabled()
    twTweak:_on_change({"enabled"})
end
--]]
function mod.on_game_state_changed(status, state_name)
    if (status == "exit" and state_name == "StateLoading") then
        -- TW_Tweaker._is_server = Managers.state.network and Managers.state.network.is_server
        mod:echo("IS SERVER:")
        mod:echo(TW_Tweaker._is_server)
    end
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
