---@class Scanner : Widget
---@field points Sphere[]
---@field targets? string[]
---@field distance number
---@field limit number
---@field range boolean
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
---@field frozen boolean
---@field lastError string
---@field lastMessage string
---@field offsetLeft number
---@field offsetTop number
---@field angle number
---@field fontSize number
---@field backgroundColor string
Scanner = Class(Widget)

local floor, abs, sqrt, min, max, clamp = math.floor, math.abs, math.sqrt, math.min, math.max, Clamp

---@param s1 Sphere
---@param s2 Sphere
---@param s3 Sphere
---@param s4 Sphere
---@return vec3
local function trilaterate(s1, s2, s3, s4)
    local r1s = s1:r2()
    local v2, v3 = s2.center - s1.center, s3.center - s1.center
    local ax = s2.center:normalize()
    local U = v2:len()
    local ay = (v3 - v3:project_on(ax)):normalize()
    local v3x, v3y = v3:dot(ax), v3:dot(ay)
    local vs = v3x * v3x + v3y * v3y
    local x = (r1s - s2:r2() + U * U) / (2 * U)
    local y = (r1s - s3:r2() + vs - 2 * v3x * x) / (2 * v3y)
    local m = r1s - (x ^ 2) - (y ^ 2)
    if m < 0.0000001 then m = 0 end
    local axx, ayy, azz = ax * x, ay * y, ax:cross(ay) * sqrt(m)
    local t1 = s1.center + axx + ayy + azz
    local t2 = s1.center + axx + ayy - azz

    ---@diagnostic disable-next-line: return-type-mismatch, param-type-mismatch
    return (s4:dst(t1) < s4:dst(t2) and t1) or t2
end

---@param s1 Sphere
---@param s2 Sphere
---@param s3 Sphere
---@param s4 Sphere
---@param results? vec3[]
local function buildTrialaterationSet(s1, s2, s3, s4, results)
    results = results or {}
    results[#results + 1] = trilaterate(s1, s2, s3, s4)
    results[#results + 1] = trilaterate(s2, s3, s4, s1)
    results[#results + 1] = trilaterate(s3, s4, s1, s2)
    results[#results + 1] = trilaterate(s4, s1, s2, s3)

    return results
end

---@param s1 Sphere
---@param s2 Sphere
---@param s3 Sphere
---@param s4 Sphere
---@param point vec3
---@param distance number
---@return boolean
local function isDistanceCloserThan(s1, s2, s3, s4, point, distance)
    return not (s1:dst(point) > distance or s2:dst(point) > distance or s3:dst(point) > distance or s4:dst(point) > distance)
end

---@param system System
---@param player Player
---@param translator Translator
function Scanner:init(system, player, translator)
    self.points = {}
    self.targets = nil
    self.distance = 250


    self.limit = 20
    self.range = true

    self.system = system
    self.system.showScreen(true)
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
    self.frozen = false

    self.lastError = nil
    self.lastMessage = nil

    self.offsetLeft = 0
    self.offsetTop = 0
    self.angle = 15.85
    self.fontSize = 12
    self:initializeOffets(false)

    self.backgroundColor = ToRGB(triangulationBackgroundColor)

    self:initEvents()
end

---@param displaySettings boolean
function Scanner:initializeOffets(displaySettings)
    local offsets, screenSize = getOffsets("scanner")

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
        self.system.print([[====== Triangulation settings ======]])
        self.system.print([[Screen resolution: ]] .. screenSize)
        self.system.print([[Left offset: ]] .. self.offsetLeft .. "px")
        self.system.print([[Offset top: ]] .. self.offsetTop .. "px")
        self.system.print([[Font size: ]] .. self.fontSize .. "px")
        self.system.print([[Angle: ]] .. self.angle .. "°")
        self.system.print([[==================================]])
    end
end

function Scanner:add()
    if self.range then
        local size = #self.points
        self.lastError = nil
        if size < 5 then
            self.points[size + 1] = Sphere.new(self.position, self.distance)
            size = size + 1
        elseif (self.distance < self.points[5].radius) then
            self.points[5] = Sphere.new(self.position, self.distance)
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
    self.lastMessage = nil
    self.waypoint = nil
    self.follow = nil
end

function Scanner:solve()
    local size = #self.points
    if size >= 4 then
        local result = nil
        local s1 = self.points[1]
        local s2 = self.points[2]
        local s3 = self.points[3]
        local s4 = self.points[4]

        local results = buildTrialaterationSet(s1, s2, s3, s4)

        if size > 4 then
            local addResults = buildTrialaterationSet(self.points[5], s1, s2, s3)
            buildTrialaterationSet(self.points[5], s2, s3, s4, addResults)
            buildTrialaterationSet(self.points[5], s3, s4, s1, addResults)
            buildTrialaterationSet(self.points[5], s4, s1, s2, addResults)
            for j = 1, #addResults do
                if isDistanceCloserThan(s1, s2, s3, s4, addResults[j], 50) then
                    results[#results + 1] = addResults[j]
                end
            end
        end

        local distance = 10000
        local currentDistance = 0
        for i = 1, #results do
            currentDistance = 0
            for j = 1, size do
                currentDistance = currentDistance + self.points[j]:dst(results[i])
            end
            if currentDistance < distance then
                result = results[i]
                distance = currentDistance
            end
        end

        if not isDistanceCloserThan(s1, s2, s3, s4, result, 50) then
            self.points = {}
            self.lastError = self.translator:get("Triangulation failed")
            return false
        end

        self.follow = true
        self.waypoint = result
        local waypoint = ToWaypoint(result)
        self.system.setWaypoint(waypoint, false)
    end
end

function Scanner:initEvents()
    ---@diagnostic disable-next-line: undefined-field
    self.system:onEvent("onUpdate", function()
        self:onUpdate()
    end)
end

---@param action string
function Scanner:onActionStart(action)
    if action == "speeddown" then
        if self.hide then
            self:clear()
            self.hide = false
            self:initializeOffets(true)

            local position = vec3(self.player.getWorldPosition())
            local increment = min(max(assistedTriangulationDistance, 15), 50)

            local forwardVec = vec3(self.system.getCameraWorldForward())
            local rightVec = vec3(self.system.getCameraWorldRight())
            local verticalVec = vec3(self.system.getCameraWorldUp())

            local forward = verticalVec:cross(rightVec):normalize()
            local right = verticalVec:cross(forwardVec):normalize()
            local vertical = verticalVec:normalize()

            local p1 = position + forward * increment
            local p2 = p1 + right * increment
            local p3 = p2 + vertical * increment + right * 5
            self.targets = {
                ToWaypoint(position),
                ToWaypoint(p1),
                ToWaypoint(p2),
                ToWaypoint(p3)
            }
            self.waypoint = nil
            self.system.setWaypoint(self.targets[1], false)
        else
            self:clear()
        end
    elseif action == "option9" then
        self.frozen = not self.frozen
    elseif action == "speedup" then
        self:add()
    elseif action == "booster" then
        self.follow = not self.follow
    elseif action == "lshift" then
        self.shiftDown = true
    elseif action == "lalt" then
        self.altDown = true
    end
    if self.frozen then
        if self.altDown then
            if action == "up" then
                self.angle = self.angle - 0.01
                self.system.print("Angle: " .. self.angle)
            elseif action == "down" then
                self.angle = self.angle + 0.01
                self.system.print("Angle: " .. self.angle)
            end
        else
            if action == "up" then
                self.offsetTop = self.offsetTop - 1
                self.system.print("Offset top: " .. self.offsetTop)
            elseif action == "down" then
                self.offsetTop = self.offsetTop + 1
                self.system.print("Offset top: " .. self.offsetTop)
            elseif action == "strafeleft" then
                self.offsetLeft = self.offsetLeft - 1
                self.system.print("Offset left: " .. self.offsetLeft)
            elseif action == "straferight" then
                self.offsetLeft = self.offsetLeft + 1
                self.system.print("Offset left: " .. self.offsetLeft)
            end
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
            throttle = clamp(throttle * 5, -5, 5)
        end
        self.position = vec3(self.player.getWorldPosition())
        self.range = self:checkRange()
        self.distance = clamp(floor(self.distance + (throttle * 1)), 0, 480)

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

function Scanner:checkRange()
    for i = 1, #self.points do
        if (self.points[i].center - self.position):len() < self.limit then
            return false
        end
    end
    return true
end

function Scanner:render()
    if self.hide then
        return { style = "", html = "Triangulation hidden" }
    else
        local top = 0.02 + 0.253 * self.distance + -1.13E-04 * (self.distance ^ 2)
        local status = [[<span class="status ready">]] .. self.translator:get("Ready") .. [[</span>]]

        if self.lastError ~= nil then
            status = [[<span class="status error">]] .. self.lastError .. [[</span>]]
        elseif not self.range then
            status = [[<span class="status error">]] .. self.translator:get("Too close") .. [[</span>]]
        end

        return {
            style = [[
            #triangulation {
            border-bottom: 28.5vh solid rgba(]] .. self.backgroundColor .. [[,.25);
            border-right: 1vw solid transparent;
            font-size: ]] .. self.fontSize .. [[px;
            height: 28.5vh;
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
            top: ]] .. (28.5 / 100 * (100 - top - 3)) .. [[vh;
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
            #triangulation p{
                display: block;
                position: absolute;
                text-align: right;
                top: calc(28.5vh + 5px);
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
