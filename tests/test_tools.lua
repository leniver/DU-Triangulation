loadSource("includes/tools")

test("toRGB turns an \"R G B\" parameter into CSS", function()
    assertEqual(Tools.toRGB("3 8 7"), "3,8,7")
    assertEqual(Tools.toRGB("300 0 12"), "255,0,12")
    assertEqual(Tools.toRGB("blue"), "2,52,110")
end)

test("toWaypoint writes a ::pos string in world coordinates", function()
    assertEqual(Tools.toWaypoint(vec3(1.5, -2.25, 3)), "::pos{0,0,1.5,-2.25,3.0}")
    assertEqual(Tools.toWaypoint(vec3(17465536.123456, 0, 0), 2), "::pos{0,2,17465536.12345,0.0,0.0}")
end)

test("clamp keeps a value between two limits", function()
    assertEqual(Tools.clamp(5, 0, 10), 5)
    assertEqual(Tools.clamp(-1, 0, 10), 0)
    assertEqual(Tools.clamp(11, 0, 10), 10)
end)
