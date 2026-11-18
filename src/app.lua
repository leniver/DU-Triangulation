--- Builds the program from the game objects. It is a module of its own so that the hot reload
--- (see Wrapper:reload) can rebuild it after reloading the sources.
App = {}

---@return Hud hud its destroy() undoes start()
function App.start()
    DUUnit.hideWidget()
    local translator = Translator:new()
    local hud = Hud:new(DUSystem)
    hud:addWidget(Scanner:new(DUSystem, DUPlayer, translator))
    hud:addWidget(Helper:new(DUSystem, translator))
    return hud
end
