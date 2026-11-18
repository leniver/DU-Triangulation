-- Starts the program.
wrapper = Wrapper:new(DUUnit, DUSystem)

if DEV_MODE then
    -- App.start is looked up at each start, so that a reloaded app.lua takes effect.
    wrapper:reload(function() return App.start() end, DEV_MODULES)
else
    App.start()
end
