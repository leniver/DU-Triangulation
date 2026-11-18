loadSource("includes/tools")

test("toRGB turns an \"R G B\" parameter into CSS", function()
    assertEqual(Tools.toRGB("3 8 7"), "3,8,7")
    assertEqual(Tools.toRGB("300 0 12"), "255,0,12")
    assertEqual(Tools.toRGB("blue"), "2,52,110")
end)

test("toWaypoint writes a ::pos string in world coordinates", function()
    assertEqual(Tools.toWaypoint(vec3(1.5, -2.25, 3)), "::pos{0,0,1.5,-2.25,3.0}")
    assertEqual(Tools.toWaypoint(vec3(17465536.123456, 0, 0), 2), "::pos{0,2,17465536.12345,0.0,0.0}")
end)

test("clamp keeps a value between two limits", function()
    assertEqual(Tools.clamp(5, 0, 10), 5)
    assertEqual(Tools.clamp(-1, 0, 10), 0)
    assertEqual(Tools.clamp(11, 0, 10), 10)
end)

--- A system whose screen is width x height.
local function screen(width, height)
    return { getScreenWidth = function() return width end, getScreenHeight = function() return height end }
end

test("getOffsets keeps the values calibrated for a resolution", function()
    local offsets, size = Tools.getOffsets(screen(2560, 1440), "scanner")
    assertEqual(size, "2560x1440")
    assertEqual(offsets.left, 377)
    assertEqual(offsets.top, 34)
    assertEqual(offsets.size, 18)
end)

test("getOffsets scales the 1080p values for other resolutions", function()
    local offsets = Tools.getOffsets(screen(1366, 768), "scanner")
    assertEqual(offsets.left, 201) -- 282 * 768 / 1080
    assertEqual(offsets.top, 17)
    assertEqual(offsets.size, 9)
    assertEqual(offsets.angle, 13.6)

    -- Windowed 1440p with a taskbar: close to the calibrated 2560x1440 values.
    local windowed = Tools.getOffsets(screen(2560, 1400), "scanner")
    assertNear(windowed.left, 377 * 1400 / 1440, 5, "left")
end)
