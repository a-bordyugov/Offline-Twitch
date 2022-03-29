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
end)
