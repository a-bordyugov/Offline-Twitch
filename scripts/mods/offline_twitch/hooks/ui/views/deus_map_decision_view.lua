local mod = get_mod("offline_twitch")

--[[
    Required original functions and variables for correct hooking from Mod
    #########################
--]]
local CAMERA_TRANSITION_DURATION = 2
local states = {
	TWITCH_STARTING = "TWITCH_STARTING",
	VOTING = "VOTING",
	FINISHED = "FINISHED",
	WAITING = "WAITING",
	VOTING_FINISHING = "VOTING_FINISHING",
	TWITCH_WAITING = "TWITCH_WAITING",
	FINISHING = "FINISHING",
	STARTING = "STARTING"
}

local shared_state_spec = {
	server = {
		map_state = {
			default_value = "",
			type = "string",
			composite_keys = {}
		},
		final_node_selected = {
			default_value = "",
			type = "string",
			composite_keys = {}
		}
	},
	peer = {
		ready = {
			default_value = false,
			type = "boolean",
			composite_keys = {}
		},
		vote = {
			default_value = "",
			type = "string",
			composite_keys = {}
		}
	}
}

SharedState.validate_spec(shared_state_spec)

local function get_next_node_types(deus_run_controller)
	local node_types = {}
	local current_node = deus_run_controller:get_current_node()

	for _, next in ipairs(current_node.next) do
		local next_node = deus_run_controller:get_node(next)

		table.insert(node_types, next_node.node_type)
	end

	return node_types
end

--[[
    Enable/Disable Twitch votes on Holseher's map
    #########################
--]]
mod:hook_origin(DeusMapDecisionView, "_start", function(self)
    self._state = states.IDLE
    local current_node_key = self._deus_run_controller:get_current_node_key()
    self._shared_state = SharedState:new("deus_map_" .. self._deus_run_controller:get_run_id() .. "_" ..
                                             current_node_key, shared_state_spec, self._is_server, self._network_server,
                                         self._server_peer_id, self._own_peer_id)

    self._shared_state:register_rpcs(self._network_event_delegate)
    self._shared_state:full_sync()
    self._shared_state:set_own(self._shared_state:get_key("ready"), true)

    local current_node = self._deus_run_controller:get_current_node()

    if self._is_server then
        local twitch_manager = Managers.twitch
        local is_twitch_voting = twitch_manager:is_connected() and #current_node.next == 2 and
                                     mod:get("otwm_cw_enabled")
        local map_state_key = self._shared_state:get_key("map_state")

        if is_twitch_voting then
            self._deus_run_controller:request_standard_twitch_level_vote(twitch_manager)
            self._shared_state:set_server(map_state_key, states.TWITCH_STARTING)
        else
            self._shared_state:set_server(map_state_key, states.STARTING)
        end

        self._shared_state:set_server(self._shared_state:get_key("final_node_selected"), "")

        local start_dialogue_event = nil
        local next_node_types = get_next_node_types(self._deus_run_controller)

        if table.contains(next_node_types, "shop") then
            start_dialogue_event = "deus_before_shrine_tutorial"
        else
            start_dialogue_event = "deus_map_tutorial"
        end

        local vo_unit = LevelHelper:find_dialogue_unit(self._world, "ferry_lady_01")
        local dialogue_input = ScriptUnit.extension_input(vo_unit, "dialogue_system")
        local event_data = FrameTable.alloc_table()

        dialogue_input:trigger_dialogue_event(start_dialogue_event, event_data)
    end

    self._shared_state:set_own(self._shared_state:get_key("vote"), "")

    if current_node_key ~= "start" then
        self._scene:set_zoomed_camera_to(current_node.layout_x, current_node.layout_y)
    end

    self._scene:animate_camera_to(current_node.layout_x, current_node.layout_y, CAMERA_TRANSITION_DURATION)

    local journey_name = self._deus_run_controller:get_journey_name()

    self._ui:set_journey_name(journey_name)
    self._ui:hide_content()
    self._ui:show_full_screen_rect()
    self._ui:set_alpha_multiplier(1)
    self._ui:fade_out(CAMERA_TRANSITION_DURATION)

    self._initial_animation_duration_left = CAMERA_TRANSITION_DURATION
    local visibility_data = self._deus_run_controller:get_map_visibility()
    self._visibility_data = visibility_data

    self._scene:setup_fog(visibility_data)

    local traversed_nodes = self._deus_run_controller:get_traversed_nodes()
    local prev_node = "start"

    self._scene:traversed_node(prev_node)

    for i = 1, #traversed_nodes, 1 do
        local node = traversed_nodes[i]

        if node ~= "start" then
            self._scene:traversed_node(node)
            self._scene:highlight_edge(prev_node, node)

            prev_node = node
        end
    end

    for _, next_node_key in ipairs(current_node.next) do
        self._scene:highlight_edge(current_node_key, next_node_key)
    end

    local unreachable_nodes = self._deus_run_controller:get_unreachable_nodes()

    for _, unreachable_node_key in ipairs(unreachable_nodes) do
        self._scene:unreachable_node(unreachable_node_key)
    end

    self._scene:select_node(current_node_key)
end)