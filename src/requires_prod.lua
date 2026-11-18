--- Includes
require("includes/tools")
-- Class first: the classes are built with Class() when they are loaded.
require("includes/Class")
require("includes/Wrapper")

--- Other required files
-- Widget first: the widgets extend it (Class(Widget)) when they are loaded.
require("classes/Widget")
require("classes/Hud")
require("classes/Helper")
require("classes/Sphere")
require("classes/Trilateration")
require("classes/Scanner")
require("classes/BoardWaypoint")
require("classes/Translator")
require("app")