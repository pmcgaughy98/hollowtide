# The first Hollow: a generated dungeon floor (Claude, 2026-10-09)

**Preston, 2026-10-09:** Explorers of Sky is his favorite game and he wants its dungeons synthesized into Hollowtide; of the plan in `docs/research/pmd-sky-references-2026-10-09.md` he said "do the slice". "The Hollows" is a working name; every number is a draft for Grok.

## Play it
Run the arena scene (F6 on `scenes/arena_prototype.tscn`) to open the matchup picker, fill your side (the first slot leads and is the one you steer; empty slots are filled at random), and press **HOLLOW**. Or F6 on `scenes/hollow_floor.tscn` for Kithflare leading Tallowroot. The controls are the arena's: WASD, mouse aim, click or J, Space, 1 to 3, C, Tab for autopilot. Find the wild creatures, then stand on the stairs for a moment to go down. Three floors to a Hollow; fainting sends you back to the top.

## What it is
- **The floor** (`scripts/hollow/hollow_gen.gd`): the Explorers of Sky structure, written from scratch. A 4 by 3 grid of cells, each 15 by 12 tiles of 16 px; each cell is a room (70%) or a hallway junction; a random spanning tree joins every cell, extra links add loops (20%), junctions left with one link are pruned so there are no dead ends; hallways are three tiles wide so the big creatures fit. The start is a random room, the stairs the room farthest from it by walking distance, and three wild creatures wait in other rooms. A floor recipe holds the numbers and the spawn list (stage 1 Rimefin, Cinderhide, Cutbank Listener and Dustkite for now).
- **The floor's look** (`scripts/hollow/hollow_floor.gd`, `_paint`): the arena's own grass for the ground, cut into patches that avoid the painted pitch lines; the walls as one dark silted bank with a lit cliff face where it meets the floor below and a shadow on the floor under it; the stairs as a dark way down with three lit steps. No new art and no paid generation.
- **The fighting is the arena's**, on the floor: `hollow_floor.gd` extends the arena script, so every move, AI behaviour, effect, control and the camera's feel carry over. What it adds: wild creatures sleep until something of yours comes within 110 px in sight (and wake the others in their room); anything chasing a target out of sight walks around the walls on a walking-distance field; your partners follow the leader around corners; nobody fires through a wall, shots end at walls and beams are cut at them; knockback that pushes a creature into a wall sets it back on the nearest floor; the camera follows your leader and leans in when a wild creature is close; standing 0.6 s on the stairs takes them, carrying your team's health down.
- **Two hooks in the arena** (`scripts/arena/arena_prototype.gd`): every floor lookup goes through `_floor()` (25 places), so a subclass can supply its own map; `picker_redirect` and `match_horn` flags let a Hollow floor run on its own with no crowd horn.

## Check (`tools/debug/hollow_check.gd`)
- Generator on 200 seeds: 0 bad (every floor tile, every room and the stairs reachable from the start; at least two rooms; every spawn on the floor). 8.5 rooms on average, never fewer than 4; 11.4 hallway links on average. `layouts.png` shows six floors (blue start, yellow stairs, red wild creatures).
- A floor on autopilot with Sparkwick leading Huskward: all three wild creatures woke and were downed, B2F reached after 47 s, no frame with a creature inside a wall, the team's health carried down (Sparkwick 176 of 225, Huskward 294 of 315), B2F's three wild creatures asleep. A second-by-second probe showed the order: Dustkite down at 9 s, Cinderhide at 35 s, Rimefin at 50 s, then the stairs.
- The picker's HOLLOW button starts a floor with the chosen side (Highsignal leading Riftfin in the probe).
- Regressions after the floor-lookup change: picker, terrain, attack-on-press and first-fight checks pass.
- Stills: `layouts.png`, `b1f_start.png`, `b1f_walk.png`, `b1f_fight.png`, `b2f_start.png`.

## Known
- The partner falls more than 160 px behind for about 15 of the 47 seconds: Huskward is slow, and it chases the leader's fights. A PMD-style chain (each partner following the one ahead) is the next refinement.
- The HUD still says RIVAL over the wild creatures and has no minimap; PMD's minimap and a WILD label are small follow-ups.
- No items, traps, hunger or run clock, secondary terrain (water, silt), Monster Houses, recruiting or jobs yet; the research doc orders them.
- The grass ground repeats its patches visibly at a distance; a Hollow-specific ground (silt, cut bank) is art work for when Preston picks a look.
- Fixed on the way: the picker rewrite earlier today had broken Codex's relay-yard practice (`relay_yard_practice.gd` called a picker function that no longer exists); its override is removed and it compiles again.
