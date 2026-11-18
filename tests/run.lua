---@diagnostic disable: lowercase-global
--- Test runner, without dependencies: `lua tests/run.lua` (Lua 5.3, the version Dual Universe runs).
--- Each tests/test_<name>.lua file registers its cases with test(name, fn); a case fails when it raises an error.

ROOT = (arg and arg[0] or ""):match("^(.*)[/\\]tests[/\\]run%.lua$") or "."

local files = {
    "trilateration",
    "translations",
    "scanner",
    "modules",
}

local cases = {}
local currentFile = nil

---@param name string
---@param fn function
function test(name, fn)
    cases[#cases + 1] = { file = currentFile, name = name, fn = fn }
end

--- Runs a source file from src/, e.g. loadSource("classes/Sphere").
---@param path string
function loadSource(path)
    dofile(ROOT .. "/src/" .. path .. ".lua")
end

--- Returns the text of a file from the project root, e.g. readFile("src/main.lua").
---@param path string
---@return string
function readFile(path)
    local file = assert(io.open(ROOT .. "/" .. path, "rb"))
    local text = file:read("a")
    file:close()
    return text
end

function assertTrue(value, message)
    if not value then error(message or "expected a true value", 2) end
end

function assertEqual(actual, expected, message)
    if actual ~= expected then
        error(string.format("%sexpected %s, got %s", message and (message .. ": ") or "", tostring(expected), tostring(actual)), 2)
    end
end

function assertNear(actual, expected, tolerance, message)
    if not (math.abs(actual - expected) <= tolerance) then
        error(string.format("%sexpected %s ± %s, got %s", message and (message .. ": ") or "", tostring(expected), tostring(tolerance), tostring(actual)), 2)
    end
end

--- Deterministic random numbers, the same on every platform: Random(seed)(a, b) is in [a, b).
---@param seed integer
---@return fun(a: number, b: number): number
function Random(seed)
    local state = seed
    return function(a, b)
        state = (state * 1103515245 + 12345) % 2147483648
        return a + (b - a) * state / 2147483648
    end
end

dofile(ROOT .. "/tests/vec3.lua")

for _, name in ipairs(files) do
    currentFile = name
    dofile(ROOT .. "/tests/test_" .. name .. ".lua")
end

local failed = 0
for _, case in ipairs(cases) do
    local ok, err = xpcall(case.fn, debug.traceback)
    if ok then
        print("ok    " .. case.file .. ": " .. case.name)
    else
        failed = failed + 1
        print("FAIL  " .. case.file .. ": " .. case.name .. "\n      " .. tostring(err):gsub("\n", "\n      "))
    end
end

print(string.format("\n%d passed, %d failed", #cases - failed, failed))
os.exit(failed == 0 and 0 or 1)
