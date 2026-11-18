# Dual Universe Triangulation

A HUD for Dual Universe that finds ore with the mining tool's scanner. The scanner only tells how far
the nearest ore is; this script takes four of these distances from four places and computes where the
ore is (trilateration), then sets a waypoint on it.

It draws a slider over the game's scanner gauge: you move the slider onto the gauge's reading with the
mouse wheel and add the reading with a key. A guided pattern of waypoints shows where to take the
readings.

## Installation

The script runs on a programming board and needs no linked elements.

1. Build it with [DU-LuaC](https://github.com/wolfe-labs/DU-LuaC) (see [Development](#development)),
   copying the result to the clipboard:

   ```sh
   du-lua build --copy=production/main
   ```

   The file is also written to `out/production/main.json`.
2. In game, right-click the programming board, then *Advanced* > *Paste Lua configuration from
   clipboard*.
3. Activate the board while standing next to it.

## Taking a triangulation

The help panel (`option9`, Alt+9 by default) shows the keys bound on your computer.

1. Press `speeddown` to show the triangulation. A waypoint is set where you stand: the first reading
   is taken there.
2. Take out the mining tool's scanner. Turn the mouse wheel until the slider is on the gauge's
   reading (hold Shift to move it 5 times faster). The number on the slider is the distance in metres.
3. Press `speedup` to add the reading. The waypoint moves to the next place of the pattern: walk
   there and repeat. The 4th place is higher than the others (25 m with the default settings: use
   the jetpack).
4. After the 4th reading, the waypoint is set on the ore and the slider shows the distance to it.
   `booster` turns this off and on.
5. Optional: a 5th reading taken closer to the ore refines the result. Later readings replace it
   when they are closer.

The overlay says when a reading can't be taken:

| Message                  | Meaning                                                              |
|--------------------------|----------------------------------------------------------------------|
| **Too close**            | Less than 20 m from an earlier reading.                              |
| **Move sideways**        | The 3rd reading would be too close to the line through the first two. |
| **Move up or down**      | The 4th reading would be too close to the plane of the first three.  |
| **Triangulation failed** | The readings don't agree. The pattern starts again from its first waypoint. |

Press `speeddown` again to hide the triangulation; showing it again starts a new one.

## Waypoint back to the board

`option7` (Alt+7 by default) sets a waypoint to the board, e.g. to find your ship again after
mining. It works whether the triangulation is shown or not, and it follows the ship if it has moved
since the board was started.

## Calibration

The overlay has to sit exactly on the game's scanner gauge. Its position is known for common screen
resolutions and computed for the others. If it is off on your screen:

1. Show the triangulation and press `option8` (Alt+8 by default): the overlay shows *Calibration*.
2. Move it with `up`/`down` and `strafeleft`/`straferight`; change its angle with Alt + `up`/`down`.
3. Press `option8` again. The values are printed in the Lua chat: copy them into the board's Lua
   parameters (right-click the board, *Advanced* > *Edit Lua parameters*) to keep them.

## Lua parameters

| Parameter                       | Default | Description                                                    |
|---------------------------------|---------|----------------------------------------------------------------|
| `language`                      | `en`    | `en`, `fr` or `de`.                                            |
| `baseColor`                     | `3 8 7` | Colour of the help panel, as "R G B".                          |
| `triangulationBackgroundColor`  | `3 8 7` | Colour of the overlay, as "R G B".                             |
| `triangulationLeft`             | `0`     | Overlay offset from the left, in pixels. 0: automatic.         |
| `triangulationTop`              | `0`     | Overlay offset from the top, in pixels. 0: automatic.          |
| `triangulationFontSize`         | `0`     | Overlay font size, in pixels. 0: automatic.                    |
| `triangulationAngle`            | `0`     | Overlay angle, in degrees. 0: automatic.                       |
| `assistedTriangulationDistance` | `25`    | Distance between the readings of the pattern, 25 to 50 metres. |

## Development

You need [Node.js](https://nodejs.org/) and DU-LuaC:

```sh
npm install -g @wolfe-labs/du-luac
du-lua build                 # builds out/development and out/production
du-lua add-code-completion   # adds util/Codex.lua, the game's API for the editor's Lua extension
```

### Layout

- `src/main.lua`: entry point (unit > start). `src/parameters.lua`: the Lua parameters.
- `src/app.lua`: builds the HUD and its widgets from the game objects.
- `src/classes/`: the HUD and its widgets (`Scanner`, `Helper`, `BoardWaypoint`), the solver
  (`Trilateration`) and the translations (`Translator`).
- `src/includes/`: `Class` (classes and inheritance), `Wrapper` (hot reload) and `tools`.
- `src/requires_prod.lua` and `src/requires_dev.lua` list the modules, in load order. Keep them in
  sync: DU-LuaC only bundles literal `require("...")` calls, and a test compares both lists.

### Dev mode and hot reload

With `DEV_MODE = true` in `src/main.lua`, the board loads the sources at run time from the game's
`Game/data/lua/autoconf/custom/triangulation/` folder (put or link `src` there) instead of the
bundle. Then `lalt`, `brake`, `lshift` and `speedup` pressed in this order (Alt, Ctrl, Shift, then
`speedup`) reload the sources and rebuild the HUD without restarting the board.

### Tests

The tests run outside the game with Lua 5.3, the version Dual Universe uses, and need nothing else:

```sh
lua tests/run.lua
```

They cover the solver, the translations, the widgets (with fake game objects in `tests/fakes.lua`),
the module order and the hot reload. The runner also fails on an accidental global (a missing
`local`).

## Licence

[MIT](LICENSE) © Leniver
