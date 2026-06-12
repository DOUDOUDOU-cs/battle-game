# DEVELOPER LOG

---

## Current Project Structure (2026-05-10)

```text
battle-game/
|- scenes/
|  |- levels/
|  |  |- main.tscn
|  |  |- level2.tscn
|  |  `- level3.tscn
|  |- player/
|  |  `- player.tscn
|  |- enemies/
|  |  |- enemy.tscn
|  |  `- enemy2.tscn
|  |- drops/
|  |  |- item_drop.tscn
|  |  |- item_drop_mushroom.tscn
|  |  `- item_drop_slime_gel.tscn
|  `- ui/
|     `- start.tscn
|- scripts/
|  |- core/
|  |  |- item_texture_library.gd
|  |  `- wave_manager.gd
|  |- levels/
|  |  |- base_level.gd
|  |  |- main.gd
|  |  |- level2.gd
|  |  |- level3.gd
|  |  `- random_level_generator.gd
|  |- player/
|  |  `- player.gd
|  |- enemies/
|  |  |- base_enemy.gd
|  |  |- enemy.gd
|  |  `- enemy2.gd
|  |- drops/
|  |  |- item_drop.gd
|  |  |- item_drop_mushroom.gd
|  |  `- item_drop_slime_gel.gd
|  |- inventory/
|  |  |- inventory.gd
|  |  |- inventory_ui.gd
|  |  |- item_data.gd
|  |  |- operations/
|  |  |  |- inventory_input_router.gd
|  |  |  `- inventory_slot_service.gd
|  |  |- render/
|  |  |  |- inventory_item_icon_drawer.gd
|  |  |  |- inventory_vine_drawer.gd
|  |  |  `- inventory_widget_factory.gd
|  |  `- state/
|  |     |- inventory_craft_state.gd
|  |     `- inventory_ui_state.gd
|  `- ui/
|     `- start.gd
|- assets/
|  |- mushroom.png
|  |- gel.png
|  `- tileset/
|- project.godot
|- AI_prompt.md
|- DEVELOPER_LOG.md
`- MEMORIES.md
```

---

## Recent Refactor Summary

### 1. Level flow refactor
- Extracted shared level logic into `scripts/levels/base_level.gd`
- Unified:
  - HUD initialization
  - pause menu wiring
  - wave start / continue flow
  - kill zone handling
  - game over flow
  - left/right transition entry handling
- Child level scripts now mainly keep level-specific spawn and transition logic

### 2. Enemy logic refactor
- Added `scripts/enemies/base_enemy.gd`
- Shared patrol / chase / attack / damage / death flow moved into the base class
- Enemy child scripts now mainly override:
  - death duration
  - drop behavior
  - custom hit reaction details
- Added LOS-based detection so obstacles can block aggro

### 3. Wave state stabilization
- `scripts/core/wave_manager.gd` now distinguishes:
  - current wave
  - cleared wave count
  - last cleared wave
  - alive enemy count
  - in-progress state
- Fixed the old logic bug where "wave 2 started" could be mistaken for "2 waves cleared"

### 4. Scene and script directory cleanup
- Grouped scenes and scripts by responsibility:
  - `levels`
  - `player`
  - `enemies`
  - `drops`
  - `inventory`
  - `core`
  - `ui`
- Updated autoloads and scene/script references to the new structure

### 5. Level 3 random map extraction
- Removed hard-coded terrain generation logic from `level3.gd`
- Added `scripts/levels/random_level_generator.gd`
- Current generator API:
  - `generate_small_map(tilemap)`
  - `generate_large_map(tilemap)`
  - `generate_glitch_zone_map(tilemap)`
- `level3.gd` now only selects a mode and applies layout results to:
  - player spawn
  - enemy spawn
  - kill zone sizing

### 6. Inventory system decomposition
- `scripts/inventory/inventory_ui.gd` was gradually reduced and turned into a coordinator
- Extracted visual responsibilities:
  - `scripts/inventory/render/inventory_item_icon_drawer.gd`
  - `scripts/inventory/render/inventory_vine_drawer.gd`
  - `scripts/inventory/render/inventory_widget_factory.gd`
- Extracted interaction and input responsibilities:
  - `scripts/inventory/operations/inventory_slot_service.gd`
  - `scripts/inventory/operations/inventory_input_router.gd`
- Extracted state containers:
  - `scripts/inventory/state/inventory_craft_state.gd`
  - `scripts/inventory/state/inventory_ui_state.gd`

### 7. Drop rendering and texture stabilization
- Replaced runtime background removal with static transparent assets:
  - `assets/mushroom.png`
  - `assets/gel.png`
- Simplified `scripts/core/item_texture_library.gd` to regular cached loading
- Removed start-of-level texture preprocessing to reduce startup hitches

### 8. Level 3 tile semantics upgrade
- Stopped guessing normal terrain tiles from visual similarity alone
- Recorded explicit tile-role mapping from the project's actual jungle tileset
- Reworked structured terrain painting toward adjacency-driven selection:
  - top faces
  - side walls
  - deep fill
  - bottom faces
  - one-tile floating ledges

---

## Problems Encountered And Fixes

### 1. Mixed indentation and outdated TileMap API
- Problem:
  - `level3.gd` had mixed tabs/spaces
  - `TileMapLayer.set_cell` was still being called with old `TileMap` argument order
- Fix:
  - normalized indentation
  - updated `set_cell` calls to `TileMapLayer`-compatible signatures

### 2. Variant inference warnings treated as errors
- Problem:
  - some local variables in `inventory_ui.gd` used `:=` with values coming from `Dictionary`, `Variant`, or untyped helper functions
- Fix:
  - replaced risky inference points with explicit types for:
    - `Dictionary`
    - `ItemData`
    - `Vector2`
    - `bool`
    - `int`
    - `float`

### 3. Encoding damage in `.gd` and `.tscn` files
- Problem:
  - some strings became corrupted after earlier edits and encoding conversions
  - broken scene text lines could break parsing or startup
- Fix:
  - converted damaged files back to readable UTF-8 content
  - replaced broken strings with safe text
- Lesson:
  - when a file is already encoding-damaged, patching line-by-line can fail silently or misalign context; restore encoding first, then edit structure

### 4. Level 3 node-name mismatch
- Problem:
  - script expected a different node path than the actual scene node name
- Fix:
  - aligned the script to the real node path used by the scene
- Lesson:
  - in Godot, type and node name are independent; always verify both before assuming a path

### 5. Level 3 world-space mismatch
- Problem:
  - random platform generation, player spawn, enemy spawn, and kill zone were not using the same coordinate assumptions
  - result: player could spawn off-platform and falling might never hit kill zone
- Fix:
  - unified all level3 placement logic around actual tile size, tilemap transform, and world coordinates
  - aligned generated terrain around the player's spawn origin instead of pushing the player to a hard-coded map point

### 6. Inventory UI instability from over-centralization
- Problem:
  - drawing, layout, drag state, slot rules, stash logic, craft state, and drop spawning all lived in one file
- Fix:
  - split by responsibility first rather than by feature ambition
- Lesson:
  - for unstable UI systems, "extract seams first" is safer than "rewrite everything"

### 7. Runtime texture processing caused avoidable hitches
- Problem:
  - dynamic background removal for drop textures added visible stalls during startup and first drop creation
- Fix:
  - switched to preprocessed static PNG assets with transparency
  - simplified the texture library to straight cached loads
- Lesson:
  - for a small Godot project, runtime image cleanup is rarely worth the cost if the assets can be fixed once offline

### 8. Level 3 terrain quality depended on explicit tile semantics
- Problem:
  - visually similar jungle tiles still carry different gameplay-facing meanings: top edge, side wall, deep fill, ledge bottom, or corner
  - naive "surface vs fill" logic produced fake walls and wrong corners
- Fix:
  - collected an explicit tile-role mapping
  - moved toward adjacency-based tile selection for structured terrain
- Lesson:
  - tilesets with handcrafted corners should be treated like rule tables, not texture pools

---

## Current Level 3 Terrain Notes

### Structured mode direction
- The current stable direction is:
  1. generate solid terrain cells first
  2. choose tiles based on neighbor exposure
  3. keep deep fill conservative
- This is safer than alternating "pretty" tiles inside deep soil, because many mid-row jungle tiles encode side-wall meaning

### Confirmed normal-terrain tile meanings from the current jungle tileset
- `(row 0, col 0)` outer top-left corner
- `(row 0, col 1)` horizontal top surface
- `(row 0, col 2)` outer top-right corner
- `(row 1, col 0)` left-facing wall
- `(row 1, col 1)` isolated deep soil
- `(row 1, col 2)` downward-facing ground underside
- `(row 2, col 0)` outer bottom-left corner
- `(row 2, col 1)` right-facing wall
- `(row 2, col 2)` outer bottom-right corner
- `(row 3, col 0)` thin left-cap ledge
- `(row 3, col 1)` thin one-tile top / bottom variation
- `(row 3, col 2)` thin right-cap ledge

### Next terrain-quality targets
1. Add the confirmed inner-corner tiles into adjacency rules
2. Distinguish broad cliff walls from one-tile decorative ledges
3. Refine canopy platform composition so floating ledges do not inherit full terrain behavior

---

## Current Inventory Refactor Notes

### What has already been separated
- Visual drawing components are independent
- Slot interaction rules are independent
- UI runtime state is independent
- Craft slot state is independent
- Widget construction is independent

### What still remains inside `inventory_ui.gd`
- bag panel orchestration
- cursor icon orchestration
- some event routing
- bridge logic between UI actions and inventory data
- drop spawning bridge

### Safe next refactor targets
1. Move more placement and merge rules from `inventory_ui.gd` into `inventory.gd`
2. Keep fixing interaction regressions before adding new inventory features
3. Treat drag/drop, stack merge, shift transfer, and stash-back behavior as protected stability paths

---

## Practical Takeaways

- Stabilizing a small project is often more valuable than pushing abstraction too early.
- For Godot projects, node path drift, encoding damage, and texture import assumptions can be just as destructive as gameplay bugs.
- When a script gets too large, the first useful split is not always by "feature", but by "kind of responsibility":
  - drawing
  - state
  - rules
  - orchestration
- If a handcrafted tileset is meant to build natural terrain, every reusable tile should have a named semantic role before procedural generation grows more complex.
