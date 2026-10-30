# Tower Rise at the new size: the climb to the doors (slice plan, 2026-10-29)

Preston, 2026-10-29. On the 10-28 door mock (`final/door_lean_3x.png`, which keeps the old depot and drum at the
doors) he said "thats the old tower". The Rise should show the new Tower instead, the one on the installed title
(`assets/slots/title/backdrop/highbank.png`, Codex's painting): the pale round Stack, brass rails, the stair up the two
plinth steps, the arched doors, and the root up the west side. Asked how the player reaches the doors, he chose
**"Climb the stair"**: the true scale, about two screens of stair, with the doors at the Stack's foot at the top.

Everything below is a proposal in working labels unless it quotes him. Numbers come from `VAST_SCALE_DESIGN.md`
("Numbers"): plinth step 1 is 52 tiles wide and 8 tall, step 2 is 42 wide and 8 tall, the Stack is 34 wide. All
three are wider than the Rise (26 tiles), so each face spans the whole width.

## The new Rise map (26 x 31, row 0 at the north)

| Rows | What | Walk |
|---|---|---|
| sky above 0 | the Stack's face going up, pale stone with brass rings, off the top; the camera's pan up the Tower runs over it | |
| 0 | the Stack's foot: the base row of the `hall` building, double door at (12,0) and (13,0), the same `room: "hall"` | solid except the doors |
| 1 to 4 | the door landing, the top of step 2 (42 to 34 wide = 4 deep), brass rail along its south edge | yes |
| 5 to 12 | step 2's face, river-stone courses, the stair at cols 12 and 13 | stair only |
| 13 to 17 | the terrace on step 1 (52 to 42 wide = 5 deep), rail on its edge | yes |
| 18 to 25 | step 1's face, the stair at cols 12 and 13 | stair only |
| 26 to 30 | the Rise's foot, today's rows 9 to 13 moved down 17: lamps, Job Board, well, wayline posts, the lane west, the steps down to the Street | yes |

- **The root:** the great tree's root comes in from the west along row 29 (the way to the Great Tree Path), half
  buried, and climbs step 1, the terrace, step 2 and the Stack's west side, cols 0 to 4. That is solid scenery, with
  treads cut into its lower run (`VAST_SCALE_DESIGN.md`, "The root").
- **Exits and anchors** move down 17 rows. `return` and the lean box (`TowerParts.CAMERA_LEAN`) move to the landing.
  `tower_foot` stays at the stair's foot, where the two first look up.

## Slice 1: walkable, coded blockout, behind the v2 switch

1. `scripts/world/areas/hall_rise.gd`: the 26 x 31 map above. Faces are solid ground rects, and the stair is two
   `steps` paths.
2. A new coded blockout for the foot (proposal: `scripts/town/tower_foot.gd`). It paints the Stack face over the sky
   band, the step faces, the stair, the rails, the doors and the root, in the title's colours (the `highbank_title`
   palette or `TowerParts.PALETTE`). Lit low from the west, as on the title.
3. On the Rise in v2, `building_template.gd` places the new foot instead of `TowerParts.place()`. TowerParts stays,
   because the Tower reveal (`scripts/story/tower_reveal.gd`) still climbs the 30-tile tower until slice 2 retimes it.
4. The Rise's four waylines leave the Low Reel, 34 tiles up and off the screen. For slice 1 they hang from above the
   area's top edge to the two posts, or they are left off with a note. That is open.
5. Checks: area_data, hub_town, town_walk, board_scene and tower_lean, with anchors updated. Run with
   `tools/debug/run_checks.py --jobs 1 --fixed-fps 30`.
6. Captures for Preston: the foot of the stair looking up, the terrace, and the doors.

## Later slices

- **Slice 2:** register the foot's parts as art slots for Codex (step faces, stair, Stack foot and doors, rails,
  root), retime the reveal for 480 tiles (`VAST_SCALE_DESIGN.md`, "Reveal climb"), and decide what happens to the old
  TowerParts body parts.
- **Slice 3:** Codex paints the parts.
