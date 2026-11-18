---@class Hud : Class
---@field system System
---@field widgets Widget[]
---@field widgetCount number
Hud = Class()

local floor, ceil = math.floor, math.ceil

---@param system System
function Hud:init(system)
    self.system = system
    self.system.showScreen(true)

    self.widgets = {}
    self.widgetCount = 0

    self:initEvents()
end

---@param widget Widget
function Hud:addWidget(widget)
    self.widgetCount = self.widgetCount + 1
    self.widgets[self.widgetCount] = widget
end

--- The Hud is the only one listening to the game's events: it passes them on to its widgets.
function Hud:initEvents()
    ---@diagnostic disable-next-line: undefined-field
    self.system:onEvent("onActionStart", function(_, action)
        for i = 1, self.widgetCount do
            self.widgets[i]:onActionStart(action)
        end
    end)
    ---@diagnostic disable-next-line: undefined-field
    self.system:onEvent("onActionStop", function(_, action)
        for i = 1, self.widgetCount do
            self.widgets[i]:onActionStop(action)
        end
    end)
    ---@diagnostic disable-next-line: undefined-field
    self.system:onEvent("onUpdate", function()
        self:onUpdate()
    end)
end

--- Updates every widget, then shows what they render.
function Hud:onUpdate()
    local style = ""
    local html = ""
    for i = 1, self.widgetCount do
        local widget = self.widgets[i]
        widget:onUpdate()
        local output = widget:render()
        style = style .. output.style
        html = html .. output.html
    end
    self.system.setScreen([[<style>]] .. style .. [[</style>]] .. html)
end