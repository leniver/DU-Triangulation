--- Includes
require(localDirectory .. "includes/tools")
require(localDirectory .. "includes/Wrapper")
require(localDirectory .. "includes/Class")

--- Other required files prefixed with "localDirectory"
-- Widget first: the widgets extend it (Class(Widget)) when they are loaded.
require(localDirectory .. "classes/Widget")
require(localDirectory .. "classes/Hud")
require(localDirectory .. "classes/Helper")
require(localDirectory .. "classes/Sphere")
require(localDirectory .. "classes/Trilateration")
require(localDirectory .. "classes/Scanner")
require(localDirectory .. "classes/Translator")