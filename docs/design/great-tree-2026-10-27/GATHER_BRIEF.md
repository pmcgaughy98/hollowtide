# Shared brief from the 2026-10-27 great tree design pass (facts, read only)

## Great tree shared brief (facts as of 2026-10-27, read only)

**Preston's note** is already recorded in TOWER_DESIGN.md:147-153 (the second "section 14") and in memory `great-tree-dungeon.md`. Those say: the Reach, root_vein and root_foot are one root of a separate massive tree that stands "somewhere beyond the Tower". It is a future dungeon. The working label is "the great tree". Any view that shows the root should read as a root arriving from somewhere else. Do not build the dungeon before its turn. The design folder `docs/design/great-tree-2026-10-27/` exists and is empty.

### The root today (scripts/town/tower_parts.gd)
- Frame 432x720. Tower Rise origin world (96,-504). Door world (288,150). Lamp glass BEACON frame (216,118) = world (312,-386). APEX frame (183,1). See :29-33 and TOWER_DESIGN.md:32.
- The root has three parts (:67, :71, :77):
  - root_foot: 96x120 @0,600, ground layer.
  - root_vein: 60x296 @80,326, body order 5.
  - reach: 104x300 @128,24, body order 9.
- Root palette ROOTC is #c49b69 #b06b3d #663f23 #3f2716 #23180e (:124).
- Path and thickness (in px):
  - root_foot tube starts at frame (4,718) at 18 thick and reaches (90,610) at 17 (:1192-1195). That puts the root's ground entry at world (100,214), Tower Rise tile (4,8).
  - root_vein goes from (90,608) at 17 up to (138,336) at 9. It bends over the depot and drum lips with 3 px shadows (:903-910).
  - The Reach shaft is 34 to 40 at the moss collar (y 318) and 24 at y 84. It curls right at radius 32 (thinning 24 to 16) to the chain hook at (216,96). It has three brass bands, rootlets on the loft and two leaf tufts (:1011-1050).
- Section 13 risk, TOWER_DESIGN.md:111: "the root could drift into a great-tree look. Keep it thick, banded and tended; forbid canopies, faces and creature shapes."
- No dialogue line names the root or a tree (dialogue/tower_reveal.dialogue:8-30).

### Views where the Tower and root show
1. **Title** (`scripts/art/placeholders/title_highbank.gd`, slot title.backdrop.highbank, 384x216 at 3x, palette highbank_title, 47 of 48 colours used, :51):
   - Highbank is seen from across the river at golden hour (:6-10).
   - The tower is 162 px tall with its frame top-left at (284,6) (:30-33).
   - Keep clear of the wordmark (x 90 to 295, y 0 to 52), the menu (x 21 to 128, y 108 to 199) and the canopy shade, which ends at (312,50) (:19-23).
   - Draw order is sky, far hills, ridge, left tree, rise, street, tower, lines, bluff, river (:76-87).
   - Far hills have a dip with a far-river glint at x 150 to 214 (:172-182). A wooded ridge rises to the right behind the Rise (:185-198).
   - **A big dark tree frames the left edge**: canopy discs up to y ~100 and a trunk down to the bluff (:200-226).
   - Root strokes spill down the Rise bank at x 276 to 300 (:245-249).
   - Screenshot 14_title_menu.png shows the crook reading as a cane against a dark sky, the root climbing the left of the tower and flaring at its foot, and the left tree behind the menu.
2. **Road home** (`scripts/story/route_scene.gd`, `scripts/art/slots/route.gd`):
   - A side-on strip 3900 px long, walking east (:34, :82).
   - The far town (road.backdrop.highbank_far, 160x96, dawn, max 24) sits at screen x 300 to 236, y 108, scale 0.82 to 1.0, haze 0.5 to 0.3 (:87). Its tower is 70 px tall (:50). Beacon anchor is (92,14) (route.gd:38-52).
   - Other layers: far wooded hills (route.gd:73), river (:93), and willow mid and near layers (:113).
   - It ends on the vista (road.backdrop.vista, 384x216, dawn, max 64). There the tower is 176 px tall at cx 268, beacon (268,36), party (84,148) (route.gd:203-223).
   - Screenshot 13_road_vista.png shows the party on a green slope at left, willow trunks at both edges, and houses ringing the tower. The crook stands alone against a banded sky with empty sky to its left.
3. **Reveal** (`scripts/story/tower_reveal.gd`):
   - Four legs, then a 1.5 s hold with the apex 10 px under the top and the lamp 127 px down (:37-42, TOWER_DESIGN.md:80).
   - The sky slot story.backdrop.tower_sky is 384x216, dawn, max 32, and does not scroll. Its brief says "top two thirds left empty", "Sky only, no tower" (route.gd:225-240). The placeholder bands are in SKY_TONES (:51-52).
   - Screenshot 11_reveal_hold_top.png shows the crook and lamp alone in flat bands, with the loft dome just visible at the bottom. Nothing gives a sense of altitude.
4. **Tower Rise walk** (`scripts/world/areas/hall_rise.gd`):
   - Normal play never shows sky (TOWER_DESIGN.md:74, :113). The lean is 72 px at most (hall_rise.gd:76).
   - Screenshot 05c (west side lane) shows the root_foot sweeping from the lower middle up to the depot's left corner, open grass to the west, and waylines falling to the post at (2,10).

### Dungeons that exist (scripts/dungeon/dungeon.gd:326-351)
| id | Name | Floors | Look | Boss |
|---|---|---|---|---|
| mouth | Hollow Mouth | 4 | ruin | none |
| first | Rootbank Warren | FLOORS=3 (:48) | riverbank | crew boss |
| hollow | The Hollow | 2 plus boss | valley/ruin | Warden in the pond garden, then the pond stone |

- Rootbank Warren is "tunnels dug through a river bank, roots in the walls" (:335-337). `rootbank_detail.gd:1-12` paints bark and leaf roots (BARK #3f2a19 #6f4c30 #8a6440 #251d17).
- Floors are logged as B1F and count down (:820).
- Boss rule (memory `dungeon-floor-plan-boss.md`): the boss is alone on a fixed top floor after a scene. An optional rest floor can come before it.
- The Warden entrance is the model for future boss scenes (memory `warden-entrance.md`, boss_intro.gd).
- The Growth Shrine is in the Street at (12,11), with a socket for the pond stone (street.gd:51-53).
- The painted terrain look is the rule (memory `dungeon-painted-look.md`).

### Scope
- THE_CONCEPT.md:169-181, step 9: "Expand only after those loops are reviewed."
- The pilot runs from the opening to the Warden plus the shrine (memory `pilot-demo-scope.md`). The alpha stops after the first growth (pilot-story-2026-10-10.md:109-110).
- The genre synthesis R6 says the town grows with routes (genre-synthesis-2026-10-12.md:119).
- There are seven route lanterns, states lit/dark/lit/lit/dark/quiet/dark (tower_parts.gd:87-90).
  - Route 1: the Street (street.gd:79-81).
  - Route 5: the quiet route to the ferry dock (ferry_ward.gd:42-44).
  - Route 4: the East Quarter (east_quarter.gd:49-51).
  - Routes 0 and 6: the Rise posts (hall_rise.gd:59-60).

### Codex
cx-12 is now READY FOR REVIEW, not in progress (STATUS.json). Nothing is installed. The key was approved ("Preston: approval go", root_foot/ledger.json). Details are in codex_root_foot_state.

### Palettes
- wayline_tower.png: 36 colours.
- highbank_title.png: 47 colours (the tower's 36 plus 11 for sky, hills and water).
- dawn.png: 40 colours.

All three are in docs/design/placeholder-factory-2026-10-26/refs/palettes/.

## Highbank map

COMPASS (Highbank v2, behind HT_HIGHBANK_V2; v1 is still the default game). North is up on every map; tiles are 24 px.

```
                 N  (beyond: nothing defined; region atlas: "upland springs and grass openings lie behind town")
         +------------------- TOWER RISE 26x14 (hall_rise.gd) -------------------+
         | row 0 hedge (back edge, no exit)        sky 528 px above, reveal only |
 W edge  | cols 0-3 side lane | cols 4-6 ROOT FOOT (solid) | Tower base 7-18 | cols 19-21 YARD | 22-25 lane | E edge
 no exit | post (2,10)        | root enters world (100,214)| doors (12,8)(13,8)          post (24,10) | no exit
         | well (8,10) lamps (11,9)(14,9) Job Board (16,9); row 13 cliff, steps (12,13) -> Street (46,1)  |
         +---------------------------------------- | ----------------------------------------------+
 +------------------------------ HIGHBANK STREET 56x16 (street.gd) -------------------------------+---> road east (55,8)
 | row 0 hedge. North side, west to east: Home (3,5) spawn (5,7) | Item Shop (12,5) | Storage (20,5)|    closed, needs
 | | Scroll Keeper (28,5) | lot A (36,5) | Crossroads (41-52, 7-14), waymark (48,11), steps N (46,0)|    east_quarter_open
 | Market Street lane row 8-9.  South side: Bluff Lookout (1,11) | Growth Shrine (12,11) |         |    EAST QUARTER 30x14
 | Training Yard (21,11) | lot B (31,11).  Row 15 = cliff (bluff edge); switchbacks S at (46,15)  |    (east_quarter.gd), lots,
 +------------------------------------------------------------------------- | --------------------+    fences on S and E edges
         +----------------------- OLD FERRY WARD 34x16 (ferry_ward.gd) ---------+
         | steps (6,0) down two cliffs; landing (18-29, 9-12); Mouth of the     |
         | Hollow (25,9); dock (28-33, 12-13) with the quiet route's post (33,13)|
         | rows 13-15: THE RIVER (runs west-east across the south)               |
         +-----------------------------------------------------------------------+
                 S  (beyond: the far bank; the title is viewed from here looking north)
```

- **The river** runs along the south: ferry_ward.gd:15 (rows 13-15 water), and in v1 at highbank_v1.gd:24 (rows 30-31).
- **The bluff:**
  - The Street is the bluff top. Its row 15 is the bluff's edge (street.gd:19).
  - The Ferry Ward steps down two cliffs to the landing (ferry_ward.gd:10-15).
  - Tower Rise is a step higher than the Street, north of the Crossroads (hall_rise.gd:27, street.gd:23 and :93).
- **The Tower and the root foot:**
  - The Tower base is (7,6) 12x3 (hall_rise.gd:45). The solid block covers cols 4 to 21, rows 0 to 8 (TOWER_DESIGN.md:73).
  - The root foot sits on the west wing, cols 4 to 6, rows 1 to 8, a solid grass rect (hall_rise.gd:34). The root enters the tower frame at frame (4,718) = world (100,214), tile (4,8), and climbs to the depot's left corner at world (186,106) (tower_parts.gd:1194-1195).
  - The yard is the east wing, cols 19 to 21.
- **The road home:**
  - It is "the south trail" (dialogue/road_to_highbank.dialogue:1, :27): a side-on strip walking east (route_scene.gd:34). Highbank and the Tower show far off, ahead and right of centre (route_scene.gd:87).
  - It ends on a rise above Highbank looking down ("The trees open. Down below...", road_to_highbank.dialogue:80-87; route.gd:221).
  - No map edge receives it. v2's first arrival is the Street's spawn at Home (index.gd:19, hub_town.gd:2201-2207).
- **Beyond the edges** (no exits are defined except S steps, N steps, the switchbacks and the road east):
  - Tower Rise has no exit to the west, north or east.
  - The Street's west edge has no exit.
  - The Ferry Ward has only its north steps. The Mouth leads into the Hollow.
  - The East Quarter has only its west road.
- **Region atlas** (region-atlas-draft.md:13): upland springs behind town, a far bank across the river, an older channel downstream, Mill Cut lower terraces.
- **Title view** (title_highbank.gd:6-10, 172-198):
  - The viewer is on the far (south) bank looking north, so west is left and east is right.
  - The tower is at the right (east). The Street's houses are to its left (west) along the bluff.
  - A wooded ridge rises toward the east behind Tower Rise. Far hills sit behind with a dip and a far-river glint, centre-left.
  - A big dark tree frames the far west edge.

## Canon hooks

- TOWER_DESIGN.md:8 and tower_parts.gd:4-5: the tower was 'built up in eras around a living root older than Highbank'; the legend proposal at TOWER_DESIGN.md:145 is 'a root older than Highbank that the first runner tied a rope to'. Not canon, but both fit a root that comes from an older tree.
- TOWER_DESIGN.md:147-153 (the second section 14) and memory great-tree-dungeon.md: Preston's great-tree note is recorded. Design work goes in docs/design/great-tree-2026-10-27/, which exists and is empty. Rule: every view of the root reads as arriving from elsewhere.
- The 'Great Root' label is already used for the root_foot buttress: TOWER_DESIGN.md:21-22 and :54, scripts/art/slots/town_tower.gd:158, hall_rise.gd:29, placeholder-factory 01-asset-census.md:226.
- Rootbank Warren (dungeon.gd:335-338): 'tunnels dug through a river bank, roots in the walls'. Its rooted den is painted by scripts/dungeon/rootbank_detail.gd:1-12 (bark and leaf colours). This is the only existing root-themed dungeon.
- Boss floor rule (memory dungeon-floor-plan-boss.md): the boss is alone on a fixed top floor after a dialogue scene, with an optional rest floor before it. A tree climb's top floor fits this rule.
- Warden entrance structure (memory warden-entrance.md, scripts/dungeon/boss_intro.gd): the model for future boss scenes.
- The Hollow and the pond stone (dungeon.gd:340-351, pilot-story-2026-10-10.md:16-18 and :33-39): the presence is tied to what lies in the Warden's pond. The stone wakes the Growth Shrine (street.gd:51-53, socket anchor (72,64)).
- Title's big dark left tree (title_highbank.gd:200-226) and the title 'canopy shade' over the upper left that ends at (312,50) (title_highbank.gd:19-23). A tree is already present on the title.
- Bluff Lookout, street.gd:49-50: 'Where the river looks close. On a clear day you can see the next bend.' Partner, road_to_highbank.dialogue:87: 'On a clear day you can see it three bends down the river.' Highbank already has lines about long sight.
- Route lanterns and waylines: there are 7 sheaves and lanterns (tower_parts.gd:87-90). One line per opened route (TOWER_DESIGN.md:15). Genre synthesis R6 'the town grows with routes' (genre-synthesis-2026-10-12.md:119). Routes 2 and 3 are lit, but no area file or Tower Rise line is tied to their sheaves (RISE_LINES use sheaves 6, 0, 5 and 1, tower_parts.gd:98-103).
- Region atlas (region-atlas-draft.md:13 and the ecology table): upland springs and grass openings lie behind town. Cotterseed to Canopyvein to Floodcrown is the 'floodplain shade and raised roots' line (creature-roster-draft.md:143-147). Its briefs forbid a literal tree, and so do Archroot's and Springvault's (creature-roster-draft.md:112-113).
- World bible ecology research (world-bible.md:62): the Missouri River loess hills, Bluffwoods oak-hickory forest, steep bluffs and springs.
- Road home layers: the far wooded hills (route.gd:73), willow mid and near layers (route.gd:113), and the vista where 'the trees open' (road_to_highbank.dialogue:84).
- Second Wind is described as 'a root you chew' (genre-synthesis-2026-10-12.md:79).
- Hollow is absence, not ghost (memory hollow-is-absence.md). The quiet route's dark lantern is Hollow shown as absence (TOWER_DESIGN.md:15).

## Conflicts

- TOWER_DESIGN.md:111 (risks) still says the root must not 'drift into a great-tree look' and to 'forbid canopies'. That sentence predates Preston's note and needs restating: no canopy on the Tower, but the root does belong to a great tree.
- The root reads as starting at the Tower, not arriving. The blockout root_foot starts in the turf at frame (4,718) (tower_parts.gd:1190-1197). Codex's cx-12 root_foot ends bottom left in a flared rootlet base with a footing stone and turf lip. It touches the cell's left edge only in its bottom 11 to 13 rows (frame x 0, y 107 to 119 of the cell), so it reads as its own base.
- The thickness profile runs backwards for a root coming from a distant tree. root_foot is 18 to 24 px and root_vein thins from 17 to 9 px, but the Reach shaft is 24 to 40 px (tower_parts.gd:903-910, :1014-1020, :1192-1195). The root gets fatter after it climbs.
- Frame limit: every part rect must sit inside the 432x720 frame (tower_parts_check, TOWER_DESIGN.md:107), and the frame's left edge is world x 96 (tile col 4). Any root shown west of col 4 needs a new slot or prop outside TowerParts.
- Tower Rise geometry: west of the root foot, cols 0 to 3 are a walkable side lane. It holds the wayline post at (2,10) and the west wayline drop (hall_rise.gd:59). Row 0 is hedge (hall_rise.gd:25). There is no west or north exit. An overground root running west or north would cross walkable tiles or need new solid rects.
- Normal play on Tower Rise never shows sky: the lean is capped at 72 px and the camera stays inside the clamp (TOWER_DESIGN.md:74, hall_rise.gd:76). The 528 px sky (hall_rise.gd:23) is drawn only for the reveal. A great tree can only appear in Rise play at ground level or at the edges.
- Reveal sky brief: story.backdrop.tower_sky is 'Sky only, no tower painted in' with 'the top two thirds left empty'. It is 384x216, does not scroll, and is limited to 32 colours (route.gd:225-240). Putting a distant tree in it contradicts the current brief. The brief is Codex's cx-10 re-brief, which is gated until the crown is approved.
- Title space and palette: 47 of 48 colours are used, leaving 1 free (title_highbank.gd:51). The wordmark (x 90 to 295, y 0 to 52), the menu (x 21 to 128, y 108 to 199) and the canopy shade (to 312,50) take the left and top (title_highbank.gd:19-23). The existing big dark left tree (title_highbank.gd:200-226) could be read as the great tree or compete with it.
- Far view read: TOWER_DESIGN.md:10 and :85 rely on the tower reading as 'a hooked column with one lit dot' down to a 16 px icon. road.backdrop.highbank_far is only 160x96 with 24 colours (route.gd:38-52). A tree near the tower in far views could break that read.
- The vista's houses ring the tower on both sides (13_road_vista.png). The map instead puts the Street's houses west of the Rise in a line, and the title follows the map (title_highbank.gd:7-10). The vista is already off-map.
- Road home geography: it is 'the south trail' (road_to_highbank.dialogue:1, :27), but it ends on a rise looking down on Highbank (road_to_highbank.dialogue:80-85, route.gd:221). In the map the only thing south of the bluff is the river (ferry_ward.gd:15), and no map edge receives the road (index.gd:19, hub_town.gd:2201-2207).
- World geography: world-bible.md:5 and region-atlas-draft.md:5 put the hometown west of the river and a city east of it, with the river running between. They also say Highbank is not automatically the hometown. The v2 map and the title put the river along Highbank's south. Where the great tree sits must pick one of these.
- Name collisions. 'The Reach' is the root crook (TOWER_DESIGN.md:8). 'The Siltward Reach' is the region's working name (world-bible.md:56). A creature is named Tarnreach (region-atlas-draft.md ecology table). 'Great Root' is already the root_foot's label.
- Dungeon direction: every floor is logged as B1F and counts down (dungeon.gd:820), and existing dungeons descend. A tree dungeon that climbs would be the first going up. Memory dungeon-floor-plan-boss.md puts the boss on the 'top highest level' floor.
- Scope: the pilot ends at the Warden and the first growth (pilot-demo-scope.md, pilot-story-2026-10-10.md:109-110). THE_CONCEPT.md:181 says expand only after loops are reviewed, and memory great-tree-dungeon.md says don't build the dungeon before its turn. The tree should be scenery and design only for now.
- TOWER_DESIGN.md has two sections numbered 14 (lines 144 and 147). The great-tree note is the second one.
- The task described cx-12 as CODEX_IN_PROGRESS. As of 13:31 on 2026-10-27 STATUS.json says READY FOR REVIEW, 5 passing slots, not installed, next batch cx-13.
