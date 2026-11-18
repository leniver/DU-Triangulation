--- Solver for the triangulation. It uses no game API, so it can be tested outside Dual Universe.
---@class Trilateration
Trilateration = {}

local sqrt = math.sqrt

--- Intersection of the spheres s1, s2 and s3; s4 picks the right one of the two mirror solutions.
---@param s1 Sphere
---@param s2 Sphere
---@param s3 Sphere
---@param s4 Sphere
---@return vec3
function Trilateration.trilaterate(s1, s2, s3, s4)
    local r1s = s1:r2()
    local v2, v3 = s2.center - s1.center, s3.center - s1.center
    local ax = v2:normalize()
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

local trilaterate = Trilateration.trilaterate

---@param s1 Sphere
---@param s2 Sphere
---@param s3 Sphere
---@param s4 Sphere
---@param results? vec3[]
---@return vec3[]
local function buildTrilaterationSet(s1, s2, s3, s4, results)
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
---@return boolean false as well for a NaN point
local function isDistanceCloserThan(s1, s2, s3, s4, point, distance)
    return s1:dst(point) <= distance and s2:dst(point) <= distance and s3:dst(point) <= distance and s4:dst(point) <= distance
end

--- How far (m) the result may be from each reading's sphere and still be accepted.
Trilateration.tolerance = 50

--- Readings that are almost on a line or in a plane give results that pass the final check but can
--- be hundreds of metres off. With whole-metre readings, these minimums keep 90% of the results
--- within about 12 m of the ore (25 m legs, ore 30-200 m away).
Trilateration.minLineDistance = 10 -- the 3rd reading from the line through the first two
Trilateration.minPlaneDistance = 5 -- the 4th reading from the plane through the first three

--- Whether a reading taken at `position` keeps the geometry usable for the solver.
---@param points Sphere[] the readings taken so far
---@param position vec3 where the next reading would be taken
---@return string|nil problem "line" when a 3rd reading would be too close to the line through the
--- first two, "plane" when a 4th one would be too close to the plane through the first three, else nil
function Trilateration.checkNextReading(points, position)
    local count = #points
    if count == 2 then
        local axis = points[2].center - points[1].center
        local v = position - points[1].center
        if (v - v:project_on(axis)):len() < Trilateration.minLineDistance then
            return "line"
        end
    elseif count == 3 then
        local normal = (points[2].center - points[1].center):cross(points[3].center - points[1].center)
        local length = normal:len()
        if length == 0 then
            return "line"
        end
        if math.abs((position - points[1].center):dot(normal)) / length < Trilateration.minPlaneDistance then
            return "plane"
        end
    end
    return nil
end

--- Finds the point that best matches the readings.
---@param points Sphere[] 4 readings, plus an optional 5th one that refines the result
---@return vec3|nil result nil when there are fewer than 4 readings or they don't agree
function Trilateration.solve(points)
    local size = #points
    if size < 4 then
        return nil
    end

    local result = nil
    local s1, s2, s3, s4 = points[1], points[2], points[3], points[4]

    local results = buildTrilaterationSet(s1, s2, s3, s4)

    if size > 4 then
        local addResults = buildTrilaterationSet(points[5], s1, s2, s3)
        buildTrilaterationSet(points[5], s2, s3, s4, addResults)
        buildTrilaterationSet(points[5], s3, s4, s1, addResults)
        buildTrilaterationSet(points[5], s4, s1, s2, addResults)
        for j = 1, #addResults do
            if isDistanceCloserThan(s1, s2, s3, s4, addResults[j], Trilateration.tolerance) then
                results[#results + 1] = addResults[j]
            end
        end
    end

    -- Degenerate readings (e.g. two at the same spot) give NaN or infinite candidates:
    -- their score is never < math.huge, so they are never picked.
    local distance = math.huge
    local currentDistance = 0
    for i = 1, #results do
        currentDistance = 0
        for j = 1, size do
            currentDistance = currentDistance + points[j]:dst(results[i])
        end
        if currentDistance < distance then
            result = results[i]
            distance = currentDistance
        end
    end

    if result == nil or not isDistanceCloserThan(s1, s2, s3, s4, result, Trilateration.tolerance) then
        return nil
    end

    return result
end
