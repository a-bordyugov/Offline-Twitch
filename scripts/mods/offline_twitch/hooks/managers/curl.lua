local mod = get_mod("offline_twitch")

-- Returning fake data for requests
mod:hook_origin(CurlManager, "get", function(self, url, headers, request_cb, userdata, options)
    if url == "https://api.twitch.tv/helix/users?login=fake_twitch" then
        mod:info(mod:localize("con_fake_login_msg"))
        return request_cb(true, 200, headers, TW_Tweaker._fake_tw_data.login, userdata)
    elseif url == "https://api.twitch.tv/helix/streams?user_id=00000000" then
        mod:info(mod:localize("con_fake_stream_msg"))
        return request_cb(true, 200, headers, TW_Tweaker._fake_tw_data.stream, userdata)
    else
        self:add_request("GET", url, nil, headers, request_cb, userdata, options)
    end
end)