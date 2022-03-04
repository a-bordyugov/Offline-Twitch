local mod = get_mod("offline_twitch")

-- Returning fake responses for Twitch connection requests
mod:hook_origin(CurlManager, "get", function (self, url, headers, request_cb, userdata, options)
    local fake_login_data = "{\"_total\": 1,\"users\": [{\"_id\": \"11111111\",\"bio\": \"\",\"created_at\": \"2013-06-03T19:12:02.580593Z\",\"display_name\": \"Offline Twitch\",\"logo\": \"\",\"name\": \"fake_twitch\",\"type\": \"staff\",\"updated_at\": \"2017-02-09T16:32:06.784398Z\"}]}"
    local fake_steam_data = "{\"stream\": {\"_id\": 11111111111,\"game\": \"Warhammer Vermintide 2\",\"viewers\": 1,\"video_height\": 720,\"average_fps\": 60,\"delay\": 0,\"created_at\": \"2016-12-14T22:49:56Z\",\"is_playlist\": false,\"preview\": {\"small\": \"\",\"medium\": \"\",\"large\": \"\",\"template\": \"\"},\"channel\": {\"mature\": false,\"status\": \"\",\"broadcaster_language\": \"en\",\"display_name\": \"Offline Twitch\",\"game\": \"Warhammer Vermintide 2\",\"language\": \"en\",\"_id\": 1111111,\"name\": \"fake_twitch\",\"created_at\": \"2009-07-15T03:02:41Z\",\"updated_at\": \"2016-12-15T01:33:58Z\",\"partner\": true,\"logo\": \"\",\"video_banner\": \"\",\"profile_banner\": \"\",\"profile_banner_background_color\": null,\"url\": \"https://127.0.0.1/lol\",\"views\": 1,\"followers\": 1}}}"

    if url == "https://api.twitch.tv/kraken/users?login=fake_twitch" then
        mod:echo("Throwing a fake login inormation...")
        return request_cb(true, 200, headers, fake_login_data, userdata)
    elseif url == "https://api.twitch.tv/kraken/streams/11111111" then
        mod:echo("Throwing a fake stream information...")
        return request_cb(true, 200, headers, fake_steam_data, userdata)
    else
        self:add_request("GET", url, nil, headers, request_cb, userdata, options)
    end
end)

-- Telling the game that the IRC connection was successfully initialized
mod:hook_origin(IRCManager, "connect", function (self, user_name, optional_password, settings, cb)
    if settings.address == "irc.chat.twitch.tv" then
        mod:echo("Skipping IRC-connection...")
        return cb("initialize")
    end

    local address = settings.address
    local port = settings.port or 6667
    local channel_name = settings.channel_name
    local allow_send = settings.allow_send

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

-- Autocomplete for Twitch username input field
mod:hook_safe(StartGameWindowTwitchLogin, "create_ui_elements", function(self)
    local widget = self._widgets_by_name["frame_widget"]
    local style = widget.style["twitch_name"]
    -- Reduce a large gap on the left
    style.offset = { 5, 10, 10 }
    -- Correctly position the caret after the letter
    style.caret_offset = { -6, -4, 0 }

    local twitch_username = "fake_twitch"
    local content = widget.content
    content.twitch_name = twitch_username
    content.caret_index = string.len(twitch_username) + 1
end)

-- Fixing a cause when Twitch won't to be disabled
mod:hook_origin(StartGameWindowTwitchLogin, "_is_button_pressed", function (self, widget)
    local content = widget.content
    local hotspot = content.button_hotspot
    local text = hotspot.text

    if hotspot.on_release then
        hotspot.on_release = false

        if string.find(text, "Disconnect from") == 1 then
            mod:echo("Twitch mode is disabled now...")
            Managers.twitch = TwitchManager:new()
        end

        return true
    end
end)