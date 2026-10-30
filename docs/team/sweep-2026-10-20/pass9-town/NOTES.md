# Pass 9, town lane (2026-10-27)

Quit safety, the Growth Shrine, the street and the v2 arrivals. Claude. Nothing committed or staged.
The probes and their logs stay in the session scratch folder; the stills that matter are in `shots/`.

## What changed

| Item | File | Change |
|---|---|---|
| T1 quit | `scripts/audio/music.gd`, `scripts/ui/game_pause_menu.gd`, `scripts/town/hub_town.gd` | Every quit way (window close, pause menu Quit, a quit while the town is still warming up) waits for the town's worker jobs, drops what they made, and lets the waiting callers finish, so nothing is left holding a texture or a script at exit. |
| T1, found by the gates | `scripts/town/hub_town.gd`, `scripts/audio/music.gd` | The first version handed Music a small wrapper function (a lambda) to call at quit. Once the team left town for a dungeon, the town's script was let go but Music still held the wrapper, and the engine crashed freeing it at exit (exit 139, 5 of 5 town_loop_check runs). Music now holds the town's method itself and empties its list once it has waited. |
| T2 shrine | `scripts/ui/shrine_info.gd`, `scripts/town/hub_town.gd` | The shrine panel read each creature file from disk five times per open (a `load()` whose result nobody kept). Now each file is read once and kept. The warm-up also reads the party's forms early, and E at the shrine waits (at most 3 s, quietly) if those reads are still going. |
| T3 counts | `scripts/ui/shrine_info.gd` | Counts clamp at the goal and read `5 / 5   done`; the dim text was lifted from 0.7 to 0.75 so it clears 4.5 contrast; one close hint, the action button only when there is an action. |
| T4 news | `scripts/town/hub_town.gd` | Back-in-town news reacts first and names a recruit when one came along (words below). |
| T5 shut doors | `scripts/town/hub_town.gd`, `tools/debug/hub_town_check.gd` | A shut building's door tiles are solid. The check now proves it per area: the door tile is closed, a step at it from the front stays put, and E there reads the sign. |
| T6 v2 arrivals | `scripts/world/areas/street.gd`, `scripts/world/areas/ferry_ward.gd` | Arrivals from the north steps and the ferry steps moved three tiles down (row 1 to row 4); the camera was already held at the map's top edge, so it could not help. |
| T7 street cache | `scripts/town/hub_town.gd`, `scripts/town/world_tile_art.gd` | The Job Board's square earth pad is gone (it read as a patch pasted on the grass). The street picture's key now covers every file that paints it, so that change repaints once, then the picture is read from disk. |
| T8 v2 scene | `scenes/debug/highbank_v2.tscn` | Its own save starts after the parcel theft, so the objective reads as the story would. |
| T10 pad chip | none | Measured only; the chip reads `Menu  [Start]` on a pad. |

## Proposed words (not canon until Preston says so)

- After a clean run: "Well, Hollow Mouth's cleared. Everything in the bag made it home."
- After a run with a recruit: "Well, Hollow Mouth's cleared. The bag made it home, and Cinderhide came along too." (the name is whoever joined)

## Measured

Every Godot run used a scratch APPDATA. Preston's `team.save`, `team.save.bak` and `menu_preferences.cfg` hash the same
before and after (`hashes_before.txt`, `hashes_after.txt`).

| What | Result |
|---|---|
| T1 quit ways, 5 runs each (window close, a quit during the warm-up, pause menu Quit, a quit with a worker running), after the fix below | 20 of 20 exit 0, 0 ERROR lines; each worker run caught a worker running |
| T1, quitting from a dungeon entered from Highbank | before the fix exit 139 on 5 of 5 town_loop_check runs; after it exit 0 on 3 of 3 each way |
| T2 shrine, 16 runs (v1 and v2, two saves) | worst frame on the first open 25 to 53 ms (was 613 to 710 ms), second open 18 to 23 ms |
| T3 contrast | counts 4.95 and 4.96, labels 5.02 (at least 4.5) |
| T7 street cache | plain: a cold paint 9.4 s, then 0.95 s and 0.94 s read from disk; v2: 1.7 s, then 0.79 s and 0.57 s; one file in each street folder (`highbank_<key>.png`, `area_street_<key>.png`) |
| Gate checks, headless, plain and v2 on | 14 of 15 pass both ways (hub_town, hollow_approach, town_walk, town_loop, way_down, story_gate, town_props, area_data, evolution, music, save, pad_play, input_map, ui_fit) |
| timing_check | failed both ways in the suite on one dungeon floor (Hollow Mouth B3F seed 104, 5.3 s and 4.1 s, limit 3.5 s; floors are built before any town code runs), then passed 4 of 4 run alone (slowest floor 1.45 to 1.73 s) |
| Windowed: world_navigation | passes both ways |
| Windowed: ui_fit | fails both ways on one point: the Home room has no pause menu 6 frames after it is added. It fails the same with the town's warm-up switched off, so it is the room's, not the town's |
| pilot_chain | passes both ways (145 s plain, 91 s v2) |

`run_checks.py` refuses `--fixed-fps 30` on its command line because it already passes it to every check; the checks ran
with it, through the runner.

## Stills (`shots/`)

- `G03_shrine_v1.png`, `G03_shrine_v2.png`: the shrine panel, counts done, one close hint.
- `T18_shrine.png`: the audit's town9 shot again.
- `D17_news_none.png`, `D17_news_recruit.png`: back in town, both news lines.
- `C04_scrolls_step.png`: a step at the Scroll Keeper's shut door; the leader stays in front.
- `V01_street_arrive_v2.png`: the v2 street with the story objective.
- `V47_street_from_rise_v2.png`, `V48_ferry_ward_v2.png`: v2 step arrivals, nobody under the HUD.
- `V10_north_steps_v2.png`: still open, see below.
- `P04_chip_pad.png`: the MENU chip on a pad.

## Still open

- V10: standing on the top row of the north steps (row 1), the leader sits under the Next panel. The camera cannot go higher. Either the HUD tucks away near the top edge or the exit moves down a row; that is Preston's call.
- The windowed ui_fit runs rewrote four tracked stills in `docs/ui/ui-fit-2026-10-14/` (01 to 04) and added two
  (05, 06). Nothing was reverted; whoever commits should decide whether to keep them.
- The town9 re-run logged frames of 265 ms to 1.2 s at the end of a growth and after an Esc that the audit's run did not.
  The town's own work there measured 180 ms (the new form's sprites) plus a 49 ms frame; the rest sits next to the
  probe's own screenshot saves, which its hitch clock counts. Not settled.
- T9 (the loading card waiting for the walkway) is deferred: the walkway job runs after the three rooms, so waiting for it would hold the card for the rooms too. It needs the warm-up reordered.
