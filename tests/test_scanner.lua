dofile(ROOT .. "/tests/fakes.lua")

local ALIOTH = { 17465536, 22665536, -34464 }

--- A scanner with fake game objects, shown (assisted pattern started) at ALIOTH.
---@param setup? function changes the Lua parameters before the scanner is created
local function shownScanner(setup)
    loadWidgets()
    if setup then setup() end
    local system, player = FakeSystem(), FakePlayer(ALIOTH)
    DUSystem = system
    local scanner = Scanner:new(system, player, Translator.new("en"))
    scanner:onActionStart("speeddown")
    scanner:onUpdate()
    return scanner, system, player
end

local ORE = vec3(ALIOTH) + vec3(40, 30, -120)

--- Walks to each assisted waypoint and takes a reading of ORE there; returns the number of readings taken.
local function walkAssistedPattern(scanner, player)
    local targets = scanner.targets
    for i = 1, 4 do
        local target = WaypointPosition(targets[i])
        player.position = { target.x, target.y, target.z }
        scanner:onUpdate()
        scanner.distance = math.floor((ORE - target):len() + 0.5)
        scanner:onActionStart("speedup")
    end
    return #scanner.points
end

test("the assisted pattern takes four readings", function()
    local scanner, _, player = shownScanner()
    assertEqual(walkAssistedPattern(scanner, player), 4)
    assertTrue(scanner.waypoint ~= nil, "no result")
    assertTrue((scanner.waypoint - ORE):len() < 10, "result " .. (scanner.waypoint - ORE):len() .. " m from the ore")
end)

test("assisted readings stay far enough apart for any distance setting", function()
    for _, setting in ipairs({ 0, 15, 19, 20, 22, 25, 40, 50, 80 }) do
        local scanner, _, player = shownScanner(function() assistedTriangulationDistance = setting end)
        assertEqual(walkAssistedPattern(scanner, player), 4, "readings taken with a setting of " .. setting)
    end
end)
