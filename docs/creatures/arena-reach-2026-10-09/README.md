# Your reach on the floor (Claude, 2026-10-09)

**Preston, 2026-10-09:** item 4 of the feel plan: a range ring for your basic and a ghost of each move's shape before it fires.

## What changed (`scripts/arena/arena_prototype.gd`)
- **The ring:** a faint ellipse in your line's colour at the basic's reach (range plus the sweep margin, plus the perch bonus on a perch) sits under the creature you steer, brighter while the mouse is live.
- **The ghost:** with the mouse live and nothing winding up, the basic's shape is drawn toward the cursor before you press: a wedge (the sweep arc) for melee basics, a thin line to the reach for shots and beams, a landing spot for lobs, so you see what a press will do.
- **Your wind-ups in your colour:** the telegraph of a move you pressed is now drawn in your line's colour as the shape it will really take (`_telegraph_shape`): a wedge along your aim for melee, a spot where the lob lands (the cursor, clamped to range), a line to the cursor for free shots, a run for charges, filling as the wind-up runs. Before this, your telegraph was the enemy's red ring drawn at the target's feet, which was wrong for every cursor-aimed move from item 3. Enemy telegraphs are untouched (red ring, yellow run).
- **Out of range shows the reach:** an ability refused for range flashes that ability's reach as a red ring for 0.6 s, so the refusal teaches the distance.

## Check (`tools/debug/arena_reach_check.gd`)
- Ring at Cinder Claw's reach: 34 px (26 + 8).
- A Cinder Claw wind-up with the cursor south-east: shape wedge, direction (1, 1), reach 34.
- Vent Barrage refused at 300 px: the reach flash shows 93 px for 0.6 s.
- A Seed wind-up with the foe south and the cursor at (50, -20): spot at (50, -20), radius 16.
- The enemy's wind-up still draws the old way.
- Aim, feedback and hitbox checks still pass.
- Stills: `ring_ghost.png`, `wedge.png`, `range_hint.png`, `spot.png`, `enemy_telegraph.png`.

## Known
- Ability ghosts show from the press (during the wind-up), not before it; a hold-to-preview, release-to-fire mode would delay quick casts and was not built.
- Remaining item of the plan: 5 combos.
