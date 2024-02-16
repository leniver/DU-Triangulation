---@class Widget : Class
Widget = Class()

function Widget:render()
    return {
        style = "",
        html = "",
    }
end

function Widget:onActionStart(action) end
function Widget:onActionStop(action) end