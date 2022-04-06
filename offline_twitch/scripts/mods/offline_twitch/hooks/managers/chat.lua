local mod = get_mod("offline_twitch")

--[[
    Searching new commands in chat with messages
    #########################
--]]
mod:hook_safe("ChatManager", "_add_message_to_list", function(self, channel_id, message_sender, local_player_id, message, is_system_message, pop_chat, is_dev, message_type, link, data)
    if (not IS_WINDOWS or is_system_message) then
		return
	end

    message = string.lower(message)

    local vote_cmd = {"#a", "#b", "#c", "#d", "#e"}
    local skip_cmd = {"#skip", "#tws"}

    -- Skip current vote
    if (table.contains(skip_cmd, message)) then
        TW_Tweaker:skip_vote(message_sender)
    end

    -- Add vote
    if (table.contains(vote_cmd, message)) then
        TW_Tweaker:add_vote(message)
    end

    --message = string.gsub(message, "#", "")
end)