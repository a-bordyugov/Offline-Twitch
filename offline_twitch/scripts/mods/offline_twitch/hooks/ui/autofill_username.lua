local mod = get_mod("offline_twitch")

--[[
    Autocomplete for Twitch username input field
    #########################
--]]
local function autofill_username(self)
    local widget = self._widgets_by_name["frame_widget"]
    local style = widget.style["twitch_name"]
    -- Reduce a large gap on the left
    style.offset = {5, 10, 10}
    -- Correctly position the caret after the letter
    style.caret_offset = {-6, -4, 0}

    local twitch_username = "fake_twitch"
    local content = widget.content
    content.twitch_name = twitch_username
    content.caret_index = string.len(twitch_username) + 1
end

-- Unified UI
mod:hook_safe(StartGameWindowTwitchOverviewConsole, "_create_ui_elements", function(self)
    autofill_username(self)
end)

-- Lagacy UI
mod:hook_safe(StartGameWindowTwitchLogin, "create_ui_elements", function(self)
    autofill_username(self)
end)

-- Chaos Wastes UI
mod:hook_safe(StartGameWindowDeusTwitch, "_create_ui_elements", function(self)
    autofill_username(self)
end)