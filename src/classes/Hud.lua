---@class Hud
---@field system System
---@field widgets Widget[]
---@field widgetCount number
Hud = {}
Hud.__index = Hud

local floor, ceil = math.floor, math.ceil

function Hud.new(system)
    local self = setmetatable({}, Hud)

    self.system = system
    self.system.showScreen(true)

    self.widgets = {}
    self.widgetCount = 0

    self:initEvents()

    return self
end

---@param widget Widget
function Hud:addWidget(widget)
    self.widgetCount = self.widgetCount + 1
    self.widgets[self.widgetCount] = widget
end

function Hud:initEvents()
    ---@diagnostic disable-next-line: undefined-field
    self.system:onEvent("onActionStart", function(__, action)
        for i=1,self.widgetCount do
            if self.widgets[i] and self.widgets[i].onActionStart then self.widgets[i]:onActionStart(action) end
        end
    end)
    ---@diagnostic disable-next-line: undefined-field
    self.system:onEvent("onActionStop", function(__, action)
        for i=1,self.widgetCount do
            if self.widgets[i] and self.widgets[i].onActionStop then self.widgets[i]:onActionStop(action) end
        end
    end)
    ---@diagnostic disable-next-line: undefined-field
    self.system:onEvent("onUpdate", function()
        self:onUpdate()
    end)
end

function Hud:onUpdate()
    local style = ""
    local html = ""
    local widget = nil
    for i=1,self.widgetCount do
        if self.widgets[i] then 
            widget = self.widgets[i]:render()
            style = style .. widget.style
            html = html .. widget.html
        end
    end
    self.system.setScreen([[<style>]] .. style .. [[</style>]] .. html)
end