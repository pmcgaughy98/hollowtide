# Placeholder factory, part 2: rewiring Highbank and its buildings in code (Claude, 2026-10-26)

Preston, 2026-10-26: the town buildings Codex made "arent right size", and the town would look better and could grow
"like how mystery dungeons big bases are if you just wire it with code like the dungeons and inner rooms and codex
generates the asset or scene for it ... Rewire whole map and town buildings too."

This is a design study. Nothing in the game was edited (factory pass 8 is editing game files right now). Every number
below was measured from the repo at `dc37005af` or from a source named next to it. Names of new areas, lots and props
are working labels and proposals, his to rename. It pairs with part 3 (`03-spec-format.md`): part 3 defines what an
art slot is; this part defines where every town slot sits, how big it is, and the map data that places it.

**The answer in four lines**
1. The buildings read wrong because they have no shared scale: door openings run 29 to 64 px tall on the same street,
   the creatures grew 1.5x a day after the building rects were set, and the art had to equal its solid footprint.
2. Fix: one building template driven by data (base footprint, wall height, roof, door, sign), sized from the measured
   creatures: every single door 22 x 48 px, every public double door 46 x 64 px.
3. Highbank becomes area files in one format (exteriors and rooms alike): a long street, Hall Rise, the Ferry Ward,
   each a few screens, joined by exits, with empty lots that open as the story goes, the way Explorers of Sky's base
   opens facilities over time.
4. Every service Highbank has today keeps its id, so saves keep working; 9 hard-coded tiles in the checks become
   named anchors.

---

## 1. How Highbank is built today (measured)

### 1.1 The pieces

| Piece | File | What it does |
|---|---|---|
| The contract | `scripts/town/town_layout.gd` (118 lines) | `T = 24`, `W = 48`, `H = 32` (lines 13-15); 6 terrain `BANDS` (19-26); 8 `PATHS` (29-38); 13 `PLACES` (42-72); `SPAWN (5, 8)` (73); `grid()` makes every building and spot solid except its door tiles (80-99) |
| The town scene | `scripts/town/hub_town.gd` (2073 lines) | view `384 x 216` at `SCALE 3.0` (29-30), so one screen is 16 x 9 tiles; `RETURN_SPOT (24, 8)` (18); music zones by tile (1176-1181); the street picture cached on disk under a hash of `BANDS, PATHS, PLACES` (547-548) |
| Ground | `highbank_ground_painter.gd` (202), `highbank_painter.gd` (932), `world_tile_art.gd`, `town_detail_art.gd` | Codex's ground, then the dungeons' painted treatment over it; 27 reads of `Layout.PLACES/PATHS/BANDS` across the five ground and detail scripts; one hard-coded tile rect, `SOFT_TILES Rect2i(15, 7, 19, 5)` (`highbank_painter.gd:780`) |
| Buildings | `building_exteriors.gd` (487) | each building is a `Sprite2D` over the ground; its PNG is used **only if its size equals rect x 24** (line 39); door art found by flood fill from fixed offsets (368-401); signs are coded pictograms (333-365); shut boards, chain and rope (222-310) |
| Open-air places | `landmark_exteriors.gd`, `crossroads_painter.gd`, `job_board_painter.gd`, `training_yard_painter.gd`, `growth_shrine_painter.gd`, `hollow_mouth_painter.gd` | lookout, landing, dock, plaza, board, yard, shrine, the Mouth |
| Rooms | `town_room.gd` (1102), `room_painter.gd` (812) | 6 rooms in one `ROOMS` dictionary (`town_room.gd:30-103`): size, door, `town_door`, `solid`, `spots`, `links`, `landing` |
| Scenes on the street | `scene_kit.gd`, `board_scene.gd` | townsfolk placed relative to a place's door (`board_scene.gd:51-56`, crew at the board door +(1,0), (-1,0), (3,0); the scene starts 3 tiles away) |
| Away from town | `hollow_approach.gd`, `riverbank_journey.gd` | separate 384 x 216 canvases, not on the town grid; `world_journey.gd` is the older courier route (Route 1, not touched) |

20 scripts preload `town_layout.gd`. 27 of the 310 scripts in `tools/debug/` read the town layout.

### 1.2 Today's map, from the data (48 x 32 tiles = 1152 x 768 px, 3 x 3.6 screens)

Rendered from `town_layout.gd:19-72`. Capital letters are solid buildings and spots, lower case are open areas,
`@` is a door tile, `#` path, `.` bluff grass, `:` terrace, `=` cliff, `~` river.

```
    000000000011111111112222222222333333333344444444
    012345678901234567890123456789012345678901234567
 0  ................................................
 1  ...................HHHHHHHHHH...................   H Wayline Hall 10x6
 2  ..........oooooo...HHHHHHHHHH...................   o Bluff Lookout
 3  ...hhhhh..oooooo...HHHHHHHHHH..SSSSSS.TTTTTT....   h Home 5x5
 4  ...hhhhh..oooooo...HHHHHHHHHH..SSSSSS.TTTTTT....   S Item Shop 6x5
 5  ...hhhhh..ooo@oo...HHHHHHHHHH..SSSSSS.TTTTTT....   T Storage 6x5
 6  ...hhhhh...........HHHH@@HHHH..SSSSSS.TTTTTT....
 7  ...hh@hh...............##.BB...SS@SSS.TT@TTT....   B Job Board
 8  .......................##.@.....................
 9  ....############################################   Market Street, road east at x 45-47
10  ....############################################
11  ..................ppppp##ppppp..................   p Crossroads (plaza)
12  ....ggg@gg........ppppp##ppppp.KK@KKK.yyy@yyy...   g Growth Shrine, K Scroll Keeper (door on TOP row)
13  ....gggggg........ppppp#@ppppp.KKKKKK.yyyyyyy...   y Training Yard
14  ....gggggg........ppppp##ppppp.KKKKKK.yyyyyyy...
15  ....gggggg........ppppp##ppppp.KKKKKK.yyyyyyy...
16  ....gggggg........ppppp##ppppp.KKKKKK.yyyyyyy...
17  .......................##.......................
18  =======================##=======================   switchback 1
19  :::::::::::::::::::::::##:::::::::::::::::::::::
20  ::::::::::::::###########:::::::::::::::::::::::
21  ::::::::::::::###########:::::::::::::::::::::::
22  ::::::::::::::##::::::::::::::::::::::::::::::::
23  ::::::::::::::##::::::::::::::::::::::::::::::::
24  ==============##================================   switchback 2
25  ::::::::::::::##################::::::::::::::::
26  ::::::::::::::##################llllll::::::::::   l Old Ferry Landing
27  ::::::::::::::::::::::::::ll@llllMMlll::::::::::   M Mouth of the Hollow
28  ::::::::::::::::::::::::::lllllll@Mllld@dddd::::   d Ferry Dock
29  ::::::::::::::::::::::::::lllllllllllldddddd::::
30  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
31  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

13 places in 1536 tiles. The 5 buildings take 175 tiles (11%), all of them solid but their doors. The shop, the
Scroll Keeper and the Yard are shut for this build (`building_exteriors.gd:222`, texts at `hub_town.gd:1141-1145`).

### 1.3 Every building, measured

PNG sizes read from the files; door openings measured by repeating the flood fill `building_exteriors.gd:368-401`
uses (dark pixels from the same start point), so they are the openings the game itself animates.

| Building | Rect (tiles) | Art (px) | Art fill | Door tile(s) | Door opening (px, w x h) | Sprite on the grid |
|---|---|---|---|---|---|---|
| Home | (3,3) 5x5 | 120 x 120 | bbox full, 79% opaque | (5,7), bottom row | 28+ x 43 (search box caps width at 28) | top-left at rect x 24; z = door row x 24 |
| Item Shop | (31,3) 6x5 | 144 x 120 | full, 80% | (33,7), bottom row | 22 x 53 | same |
| Storage | (38,3) 6x5 | 144 x 120 | bbox y 38-118 only, 50% | (40,7), bottom row | 15 x 29 | same |
| Scroll Keeper | (31,12) 6x5 | 144 x 120 | bbox y 0-110, 62% | (33,12), **top row** | cellar lid, not flood-filled | z = top row; porch cut and lifted 12 px (`PORCH_LIFT`, line 179) |
| Wayline Hall | (19,1) 10x6 | 240 x 144 | full, 81% | (23,6) and (24,6) | 52 x 64 | z = door row; door art at -48 px |
| Growth Shrine (open) | (4,12) 6x5 | 144 x 120 | 54% | (7,12) | n/a | painter |
| Training Yard (open) | (38,12) 7x5 | 168 x 120 | 54% | (41,12) | n/a | painter |

The creatures that walk past them (the town set, `assets/sprites/arena/<form>/town/s.png`, visible height of the
opaque box, 51 forms measured):

| Stage | Visible height | Examples |
|---|---|---|
| 1 | 22-40 px (0.9-1.7 tiles) | starters Cinderhide 27, Punchybun 29, Rimefin 31, Kithflare 33, Tallowroot 34; townsfolk Grubbit 32, Mirekit 34, Gruntle 36 (boosted 1.25x), Whinet 40 |
| 2 | 40-55 px | Clinkerhide 40, Archroot 42, Sparkjab 45, Caller 52, Windcut 54 |
| 3 | 55-69 px (2.3-2.9 tiles) | Starward 56, Springvault 58, Oxbowarchon 60, Warden 61, Galeshear 62, Rampartroot 65, Highsignal 66, Stormwick 69 |

A creature stands with its feet about 23 px down its tile (`hub_town.gd:754-763`: node at tile x 24 + (12, 18.7),
sprite bottom 4 px below that).

A scale sheet (each building at 1x on its grid, the door tile outlined, Cinderhide, Clinkerhide and Stormwick on the
tile in front) was built for this study at
`C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\scale_sheet.png`.

### 1.4 Why the Codex buildings read as the wrong size

1. **The creatures grew after the buildings were sized.** The rects were set on 2026-10-09 (`town_layout.gd:2`);
   the Home and Item Shop art folders are dated `2026_10_09`. On 2026-10-10 the town set was rebuilt at 1.5x the
   dungeon size because Preston said the creatures looked too small (`hub_town.gd:705-707`,
   `build_dungeon_set.py --set=town --scale=1.5`). The starters were about 18-23 px tall at dungeon size and are
   27-34 px now, so the Home's 43 px door went from about 1.9-2.4x a starter to 1.3-1.6x. Every stage 3 (55-69 px) is taller than
   every door except the Hall's 64 px.
2. **No shared scale between neighbours.** Door heights on the same street: Storage 29, Home 43, Shop 53, Hall 64.
   The Storage door is 0.55x the Shop door next to it, and the Storage art only uses rows 38-118 of its 120: its
   planks and windows are drawn at about half the detail size of the Shop's, so it reads as a model of a house.
   The Shop's door is a tall arch (22 x 53) while the Home's is a squat one (28 x 43). Each was painted to its own
   rect with no door, wall or window size given.
3. **Art had to equal the solid footprint.** `available()` refuses any PNG that is not exactly rect x 24
   (`building_exteriors.gd:39`), and the whole rect is solid (`town_layout.gd:93-96`). So a building's drawn height
   equals its blocked depth in tiles: a 5-row rect gets a 120 px picture, nothing taller. Codex filled those squares
   with mostly roof (the Home's dome runs from the top to about y 70 of 120, the door from y 73), so the wall the
   creatures stand against is about 2 tiles and the buildings read as mounds. In a top-down town the roof rises
   above the footprint and the footprint is the base of the wall.
4. **Perspective breaks where the door is not on the street side.** The Scroll Keeper's door is on the rect's top
   row (`town_layout.gd:58`), so the team stands on its roof to use it (the scale sheet shows it), which took a cut
   and a 12 px lift of its porch to patch (`building_exteriors.gd:173-219`).
5. **Doors are guessed, not specified.** The code finds each opening by flood fill from fixed offsets: (14, 30) at
   -2, -36 for the small buildings, (26, 40) at -2, -48 for the Hall (`building_exteriors.gd:368-416`). A repaint
   that moves its door by a few pixels breaks the door animation silently.
6. **Size against the screen.** The Hall is 240 x 144, 62% of the 384 px view width. The street is 48 tiles wide, 3
   screens, with services spaced 6 to 30 tiles apart. That is fine; it is the per-building scale that disagrees.

Open question for Preston: when he says "not the right size", is it too big, too small, or "they don't match each
other"? The numbers say the third. Section 5.1 has a one-knob way to let him pick by walking it.

---

## 2. Explorers of Sky's base, structure only

Sources this session: the official instruction booklet (nintendo.com PDF, the Wigglytuff's Guild, Treasure Town and
Spinda's Cafe pages, printed pages 29-35), Serebii's Treasure Town page, the Mystery Dungeon Franchise Wiki's Treasure
Town stub, and Bulbapedia read through search summaries. Bulbapedia and the Spriters Resource answered 403, Fandom
402, and Firecrawl reported its credits used up, so **no map sizes in tiles could be measured**; anything not named
to a source below is from play knowledge and marked unverified. Nothing here copies their text, art or data.

### 2.1 The areas and how they connect

```
                      [Guild entrance + sentry post]
                                   |  long stairs
                          [Guild Sublevel 1]  job board, outlaw board, Q&A signboard, team assembly
                                   |  ladder
                          [Guild Sublevel 2]  Guildmaster's chamber, crew rooms 1 and 2, hero's room,
                                   |            hallway, mess hall, item swap shop
  [Sharpedo Bluff] ---- [Treasure Town] ---- [Crossroads] ---- east: the world map and the dungeons
  partner's cave,       one street, shops     |  up: guild stairs
  apart from town       both sides, river     |  down: beach path
                        through the middle   [Beach]  washed-up bottles give jobs
                        cafe near the exit (opens later)
```

- Crossroads east of town: the world's dungeons east, the guild north, the beach south (Bulbapedia, via search).
- The town sits on a cliff, east of Sharpedo Bluff, with a river through its middle (Mystery Dungeon wiki).
- The guild: entrance with a sentry post; Sublevel 1 holds the job board, the outlaw board, the Q&A signboard and the
  team assembly; Sublevel 2 holds the Guildmaster's chamber, two crew rooms, the hero's room, a hallway, the mess
  hall and the swap shop (booklet, guild page). The hero's bed in the guild is the save point (booklet, "New Game").
- The team you chose waits near the well in front of the guild, or at the cafe (booklet, assembly section).
- Facilities in town per the booklet: two shopkeeper brothers side by side (food left, orbs and TMs right), a link
  shop, a bank, an appraiser, a storage, a dojo of small no-risk dungeons, a day care. The cafe holds a juice bar, a
  recycle shop and a prize counter, and gives jobs.
- **Growth over time** (booklet, Treasure Town page): only a few facilities are open at the start, and more open as
  the story goes. The cafe opens later and leads to a new land (Serebii). Shop stock changes at story points
  (search summary of Bulbapedia).
- Unverified (play knowledge): most town services are street-front counters you talk to from the path, not rooms you
  enter; the hero moves out of the guild to the bluff after graduating.

### 2.2 What Hollowtide takes from it (structure)

1. **Small single-purpose areas joined at a junction.** Each area is one to three screens; the crossroads is the
   switchboard. Highbank today is one 3 x 3.6 screen map.
2. **The street is the menu.** Services sit in a row facing the path, entrance toward the path, path widening at
   each door (also the 2026-10-10 Codex brief, `docs/team/CODEX_TOWN_FINISH_BRIEF_2026-10-10.md:18`).
3. **Few rooms, many counters.** Only the guild (and later the cafe) has rooms. Hollowtide already has 6 rooms; new
   services can be street stalls first, rooms later, which halves the art per service.
4. **The guild is vertical:** public work floor first, living floor below. Highbank's Hall already does this
   (`town_room.gd:44-103`: `hall` 22x14, `hall_low` 30x18, `runners` 14x10, `chamber` 17x11).
5. **The base opens as the story goes:** empty or shut places that open on a story beat. Highbank already does one
   (R6: Storage shut until Rootbank Warren is cleared, `docs/design/genre-synthesis-2026-10-12.md:119-120`).
6. **A team waiting spot in front of the guild:** a natural home for the party switch.

---

## 3. The map data format (one format for streets and rooms)

### 3.1 Where it lives

One GDScript file per area, `scripts/world/areas/<id>.gd`, each holding `const AREA := {...}`, plus
`scripts/world/areas/index.gd` listing them. GDScript and not JSON for the reasons part 3 gives for its slot registry
(parse-checked, `Rect2i` and `Vector2i` native, exports without a filter rule), and because `town_room.gd`'s `ROOMS`
and `town_layout.gd` are already this shape, so Preston and Codex read the same kind of file they read today.

`town_layout.gd` stays as the API the 20 scripts call (`PLACES`, `door_tiles()`, `place_at()`, `grid()`), but its
values come from the active area file. First slice: today's map converted 1:1, same tiles, so every check passes
before anything moves.

### 3.2 Area fields

| Field | Meaning |
|---|---|
| `id`, `name`, `kind` | `"street"`, `"Highbank Street"`, `"exterior"` or `"interior"` |
| `size` | tiles, `Vector2i(56, 16)`; the picture is size x 24 px |
| `card`, `music` | the name card on arrival (today's `CARD_NAME "HIGHBANK"`, `hub_town.gd:374`) and the area's track (replaces the tile zones at `hub_town.gd:1176-1181`) |
| `ground` | exterior: base material and rows or rects of `grass`, `terrace`, `cliff`, `water`, `hedge` (today's `BANDS`, generalised to rects). Interior: `walls` `{n: 2, s: 1, w: 1, e: 1}` tiles and a `floor` material |
| `paths` | `[{rect, kind}]`, kind `lane`, `steps`, `boardwalk` |
| `buildings` | section 3.3 |
| `places` | open-air services and spots, today's `"area"` and `"spot"` entries unchanged: `id, name, kind, rect, door, service, what`, plus optional `anchors` |
| `props` | `[{slot, tile, solid, light, flat}]`: lamps, signposts, the well, benches, crates, fences, furniture in rooms |
| `lots` | section 3.6 |
| `exits` | `[{id, rect, to, at, facing, sfx, needs}]`: `to` an area id, `at` an anchor in that area. Same shape as a room's `links` today (`town_room.gd:59, 78-80`) |
| `anchors` | named tiles: `spawn`, `return`, `north_steps`, the board scene's stand, the camera's look points |
| `npcs` | `[{form, tile, facing, when}]` townsfolk standing spots (when: a story flag) |
| `spots` | interiors: today's room `spots` unchanged (`id, rect, name, what, service, what_if`) |

### 3.3 Building fields

| Field | Meaning | Example |
|---|---|---|
| `id`, `name`, `service`, `what` | as today's `PLACES` entry; ids never change | `"shop"`, `"Item Shop"`, `"shop"` |
| `class` | `cottage`, `shop`, `stall`, `hall` (table 4.2); sets wall, roof and door sizes | `"shop"` |
| `base` | the solid footprint: `Rect2i(x, y, w, d)`, front wall on its bottom row | `Rect2i(12, 5, 6, 2)` |
| `door` | door tiles, in the base's bottom row (kept walkable, as today) | `[Vector2i(14, 6)]` |
| `roof` | `moss`, `gable`, `hip`, `flat`, `awning` | `"moss"` |
| `wall` | `stone`, `plank`, `timber`, `river_stone` | `"plank"` |
| `windows` | base columns that get a window | `[0, 5]` |
| `sign` | `{col, icon}`: the board beside the door, icon one of the coded pictograms | `{"col": 4, "icon": "bag"}` |
| `chimney`, `awning` | column, or false | `1` |
| `room` | the interior area id, or "" | `"shop_room"` |
| `opens`, `shut` | `{beaten: "first"}` or `{flag: "runner"}`; key into the `SHUT` texts | `{"beaten": "first"}` |
| `walk_behind` | roof rows walkable (creatures sort behind the roof); default false | `false` |
| `slot` | art slot id, default `town.building.<id>` (part 3 naming) | `town.building.shop` |
| `anchors` | named pixels in the canvas, for scenes (the shrine's socket is one today, `hub_town.gd:1403-1405`) | `{"socket": Vector2i(72, 64)}` |

### 3.4 One area, as it would read

```gdscript
# scripts/world/areas/highbank_street.gd (proposal)
const AREA := {
	"id": "street", "name": "Highbank Street", "kind": "exterior", "size": Vector2i(56, 16),
	"card": "HIGHBANK", "music": "highbank",
	"ground": {"base": "grass", "rects": [{"rect": Rect2i(0, 0, 56, 1), "kind": "hedge"}, {"rect": Rect2i(0, 15, 56, 1), "kind": "cliff"}]},
	"paths": [{"rect": Rect2i(1, 8, 55, 2), "kind": "lane"}, {"rect": Rect2i(46, 1, 2, 7), "kind": "steps"},
		{"rect": Rect2i(46, 10, 2, 6), "kind": "steps"}],
	"buildings": [
		{"id": "home", "name": "Home", "service": "home", "class": "cottage", "base": Rect2i(3, 5, 5, 2),
			"door": [Vector2i(5, 6)], "roof": "moss", "wall": "river_stone", "windows": [0], "chimney": 1, "room": "home"},
		{"id": "shop", "name": "Item Shop", "service": "shop", "class": "shop", "base": Rect2i(12, 5, 6, 2),
			"door": [Vector2i(14, 6)], "roof": "gable", "wall": "plank", "awning": true, "sign": {"col": 4, "icon": "bag"},
			"room": "", "shut": "shop"},
	],
	"places": [
		{"id": "shrine", "name": "Growth Shrine", "kind": "area", "rect": Rect2i(12, 11, 6, 4), "door": Vector2i(14, 11),
			"service": "growth", "anchors": {"socket": Vector2i(72, 64)}},
	],
	"props": [{"slot": "town.prop.lamp_post", "tile": Vector2i(10, 7), "solid": true, "light": true}],
	"lots": [{"id": "lot_a", "base": Rect2i(36, 5, 4, 2), "class": "stall", "opens": {"beaten": "first"}, "before": "tarp"}],
	"exits": [{"id": "north_steps", "rect": Rect2i(46, 0, 2, 1), "to": "hall_rise", "at": "south_steps", "facing": "n", "sfx": "stairs"}],
	"anchors": {"spawn": Vector2i(5, 7), "north_steps": Vector2i(46, 1), "south_steps": Vector2i(46, 14)},
}
```

### 3.5 Interiors in the same format

Every field of today's rooms has a home in the area format, so `ROOMS` converts without changing a tile:

| `town_room.gd` room field | Area field |
|---|---|
| `name`, `w`, `h` | `name`, `size` |
| `door`, `exit_rect`, `town_door` | an exit `{rect, to: <street area>, at: <place id>}`; arrival back on the street still goes through `arrive_at` = place id |
| `links` (`rect, to, at, facing, sfx, needs`) | `exits`, same keys |
| `landing` | `anchors.landing` |
| `solid` | furniture `props` with a solid rect (or kept as a `solid` list) |
| `spots` | `spots`, unchanged |
| `floor_top`, `hint` | `ground.walls.n`, `hint` |
| `LIGHTS` (`town_room.gd:682`) | props with `light: true` |

The rooms already have a modular art shape, measured from `assets/sprites/world/hall_floors_2026_10_11/`: a floor plus
four wall strips, north 2 rows tall, south 1 row, sides 1 column. `hall_low` (30 x 18 tiles) is `lower_floor` 672 x 360 +
`lower_north` 720 x 48 + `lower_south` 720 x 24 + two 24 x 360 sides = 720 x 432 px exactly. `runners` and `chamber`
follow the same rule. Furniture is separate (`bunk_ochre` 48 x 52, `dais` 72 x 52, `mess` 144 x 50). So rooms keep
modular slots; streets get whole-building slots (section 5).

### 3.6 Lots: how the base grows

A lot is a building or stall that is not open yet:

```gdscript
{"id": "lot_a", "base": Rect2i(36, 5, 4, 2), "class": "stall", "opens": {"beaten": "first"}, "before": "tarp",
	"building": {"id": "...", "name": "...", "service": "...", "sign": {"col": 2, "icon": "..."}}}
```

- Before it opens: the template draws its `before` state on the same base (a tarp over a frame, a fenced plot,
  shutters), solid, with a short sign line in the shared text box. After: the building, its door, its service.
- Opening is a data condition the record already holds (`beaten`, `story` flags), checked on arrival, like the
  Storage's R6 rule. A first opening plays the scene kit's walk-up beat if the area has one.
- A new service is: one lot entry, one slot (placeholder until Codex paints it), one `service` handler in
  `hub_town.gd act_use`. A new area is: one area file, a pair of exits (one in it, one in its neighbour), an
  `index.gd` line, a card name. The checks in section 7.3 refuse a one-way exit or an unreachable door.

---

## 4. The building template

### 4.1 The scale rule, from the creatures

- **Single door opening: 22 x 48 px** (1 tile wide inside its frame, 2 tiles tall). Every stage 1 clears it (tallest
  Whinet 40) and stage 2 up to 48 (Clinkerhide 40, Archroot 42, Sparkjab 45); Caller 52 and Windcut 54 dip their heads.
  Pass creature: `sparkjab` (45 px).
- **Public double door: 46 x 64 px** (2 tiles), for the Hall and any future gathering place. Clears stage 3 up to 64
  (Starward 56, Springvault 58, Oxbowarchon 60, Warden 61, Galeshear 62); Rampartroot 65, Highsignal 66 and
  Stormwick 69 duck by 1-5 px. Pass creature: `galeshear` (62 px).
- **Wall** = door + 12 px of lintel (60 px; 80 for the Hall). **Roof** rises 36 px above the eave (40 for the Hall),
  over the footprint's depth.
- **Canvas** = `(w x 24 + 12) x (d x 24 + wall + roof)`: 6 px of eave each side hang over the neighbouring tiles
  without collision. Heights land on whole tiles: 144 px (6 tiles) for cottages and shops, 192 px (8) for the Hall.
- One constant, `BUILDING_SCALE` (1.0 by default), multiplies wall, roof and door so Preston can walk 1.0 and 1.25
  side by side before Codex paints anything.

### 4.2 Classes

| Class | Base (w x d tiles) | Wall | Roof rise | Canvas (px) | Door opening `door_px` in the canvas | Today, for comparison |
|---|---|---|---|---|---|---|
| cottage (Home) | 5 x 2 | 60 | 36 | 132 x 144 | `Rect2i(55, 94, 22, 48)` (door in base column 2) | 120 x 120, door 28+ x 43 |
| shop (Item Shop, Storage, Scroll Keeper) | 6 x 2 | 60 | 36 | 156 x 144 | `Rect2i(55, 94, 22, 48)` | 144 x 120, doors 22 x 53, 15 x 29, cellar lid |
| stall (lots, street counters) | 4 x 2 | 36 (counter 20) | 36 awning | 108 x 120 | none: a counter along the bottom row, the keeper behind it | new |
| hall (Wayline Hall) | 12 x 3 | 80 | 40 | 300 x 192 | `Rect2i(127, 126, 46, 64)` (door in base columns 5-6) | 240 x 144, door 52 x 64 |

`door_px` y = canvas height - 2 (the step) - door height. The anchor (part 3's `[x, foot_row]`) is the canvas's
bottom-centre: `(66, 143)`, `(78, 143)`, `(54, 119)`, `(150, 191)`.

The Hall at 300 x 192 fills 78% of the view's width and 89% of its height: it is the landmark, as the guild is. With
the camera on a leader at its door, the top 78 px are above the screen; the arrival on Hall Rise frames the whole
front (an anchor `hall_view`, set as `cam_focus` for the first second, the way scenes already pan).

### 4.3 How a building sits on the grid

```
  canvas x0 = base.x*24 - 6            canvas y0 = (base.y + d)*24 - canvas_h
  |
  v     <------------- w*24 + 12 ------------->
  +-------------------------------------------+  ^
  |              roof rise (36)               |  |
  |     .-'''''''''''''''''''''''''''''-.     |  |  roof rows: tiles above the base,
  |   .'   roof over the footprint (d*24)  '.  |  |  blocked unless walk_behind
  |  /_____________________________________\  |  |  (cottage and shop: 4 rows,
  |  |[win]          ______        [sign] |  |  |   Hall: 5 rows)
  |  |              |      |       (icon) |  |  canvas_h
  |  |   wall 60    | door |              |  |  |
  |  |              |22x48 |              |  |  |
  |  |______________|______|______________|  |  |  <- base row d-1: the door tile is here, walkable
  +--+--------------+======+---------------+--+  v  <- foot row = base bottom edge = the anchor's y
     ^ base.x                ^ step 2 px
     <------- base: w x d tiles, solid ------->
```

- Sorting stays as today: the building's z is its base's last row x 24 (`building_exteriors.gd:117`), a creature's z
  is its position y. A creature on the door tile draws in front of the door; one north of the base, behind the roof.
- Collision is the base plus the roof rows (default). Today a 6 x 5 shop blocks 29 tiles; the template's 6 x 2 base
  (11 solid plus the door) and 4 roof rows block 35, about the same, but the wall the team stands against grows from
  about 2 tiles to 2.5 and the door is specified.
- Every door faces the street (south, toward the camera). The Scroll Keeper's north cellar lid becomes a south door
  that leads down to a cellar room (a proposal; the cellar lid art could stay as a prop inside).

### 4.4 What the coded placeholder draws

Clean, readable, the house palette, never a grey box. In this order, each from data:

1. Contact shadow falling bottom-right, a third darker than the ground (the rule at `building_exteriors.gd:48-56`).
2. Foundation stones along the base, skipping the door (`building_exteriors.gd:315-321`).
3. Wall of the `wall` material in the class height: planks (`WOOD #80694a`, lit edge `#bba17a`), stone courses
   (`STONE #8f805e`, `LIGHT #bea986`), lit top-left.
4. Roof by `roof` style over the footprint and its rise, 6 px eaves, a drip line in `INK #0b0e11`.
5. Door at `door_px`: dark opening (`#333b2f` to `#987b46`, as today), a 2 px light frame, the step and mat
   (`building_exteriors.gd:328-330`), three swing frames made from `door_px` (no flood fill).
6. Windows at their columns, lit `#e2bd72`; chimney, awning.
7. Sign board at `sign.col` with the existing pictograms (bag, crate, waymark: `building_exteriors.gd:333-365`) plus
   new ones per service.
8. The shared sel-out finish, `exterior_finish.gd` (`Finish.apply(sprite, true)`), as every building has today.
9. In placeholder debug mode only: the slot id in small type under the sign. Never drawn over real art (part 3,
   rule 3.2.4).

Ground stays code-painted (`highbank_painter.gd`'s treatment, taking an area instead of `Layout`), in keeping with
the painted terrain rule (`USE_TILE_ART := false`, `riverbank_painter.gd:6`, `ruin_painter.gd:5`). No ground slot.

---

## 5. Art slots for the town (who paints what)

### 5.1 Whole building or pieces

- **Streets: one whole PNG per building** at the exact canvas, with `door_px` dark and in place. Codex's five
  buildings are whole compositions and its strength is the scene; roof, wall and door as separate slots would be 4x
  the slots and seams at every join. The template makes the placeholder from pieces; Codex paints the whole.
- **Separate small slots where code animates or swaps:** the door's three swing frames (optional; the template makes
  them from the PNG's `door_px` if absent), the sign board, the shut overlays (boards, chain, rope), the lot's
  `before` state.
- **Rooms: modular**, as they already are (3.5): floor, four wall strips, furniture.
- **Open-air places keep their canvases**, and the proposal sizes them so Codex's current art still fits: Shrine
  144 x 120, Yard 168 x 120, Lookout 144 x 96, Landing 288 x 108, Dock 144 x 72, Mouth 48 x 48 (all measured in
  `assets/sprites/world/`).

Old building PNGs do not fit the new canvases; until Codex repaints, the placeholder shows. That is the intent
(Preston: placeholders for now). The old PNGs stay in their dated folders.

### 5.2 The town slot list (Highbank v2, proposal)

| Slot id (part 3 naming) | Owner | Canvas (px) | Footprint | Notes |
|---|---|---|---|---|
| `town.building.hall` | Codex | 300 x 192 | base (7,6) 12 x 3 on Hall Rise, doors (12,8) (13,8) | door 46 x 64 at (127,126); pass `galeshear` |
| `town.building.home` | Codex | 132 x 144 | base (3,5) 5 x 2 on the street, door (5,6) | door 22 x 48 at (55,94); pass `sparkjab` |
| `town.building.shop` | Codex | 156 x 144 | base (12,5) 6 x 2, door (14,6) | shut boards overlay |
| `town.building.storage` | Codex | 156 x 144 | base (20,5) 6 x 2, door (22,6) | room `storage` exists, 408 x 312 |
| `town.building.scrolls` | Codex | 156 x 144 | base (28,5) 6 x 2, door (30,6) | south door down to a cellar |
| `town.building.lot_a` | Codex | 108 x 120 | base (36,5) 4 x 2 | stall; `before` state too |
| `town.landmark.shrine` | Codex | 144 x 120 | area (12,11) 6 x 4 + 1 overhang row | current art fits |
| `town.landmark.yard` | Codex | 168 x 120 | area (21,11) 7 x 4 + 1 row | current art fits |
| `town.landmark.lookout` | Codex | 144 x 96 | area (1,11) 6 x 4 | current art fits |
| `town.landmark.landing`, `.dock`, `.mouth` | Codex | 288 x 108, 144 x 72, 48 x 48 | Ferry Ward | current art fits |
| `town.room.<id>.floor/.north/.south/.west/.east` | Codex | room size x 24 by strip | rooms | existing rooms already have these |
| `town.room.shop`, `town.room.scrolls_cellar` | Codex | 336 x 240, 288 x 216 | new rooms (proposal: 14 x 10, 12 x 9) | placeholders until painted |
| `town.prop.lamp_post` | Grok | 24 x 48 | 1 tile, solid | light anchor (12, 8); glow drawn in code |
| `town.prop.well` | Grok | 48 x 56 | 2 x 2, solid | Hall Rise, the team's waiting spot |
| `town.prop.waymark` | Grok | 24 x 48 | 1 tile, solid | the Crossroads post |
| `town.prop.bench`, `.crates`, `.barrel`, `.planter`, `.fence_h/_v/_corner`, `.mooring_post` | Grok | 48 x 32, 24 x 24, 24 x 28, 24 x 24, 24 x 24, 24 x 36 | 1-2 tiles | fill the street between doors |
| `town.sign.<service>` | Grok | 24 x 24 | on the wall at `sign.col` | icon boards; today coded pictograms |
| `town.overlay.shut_boards`, `.shut_chain`, `.shut_rope` | Grok | door_px size, 28 x 36, 30 x 20 | over a door or gate | today coded (`building_exteriors.gd:235-310`) |

Every NPC in Highbank is a creature, so "character sprites" for Grok has no town slot here except non-creature figures
(the soul's light), which belong to the scenes, not the map.

---

## 6. Highbank v2: the rewired map (proposal)

### 6.1 Three street areas and the rooms

```
                                [Hall Rise]  26 x 14  Wayline Hall, Job Board, the well
                                     |  steps                    |
                                     |                           +-- door -> hall -> hall_low -> runners, chamber
   [Highbank Street]  56 x 16  -----+-----  road east (closed: a later quarter)
   Home | Item Shop | Storage | Scroll Keeper | lot A | Crossroads
   Lookout | Growth Shrine | Training Yard | lot B   |
        |                                           |  switchbacks
   door -> home, storage, (shop, cellar later)    [Old Ferry Ward]  34 x 16
                                                   landing, Mouth of the Hollow -> hollow_approach / runs, dock
```

| Area | Tiles | Pixels | Screens (16 x 9) | Holds | Exits |
|---|---|---|---|---|---|
| Highbank Street | 56 x 16 | 1344 x 384 | 3.5 x 1.8 | Home, Item Shop, Storage, Scroll Keeper, lot A (north side, doors south); Lookout, Growth Shrine, Training Yard, lot B (south side, open-air); the Crossroads and waymark at the east end | N steps to Hall Rise, S switchbacks to the Ferry Ward, E road (closed) |
| Hall Rise | 26 x 14 | 624 x 336 | 1.6 x 1.6 | Wayline Hall, Job Board, the well and waiting spot, the `return` anchor | S steps to the street |
| Old Ferry Ward | 34 x 16 | 816 x 384 | 2.1 x 1.8 | the switchbacks, Old Ferry Landing, Mouth of the Hollow, Ferry Dock | N to the street; the Mouth to the Hollow as today |

The three are 2024 tiles against today's 1536, in pictures of 1.0 megapixels against 0.88. Waking at Home to the Hall
is one exit (street to Hall Rise); the Hall to the Mouth is two. Today both are a walk with no fade. That is the cost
of areas; the gain is that each area grows on its own and a new one is a file. A five-area split (Home Bluff and the
Crossroads on their own, closer to Explorers of Sky) is the same format with more fades; the three-area split is the
recommendation.

### 6.2 Highbank Street (56 x 16)

Rendered from the prototype data with a reachability flood fill: every door and exit is reachable from the north
steps. `^` roof rows (blocked), `%` hedge, `=` bluff edge, `>` exit, `i` lamp post, `+` waymark, `@` door or stand tile.

```
    00000000001111111111222222222233333333334444444444555555
    01234567890123456789012345678901234567890123456789012345
 0  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%>>%%%%%%%%   > to Hall Rise
 1  ...^^^^^....^^^^^^..^^^^^^..^^^^^^..^^^^......##........
 2  ...^^^^^....^^^^^^..^^^^^^..^^^^^^..^^^^......##........
 3  ...^^^^^....^^^^^^..^^^^^^..^^^^^^..^^^^......##........
 4  ...^^^^^....^^^^^^..^^^^^^..^^^^^^..^^^^......##........
 5  ...HHHHH....SSSSSS..TTTTTT..KKKKKK..AAAA......##........   H Home, S Item Shop, T Storage,
 6  ...HH@HH....SS@SSS..TT@TTT..KK@KKK..A@AA......##........   K Scroll Keeper, A lot A (stall)
 7  .....#....i...#....i..#....i..#....i.#...ipppp##ppppi...
 8  .######################################################>   lane; > road east (closed)
 9  .######################################################>
10  .........................................ppppp##ppppp...   p Crossroads
11  .oooooo.....gg@ggg...yyy@yyy...bb@bbb....ppppp##+pppp...   o Lookout, g Growth Shrine,
12  .ooo@oo.....gggggg...yyyyyyy...bbbbbb....ppppp@#ppppp...   y Training Yard, b lot B
13  .oooooo.....gggggg...yyyyyyy...bbbbbb....ppppp##ppppp...
14  .oooooo.....gggggg...yyyyyyy...bbbbbb....ppppp##ppppp...
15  ==============================================>>========   > switchbacks to the Ferry Ward
```

(The Lookout and Yard are drawn at their proposed 6 x 4 and 7 x 4 so Codex's current art fits; the prototype file
used 8-wide placeholders for both, which made no difference to reachability.)

`spawn` (5,7) under the Home door. Lamps on the verge between doors, never on a door's approach tile.

### 6.3 Hall Rise (26 x 14)

```
    00000000001111111111222222
    01234567890123456789012345
 0  %%%%%%%%%%%%%%%%%%%%%%%%%%
 1  .......^^^^^^^^^^^^.......
 2  .......^^^^^^^^^^^^.......
 3  .......^^^^^^^^^^^^.......      Hall canvas 300 x 192 covers rows 1-8
 4  .......^^^^^^^^^^^^.......
 5  .......^^^^^^^^^^^^.......
 6  .......HHHHHHHHHHHH.......
 7  .......HHHHHHHHHHHH.......      base 12 x 3
 8  .......HHHHH@@HHHHH.......      double door (12,8) (13,8)
 9  ...........i##i.BB........      B Job Board, stand (16,10); `return` (12,9) on the steps
10  ........WW..##..@.........      W the well, team waiting spot (10,11)
11  ........WW@.##............
12  ............##............
13  ============>>============      > steps down to the street (46,1)
```

The board scene keeps working unchanged: the crew stand at the board door + (1,0), (-1,0), (3,0)
(`board_scene.gd:51`), all open grass here.

### 6.4 Old Ferry Ward (34 x 16)

```
    0000000000111111111122222222223333
    0123456789012345678901234567890123
 0  ......>>..........................      > up to the street
 1  ......##..........................
 2  ======##==========================      switchback through the upper cliff
 3  ::::::################::::::::::::
 4  ::::::################::::::::::::
 5  ::::::::::::::::::::##::::::::::::
 6  ::::::::::::::::::::##::::::::::::
 7  ====================##============      switchback through the lower cliff
 8  :::::::::::::::::::i#########:::::
 9  ::::::::::::::::::ll#####MM##l::::      M Mouth of the Hollow, door (25,10)
10  ::::::::::::::::::llll@llMMlll::::      l Old Ferry Landing, stand (22,10)
11  ::::::::::::::::::llllllllllll::::
12  ::::::::::::::::::lllllllll|d@dddd      d Ferry Dock, | mooring post
13  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~dddddd
14  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
15  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

### 6.5 Every service Highbank has today, kept

| Place id | Service | Today | v2 |
|---|---|---|---|
| `hall` | guild | (19,1) 10x6, doors (23,6) (24,6) | Hall Rise, base (7,6) 12x3, doors (12,8) (13,8) |
| `board` | jobs | (26,7) 2x1 | Hall Rise (16,9) 2x1 |
| `lookout` | view | (10,2) 6x4 | street (1,11) 6x4 |
| `home` | home | (3,3) 5x5 | street base (3,5) 5x2 |
| `shop` | shop (shut) | (31,3) 6x5 | street base (12,5) 6x2 |
| `storage` | storage | (38,3) 6x5 | street base (20,5) 6x2 |
| `scrolls` | scrolls (shut) | (31,12) 6x5, door on top | street base (28,5) 6x2, door south |
| `yard` | arena (shut) | (38,12) 7x5 | street (21,11) 7x4 |
| `shrine` | growth | (4,12) 6x5 | street (12,11) 6x4, `socket` anchor |
| `plaza` | waymark | (18,11) 12x6 | street (41,7) 12x8 |
| `landing` | landing | (26,26) 12x4 | Ferry Ward (18,9) 12x4 |
| `gate` | dungeon | (33,27) 2x2 | Ferry Ward (25,9) 2x2 |
| `dock` | view | (38,28) 6x2 | Ferry Ward (28,12) 6x2 |

New, proposals: the well (Hall Rise), lots A and B (street), the road east (an exit with `needs`).

---

## 7. What changes for story beats, checks and saves

### 7.1 Saves: safe

No town tile is saved. The town picks its arrival from a place id (`arrive_at`, `hub_town.gd:201-208`) or
`RETURN_SPOT` after a run (`hub_town.gd:18`); rooms send back by `town_door`. v2 keeps every place id, adds the area
to the lookup (place id to area), and resolves an old save's `arrive_at` the same way. Nothing to migrate.

### 7.2 Code that holds a town tile or a layout fact

| Where | What | Becomes |
|---|---|---|
| `hub_town.gd:18` | `RETURN_SPOT (24, 8)` | Hall Rise anchor `return` |
| `town_layout.gd:73` | `SPAWN (5, 8)` | street anchor `spawn` |
| `hub_town.gd:1176-1181` | music by tile: `y >= 19` ferry, `Rect2i(17, 0, 14, 9)` hall | the area's `music`; the settle timer (1189-1233) stays for areas with zones |
| `hub_town.gd:1403-1405` | shrine socket at rect + (72, 64) px | the shrine's `anchors.socket` |
| `hub_town.gd:547-548`, 577 | street cache key from `BANDS, PATHS, PLACES`, size from `W, H` | key from the area dict, one cached picture per area |
| `hub_town.gd:1691` | camera clamped to `W x H x 24` | the area's size |
| `building_exteriors.gd:39` | art must equal rect x 24 | the slot loader's size check (part 3, 3.2) against the class canvas |
| `building_exteriors.gd:70` | worn path from each door down to row 9 (Market Street) | to the nearest `paths` tile |
| `building_exteriors.gd:117, 153, 173-219, 368-416` | per-building z, door offsets (-36, -48, `PORCH_LIFT`), flood-filled doors, the porch cut | the template's `door_px` and anchor; the porch cut goes away with the south door |
| `highbank_painter.gd:780` | `SOFT_TILES Rect2i(15, 7, 19, 5)` | an area `ground` rect |
| `board_scene.gd:51-56` | crew relative to the board door, 3-tile trigger | unchanged (relative), needs the board in Hall Rise |
| `guild_crew.gd`, `guild_scene.gd`, `town_room.gd` | room tiles | unchanged until rooms convert, then the same numbers |
| `hub_town.gd:1141-1145` | `SHUT` texts by service | unchanged |

### 7.3 Checks

27 of 310 `tools/debug` scripts read the town layout. Those that place by place id or door offset survive as they are
(`storage_check.gd:48`, `board_scene_check.gd:48-49`, `hub_town_check.gd:97`). These hold absolute town tiles and
change to anchors:

| Check | Lines | Tiles |
|---|---|---|
| `hub_town_check.gd` | 13, 108 | `FERRY (28, 27)`, (32, 28) |
| `town_walk_check.gd` | 78-79, 105, 112 | (24,9) (25,9) (26,9), (5,9) (4,9) (3,9), gate (41,12), (41,11) |
| `town_loop_check.gd` | 86, 116 | (32, 28) |
| `music_check.gd` | 96, 101 | (24, 9), (26, 27) |
| `town_view_capture.gd` | 24 | (24, 10), (20, 21), (32, 26) |

Room tiles (`town_room_check.gd:187-227, 303, 309`, `pilot_chain_check.gd:325, 333`, `save_check.gd:201`) stay valid
while rooms keep their sizes. Run everything with `tools/debug/run_checks.py --fixed-fps 30`, and the full pilot
chain (720 s) after each step that moves a place.

New: `tools/debug/area_data_check.gd`, headless. For every area: every exit has a return exit in its target; every
door, stand and exit is reachable from the spawn or first exit (the flood fill the prototype above ran); every door
tile has a walkable tile in front; no prop on a door's approach; every anchor on a walkable tile; every canvas fits in
384 x 216; `door_px` inside its wall band; all 13 place ids present once across the areas.

---

## 8. The order to build it (one thing that runs per session)

Start after factory pass 8 lands. Each step ends with something Preston can walk.

1. **Building lineup.** `scenes/debug/building_lineup.tscn`: every class drawn by the template from data, beside
   Codex's current PNG, with a stage 1, 2 and 3 creature on each door tile, and `BUILDING_SCALE` 1.0 and 1.25 side by
   side. No game file changes beyond the new template script. Preston picks the scale.
2. **Today's map as an area file, 1:1.** `town_layout.gd` reads it; same tiles; all checks pass unchanged. Proves the
   format before anything moves.
3. **Highbank v2 behind a switch** (`HIGHBANK_V2`, off by default): the three areas, exits with fades (the room
   `go_room` path), anchors, placeholders for the five buildings, existing art for the open-air places. Checks get
   anchors and run both ways.
4. **Preston walks v2;** the switch flips; the pilot chain passes; the old layout stays one week as the fallback.
5. **Rooms in the same format** (`ROOMS` converted 1:1), plus the shop and cellar rooms as placeholders.
6. **Lots open with the story**, the first one tied to an existing beat.

Codex and Grok task lists come from the slot table in 5.2 through part 3's pipeline (reference renders with the grid,
door and creature silhouettes for each canvas).

---

## 9. Open questions for Preston

1. "Not the right size": too big, too small, or not matching each other? (The numbers say not matching.) Step 1 lets
   him choose 1.0 or 1.25 by walking it.
2. Three street areas with fades between them, or keep one big walkable map and only re-size the buildings? Areas are
   what lets the base grow like Sky's; one map has no fades.
3. Is Home on the street (one fade to the Hall) or apart on its own bluff like Sharpedo Bluff (two fades)?
4. Scroll Keeper: a south door down to a cellar room, or keep the lid in the ground?
5. Should the first new service be a street stall (no room) the way most of Treasure Town works?
6. The well on Hall Rise as the team's waiting spot and party switch: yes or no?

## 10. What each tool gave

- Repo reads and Python measurements: every size, opening, opacity and creature height above.
- One scale sheet image (the buildings with three creature stages at their doors): confirmed the Storage's half-scale
  detail and the team standing on the Scroll Keeper's roof.
- A Python prototype of the three v2 areas with a flood-fill reachability check (scratchpad `areas_proto.py`).
- Web: the official booklet (guild floors, facilities, growth over time, team waiting spot), Serebii (facilities, the
  cafe near the town exit), the Mystery Dungeon wiki (river, cliff, bluff to the west), Bulbapedia through search
  summaries (crossroads connections). Firecrawl: out of credits. Bulbapedia and the Spriters Resource direct: 403.
  Fandom: 402. So no tile sizes for Sky's areas were measured.
- Part 3 (`03-spec-format.md`) for the slot id and field names, so the two parts use one vocabulary.
