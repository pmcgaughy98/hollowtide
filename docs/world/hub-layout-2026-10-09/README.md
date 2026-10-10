# Hub town layout: Highbank, for Codex to fill (Claude, 2026-10-09)

**Preston, 2026-10-09:** "Can you do the world layout with the synthesis so Codex can just fill it in, to account for its weakness in determining positions etc. and also not having synthesis context, like how it did for the dungeon."

## How this works (the same split as the dungeon)
- **Claude owns the positions, sizes, doors, paths and what each place does.** They live in one file, `scripts/town/town_layout.gd`. The checks and the rules read it.
- **Codex owns the art:** buildings, lanes, cliffs, water, props and the UI for each service. Draw to the rects below.
- **The current picture is plain blocks** (`paint()` in `scripts/town/hub_town.gd`). Replace it the way `hollow_bank_painter.gd` replaced the dungeon's procedural floor: keep `paint()` as the fallback, and put a painter of your own in front of it.
- **Do not move a door, a path tile or a footprint without telling Claude.** If the art needs a different footprint, write the new rect in your log and Claude changes the layout and reruns the check.
- **Run it:** F6 on `scenes/hub_town.tscn`. The check is `tools/debug/hub_town_check.gd`. The stills are `layout_full.png` (the whole map at 1x) and `hall_panel.png`.

## The synthesis behind it (structure only; you don't need to read the games)
- **Explorers of Sky's hub** is a crossroads: the guild up on the high ground, a street of services, the hero's home off to one side, paths down to the water, and the way out to the dungeons. It is compact, so everything is a short walk.
- **Rescue Team DX** puts its services around one square, so the player sees them all at once.
- **Hollowtide's own world bible** says Highbank is a bluff town: "upper streets hold homes, shops, and the dispatch hall. Switchback lanes descend ... to the ferry district". The Old Ferry Ward is where the first Hollowtide reports came from. So the guild (Wayline Hall) is on the bluff, the services line Market Street, and the switchbacks lead down to the ferry landing, where the Mouth of the Hollow is the way into the dungeon.
- **Names** are the world bible's working names or plain roles. Preston names them.

## The map
- **Size:** 48 x 32 tiles of 24 px, 1152 x 768 px, the dungeon's tile size, so creatures walk the town at the same scale. The view is 384 x 216 at 3x, like the dungeon.
- **Terrain bands, top to bottom:**
  - y 0-17: the bluff top (grass, the town);
  - y 18: a cliff;
  - y 19-23: the middle terrace;
  - y 24: a cliff;
  - y 25-29: the lower terrace at the ferry;
  - y 30-31: the river.
- **Paths:**
  - Market Street: x 4-44, y 9-10;
  - the Hall's steps and the street south through the plaza: x 23-24;
  - switchback 1 through the upper cliff: x 23-24, y 18-19;
  - the middle terrace path: x 14-24, y 20-21;
  - switchback 2 through the lower cliff: x 14-15, y 22-25;
  - the landing path: x 14-31, y 25-26;
  - the road east, closed for now: x 45-47, y 9-10.
- **The spawn** is (5, 8), outside Home's door.

## The places
Tile coordinates (x, y) and size, the same in pixels, and the door tile. A building is solid except its door; an area or spot is open ground.

| Place | Kind | Tiles | Pixels | Door | Service | What it is |
|---|---|---|---|---|---|---|
| Wayline Hall | building | (19, 1) 10x6 | (456, 24) 240x144 px | (24, 6) | guild | The Wayline Compact's hall: jobs, the team roster, reports. The guild of this game. |
| Job Board | spot | (26, 7) 2x1 | (624, 168) 48x24 px | (26, 8) | jobs | Requests to take into the Hollows. Pick one, then go down to the ferry. |
| Bluff Lookout | area | (10, 2) 6x4 | (240, 48) 144x96 px | (13, 5) | view | Where the river looks close. Later: the region map. |
| Home | building | (3, 3) 5x5 | (72, 72) 120x120 px | (5, 7) | home | The team's place to sleep and save. The day starts here. |
| Item Shop | building | (31, 3) 6x5 | (744, 72) 144x120 px | (33, 7) | shop | Berries, lamp oil, stones: what a run needs. |
| Storage | building | (38, 3) 6x5 | (912, 72) 144x120 px | (40, 7) | storage | Keeps items between runs; a run's bag is lost on a faint, storage is not. |
| Scroll Keeper | building | (31, 12) 6x5 | (744, 288) 144x120 px | (33, 12) | scrolls | Move scrolls: teaches a shared signature to a body that has the parts, and remembers forgotten moves. |
| Training Yard | area | (38, 12) 7x5 | (912, 288) 168x120 px | (41, 12) | arena | The arena side mode as the town's dojo: real-time spars and practice. |
| Growth Shrine | area | (4, 12) 6x5 | (96, 288) 144x120 px | (7, 12) | growth | Shows each creature's growth toward evolving, and its IQ skills. |
| Crossroads | area | (18, 11) 12x6 | (432, 264) 288x144 px | (24, 14) | waymark | The town's centre: the waymark points to every place. |
| Old Ferry Landing | area | (26, 26) 12x4 | (624, 624) 288x96 px | (28, 27) | landing | The old crossing, where the first Hollowtide reports came from. |
| Mouth of the Hollow | spot | (33, 27) 2x2 | (792, 648) 48x48 px | (33, 28) | dungeon | The way into the Hollow. Step in to start a run. |
| Ferry Dock | area | (38, 28) 6x2 | (912, 672) 144x48 px | (39, 28) | view | Planks over the water. Later: the crossing to the far bank. |

## What to draw first (one at a time, Preston reviews each)
1. **The bluff-top ground and Market Street** (grass, the street's paving, the cliff edge). This is most of what the player sees.
2. **Wayline Hall**, the biggest building and the guild, 240 x 144 px with the door at the bottom centre.
3. **The four service buildings** (Home, Item Shop, Storage, Scroll Keeper) at their footprints.
4. **The switchbacks and the ferry landing**, the Mouth of the Hollow included.
5. **The service screens** (the shop, storage, the job board) are later jobs. Each one's rules come from Claude, its look from you.

## Not done yet (Claude's side)
- **Launch:** Codex's creature prologue still launches the dungeon directly. The next step routes prologue → town → the Mouth of the Hollow → dungeon, and back to the town after a clear or a faint. Codex owns the launch flow, so agree the hand-off.
- **The services only show what they are.** The shop, storage, the scroll keeper's relearning and the shrine's growth screen get their rules next, one at a time.

## Wired in (Claude, later on October 9)
Preston: "Do the town wiring, prologue to town to hollow and back."

**The loop:**
1. The creature prologue opens Highbank.
2. Stepping into the Mouth of the Hollow starts a run.
3. A cleared dungeon or a faint brings the team back to the Hall's steps, with a message.

**The team record** (`scripts/town/team_state.gd`) carries the party, the hall roster, the bag, taught moves, evolution growth, IQ, team orders and the clear count between scenes. It is not saved to disk yet; that's the save system's job.

**The dungeon run on its own** (F6, or the checks) still loops back to its first floor. Only a run started from the town returns to it (`return_to_town`).

**Check** (`tools/debug/town_loop_check.gd`), with real scene changes:
| Step | Result |
|---|---|
| The prologue | opened the town in 3 presses |
| The Mouth | started a run with the team |
| A clear | came home with the bag, IQ and clear count, greeted on the Hall's steps |
| The next run | got them back |
| A faint | came home with the bag lost |

**Codex:** `scripts/creature_prologue.gd` is yours, and its last step now opens `scenes/hub_town.tscn` instead of the dungeon. Three lines, marked with a comment.
