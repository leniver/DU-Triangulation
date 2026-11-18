--- Includes
require(localDirectory .. "includes/tools")
-- Class first: the classes are built with Class() when they are loaded.
require(localDirectory .. "includes/Class")
require(localDirectory .. "includes/Wrapper")

--- Other required files prefixed with "localDirectory"
-- Widget first: the widgets extend it (Class(Widget)) when they are loaded.
require(localDirectory .. "classes/Widget")
require(localDirectory .. "classes/Hud")
require(localDirectory .. "classes/Helper")
require(localDirectory .. "classes/Sphere")
require(localDirectory .. "classes/Trilateration")
require(localDirectory .. "classes/Scanner")
require(localDirectory .. "classes/Translator")