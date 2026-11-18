---@class Sphere : Class
---@field center vec3
---@field radius number
Sphere = Class()

local abs = math.abs

---@param center vec3
---@param radius number
function Sphere:init(center, radius)
    self.center = center
    self.radius = radius
end


function Sphere:r2()
    return self.radius * self.radius
end

---@param point vec3
---@return number
function Sphere:dst(point)
    return abs((self.center - point):len() - self.radius)
end