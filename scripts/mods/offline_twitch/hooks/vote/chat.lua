local mod = get_mod("offline_twitch")

--[[
    Searching new messages in chat for vote key
    #########################
--]]
mod:hook_safe(ChatManager, "_add_message_to_list", function(self, channel_id, message_sender, local_player_id, message, is_system_message, pop_chat, is_dev, message_type, link, data)
    if not IS_WINDOWS and not self._chat_enabled then
		return
	end

    local vote_keys = {"#a", "#b", "#c", "#d", "#e", "#A", "#B", "#C", "#D", "#E"}

    if (not table.contains(vote_keys, message)) then
        return
    end

    if not is_system_message and TW_Tweaker._is_server then
		--message = string.gsub(message, "#", "")
        message = string.lower(message)
        TW_Tweaker:add_vote(message)
	end
end)