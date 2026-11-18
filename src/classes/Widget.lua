---@class Widget : Class
Widget = Class()

function Widget:render()
    return {
        style = "",
        html = "",
    }
end

--- Called every frame by the Hud, before render().
function Widget:onUpdate() end

---@param action string
function Widget:onActionStart(action) end

---@param action string
function Widget:onActionStop(action) end