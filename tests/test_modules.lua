dofile(ROOT .. "/tests/fakes.lua")

--- The modules src/requires_prod.lua loads, in its order.
local function prodModules()
    local modules = {}
    for path in readFile("src/requires_prod.lua"):gmatch('require%("([^"]+)"%)') do
        modules[#modules + 1] = path
    end
    return modules
end

test("the modules load in the bundled order, widgets extending Widget", function()
    -- Forget what the other tests loaded, so a module loaded before one it needs fails here.
    Class, Wrapper, Widget, Hud, Helper, Sphere, Trilateration, Scanner, Translator = nil, nil, nil, nil, nil, nil, nil, nil, nil
    for _, path in ipairs(prodModules()) do
        loadSource(path)
    end
    assertTrue(Widget ~= nil, "Widget not loaded")
    assertEqual(Helper:super(), Widget, "Helper's base")
    assertEqual(Scanner:super(), Widget, "Scanner's base")
end)

test("a subclass without init uses the init of its base", function()
    loadSource("includes/Class")
    local Base = Class()
    function Base:init(value) self.value = value end
    local Derived = Class(Base)
    local instance = Derived:new(42)
    assertEqual(instance.value, 42)
    assertTrue(instance:instanceOf(Base), "instanceOf(Base)")
    assertEqual(Class():new().value, nil, "a root class without init")
end)

test("dev mode loads the same modules as the bundle, in the same order", function()
    local list = readFile("src/requires_dev.lua"):match("local modules = (%b{})")
    assertTrue(list ~= nil, "no module list in requires_dev.lua")
    local dev = {}
    for path in list:gmatch('"([^"]+)"') do
        dev[#dev + 1] = path
    end
    local prod = prodModules()
    assertEqual(table.concat(dev, ", "), table.concat(prod, ", "))
end)
