local mod = get_mod("offline_twitch")

--[[
    IRC-Manager skipping connecting to Twitch services if user choose fake twitch
    #########################
--]]
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