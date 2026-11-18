loadSource("classes/Sphere")
loadSource("classes/Trilateration")

-- World coordinates near Alioth: millions of metres from the origin, like in game.
local ALIOTH = vec3(17465536, 22665536, -34464)

--- Readings taken on the assisted pattern (25 m legs) that starts at `start`, for an ore at `ore`.
---@param round boolean round the distances to whole metres, like the slider
local function assistedReadings(start, ore, round)
    local forward, side, up = vec3(1, 0, 0), vec3(0, 1, 0), vec3(0, 0, 1)
    local p1 = start + forward * 25
    local p2 = p1 + side * 25
    local p3 = p2 + up * 25 + side * 5
    local readings = {}
    for i, p in ipairs({ start, p1, p2, p3 }) do
        local d = (ore - p):len()
        if round then d = math.floor(d + 0.5) end
        readings[i] = Sphere.new(p, d)
    end
    return readings
end

--- A start position and an ore 30-200 m under it.
local function randomCase(random)
    local start = ALIOTH + vec3(random(-500, 500), random(-500, 500), random(-50, 50))
    local ore = start + vec3(random(-150, 150), random(-150, 150), -random(30, 200))
    return start, ore
end

test("Sphere:dst is the distance to the sphere's surface", function()
    local sphere = Sphere.new(vec3(10, 0, 0), 5)
    assertNear(sphere:dst(vec3(20, 0, 0)), 5, 1e-9)
    assertNear(sphere:dst(vec3(10, 2, 0)), 3, 1e-9)
end)

test("finds the ore from four exact readings", function()
    local random = Random(1)
    for _ = 1, 100 do
        local start, ore = randomCase(random)
        local result = Trilateration.solve(assistedReadings(start, ore, false))
        assertTrue(result ~= nil, "no result")
        assertNear((result - ore):len(), 0, 0.01, "distance to the ore")
    end
end)

test("stays within a few metres with whole-metre readings", function()
    local random = Random(2)
    local errors = {}
    for i = 1, 200 do
        local start, ore = randomCase(random)
        local result = Trilateration.solve(assistedReadings(start, ore, true))
        assertTrue(result ~= nil, "no result")
        errors[i] = (result - ore):len()
    end
    table.sort(errors)
    -- Before the axis fix, the median error here was about 64 m.
    assertTrue(errors[100] < 5, "median error " .. errors[100] .. " m")
end)

test("uses a 5th reading", function()
    local start = ALIOTH + vec3(120, -80, 10)
    local ore = start + vec3(40, 60, -90)
    local readings = assistedReadings(start, ore, false)
    local p5 = ore + vec3(10, 10, 60)
    readings[5] = Sphere.new(p5, (ore - p5):len())
    local result = Trilateration.solve(readings)
    assertTrue(result ~= nil, "no result")
    assertNear((result - ore):len(), 0, 0.01, "distance to the ore")
end)

test("rejects readings that don't agree", function()
    local readings = {
        Sphere.new(ALIOTH, 10),
        Sphere.new(ALIOTH + vec3(25, 0, 0), 10),
        Sphere.new(ALIOTH + vec3(25, 25, 0), 10),
        Sphere.new(ALIOTH + vec3(30, 50, 25), 300),
    }
    assertEqual(Trilateration.solve(readings), nil)
end)

test("needs four readings", function()
    local readings = assistedReadings(ALIOTH, ALIOTH + vec3(0, 0, -100), false)
    readings[4] = nil
    assertEqual(Trilateration.solve(readings), nil)
end)
