# Factory pass 5, performance and the unseen screens: result (2026-10-24)

Plan: [PASS5_PLAN_2026-10-24.md](PASS5_PLAN_2026-10-24.md). Five Claude lanes, then one integrator (Claude). Nothing is
committed or staged. This pass sits on `9a09a77ca` (passes 1 to 4).

## In short

- **44 of 45 lane items are done.** The one skip (S5, the walking hint boxes) needed no change: the riverbank and
  Hollow entrance strips already draw at the town strip's size and frame.
- **Suite: the same as after pass 4, on the first run.** 98 PASS, 1 FAIL (ui_fit's three title-panel points, Codex's
  C2), 0 TIMEOUT, 0 BROKEN, 4 RAN. No reruns were needed; timing_check passed inside the full run.
- **Every floor builds faster.** Slowest floor 3.03 s to 1.56 s, mean 1.35 s to 0.84 s (timing_check alone). A warm
  Highbank arrival went from 448 ms to 61 ms, and a second session's first arrival from about 4.5 s to 0.7 s.
- **The engine's `custom_samplers` error lines are gone** (6 per timing run before, 0 now).
- **lv1_run's table for Grok moved** (0 of 10 seeds cleared, was 4). Traced to a reshuffle of the shared random
  generator by frame timing, not a harder Mouth: on 20 fresh seeds pass 5 clears 4, the committed code 3.
- **Re-shot the live audit's screens.** Of its 36 findings, 23 now read fixed, 2 are partly fixed, 1 needed no change,
  9 wait on Codex's title and art work and 1 waits on Preston (footsteps).

## Integration

Applied, with line endings kept (hub_town.gd and dungeon.gd are CRLF, the other two LF):

| From | File | What |
|---|---|---|
| dungeon-art | scripts/art/selout_rim.gdshaderinc | `rim_sample` and `SELECTIVE_RIM` are macros that read TEXTURE themselves, so no rimmed shader hands a built-in sampler to a function. sel_out.gdshaderinc already switched to the macro when it exists. Only sel_out.gdshaderinc called `selective_rim`. |
| rooms | scripts/town/hub_town.gd | `_sfx(name, keep)`: a kept sound plays on the tree root, so the 0.66 s door outlasts the fade that frees the town; `enter_room` uses it. |
| screens | scripts/dungeon/dungeon.gd | `_faint_screen` hands the faint screen the last floor frame (`info["floor_still"]`) before the black; skipped headless. |
| screens | tools/debug/music_check.gd | The faint screen's bed is now `storm_rain` (looped), so the check expects it; its two comments say so too. Same strictness. |

Held, not applied:

| From | File | Why |
|---|---|---|
| town | scripts/dungeon/dungeon.gd `_place_jobs` | Keeps each job client in the Hollow the board names (`Jobs.hollow_of`, default "first"). The request itself asks for Preston's or Grok's yes, and it rides on Grok's open question LO5-28 (where clients come from). Its old text still matches, so it can be applied as written. |

Parse checks: all 22 touched scripts parse clean (`--check-only`), including scripts/creature_brief.gd. Godot made
`scripts/creature_brief.gd.uid` during the runs; it belongs in the same commit as the script.

## The suite, before and after

| | After pass 4 (with reruns) | After pass 5 (first full run) |
|---|---|---|
| PASS | 98 | 98 |
| FAIL | 1 (ui_fit, 3 title points) | 1 (ui_fit, the same 3 title points) |
| TIMEOUT / BROKEN | 0 / 0 | 0 / 0 |
| RAN | 4 | 4 |
| WINDOW / RETIRED / SKIPPED | 6 / 3 / 1 | 6 / 3 / 1 |
| pilot_chain | PASS, 124 s | PASS, 89 s |

Table: [after-pass5-checks.md](after-pass5-checks.md). Logs:
`C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\integ\p5_suite1`.
The run (13:42 to 13:51, `--long --arena --jobs 3`) had the Summer app and Chrome open; CPU was about 21% before it
started. Nothing was slow enough to need a rerun.

### Timing, before and after

Before is the timing_check run on the committed pass 4 tree at 11:55 (the pass 5 harvest). After is timing_check alone
at 13:59, with the full run's numbers in brackets. Room re-entry and a second session's first arrival are not in
timing_check (each check gets an empty APPDATA and enters each room once), so an integrator probe measured them with
timing_check's method over two sessions on one APPDATA.

| Measure | Before | After | Item |
|---|---|---|---|
| Slowest floor build (20 floors) | 3.03 s | 1.56 s (1.80) | all |
| Mean floor build | 1.35 s | 0.84 s (0.98) | all |
| Valley floors, mean | 2.62 s | 1.27 s (1.43) | PERF-01 (A1) |
| Ruin floors (Mouth, Hollow stone), mean | 1.16 s | 0.66 s (0.77) | PERF-03 (A2) |
| Riverbank floors (Warren), mean | 1.32 s | 1.05 s (1.24) | A3's new walls cost about 0.08 s of paint; PERF-06 more than pays for it |
| The last floor built again, same seed | 215 ms | 11 ms | PERF-06 (D10: `_make` no longer loads each form) |
| Dungeon scene ready with its first floor | 1839 ms | 1741 ms (1910) | includes D11's warm-up under the card |
| First hit on a floor (dungeon lane probe, rerun) | 16.8 ms with the caches cleared (the audit measured 44.5 ms) | 0.20 ms | PERF-07 (D11) |
| Highbank first arrival, painted | 4472 ms | 4384 ms (5046) | painting unchanged; T9 adds about 50 ms |
| Highbank first arrival, second session | painted again, about 4.5 s | 702 ms, read from user://street | PERF-02 (T10) |
| Highbank warm arrival | 448 ms | 61 ms (78) | PERF-04 (T11) |
| 'team sprites' step, warm arrival | 152 ms | 0.6 ms | PERF-04 (T11) |
| Room 'hall', first entry | 607 ms | 449 ms (534) | T11 holds the textures |
| Room 'home', first entry | 292 ms | 107 ms (144) | T11 |
| Room re-entry, same session | repainted each time (as a first entry) | hall 157 ms, home 2 ms | PERF-05 (RM9) |
| `custom_samplers` engine error lines | 6 | 0 | A5 plus the rim request |
| Static memory over 20 floors | +13.9 MB | +14.8 MB | limit 20 MB |
| Static memory at the end of the run | 129.9 MB | 138.4 MB | +8.5 MB: the session caches (room pictures, held sprites, warm effects); not split by item |

### lv1_run, the table for Grok

lv1_run passed (it judges only that every seed gives a row), but its table moved: 0 of 10 seeds cleared with 30 downs,
against 4 of 10 with 22 after pass 4. The integrator checked whether pass 5 made the Mouth harder. It did not:

| Run (same check, seeds as shown) | Cleared | Downs |
|---|---|---|
| Pass 5, seeds 1 to 10, 30 fps (the suite) | 0 of 10 | 30 |
| Pass 5, seeds 1 to 10, 60 fps | 1 of 10 | 29 |
| Committed dungeon.gd swapped in, seeds 1 to 10, 30 fps | 4 of 10 | 23 |
| Pass 5, seeds 11 to 30 | 4 of 20 | 49 |
| Committed dungeon.gd swapped in, seeds 11 to 30 | 3 of 20 | 54 |

The fights and the later floors roll on Godot's shared random generator, and the camera shake and the particles draw
from it every frame, so any change in frame counts (pass 5 holds the floor card longer and spaces the knock-out sounds)
reshuffles every roll after it. The same code at 60 fps gives a different table, and on 20 fresh seeds pass 5 clears
slightly more often than the committed file. Grok's note is in GROK_TASKS line 4 of "Pass 5 lines".

## Per lane

**dungeon (D1 to D11): all done.** Arrival menus wait for the floor card; the card holds 1.13 s with the floor number
beside the Hollow name and its words gone before the map shows; partner talk sits in the bottom strip with its
portrait; pickup and status pops draw above the fog; popups step off the HUD panels; the message box fades after 3 s,
L pins it; MENU no longer blinks through banners; bag and learn panels open away from the leader; the lantern meter
shows the lamp oil icon; ranged moves front with throw.wav; a partner going down plays ui/faint.wav; no frame starts
more than 3 sounds; autopilot has its own soft cue; the log opens and closes with ticks; standing creatures bob 1 px;
`_make` reads scripts/creature_brief.gd; hit sounds and effects are loaded under the card.

**dungeon-art (A1 to A5): all done.** Valley and Hollow stone paint share precomputed noise grids (pictures identical
to the pixel on 11 seeds); the Warren's walls have a shadow line, a clay face, a grass lip and about half a tile of
turf, then fall to black in three ragged steps, through a wall field shared with the Mouth; the Mouth's ordered
checker and the Warren's dot grid are replaced by clustered marks; `sample_art` is a macro.

**town (T1 to T12): all done.** The shrine fades into the growth scene and the growth's black runs straight into the
end card; both stages draw from one art family at one whole scale; the end card is a framed panel with the team and a
swelling track (copy unchanged); the 'run is kept' toast is freed before the scene change; the stone moment frames the
whole team; followers arrive a tile apart; the shrine plays presence_swell and the way-down list menu_open; board rows
and way-down rows name the Hollow and floor; the grass edge below Wayline Hall is irregular; the painted street is
saved under user://street; party and crew textures are held; townsfolk and the team bob 1 px.

**rooms (RM1 to RM11): all done** (RM6 needed no code: pass 3's arrival tiles already pass). Storage shows 7 rows
and scrolls; the cursor follows the item kind; banners hide behind panels and the fill is opaque; refusals play
denied.wav; Storage, room exits and waking have their sounds and the night lasts 1.5 s; the mail call puts the team on
set marks clear of the crew; the Home fire and lantern flicker and room creatures bob; painted rooms are kept for the
session; the desk and stand read through `UI.res_image`; the crew scene walks followers up so everyone stays framed.

**screens (S1 to S6): five done, one skipped.** The shrine's count shows 'n / goal' in full; unbound rebind slots
are empty key caps; both pages have brass pixel scrollbars; the faint screen shows the dimmed last floor and a steady
looping rain bed; the riverbank comment is reworded. S5 skipped: nothing to change (see above).

## Re-shot screens and what they show now

Summer Engine did not connect this session, so the re-shoot used the windowed-probe fallback: each lane's windowed
probe rerun on the integrated tree, plus an integrator probe for the walls and a real wipe to the faint screen. Every
run had its own empty APPDATA. Preston's real user data folder (3178 files) was backed up and hashed first. Afterwards
one file differed, `summer_engine_settings.cfg`, written at 14:05 by the Summer app, not by a probe (no probe wrote one
in its own folder). Following the live audit's rule it was restored from the backup, and all 3178 hashes then matched.
The Summer app's newer copy is kept at
`C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\integ\summer_engine_settings_written_1405.cfg`.

Stills: `C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\integ\reshoot\`
(contact sheets `sheet_walls.png`, `sheet_dungeon1.png`, `sheet_faint.png`, `sheet_town.png`,
`sheet_rooms_screens.png`, `sheet_strips.png`, and `highbank_ground_2x.png`, `warren_zoom3x.png`).

| Finding | Verdict | What the re-shoot shows |
|---|---|---|
| LV-01 Storage overflow | Fixed | 7 rows, a down arrow, keys and status inside the frame; MENU hidden while open |
| LV-02 Storage cursor jumps | Fixed | Probe: the third press names Lamp Oil or refuses; order holds |
| LV-03 Storage over banners | Fixed | No banner pixels; 252 of 252 fill samples are the weave's colours |
| LV-04 Shrine goal clipped | Fixed | '5 / 5', '0 / 60' in full; right edge 1055 against a limit of 1065 |
| LV-05 Growth stages mismatched | Fixed | Kithflare and Sparkwick both front idles at 2x; 232 px to 306 px |
| LV-06 Growth hard cuts | Fixed | Largest start step 0.033; 0 bright frames between growth and card; last fade step 0.009 |
| LV-07 End card bare and silent | Fixed (Claude's part) | Framed panel, team above, evolution_rising_shimmer swells in; the words wait on Preston |
| LV-08 Card over the learn menu, toast in the run | Fixed | Prompt first drawn on frame 42 with the card at 0; 0 arrival frames with the toast |
| LV-09 Card too short, title over the map | Fixed | Black held 34 frames (1.13 s); 'ROOTBANK WARREN  B3F' on one row; words gone before the map lifts (state probe: 0 frames). The windowed probe's word counter reads 4 frames, but that band count rises with the map's own brightness after the words were already 0. |
| LV-10 Walls don't match, mechanical dither | Fixed | Mouth and Warren share a rim, face and stepped fall to black with clustered marks; no dot grid or checker |
| LV-11 The world freezes | Fixed | Rootbank B2F: 93 of 120 frames change; Highbank 104 of 120; Home fire and team change |
| LV-12 Pasted grass strip below Wayline Hall | Fixed | 0 straight grass/cobble runs over 8 px there (was 11, up to 113 px) |
| LV-15 Followers stack | Fixed | 0 shared tiles in 4 street arrivals and 9 room entries |
| LV-16 Mail call clump | Fixed | 0 team/crew overlaps in 8 runs (stage 2 caveat below) |
| LV-17 Stone moment cuts the team | Fixed | Every team sprite inside the view; the highest head at y 1 |
| LV-18 Talk box over the warned room | Fixed | Talk in the bottom strip; the wild's tile clear; 18 of 60 tiles under the strip (was 20) |
| LV-19 Pickup word clipped by fog | Fixed | 202 text pixels at the fog edge and on open floor |
| LV-20 HUD at rest | Fixed | Box gone after 4 s; MENU on all 60 banner frames; panels never on the leader; lamp oil icon on the meter |
| LV-29 Wrong or missing town sounds | Partly | Shrine presence_swell, way-down and Storage menu_open, room exit door, wake on waking, log ticks in the dungeon all play; resting with Z in the dungeon is still silent |
| LV-30 Storage refusals | Fixed | denied.wav at the cap and on 'None of that kept here.' |
| LV-31 Combat audio | Fixed | Ember Shot fronts with throw.wav; one level_up on a triple; at most 1 start per frame in the KO probe |
| LV-32 Autopilot cue, Hollow music | Partly | Autopilot plays ui/cursor.wav at -14 dB; Warren music waits on Preston |
| LV-33 Job rows and way-down list | Fixed | 'Rootbank Warren B3F   dropped there'; way-down rows carry B4F/B3F/B2F tabs and client faces |
| LV-34 Rebind 'none' and flat bars | Fixed | 19 empty key caps, 0 read 'none'; brass pixel scrollbars |
| LV-35 Faint screen black, rain restarts | Fixed | A real wipe now shows the floor at 26% light behind the words; rain started once, no restart in 10 s |
| LV-36 Tiny walking hints | No change needed | The riverbank and entrance strips match the town strip's size and frame at 3x |
| LV-13, LV-14, LV-21 to LV-27 | Waiting on Codex | Title, splash, prologue, Scroll Keeper and signs (Codex's files) |
| LV-28 No footsteps | Waiting on Preston | Default: no footsteps this pass |

Two things the re-shoot noticed, both small and both for the next pass:

- The faint screen's dimmed still includes the HUD frames (team panel, key strip, MENU [P]), so a dim MENU button sits
  behind the words. Taking the still with the HUD hidden for that frame would fix it.
- Where a room sits within about three tiles of the map's outer edge, the clustered marks of the fall to black stop
  on a straight vertical line at the map edge. The marks are dark brown on black, so it is faint.

## New player-facing words (proposals, not canon)

No new words were added. These lines are built from existing names in a new order:

- The floor card puts the place and floor on one row: 'ROOTBANK WARREN  B3F'.
- Job Board where-lines and the Taken message name the Hollow: 'Rootbank Warren B3F   dropped there',
  'Taken: Find Dustkite. Rootbank Warren B2F.'
- The way-down list shows a cleared Hollow's floor count ('B4F') on the board's brass tab, and the faces of clients
  waiting there.

## Notes for Preston

- **L now keeps the message box open** until L is pressed again. Before, it showed the box for a few seconds.
- **Sounds picked from what we have:** autopilot uses ui/cursor.wav, quietly; a partner going down uses ui/faint.wav
  (the arena's faint); the faint screen's rain is now the steady flood-night rain, looping. Listen once and say if you
  want the old splash back.
- **The faint screen** now shows the floor you went down on, dimmed, behind the words.
- **'The run is kept.'** now only shows during the 0.2 s fade when the team sets out. A version that held the team at
  the Mouth for about 1.1 s so it could be read broke town_loop_check, which expects the dungeon within 8 frames.
- **After the first growth,** the end card comes straight out of the growth scene, so the growth's line ('Kithflare
  has grown into Sparkwick!') now shows in town after the card.
- **The growth scene's creatures are bigger** (front idles at 2x). Rimefin to Riftfin falls back to the small stills,
  because Riftfin is long and low; a taller Riftfin still from Codex would fix it.
- **Warren walls** now look like the Mouth's: a dark line at the floor, clay, a grass lip, a little turf, then earth
  falling into black. The crew's den keeps turf all the way round so its root arch does not float over black.
- **Mail call:** the crew on both sides of the rug moved one tile out to make room. A big stage 2 creature like
  Sparkwick can still touch Wickglow at the partner's spot; stage 1 teams are clear.
- **Highbank's painted street is saved** under user://street and read back next session. Whoever changes a street
  painter should raise STREET_VERSION in hub_town.gd (editor edits already force a repaint through file times).
- **Bed:** the night is 1.5 s of black and you wake to wake.wav. The Home fire and lantern flicker.
- **One live look is worth it:** the dungeon lane could not find what made MENU blink for a frame during the nest
  banner. It now hides only after its reason holds two frames, and the probe saw no blink in 60 frames.

## Preston's calls (each has a default if unanswered)

| Item | Question | Default |
|---|---|---|
| LO5-26 | Inside the Hollow, drop 'through the Mouth of the Hollow' from the pause Objective? | Leave as is |
| LV-07 | End card words replaced with in-world copy? | Keep the current two lines |
| LV-28 | Footsteps: an ElevenLabs take (uses credits) or a code-made soft tick? | No footsteps this pass |
| LV-32 | Give Rootbank Warren its own music? | Both keep hollow.mp3 |
| LV-22 | Rename the title Quit confirm's 'Back to title' to 'Stay'? | Keep 'Back to title' |
| LO5-05 | Words for the New Game overwrite prompt | Codex builds it, off until you pick |
| T4 | Drop 'The run is kept.' on setting out, or allow a short hold and loosen town_loop_check? | Leave as now (shown during the fade) |
| A3 | Should the crew's den fall to black like the other Warren rooms? | Keep turf all round |
| Held request | Keep job clients only in the Hollow the board names (needs your or Grok's yes) | Not applied |

## Codex and Grok

Codex: [CODEX_TASKS_2026-10-22.md](../CODEX_TASKS_2026-10-22.md) section 8 (the plan's 21 Codex lines plus two from
the lanes). Grok: [GROK_TASKS_2026-10-22.md](../GROK_TASKS_2026-10-22.md), "Pass 5 lines" (LO5-27 to LO5-29, and how to
read lv1_run now).

## What remains

- ui_fit's three title-panel points (Codex's C2).
- Resting with Z in the dungeon is silent (the rest of LV-29); no lane item covered it.
- The faint screen's still includes the HUD frames; the Warren and Mouth falloff stops on a straight line at the map
  edge near edge rooms (both above).
- The dungeon lane's windowed D2 word counter counts the lit map as words once the black lifts; its headless state
  probe is the one to trust (0 frames).
- Riftfin's growth pair uses the small stills until a taller still or idle exists.
- The held job-client request waits on Grok's LO5-28 answer.
- Codex's title, splash, prologue, signs, Scroll Keeper and export lines; Grok's G1 to G5, job clients and Guardian.
- Gameplay rolls share Godot's random generator with the camera shake and particles, so lv1_run and dungeon_chain
  rows reshuffle whenever frame counts change. A separate generator for gameplay would keep seed rows comparable
  (a Claude dungeon item; Grok asked first).
- Commit when Preston says so, including scripts/creature_brief.gd and its .uid.
