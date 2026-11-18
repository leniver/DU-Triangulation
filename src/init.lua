-- This is where you initialize your program
local load = function()
    DUUnit.hideWidget()
    --triangulationBackgroundColor = "3 8 7"
    local hud = Hud.new(DUSystem)
    local translator = Translator.new()
    hud:addWidget(Scanner:new(DUSystem, DUPlayer, translator))
    hud:addWidget(Helper:new(DUSystem, translator))
end

wrapper = Wrapper.new(DUUnit, DUSystem, DULibrary)

if DEV_MODE then
    wrapper:reload(load, {
        localDirectory .. "includes/tools",
        localDirectory .. "includes/Wrapper",
        localDirectory .. "classes/Widget",
        localDirectory .. "classes/Hud",
        localDirectory .. "classes/Helper",
        localDirectory .. "classes/Trilateration",
        localDirectory .. "classes/Scanner",
        localDirectory .. "classes/Translator",
        localDirectory .. "init"
    })
else
    load()
end