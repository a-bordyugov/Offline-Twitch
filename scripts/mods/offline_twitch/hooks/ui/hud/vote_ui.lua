local mod = get_mod("offline_twitch")

--[[
    Fixing an issue when game won't to hide a reseted vote
    Unlock an unreleased breed packages to avoid a crash when the game try to unload it
    #########################
--]]
mod:hook_safe(TwitchVoteUI, "event_reset_vote_ui", function(self, vote_key)
    -- Hide unreleased vote UI
    if vote_key then
		if self._active_vote and self._active_vote.vote_key == vote_key then
			self:hide_ui()
		end
    end

    -- Unlock breeds
    local locked_breeds = Managers.twitch.locked_breed_packages

    for a_name, _ in pairs(locked_breeds) do
        Managers.level_transition_handler.enemy_package_loader:unlock_breed_package(a_name)
        locked_breeds[a_name] = nil
    end
end)
