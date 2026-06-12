# Development Memories

## Effective patterns used in this project

### 1. Stabilize before expanding
- When a system is already bug-prone, do not begin with a full rewrite.
- First isolate responsibilities and reduce coupling.
- This approach worked well for:
  - level flow refactor
  - enemy refactor
  - inventory UI decomposition
  - drop texture simplification

### 2. Prefer "shared base + thin child" for repeated Godot gameplay scripts
- `BaseLevel` reduced repeated HUD / pause / wave / game-over logic
- `BaseEnemy` reduced repeated AI and damage/death logic
- This makes future behavior changes cheaper and less risky

### 3. For random map systems, return layout data instead of mutating everything ad hoc
- `RandomLevelGenerator` now returns:
  - platforms
  - level width
  - spawn references
  - kill zone row
- This keeps the generator reusable and level scripts simpler

### 4. For unstable UI, split by responsibility first
- Best split order discovered so far:
  1. custom drawing
  2. slot interaction rules
  3. craft state
  4. widget construction
  5. UI state
  6. event routing cleanup

### 5. For handcrafted tilesets, define tile meaning before polishing the generator
- Procedural terrain got more stable only after explicit tile semantics were written down
- "Looks similar" is not enough for a jungle tileset with corners, walls, ledges, and underside pieces
- Adjacency rules become much easier to reason about once every reusable tile has a role

### 6. Prefer fixed assets over runtime image cleanup in a small project
- Runtime background removal caused avoidable hitches
- Replacing source assets with transparent PNGs was simpler, faster, and easier to verify

## Common project risks discovered

- Encoding corruption in `.gd` / `.tscn`
- Godot node name vs node type mismatch
- `Variant` inference warnings becoming parser blockers
- Scene transition logic accidentally counting non-death removals
- UI scripts directly mutating data structures in too many places
- Procedural tile placement using visual guesswork instead of explicit tile meaning
- Runtime texture processing being mistaken for harmless convenience

## Current guidance for future work

- Inventory work should continue in small passes.
- Avoid ambitious "Minecraft-like full inventory rewrite" jumps.
- Treat drag/drop, stack merge, shift transfer, and stash-back behavior as critical stability paths.
- Prefer extracting helpers/services over redesigning visible behavior unless a bug forces it.
- For level3 terrain work, continue refining adjacency rules with explicit tile-role notes instead of broad visual guesses.
