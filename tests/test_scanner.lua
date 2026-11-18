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

--- The assisted waypoints of a scanner shown with the camera set by `setCamera(system)`.
local function assistedTargets(setCamera)
    loadWidgets()
    local system, player = FakeSystem(), FakePlayer(ALIOTH)
    DUSystem = system
    setCamera(system)
    local scanner = Scanner:new(system, player, Translator.new("en"))
    scanner:onActionStart("speeddown")
    local targets = {}
    for i = 1, 4 do targets[i] = WaypointPosition(scanner.targets[i]) end
    return targets
end

test("assisted waypoints stay level when looking down", function()
    local s = math.sqrt(0.5)
    local targets = assistedTargets(function(system)
        system.cameraForward, system.cameraUp = { 0, s, -s }, { 0, s, s } -- 45° down
    end)
    assertNear(targets[2].z, targets[1].z, 0.01, "height of the 2nd waypoint")
    assertNear(targets[3].z, targets[1].z, 0.01, "height of the 3rd waypoint")
    assertNear(targets[4].z - targets[3].z, 25, 0.01, "climb to the 4th waypoint")
    assertNear((targets[2] - targets[1]):len(), 25, 0.01, "1st leg")
    assertTrue(targets[2].y > targets[1].y, "the 1st leg goes the way the camera looks")
end)

test("assisted waypoints use the player's heading when looking straight down", function()
    local targets = assistedTargets(function(system)
        system.cameraForward, system.cameraUp = { 0, 0, -1 }, { 0, 1, 0 }
    end)
    assertNear((targets[2] - targets[1]):len(), 25, 0.01, "1st leg")
    assertNear(targets[2].z, targets[1].z, 0.01, "height of the 2nd waypoint")
end)
