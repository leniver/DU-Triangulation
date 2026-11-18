dofile(ROOT .. "/tests/fakes.lua")

test("the Hud passes the game's events to its widgets", function()
    loadWidgets()
    local system = FakeSystem()
    local hud = Hud:new(system)
    local scanner = Scanner:new(system, FakePlayer({ 0, 0, 0 }), Translator:new("en"))
    hud:addWidget(scanner)
    hud:addWidget(Helper:new(system, Translator:new("en")))
    assertEqual(system:handlerCount("onUpdate"), 1, "onUpdate handlers")

    system:triggerEvent("onActionStart", "speeddown")
    system:triggerEvent("onUpdate")
    assertTrue(scanner.position ~= nil, "the scanner was not updated")
    assertTrue(system.screen:find('id="triangulation"', 1, true) ~= nil, "the scanner was not rendered")
    assertTrue(system.screen:find('class="help"', 1, true) ~= nil, "the help was not rendered")
end)

test("destroy() removes the Hud's event handlers", function()
    loadWidgets()
    local system = FakeSystem()
    local hud = Hud:new(system)
    hud:destroy()
    for _, event in ipairs({ "onUpdate", "onActionStart", "onActionStop" }) do
        assertEqual(system:handlerCount(event), 0, event .. " handlers")
    end
end)

test("the hot reload rebuilds the program without stacking handlers", function()
    loadWidgets()
    loadSource("includes/Wrapper")
    local system = FakeSystem()
    local starts = 0
    local wrapper = Wrapper:new({}, system)
    wrapper:reload(function()
        starts = starts + 1
        return Hud:new(system)
    end, {})
    local function press(...) for _, action in ipairs({ ... }) do system:triggerEvent("onActionStart", action) end end
    local function release(...) for _, action in ipairs({ ... }) do system:triggerEvent("onActionStop", action) end end

    press("lalt", "brake", "lshift", "speedup")
    assertEqual(starts, 2, "starts after the reload keys")
    assertEqual(system:handlerCount("onUpdate"), 1, "onUpdate handlers after a reload")

    release("lshift", "brake", "lalt")
    press("lalt", "brake", "speedup")
    assertEqual(starts, 2, "starts after the keys without Shift")
end)

test("the Hud only updates the screen when its content changes", function()
    loadWidgets()
    local system = FakeSystem()
    local hud = Hud:new(system)
    local scanner = Scanner:new(system, FakePlayer({ 0, 0, 0 }), Translator:new("en"))
    hud:addWidget(scanner)
    hud:addWidget(Helper:new(system, Translator:new("en")))
    system:triggerEvent("onActionStart", "speeddown")

    system:triggerEvent("onUpdate")
    system:triggerEvent("onUpdate")
    assertEqual(system.screenUpdates, 1, "updates without changes")

    system.throttle = 1 -- the mouse wheel moves the slider
    system:triggerEvent("onUpdate")
    assertEqual(system.screenUpdates, 2, "updates after a change")
end)
