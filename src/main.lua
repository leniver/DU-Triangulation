--- This code will be copied into unit->start
--- Should contain global declaration and requirements

DUUnit = unit
debug = false
localDirectory = "autoconf/custom/triangulation/"


require("parameters")
require("includes/Events")
if debug then
  require(localDirectory .. "requires_dev")
  require(localDirectory .. "init")
else
  require("requires_prod")
  require("init")
end