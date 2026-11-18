dofile(ROOT .. "/tests/fakes.lua")

--- The modules src/requires_prod.lua loads, in its order.
local function prodModules()
    local modules = {}
    for path in readFile("src/requires_prod.lua"):gmatch('require%("([^"]+)"%)') do
        modules[#modules + 1] = path
    end
    return modules
end

test("widgets extend Widget when loaded in the bundled order", function()
    DUSystem = FakeSystem()
    Widget, Helper, Scanner = nil, nil, nil
    for _, path in ipairs(prodModules()) do
        loadSource(path)
    end
    assertTrue(Widget ~= nil, "Widget not loaded")
    assertEqual(Helper:super(), Widget, "Helper's base")
    assertEqual(Scanner:super(), Widget, "Scanner's base")
end)
