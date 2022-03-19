local mod = get_mod("offline_twitch")

local function create_command_function(option)
    option = string.lower(option)
    return function()
        local twitch_manager = Managers.twitch
        local current_vote = twitch_manager._current_vote or twitch_manager._vote_queue[1]

        if not current_vote then
            mod:echo(mod:localize("chat_vote_denied"))
            return
        end

        local vote_data = twitch_manager:get_vote_data(current_vote)

        if not vote_data then
            mod:error(mod:localize("chat_vote_error"), current_vote)
            return
        end

        for index, option_string in ipairs(vote_data.option_strings) do
            if string.find(option_string, option) then
                twitch_manager:vote_for_option(
                        current_vote,
                        Managers.player:local_player():name(),
                        index
                )
                mod:echo(mod:localize("chat_vote_allowed"), option)
            end
        end
    end
end

local vote_options = {
    "a", "b", "c", "d", "e",
    "A", "B", "C", "D", "E",
}

for _, vote_option in ipairs(vote_options) do
    mod:command(vote_option, mod:localize("cmd_vote_" .. string.lower(vote_option) .. "_descr"), create_command_function(vote_option))
end