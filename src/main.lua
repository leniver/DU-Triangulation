--- This code will be copied into unit->start
--- Should contain global declaration and requirements

DUUnit = unit
-- true: load the sources from the game's Lua folder (localDirectory) and enable hot reload.
-- Not named "debug": that would hide Lua's debug library.
DEV_MODE = false
localDirectory = "autoconf/custom/triangulation/"


require("parameters")
require("includes/Events")
if DEV_MODE then
  require(localDirectory .. "requires_dev")
  require(localDirectory .. "init")
else
  require("requires_prod")
  require("init")
end