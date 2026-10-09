# Mouse aim and target lock (Claude, 2026-10-09)

**Preston, 2026-10-09:** item 3 of the feel plan. The mouse is the aim; right click locks an enemy.

## What changed (`scripts/arena/arena_prototype.gd`)
- **The mouse is live** for 1.5 s after it moves or clicks. While it is live, the creature you steer aims at the cursor; when it is idle (keyboard play, J and WASD) everything works as item 1 built it, at the target in reach or down the steering line.
- **The basic with the mouse:** the swing or shot goes toward the cursor. The nearest enemy inside a cone of about 35 degrees either side of the cursor line, within reach, becomes the target (a locked enemy first). Nobody in the cone makes it a free swing toward the cursor that takes whoever is in its arc. A ranged basic (Whistle Dart, Molten Beam, Wick Bolt) flies toward the cursor, so it is a skillshot that can miss a sidestep.
- **Abilities with the mouse:** the same cone picks the target. A shaped attack (damage, a reach, not a charge) with nobody in the cone goes to the cursor as a free shot and is never refused for range; a lob or area move lands at the cursor, clamped to its range. Support, mobility and other targeted moves keep their target. With a target in the cone the out-of-range refusal from item 2 still applies.
- **Facing:** while the attack button is held the creature faces the cursor, even standing still (standing creatures otherwise turn to their target).
- **Right click** locks the enemy within 40 px of the cursor: the target marker turns red and the enemy wears a four-corner bracket; right click on empty ground clears the lock back to auto. Q, E and Tab still work.
- **A reticle** (a small ring with four ticks) sits on the floor at the cursor while the mouse is live, brighter while the button is held.
- `mouse_override` lets the checks place the cursor.

## Check (`tools/debug/arena_aim_check.gd`)
- Cursor south with the auto target 30 px east and another enemy 34 px south: the swing aimed south, the south enemy took 18, the auto target took 0, facing s.
- Cursor west over empty ground: a free swing west, the telegraph at the basic's reach, nobody hit.
- Holding the button with the cursor to the north-west: facing nw.
- Right click on Scourmaw: locked; right click on empty ground: cleared.
- Whistle Dart with the foe south and the cursor east: the dart flies east.
- Seed with the foe south and the cursor at (70, -30): telegraph and seed at (64, -28), the cursor clamped to the lob's range.
- Mouse idle with a stale cursor west and the target 30 px east: not free, the target hit.
- The press, feedback and picker checks still pass.
- Stills: `cone_target.png`, `lock.png`, `lob_cursor.png`.

## Known
- The cone (0.6 rad), the live window (1.5 s) and the lock reach (40 px) are drafts.
- A locked enemy outside the cone is not hit by a free swing in another direction; the lock sets the target, the cursor sets the line.
- Remaining items of the plan: 4 your own range ring and telegraph ghost, 5 combos.

## Fixed the same evening
Preston: "the attack camera cone is stuck top left." The floor lives in a SubViewport shown at 3x, and a SubViewport never sees the mouse: `_fx.get_local_mouse_position()` always answered the origin, so every aim pointed at the top-left corner. `_mouse_world` now takes the arena node's own mouse position, divides by the screen scale and undoes the camera's world transform. Probed at three screen points in the picker's arena (the window centre maps to the view's centre); the aim check still passes.
