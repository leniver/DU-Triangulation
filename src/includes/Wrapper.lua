---@class Wrapper : Class
---@field unit ControlUnit
---@field system System
---@field app table|nil what the start function of reload() returned
---@field stopped boolean
---@field stopOnError boolean
---@field rethrowErrorAlways boolean
---@field rethrowErrorIfStopped boolean
---@field printSameErrorOnlyOnce boolean
---@field printError boolean
---@field error function
---@field traceback function
Wrapper = Class()

---@type {[string] : boolean}
local logs = {}

---@param unit ControlUnit
---@param system System
function Wrapper:init(unit, system)
    self.unit = unit
    self.system = system
    self.app = nil
    self.stopped = false
    self.stopOnError = false
    self.rethrowErrorAlways = false
    self.rethrowErrorIfStopped = true
    self.printSameErrorOnlyOnce = true
    self.printError = true
    self.error = function(a)
        if self.stopped then
            return
        end
        a = tostring(a):gsub('"%-%- |STDERROR%-EVENTHANDLER[^"]*"', 'chunk')
        local b = self.unit or self or {}
        if self.printError and self.system and self.system.print then
            if not self.printSameErrorOnlyOnce or logs[a] == nil then
                logs[a] = true
                self.system.print(a)
            end
        end
        if self.stopOnError then
            self.stopped = true
        end
        if self.stopped and b and b.exit then
            b.exit()
        end
        if self.rethrowErrorAlways or (self.stopped and self.rethrowErrorIfStopped) then
            error(a)
        end
    end
    self.traceback = traceback or (debug and debug.traceback) or function(a, b) return b or a end
end

--- Runs callback, printing its error instead of stopping the script.
---@param callback function
---@return any result what callback returned, nil when it failed
function Wrapper:execute(callback)
    if not self.stopped then
        local ok, result = xpcall(callback, self.traceback, self.unit)
        if not ok then
            self.error(result)
            return nil
        end
        return result
    end
end

--- Runs start, then reruns it each time lalt, brake, lshift and speedup are pressed in that order
--- (Alt + Ctrl + Shift + speedup): first the object start returned is destroyed (its destroy()
--- removes its event handlers), then the modules are reloaded from their files.
---@param start fun(): table|nil builds the program and returns its root object
---@param modules? string[] the modules to reload, in load order
function Wrapper:reload(start, modules)
    local shiftDown = false
    local altDown = false
    local ctrlDown = false
    ---@diagnostic disable-next-line: undefined-field
    self.system:onEvent('onActionStart', function(_,action)
        if action == "lalt" then
            altDown = true
        elseif altDown then
            if action == "brake" then
                ctrlDown = true
            elseif ctrlDown then
                if action == "lshift" then
                    shiftDown = true
                elseif shiftDown and action == "speedup" then
                    if self.app and self.app.destroy then
                        self.app:destroy()
                    end
                    for _, lib in ipairs(modules or {}) do
                        if package.loaded[lib] then
                            self.system.print("Reload: " .. lib)
                            package.loaded[lib] = nil
                            require(lib)
                        end
                    end
                    self.app = self:execute(start)
                end
            end
        end
    end)
    ---@diagnostic disable-next-line: undefined-field
    self.system:onEvent('onActionStop', function(_,action)
        if action == "lalt" then
            altDown = false
        elseif action == "brake" then
            ctrlDown = false
        elseif action == "lshift" then
            shiftDown = false
        end
    end)

    self.app = self:execute(start)
end