---@diagnostic disable: lowercase-global
--- Fake game objects, to run the widgets outside Dual Universe.

local loaded = false

--- Loads the sources the widgets need (once) and resets the Lua parameters to their defaults.
function loadWidgets()
    if not loaded then
        for _, path in ipairs({ "includes/tools", "includes/Class", "classes/Widget", "classes/Hud", "classes/Sphere",
            "classes/Trilateration", "classes/Translator", "classes/Scanner", "classes/Helper",
            "classes/BoardWaypoint" }) do
            loadSource(path)
        end
        loaded = true
    end
    loadSource("parameters")
end

--- A fake `system`: records what the widgets print, show and set as waypoint.
function FakeSystem()
    local system = {
        printed = {},
        waypoints = {},
        screen = nil,
        screenUpdates = 0, -- number of setScreen() calls
        throttle = 0,
        width = 1920,
        height = 1080,
        cameraForward = { 0, 1, 0 },
        cameraRight = { 1, 0, 0 },
        cameraUp = { 0, 0, 1 },
        handlers = {},
    }

    function system.print(message) system.printed[#system.printed + 1] = tostring(message) end
    function system.setWaypoint(waypoint) system.waypoints[#system.waypoints + 1] = waypoint end
    function system.showScreen() end
    function system.setScreen(content)
        system.screen = content
        system.screenUpdates = system.screenUpdates + 1
    end
    function system.getActionKeyName(action) return "[" .. action .. "]" end
    function system.getThrottleInputFromMouseWheel() return system.throttle end
    function system.getScreenWidth() return system.width end
    function system.getScreenHeight() return system.height end
    function system.getCameraWorldForward() return system.cameraForward end
    function system.getCameraWorldRight() return system.cameraRight end
    function system.getCameraWorldUp() return system.cameraUp end

    -- Event handling, like the one DU-LuaC adds to the game objects.
    function system:onEvent(event, handler)
        local list = self.handlers[event] or {}
        self.handlers[event] = list
        list[#list + 1] = handler
        return #list
    end

    function system:clearEvent(event, id)
        if self.handlers[event] then self.handlers[event][id] = false end
    end

    -- Like DU-LuaC, handlers added while an event is dispatched only get the next ones.
    function system:triggerEvent(event, ...)
        local list = self.handlers[event] or {}
        for i = 1, #list do
            if list[i] then list[i](self, ...) end
        end
    end

    --- Number of handlers still registered for `event`.
    function system:handlerCount(event)
        local count = 0
        for _, handler in ipairs(self.handlers[event] or {}) do
            if handler then count = count + 1 end
        end
        return count
    end

    return system
end

--- A fake `player`, standing upright at `position` on a planet whose up is +z.
function FakePlayer(position)
    local player = { position = position or { 0, 0, 0 }, up = { 0, 0, 1 }, forward = { 0, 1, 0 } }
    function player.getWorldPosition() return player.position end
    function player.getWorldUp() return player.up end
    function player.getWorldForward() return player.forward end
    return player
end

--- A fake `construct` at `position`, with the given axes (world coordinates); change its fields to move it.
function FakeConstruct(position, right, forward, up)
    local construct = {
        position = position,
        right = right or { 1, 0, 0 },
        forward = forward or { 0, 1, 0 },
        up = up or { 0, 0, 1 },
    }
    function construct.getWorldPosition() return construct.position end
    function construct.getWorldRight() return construct.right end
    function construct.getWorldForward() return construct.forward end
    function construct.getWorldUp() return construct.up end
    return construct
end

--- The position in a "::pos{0,0,x,y,z}" waypoint.
---@param waypoint string
---@return table vec3
function WaypointPosition(waypoint)
    local x, y, z = waypoint:match("^::pos{0,0,([^,]+),([^,]+),([^}]+)}$")
    assert(x, "not a waypoint: " .. tostring(waypoint))
    return vec3(tonumber(x), tonumber(y), tonumber(z))
end
