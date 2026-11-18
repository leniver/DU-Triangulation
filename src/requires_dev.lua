--- Dev mode: the modules are loaded from the game's Lua folder (localDirectory) at run time, and
--- the hot reload reloads them in this order. requires_prod.lua must require the same modules in the
--- same order (a test checks it): DU-LuaC only bundles literal require("...") calls.
local modules = {
    "includes/tools",
    "includes/Class",
    "includes/Wrapper",
    "classes/Widget",
    "classes/Hud",
    "classes/Helper",
    "classes/Sphere",
    "classes/Trilateration",
    "classes/Scanner",
    "classes/Translator",
    "app",
}

DEV_MODULES = {}
for i, module in ipairs(modules) do
    DEV_MODULES[i] = localDirectory .. module
    require(DEV_MODULES[i])
end
