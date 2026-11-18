dofile(ROOT .. "/tests/fakes.lua")

test("the board waypoint leads to where the board was started", function()
    loadWidgets()
    local system = FakeSystem()
    local construct = FakeConstruct({ 1000, 2000, 3000 })
    local widget = BoardWaypoint:new(system, FakePlayer({ 1005, 2003, 3001 }), construct, Translator:new("en"))

    widget:onActionStart("option7")
    local target = WaypointPosition(system.waypoints[#system.waypoints])
    assertNear((target - vec3(1005, 2003, 3001)):len(), 0, 0.001, "distance to the board")
    assertEqual(system.printed[#system.printed], "Waypoint set to the board")
end)

test("the board waypoint follows the construct when it moves and turns", function()
    loadWidgets()
    local system = FakeSystem()
    local construct = FakeConstruct({ 1000, 2000, 3000 })
    local widget = BoardWaypoint:new(system, FakePlayer({ 1005, 2003, 3001 }), construct, Translator:new("en"))

    -- The construct moves 100 m along x and turns 90 degrees around its up axis.
    construct.position = { 1100, 2000, 3000 }
    construct.right, construct.forward = { 0, 1, 0 }, { -1, 0, 0 }
    widget:onActionStart("option7")
    local target = WaypointPosition(system.waypoints[#system.waypoints])
    assertNear((target - vec3(1097, 2005, 3001)):len(), 0, 0.001, "distance to the board")
end)

test("the board waypoint works while the triangulation is hidden", function()
    loadWidgets()
    local system = FakeSystem()
    local hud = Hud:new(system)
    hud:addWidget(Scanner:new(system, FakePlayer({ 0, 0, 0 }), Translator:new("en")))
    hud:addWidget(BoardWaypoint:new(system, FakePlayer({ 0, 0, 0 }), FakeConstruct({ 0, 0, 0 }), Translator:new("en")))
    system:triggerEvent("onActionStart", "option7")
    assertEqual(#system.waypoints, 1, "waypoints set")
end)
