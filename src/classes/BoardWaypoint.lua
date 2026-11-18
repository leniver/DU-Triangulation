--- Sets a waypoint back to the board, e.g. to find the ship again after mining.
---
--- A player starts the board while standing at it, so the player's position at that moment marks
--- the board. It is kept in the construct's coordinates: if the construct moves or turns, the
--- waypoint still leads to the board. (Only world coordinates documented by the game are used.)
---@class BoardWaypoint : Widget
---@field system System
---@field construct Construct
---@field translator Translator
---@field offset vec3 where the player stood when the board started, in the construct's coordinates
BoardWaypoint = Class(Widget)

---@param system System
---@param player Player
---@param construct Construct
---@param translator Translator
function BoardWaypoint:init(system, player, construct, translator)
    self.system = system
    self.construct = construct
    self.translator = translator
    self.offset = self:toConstruct(vec3(player.getWorldPosition()))
end

--- The construct's position and axes, in world coordinates.
---@return vec3 origin, vec3 right, vec3 forward, vec3 up
function BoardWaypoint:frame()
    local c = self.construct
    return vec3(c.getWorldPosition()), vec3(c.getWorldRight()):normalize(),
        vec3(c.getWorldForward()):normalize(), vec3(c.getWorldUp()):normalize()
end

--- A position in world coordinates, in the construct's coordinates.
---@param world vec3
---@return vec3
function BoardWaypoint:toConstruct(world)
    local origin, right, forward, up = self:frame()
    local d = world - origin
    return vec3(d:dot(right), d:dot(forward), d:dot(up))
end

--- A position in the construct's coordinates, in world coordinates.
---@param position vec3
---@return vec3
function BoardWaypoint:toWorld(position)
    local origin, right, forward, up = self:frame()
    return origin + right * position.x + forward * position.y + up * position.z
end

---@param action string
function BoardWaypoint:onActionStart(action)
    if action == "option7" then
        self.system.setWaypoint(Tools.toWaypoint(self:toWorld(self.offset)), true)
        self.system.print(self.translator:get("Waypoint set to the board"))
    end
end
