local floor, random = math.floor, math.random
local abs, sqrt, pi, acos, atan, deg = math.abs, math.sqrt, math.pi, math.acos, math.atan, math.deg
local min, max = math.min, math.max
local match, format = string.match, string.format

---@param t table
---@param fnKeep function
---@return table
function ArrayRemove(t, fnKeep)
    local j, n = 1, #t;

    for i=1,n do
        if (fnKeep(t, i, j)) then
            -- Move i's kept value to j's position, if it's not already there.
            if (i ~= j) then
                t[j] = t[i];
                t[i] = nil;
            end
            j = j + 1; -- Increment position of where we'll place the next kept value.
        else
            t[i] = nil;
        end
    end

    return t;
end

--- Don't forget to call math.randomseed at initialization
---@param n number
---@return integer
function Rand(n)
    return floor(random() * n)
end


local defaultOffsets = {
    ["default"] = {
        scanner = {
            left = 282,
            top = 24,
            size = 13,
            angle = 13.6,
        }
    },
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
    ["1650x1050"] = {
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

function getOffsets(category)
    local screenSize = format("%sx%s", DUSystem.getScreenWidth(),DUSystem.getScreenHeight())
    local offsets = defaultOffsets["default"]

    if defaultOffsets[screenSize] ~= nil then
        offsets = defaultOffsets[screenSize]
    end
    if category ~= nil then
        return offsets[category],screenSize
    end
    return offsets,screenSize
end

function ToWaypoint(vector, bodyId)
    return [[::pos{0,]] .. (bodyId or 0) .. [[,]] .. 
    (floor(vector.x * 100000) / 100000) .. [[,]] .. 
    (floor(vector.y * 100000) / 100000) .. [[,]] ..
    (floor(vector.z * 100000) / 100000) .. [[}]]
end

function Clamp(value, minValue, maxValue)
    return max(min(value, maxValue), minValue)
end

function ToRGB(color)
    local r, g, b = match(color, "(%d+) (%d+) (%d+)")
    if r == nil or g == nil or b == nil then
        r = 2
        g = 52
        b = 110
    end
    r = Clamp(tonumber(r), 0, 255)
    g = Clamp(tonumber(g), 0, 255)
    b = Clamp(tonumber(b), 0, 255)
    return format("%d,%d,%d", r, g, b)
end