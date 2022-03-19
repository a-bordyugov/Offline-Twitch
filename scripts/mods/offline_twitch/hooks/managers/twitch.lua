local mod = get_mod('offline_twitch')

mod:hook_origin(
    TwitchGameMode,
    'cb_on_vote_complete',
    function(self, current_vote)
        Managers.telemetry.events:twitch_poll_completed(current_vote)

        local winning_template = TwitchVoteTemplates[current_vote.winning_template_name]
        self._funds = self._funds + winning_template.cost
        self._used_vote_templates[winning_template.name] = TW_Tweaker._NUM_ROUNDS_TO_DISABLE_USED_VOTES
        self._vote_keys[current_vote.vote_key] = nil
    end
)

mod:hook_origin(
    TwitchGameMode,
    '_clear_used_votes',
    function(self, force_clear)
        local used_vote_templates = self._used_vote_templates
        local game_mode_whitelist = self:_get_game_mode_whitelist()
        local num_available_vote_templates =
            (game_mode_whitelist and #game_mode_whitelist) or #TwitchVoteTemplatesLookup

        if
            force_clear or
                num_available_vote_templates - table.size(used_vote_templates) <= TW_Tweaker._MIN_VOTES_LEFT_IN_ROTATION
         then
            table.clear(used_vote_templates)
        end
    end
)

mod:hook_safe(
    TwitchManager,
    'disconnect',
    function()
        if (Managers.twitch._twitch_user_name == 'fake_twitch') then
            Managers.twitch = TwitchManager:new()
        end
    end
)
