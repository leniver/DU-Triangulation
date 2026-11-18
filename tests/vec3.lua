---@diagnostic disable: lowercase-global
--- Minimal stand-in for Dual Universe's vec3 (cpml), with the operations this project uses.
--- Like cpml, operations return new vectors and never change their operands.

local mt = {}
mt.__index = mt

---@return table
local function new(x, y, z)
    if type(x) == "table" then
        x, y, z = x.x or x[1], x.y or x[2], x.z or x[3]
    end
    return setmetatable({ x = x or 0, y = y or 0, z = z or 0 }, mt)
end

function mt.__add(a, b) return new(a.x + b.x, a.y + b.y, a.z + b.z) end
function mt.__sub(a, b) return new(a.x - b.x, a.y - b.y, a.z - b.z) end
function mt.__unm(a) return new(-a.x, -a.y, -a.z) end
function mt.__div(a, k) return new(a.x / k, a.y / k, a.z / k) end
function mt.__eq(a, b) return a.x == b.x and a.y == b.y and a.z == b.z end
function mt.__tostring(a) return string.format("(%g, %g, %g)", a.x, a.y, a.z) end

function mt.__mul(a, b)
    if type(a) == "number" then a, b = b, a end
    if type(b) == "number" then return new(a.x * b, a.y * b, a.z * b) end
    return new(a.x * b.x, a.y * b.y, a.z * b.z)
end

function mt.dot(a, b) return a.x * b.x + a.y * b.y + a.z * b.z end
function mt.cross(a, b) return new(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x) end
function mt.len2(a) return a:dot(a) end
function mt.len(a) return math.sqrt(a:dot(a)) end

function mt.normalize(a)
    local l = a:len()
    if l == 0 then return new() end
    return new(a.x / l, a.y / l, a.z / l)
end

function mt.project_on(a, b)
    local s = a:dot(b) / b:dot(b)
    return new(b.x * s, b.y * s, b.z * s)
end

vec3 = setmetatable({ new = new }, { __call = function(_, ...) return new(...) end })
