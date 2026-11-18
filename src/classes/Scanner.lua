---@class Scanner : Widget
---@field points Sphere[]
---@field targets? string[]
---@field distance number
---@field problem string|nil why no reading can be taken here: "close", "line" or "plane"
---@field system System
---@field translator Translator
---@field player Player
---@field hide boolean
---@field position vec3
---@field follow boolean
---@field waypoint vec3
---@field selected string[]
---@field altDown boolean
---@field shiftDown boolean
---@field calibrating boolean the movement keys move the overlay
---@field lastError string
---@field offsetLeft number
---@field offsetTop number
---@field angle number
---@field fontSize number
---@field backgroundColor string
Scanner = Class(Widget)

local floor, abs, min, clamp = math.floor, math.abs, math.min, Tools.clamp

local MAX_DISTANCE = 480 -- range of the game's scanner, in metres: the slider goes from 0 to this
local START_DISTANCE = 250 -- distance on the slider when the script starts
local MIN_SPACING = 20 -- minimum distance between two readings, in metres ("Too close")
-- The assisted readings are at least 5 m further apart than MIN_SPACING, so that a reading taken
-- a few metres short of its waypoint isn't refused as "Too close".
local ASSISTED_MIN, ASSISTED_MAX = MIN_SPACING + 5, 50
local ASSISTED_SIDE_STEP = 5 -- the 4th assisted waypoint is also moved this far to the side, in metres
local FAST_SCROLL = 5 -- the mouse wheel moves the slider this many times faster while Shift is held
local GAUGE_HEIGHT = 28.5 -- height of the game's scanner gauge, in % of the screen height (vh)
local SLIDER_OFFSET = 3 -- moves the slider's glyph onto its height, in % of the gauge

--- Height of the slider for a distance, in % of the gauge from its bottom. The game's gauge isn't
--- linear; this curve follows it (0 m: 0 %, 240 m: 54 %, 480 m: 95 %).
---@param distance number in metres
---@return number
local function sliderHeight(distance)
    return 0.02 + 0.253 * distance - 1.13E-04 * distance ^ 2
end

---@param system System
---@param player Player
---@param translator Translator
function Scanner:init(system, player, translator)
    self.points = {}
    self.targets = nil
    self.distance = START_DISTANCE
    self.problem = nil

    self.system = system
    self.translator = translator
    self.player = player
    self.hide = true
    self.position = nil
    self.follow = false
    self.waypoint = nil

    self.selected = {}
    self.selected[0] = "<span style='color:white'>➀➁➂➃</span>"
    self.selected[1] = "<span style='color:#eca943'>➊</span>➁➂➃"
    self.selected[2] = "<span style='color:#eca943'>➊➋</span>➂➃"
    self.selected[3] = "<span style='color:#eca943'>➊➋➌</span>➃"
    self.selected[4] = "<span style='color:#498aff'>➊➋➌➍</span>"

    self.altDown = false
    self.shiftDown = false
    self.calibrating = false

    self.lastError = nil

    self:initializeOffets(false)

    self.backgroundColor = Tools.toRGB(triangulationBackgroundColor)
end

---@param displaySettings boolean
function Scanner:initializeOffets(displaySettings)
    local offsets, screenSize = Tools.getOffsets(self.system, "scanner")

    if triangulationLeft > 0 then
        self.offsetLeft = triangulationLeft
    else
        self.offsetLeft = offsets.left
    end

    if triangulationTop > 0 then
        self.offsetTop = triangulationTop
    else
        self.offsetTop = offsets.top
    end

    if triangulationFontSize > 0 then
        self.fontSize = triangulationFontSize
    else
        self.fontSize = offsets.size
    end

    if triangulationAngle > 0 then
        self.angle = triangulationAngle
    else
        self.angle = offsets.angle
    end

    if displaySettings then
        local t = self.translator
        self.system.print("====== " .. t:get("Triangulation settings") .. " ======")
        self.system.print(t:get("Screen resolution: %s", screenSize))
        self.system.print(t:get("Left offset: %s px", self.offsetLeft))
        self.system.print(t:get("Top offset: %s px", self.offsetTop))
        self.system.print(t:get("Font size: %s px", self.fontSize))
        self.system.print(t:get("Angle: %s°", self.angle))
        self.system.print("==================================")
    end
end

function Scanner:add()
    if self.problem == nil then
        local size = #self.points
        self.lastError = nil
        if size < 5 then
            self.points[size + 1] = Sphere:new(self.position, self.distance)
            size = size + 1
        elseif (self.distance < self.points[5].radius) then
            self.points[5] = Sphere:new(self.position, self.distance)
        end
        if size == 4 then
            self:solve()
            self.targets = nil
        elseif size > 4 then
            self:solve()
        elseif self.targets ~= nil then
            self.system.setWaypoint(self.targets[min(#self.points + 1, 4)], false)
        end
    end
end

function Scanner:clear()
    self.points = {}
    self.targets = nil
    self.hide = true
    self.lastError = nil
    self.waypoint = nil
    self.follow = nil
end

function Scanner:solve()
    if #self.points < 4 then
        return
    end

    local result = Trilateration.solve(self.points)
    if result == nil then
        self.points = {}
        self.lastError = self.translator:get("Triangulation failed")
        return false
    end

    self.follow = true
    self.waypoint = result
    self.system.setWaypoint(Tools.toWaypoint(result), false)
end

--- Shows the scanner and starts the assisted pattern from the player's position.
function Scanner:show()
    self:clear()
    self.hide = false
    self:initializeOffets(true)

    local position = vec3(self.player.getWorldPosition())
    local increment = clamp(assistedTriangulationDistance, ASSISTED_MIN, ASSISTED_MAX)

    -- Lay the pattern out on the horizontal plane: the player's up is the planet's vertical,
    -- and the camera only gives the heading, whatever its pitch.
    local vertical = vec3(self.player.getWorldUp()):normalize()
    local look = vec3(self.system.getCameraWorldForward())
    local forward = look - vertical * look:dot(vertical)
    if forward:len() < 0.1 then
        -- Looking (almost) straight up or down: use the way the player faces.
        local facing = vec3(self.player.getWorldForward())
        forward = facing - vertical * facing:dot(vertical)
    end
    forward = forward:normalize()
    local side = vertical:cross(forward)

    local p1 = position + forward * increment
    local p2 = p1 + side * increment
    local p3 = p2 + vertical * increment + side * ASSISTED_SIDE_STEP
    self.targets = {
        Tools.toWaypoint(position),
        Tools.toWaypoint(p1),
        Tools.toWaypoint(p2),
        Tools.toWaypoint(p3)
    }
    self.waypoint = nil
    self.system.setWaypoint(self.targets[1], false)
end

---@param action string
function Scanner:onActionStart(action)
    -- Modifier keys are tracked even while hidden, so their state is right once the scanner is shown.
    if action == "lshift" then
        self.shiftDown = true
        return
    elseif action == "lalt" then
        self.altDown = true
        return
    end

    if action == "speeddown" then
        if self.hide then
            self:show()
        else
            self:clear()
        end
        return
    end

    -- The other keys only act on the shown scanner.
    if self.hide then
        return
    end

    if action == "option8" then
        self:toggleCalibration()
    elseif action == "speedup" then
        self:add()
    elseif action == "booster" then
        self.follow = not self.follow
    end
    if self.calibrating then
        self:calibrate(action)
    end
end

--- Turns the calibration mode on or off. When it ends, prints the values to copy into the Lua parameters.
function Scanner:toggleCalibration()
    self.calibrating = not self.calibrating
    if self.calibrating then
        self.system.print(self.translator:get("Calibration on: see the help for the keys"))
    else
        self.system.print(self.translator:get("Calibration off. To keep it, set these Lua parameters:"))
        self.system.print("triangulationLeft = " .. self.offsetLeft)
        self.system.print("triangulationTop = " .. self.offsetTop)
        self.system.print("triangulationAngle = " .. self.angle)
    end
end

--- Moves or skews the overlay, to align it with the game's scanner gauge.
---@param action string
function Scanner:calibrate(action)
    if self.altDown then
        if action == "up" then
            self.angle = self.angle - 0.01
            self.system.print(self.translator:get("Angle: %s°", self.angle))
        elseif action == "down" then
            self.angle = self.angle + 0.01
            self.system.print(self.translator:get("Angle: %s°", self.angle))
        end
    else
        if action == "up" then
            self.offsetTop = self.offsetTop - 1
            self.system.print(self.translator:get("Top offset: %s px", self.offsetTop))
        elseif action == "down" then
            self.offsetTop = self.offsetTop + 1
            self.system.print(self.translator:get("Top offset: %s px", self.offsetTop))
        elseif action == "strafeleft" then
            self.offsetLeft = self.offsetLeft - 1
            self.system.print(self.translator:get("Left offset: %s px", self.offsetLeft))
        elseif action == "straferight" then
            self.offsetLeft = self.offsetLeft + 1
            self.system.print(self.translator:get("Left offset: %s px", self.offsetLeft))
        end
    end
end

---@param action string
function Scanner:onActionStop(action)
    if action == "lshift" then
        self.shiftDown = false
    elseif action == "lalt" then
        self.altDown = false
    end
end

function Scanner:onUpdate()
    if not self.hide then
        local throttle = self.system.getThrottleInputFromMouseWheel();
        if self.shiftDown then
            throttle = clamp(throttle * FAST_SCROLL, -FAST_SCROLL, FAST_SCROLL)
        end
        self.position = vec3(self.player.getWorldPosition())
        self.problem = self:checkPosition()
        self.distance = clamp(floor(self.distance + throttle), 0, MAX_DISTANCE)

        if abs(throttle) > 0 then
            self.lastError = nil
            self.follow = false
        else
            if self.follow and self.waypoint ~= nil then
                self.distance = floor((self.waypoint - self.position):len() * 10) / 10
            end
        end
    end
end

--- Why no reading can be taken at the current position, or nil when one can.
---@return string|nil problem "close" (too close to an earlier reading), "line" or "plane" (see Trilateration.checkNextReading)
function Scanner:checkPosition()
    for i = 1, #self.points do
        if (self.points[i].center - self.position):len() < MIN_SPACING then
            return "close"
        end
    end
    return Trilateration.checkNextReading(self.points, self.position)
end

function Scanner:render()
    if self.hide then
        return {
            style = [[
            .triangulation-hidden {
            font-size: 12px;
            left: 10px;
            position: absolute;
            top: 25px;
        }
            ]],
            html = [[<div class="triangulation-hidden">]] .. self.translator:get("Triangulation hidden") .. [[</div>]]
        }
    else
        local sliderTop = GAUGE_HEIGHT / 100 * (100 - sliderHeight(self.distance) - SLIDER_OFFSET)
        local status = [[<span class="status ready">]] .. self.translator:get("Ready") .. [[</span>]]

        if self.lastError ~= nil then
            status = [[<span class="status error">]] .. self.lastError .. [[</span>]]
        elseif self.calibrating then
            status = [[<span class="status calibration">]] .. self.translator:get("Calibration") .. [[</span>]]
        elseif self.problem == "close" then
            status = [[<span class="status error">]] .. self.translator:get("Too close") .. [[</span>]]
        elseif self.problem == "line" then
            status = [[<span class="status error">]] .. self.translator:get("Move sideways") .. [[</span>]]
        elseif self.problem == "plane" then
            status = [[<span class="status error">]] .. self.translator:get("Move up or down") .. [[</span>]]
        end

        return {
            style = [[
            #triangulation {
            border-bottom: ]] .. GAUGE_HEIGHT .. [[vh solid rgba(]] .. self.backgroundColor .. [[,.25);
            border-right: 1vw solid transparent;
            font-size: ]] .. self.fontSize .. [[px;
            height: ]] .. GAUGE_HEIGHT .. [[vh;
            left: 50%;
            margin-left: ]] .. self.offsetLeft .. [[px;
            margin-top: ]] .. self.offsetTop .. [[px;
            min-width: 9vw;	
            position: absolute;
            top: 50%;
            transform: skew(]] .. self.angle .. [[deg);
            width: 15em;
        }
            #triangulation .slider {
            color:#eca943;
                display: block;
            left: -8px;
            top: ]] .. sliderTop .. [[vh;
            position: absolute;
        }
            #triangulation .slider i{
            font-size: 0.8em;
        }
            #triangulation .slider span{
            margin-left: 8em;
        }
            #triangulation .status{
            font-weight: bold;
            padding: 5px;
            position: absolute;
            text-align: center;
            width: 100%;
        }
            #triangulation .status.ready{
            color: #0CA313;
        }
            #triangulation .status.error{
            color: red;
        }
            #triangulation .status.calibration{
            color: #498aff;
        }
            #triangulation p{
                display: block;
                position: absolute;
                text-align: right;
                top: calc(]] .. GAUGE_HEIGHT .. [[vh + 5px);
                width: 100%;
            }
         ]],
            html = [[
        <div id="triangulation">	 	
        ]] .. status .. [[
        <div class="slider">◯<span>━━[ <i>]] .. self.distance .. [[</i> ]</span></div>
        <p>]] .. self.selected[min(#self.points, 4)] .. [[</p>
        </div>]]
        }
    end
end
