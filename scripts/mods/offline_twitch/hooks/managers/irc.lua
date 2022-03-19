local mod = get_mod("offline_twitch")

-- We are not streamers, so.. we dont need a chat
mod:hook_origin(IRCManager, "connect", function(self, user_name, optional_password, settings, cb)
    local address = settings.address
    local port = settings.port or 6667
    local channel_name = settings.channel_name
    local allow_send = settings.allow_send

    if address == "irc.chat.twitch.tv" and channel_name == "#fake_twitch" then
        mod:info(mod:localize("con_irc_skip_msg"))

        return cb({result = true})
    end

    fassert(address and port, "[IRCManager] You need to provide both address and port when connecting to IRC")

    self._host_address = address
    self._port = port
    local default_user_name = "justinfan" .. Math.random(99999)
    self._user_name = user_name or self._user_name or default_user_name
    self._user_name = string.gsub(self._user_name, " ", "_")
    self._password = optional_password or nil
    self._auto_join_channel = channel_name
    self._home_channel = channel_name or ""

    self:_change_state("initialize")

    self._callback = cb
    self._allow_send = allow_send
end)

mod:hook_origin(IRCManager, "unregister_message_callback", function(self, key, optional_message_type)
    if (self._user_name == nil) then
        return true
    end

    if optional_message_type then
        self._callback_by_type[optional_message_type][key] = nil
    else
        for message_type, callbacks in pairs(self._callback_by_type) do
            self._callback_by_type[message_type][key] = nil
        end
    end
end)

mod:hook_origin(IRCManager, "register_message_callback", function(self, key, message_type, callback)
    if (self._user_name == nil) then
        mod:dump(callback, nil, 1)
        return true
    end

    fassert(self._callback_by_type[message_type], "[IRCManager] There is no message type called %s", message_type)

    self._callback_by_type[message_type][key] = callback
end)