local floor, min, max = math.floor, math.min, math.max
local match, format = string.match, string.format

--- Helpers shared by the classes, in one global table.
Tools = {}

local DEFAULT_COLOR = { 2, 52, 110 } -- dark blue, for a colour parameter that isn't "R G B"

--- Overlay offsets calibrated in game, by screen resolution.
local calibratedOffsets = {
    ["1920x2160"] = {
        scanner = {
            left = 658,
            top = 125,
            size = 20,
            angle = 13.6,
        }
    },
    ["3840x2160"] = {
        scanner = {
            left = 559,
            top = 49,
            size = 20,
            angle = 13.6,
        }
    },
    ["3840x2141"] = {
        scanner = {
            left = 553,
            top = 48,
            size = 24,
            angle = 13.6,
        }
    },
    ["2560x1440"] = {
        scanner = {
            left = 377,
            top = 34,
            size = 18,
            angle = 13.6,
        }
    },
    ["1920x1080"] = {
        scanner = {
            left = 282,
            top = 24,
            size = 13,
            angle = 13.6,
        }
    },
    ["1920x1065"] = {
        scanner = {
            left = 277,
            top = 24,
            size = 13,
            angle = 13.6,
        }
    },
    ["1680x1050"] = {
        scanner = {
            left = 274,
            top = 22,
            size = 13,
            angle = 13.6,
        }
    },
    ["1600x1024"] = {
        scanner = {
            left = 269,
            top = 23,
            size = 13,
            angle = 13.6,
        }
    },
    ["1440x900"] = {
        scanner = {
            left = 236,
            top = 19,
            size = 11,
            angle = 13.6,
        }
    },
    ["1280x1024"] = {
        scanner = {
            left = 268,
            top = 21,
            size = 12,
            angle = 13.6,
        }
    },
    ["1280x720"] = {
        scanner = {
            left = 190,
            top = 15,
            size = 9,
            angle = 13.6,
        }
    },
}

--- The 1920x1080 offsets scaled to a screen height: the game's HUD scales with the screen height,
--- and the calibrated entries follow that scale within a few pixels.
---@param height number
local function scaledOffsets(height)
    local scale = height / 1080
    local offsets = {}
    for category, values in pairs(calibratedOffsets["1920x1080"]) do
        offsets[category] = {
            left = floor(values.left * scale + 0.5),
            top = floor(values.top * scale + 0.5),
            size = floor(values.size * scale + 0.5),
            angle = values.angle,
        }
    end
    return offsets
end

--- Overlay offsets for the screen resolution: its calibrated entry, or else the 1920x1080 values
--- scaled to the screen height (e.g. in windowed mode, where the height depends on the taskbar).
---@param system System
---@param category? string
---@return table offsets
---@return string screenSize "<width>x<height>"
function Tools.getOffsets(system, category)
    local height = system.getScreenHeight()
    local screenSize = format("%sx%s", system.getScreenWidth(), height)
    local offsets = calibratedOffsets[screenSize]
    if offsets == nil then
        offsets = scaledOffsets(height > 0 and height or 1080)
    end

    if category ~= nil then
        return offsets[category], screenSize
    end
    return offsets, screenSize
end

--- The waypoint string ("::pos{...}") of a position in world coordinates.
---@param vector vec3
---@param bodyId? integer
---@return string
function Tools.toWaypoint(vector, bodyId)
    return [[::pos{0,]] .. (bodyId or 0) .. [[,]] .. 
    (floor(vector.x * 100000) / 100000) .. [[,]] .. 
    (floor(vector.y * 100000) / 100000) .. [[,]] ..
    (floor(vector.z * 100000) / 100000) .. [[}]]
end

---@param value number
---@param minValue number
---@param maxValue number
---@return number
function Tools.clamp(value, minValue, maxValue)
    return max(min(value, maxValue), minValue)
end

--- "R G B" (a Lua parameter) to "R,G,B" for CSS; a dark blue when the text isn't three numbers.
---@param color string
---@return string
function Tools.toRGB(color)
    local r, g, b = match(color, "(%d+) (%d+) (%d+)")
    if r == nil or g == nil or b == nil then
        r, g, b = DEFAULT_COLOR[1], DEFAULT_COLOR[2], DEFAULT_COLOR[3]
    end
    r = Tools.clamp(tonumber(r), 0, 255)
    g = Tools.clamp(tonumber(g), 0, 255)
    b = Tools.clamp(tonumber(b), 0, 255)
    return format("%d,%d,%d", r, g, b)
end