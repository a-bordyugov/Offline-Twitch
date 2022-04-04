local mod = get_mod("offline_twitch")

--[[
    Fixing an issue when game won't to hide a reseted vote
    #########################
--]]
mod:hook_safe(TwitchVoteUI, "event_reset_vote_ui", function(self)
    -- Hide unreleased vote UI
    if (not self._fade_out) then
        self:hide_ui()
    end

    -- Unlock twitch breed packages to avoid game crash
    local locked_breeds = Managers.twitch.locked_breed_packages

    for a_name, _ in pairs(locked_breeds) do
        Managers.level_transition_handler.enemy_package_loader:unlock_breed_package(a_name)
        locked_breeds[a_name] = nil
    end
end)
