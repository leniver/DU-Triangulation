---@class Sphere
---@field center vec3
---@field radius number
Sphere = {}
Sphere.__index = Sphere

local abs = math.abs

---@param center vec3
---@param radius number
---@return Sphere
function Sphere.new(center, radius)
    local self = setmetatable({}, Sphere)

    self.center = center
    self.radius = radius

    return self
end


function Sphere:r2()
    return self.radius * self.radius
end

---@param point vec3
---@return number
function Sphere:dst(point)
    return abs((self.center - point):len() - self.radius)
end