# Factory pass 7, the later dungeons and accessibility: result (2026-10-26)

Plan: [PASS7_PLAN_2026-10-26.md](PASS7_PLAN_2026-10-26.md). Five Claude lanes (dungeon, floors, town, story, ui), then
one integrator (Claude). Nothing is committed or staged. The pass sits on `36cd4b4cb` plus pass 6, still uncommitted.

## In short

- **37 of 39 lane items are done.** Two wait on Codex: S7 (the board stand's arena fronts, C22) and U9 (removing the
  old heading font, C7). D7 was done another way than planned (see the dungeon lane).
- **Suite: 99 PASS, 0 FAIL, 0 TIMEOUT, 0 BROKEN, 4 RAN** (pass 6: 98 PASS and ui_fit's title FAIL). The first full run had one new TIMEOUT (flood_opening), caused by the dungeon lane's arrival
  split adding two frames to headless runs; the integrator restored pass 6's headless order and it passes. ui_fit's three
  title points, the one FAIL left after pass 6, now pass too (Codex's C2 landed today).
- **Timing did not regress past noise.** Floors, the dungeon scene and Highbank are within the run-to-run spread of the
  same code (pass 6's own files measured 4745 ms for Highbank this morning). Rootbank Warren floors cost 5 to 13% more
  to paint (the new walls and ripples), inside the floors lane's 10% bound on its own benchmark. The memory line had
  jumped to +19.0 MB of its 20 MB limit; that was the check sampling before the music loaded (the new 0.25 s music wait),
  and with the sample moved it reads +14.6 MB (pass 6: +14.8).
- **Live stalls are gone or halved.** Continue into Highbank: no frame over 250 ms (was one 4.4 s frame). Highbank gate
  into The Hollow B1F: 534 ms (was 1995 ms). Hollow stairs: 270 and 535 ms (was 611 and 1351 ms).
- **Re-shot the live audit's screens.** Of the 27 findings, 20 now read fixed, 1 partly (L7-21 team stacking), 4 wait on
  Codex (L7-17 to L7-20, three of them likely closed by Codex's own results today) and 2 stay with Preston by default
  (L7-15, L7-27).

## Integration

All seven cross-lane edits still matched and went in once each, with the file's own line endings
(dungeon_visibility_canvas.gd and guild_scene.gd are CRLF, the rest LF). A dry run before and after confirmed each new
text is there exactly once. Copies of the files before the edits are in
`C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\p7int\backup_before_xlane`.

| From | File | What |
|---|---|---|
| dungeon (D10) | tools/debug/ui_fit_check.gd | The message-box section reads the game's own `log_away_now()` and calls `log_clock_start()` (the player acts) before it ages the box, since the box now waits for the player's next action. |
| floors (F1) | scripts/dungeon/dungeon_visibility_canvas.gd | The wall tile above a north face is revealed too, so the Warren's bank reads two tiles high. The floors lane asked for a Mouth still first: in the Mouth it shows the broken tops of the ruin walls against the dark, which reads as ruin and not as a fault (`p7int\floor_stills\mouth_b1_int.png` beside the floors lane's `floors\mouth_b1_after4.png`). |
| town (T2), two edits | scripts/ui/ui_style.gd | `UI.res_image` reads the imported texture on any thread (the main-thread-only rule is gone, and its doc line says to poll such a worker, never block on it). No dungeon painter reaches it on a worker today (`USE_TILE_ART` is false), so the dungeon's `_exit_tree` wait cannot deadlock on it. `town_room.art_off_main()` was left as it is: it could now return true in an exported game, but no export exists to test it (Codex C11). |
| town (T2) | tools/debug/timing_check.gd | Prints `TownRoom.prepare` for the Hall, the lower Hall and Home, then each room's arrival after it, so the check shows what a player gets after the town's warm-up. |
| town (for story S2) | scripts/town/guild_scene.gd | Returns when the room was freed while the team walked in. This cleared town_room_check's three script errors. |
| ui (U6) | scripts/ui/rebind_page.gd | The rebind page says RB+ only when `UI.chord_needed` says the button is shared, so a move put on L3 reads 'L3', as it fires. |

The integrator's own changes, both found by the suite:

| File | What and why |
|---|---|
| scripts/dungeon/dungeon.gd `_ready` | The first floor's split arrival (art ahead, a frame, the paint, a frame) now runs only when `_threads_ok()`. Headless, the arrival is pass 6's two frames and one build again. With the split always on, flood_opening_check waited its 4 frames after the arch and found the floor still unbuilt (`ents` empty, a script error, then the 300 s timeout). The dungeon lane had meant headless runs to keep the old build; the windowed path, which carries D3's gain, is unchanged. |
| tools/debug/timing_check.gd | The memory sample waits out the music's new 0.25 s start (`music.gd COALESCE`, U8) before its first reading. Without that, the place's music stream (3.4 MB) loaded after the first sample and counted as floor growth: +19.0 MB against a 20 MB limit. Proof: with COALESCE set to 0 for one run (then restored, hash checked) the same check read +15.6 MB. The limit is unchanged. |

Every touched script parse-checks clean (29 files; mouth_escape.gd reports only the DialogueManager autoload, which is
normal in that mode).

Codex was still working on the title during the integration: creature_opening.gd changed at 10:30 and main_menu.gd at
10:39 (its C4 recheck and C6 Continue details), with two new handoffs. The integrator touched none of those files. The
final suite started after both edits, so its 99 PASS includes them; the first suite and the hollowtime re-shoot ran
before the 10:39 edit.

## The suite, before and after

| | Pass 6 (after-pass6-checks.md) | Pass 7, first run | Pass 7, final run |
|---|---|---|---|
| PASS | 98 | 98 | 99 |
| FAIL | 1 (ui_fit's title points) | 0 | 0 |
| TIMEOUT | 0 | 1 (flood_opening) | 0 |
| BROKEN | 0 | 0 | 0 |
| RAN (judges nothing) | 4 | 4 | 4 |
| WINDOW (needs a window) | 6 | 6 | 6 |
| RETIRED, SKIPPED | 3, 1 | 3, 1 | 3, 1 |

dungeon_evolve_check moved from RAN to PASS in the lanes' own runs (F4 gives it a verdict); it shows as PASS in both
pass 7 runs. pilot_chain passed in 92.5 s in the first run (pass 6: 67 s), 106 s in the final run; its random runs differ each time (the dungeon lane's own pass took 78 s), so the time is not a verdict. The table of
the final run is [after-pass7-checks.md](after-pass7-checks.md).

### Timing, before and after

timing_check alone on a quiet machine, the final code. In brackets, a second run of the same code (before the memory
sample moved), to show the spread.

| Measure | Pass 6 | Pass 7 |
|---|---|---|
| Slowest floor build (20 floors) | 1.53 s | 1.57 s (1.59) |
| Mean floor build | 0.77 s | 0.79 s (0.84) |
| Ruin floors, mean | 0.58 s | 0.59 s (0.63) |
| Riverbank floors (Warren), mean | 1.01 s | 1.06 s (1.14) |
| Valley floors, mean | 1.21 s | 1.22 s (1.24) |
| Dungeon scene ready with its first floor | 1586 ms | 1685 ms (1740) |
| Highbank first arrival, painted (headless, one call) | 4263 ms | 4527 ms (4449) |
| Highbank warm arrival | 60 ms | 62 ms (62) |
| Room 'hall', first entry | 448 ms | 196 ms after `TownRoom.prepare` (248 ms, done on a worker after a player arrives) |
| Room 'hall_low', first entry | not measured | 2 ms after prepare (858 ms) |
| Room 'home', first entry | 104 ms | 4 ms after prepare (109 ms) |
| Static memory over 20 floors | +14.8 MB | +14.6 MB (+19.0 before the sample fix) |
| Static memory at the end of the run | 141.2 MB | 144.9 MB (the check now prepares three rooms) |

Reading it: the same pass 6 files measured 1682 ms (dungeon ready) and 4745 ms (Highbank) at 08:46 this morning, so
those rows are within the spread. To place the riverbank cost, the integrator ran the check with the floors lane's
before-painters swapped in (1.03 s) and with the dungeon lane's before-files (1.08 s), each restored and hash checked
after. The new Warren walls and ripples cost 5 to 13% here; the floors lane's own paint benchmark (min of 3 rounds,
7 seeds) put it at +2.8%. The headless Highbank number is the old one-call build: a player's window now paints the
street on a worker behind the card (below).

### Live stalls (windowed, wall clock, screen readback off)

| Where | Live audit | Re-shoot |
|---|---|---|
| Continue into Highbank (the card) | one 4379 ms frame | no frame over 250 ms |
| Highbank gate into The Hollow B1F (the card) | 1995 ms | 534 ms |
| Hollow stairs | 611 and 1351 ms | 270 and 535 ms |
| Into hollow_approach from town | 1004 ms | 990 ms (not in this pass) |
| Title Continue (Codex's) | 815 ms | 450 ms |

The town lane's own windowed probe: Hall door 59 ms and lower Hall 22 ms after the warm-up (were 315 to 341 and 1013
to 1032 ms); the street painted on the worker matched the main-thread paint byte for byte.

## Per lane

**dungeon (11 of 11).** D1: a boss's first fall sets `down_handled`; later blows return at once, so the Warden's and
the crew's endings and the boss EXP happen once (warden_yield: 17 lines, 17 unique, EXP 130 = one grant; with the guard
removed for one run, 34 lines and 260 EXP, FAIL). D2: the knock-out fade is kept on the creature and stopped when the
stand-off takes over; the leader lies in its down pose through the stone scene (asserted every frame). D3 and D4: the
first floor and stairs paint ahead, on a worker thread with a player at a window, with creature art loading on
threads; the Menu hint is hidden under the card. D5: no message box behind the learn panel, the recruit box on the far
side from the asker, the key strip hidden while the box shows the keys. D6: one callout per creature, kept on screen
below the floor bar. D7: the den map was already wider than the view and the camera already clamped; the black pillars
were the fog, so the den lights its whole room instead of being padded. D8: the log and key strip on the full panel,
the age fade dropped (UI.rich fades a whole row), downed names in #ff8a7a; measured 4.7 to 6.7:1, about 3% under the
plan's targets on measure.py's p99 floor and at the targets on the floor the evidence used. D9: trap rims, wind-up
corner ticks with a dark inner line (the pale tick alone measured 2.9 to 4.1:1), a dark edge on the leader's map dot and
a hollow stairs square. D10: the message box waits for the player's next action. D11: Reduce motion caps the boss-fall
flash and the boss-intro white at 0.3.

**floors (4 of 4).** F1: Warren rooms share the corridors' banded sediment face (21 px) with hanging roots, and room
sides are a wide turf bank with roots. F2: the long white strokes are gone; small curved ripples with a shadow side.
F3: the rising water has a moving foam line, opaque darker bands and glints; no grass shows under the first row. F4:
dungeon_evolve judges each autopilot seed (forcing zero runs gave FAIL).

**town (8 of 8).** T1: Highbank's street paints on a worker behind the card, which now has a flickering pixel lantern.
T2: the Hall, lower Hall and Home are prepared on a worker after arrival. T3: the run line shows only when the way down
is open. T4: the board's highlight follows the request just taken or put back. T5: Storage, The way down and the news
panel carry the nameplate tab; the way down list now hangs from the top of the screen. T6: refusals play `denied` on
the UI bus, closing a town panel plays `menu_close`, the bed opens with a tick and wakes to `presence_swell` at -14 dB.
T7: the town key strip sits on an opaque panel (7.2:1). T8: arrivals are spaced by each sprite's real size.

**story (6 of 7, S7 waits on C22).** S1: Wayling's line points to the Mouth (proposal). S2: Starward walks 0.2 s a
tile, lines start while walkers move, and the use key snaps a walk to its end. S3: four open carpet marks in the Hall.
S4: the escape walk's choices match the flood talk's. S5: the waking bank and the entrance finishes are made once a
session (pixel identical; 340 to 650 ms down to 0.2 to 3 ms after the first). S6: `scripts/ui/opening_dialogue.gd` and
its uid deleted (nothing outside docs/ used them; the archived copies stay).

**ui (8 of 9, U9 waits on C7).** U1: evolution swaps never faster than 0.2 s apart; Reduce motion gives one 0.4 s
cross-fade and a 0.35 white. U2: the Objective page says its sentence once. U3: the shrine's four names share one size.
U4: the Team page has the big title heading; the shrine has the nameplate. U5: after the stone, the Team page dims the
growth rows and says why. U6: a chord is needed only when the pad button is shared in that context. U7: disabled rows
4.27:1, shrine stone rows 4.03:1 on the real screen. U8: music requests within 0.25 s coalesce. U9 waits:
main_menu.gd still defines and calls `_ensure_menu_inputs` (lines 99 and 111); no runtime `UI.HEAD` users remain.

## Re-shot screens and what they show now

Summer Engine did not connect this session (connection timeout), so the re-shoot used the windowed-probe fallback: a
copy of the live audit's own probe, each phase with its own APPDATA under `%TEMP%\p7i` and its own copy of the audit's
saves. Stills and logs:
`C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\p7int\reshoot`
(play_story_part1 from s1 through the end card, play_story_part2 from s5, play_town, play_storage, play_dungeon,
play_pad, play_menus, play_hollowtime_nolum), plus floor stills in `...\p7int\floor_stills` and the story lane's
real-time reading probe rerun as `...\lane_story7\run_int7`. One early story run was spoiled when two phases shared a
folder; it was stopped and both were rerun with their own folders (the spoiled ones are kept as `zz_clobbered_*`).

Save safety: before the re-shoot, Preston's user data folder (3173 files outside logs/) was copied to
`...\p7int\userdata_backup` and hashed (SHA-256). After the re-shoot all 3173 hashes matched. The only change in that folder is Godot's own rotating logs/: the integrator's parse checks, run without a temp APPDATA, added one 73-byte log and Godot rotated out one older log. No save, preference or setting changed.

| Finding | Now | What the re-shoot shows |
|---|---|---|
| L7-01 Warden ending x3 | fixed | Every ending line once (part 2, 253.9 to 332.7 s). The ending runs 75 s of game time from 'You fight well' to the last line, about 93 s to the scene's end (was 252 s). 'Rest, then. The pond will keep you.' is said twice, once when the fight opens and once at the stand-off: that is the script, not a repeat. |
| L7-02 Kithflare missing | fixed | S23_B3F_turn308: Kithflare lies in its down pose beside Tallowroot while Starward stands over them. |
| L7-03 frozen cards | fixed | Highbank: no frame over 250 ms. The Hollow B1F: 534 ms. Stairs: 535 ms at worst. |
| L7-04 Wayling's directions | fixed (proposal words) | 'The Warren's down through the Mouth, by the Old Ferry Landing. Mind the roots.' |
| L7-05 run line while the story holds | fixed | S10 (Tell Starward) and S32 (Bring the parcel to Starward): the strip shows only WASD and E. |
| L7-06 Objective twice | fixed | X03: the heading sentence, then only 'The shrine is there for whoever is ready next.' |
| L7-07 silent stretches | fixed | Real-time page-aware probe: longest gap between text starts 5.66 s over 27 gaps (target 6). The audit's probe still logs 13.5 to 15.3 s in the Hall, because it waits up to 8 s on two-page lines and its game clock ran twice the wall clock; on that same probe the board theft's 12.4 s gap is now 7.7 s. |
| L7-08 learn panel and recruit box | fixed | D06 and P10: no letters behind the learn panel. S08: the recruit box sits left, clear of the team panel and the asker, and the corner strip is hidden. On the pad shot the panel docks right and covers part of one partner. |
| L7-09 shrine name sizes | fixed | S63: Kithflare, Tallowroot, Cutbank Listener and Skimlet in one size. |
| L7-10 board highlight | fixed | T12 to T13 and P05 to P06: the highlight stays on 'Recover Cinderhide's River Stone', now Taken. |
| L7-11 black pillars in the den | fixed | S30_B4F_turn680: tree-trunk walls and bank reach both screen edges. |
| L7-12 Warren room walls | fixed | first_b1_int: a banded clay face with roots on the north edge, the turf cap above it now in view, a turf bank with roots on the sides. |
| L7-13 white streaks | fixed | Small curved ripple marks in patches; no straight white strokes. They read a little regular, like scales, at full size. |
| L7-14 flat water | fixed | water_t0_int: a foam edge, opaque darker bands, no grass under the first row; the foam changes between turns (the floors lane counted 1097 changed pixels). |
| L7-15 B2F looks like the Mouth | Preston (default: leave) | unchanged |
| L7-16 stacked callouts | fixed | D22: one 'EMBER SHOT!' callout, below the floor bar and on screen. |
| L7-17 to L7-20 title | Codex | Not re-shot (Codex's files). ui_fit's three title-panel points now pass, and Codex's own results today report C2, C3 and C4 done. |
| L7-21 team stacking | partly | Fixed at the Hall door (T14), the way down (D03) and the street. Still stacked: Home after walking to the bed (T09, T10: the one-tile walking trail, which the plan kept) and the Hall line-up (S35: Skimlet one tile in front of Tallowroot covers most of it; the four marks are separate tiles, but a tile apart is not enough for those sprites, and a row further back sits under the text box). The cleaner fix depends on L6-19. |
| L7-22 heading styles | fixed | Job Board, Storage, The way down, the shrine: one nameplate tab. Pause: OBJECTIVE and TEAM share the title heading. |
| L7-23 refusal bus | fixed | Storage cap: denied.wav on UI -8. |
| L7-24 the bed | fixed | Bed panel: menu_open tick. Waking: presence_swell.wav on SFX -14, no wake.wav. |
| L7-25 closing sounds | fixed | Esc on Storage and the board: menu_close.wav. |
| L7-26 music collisions | fixed in the log, not heard | One music start per beat: the Warren goes hollow, deep_hollow once, crew_theme alone; the pond goes pond_garden, then boss_scene 33 s later. Victory still plays twice after the crew's den, as in the audit. Preston's listen stays open. |
| L7-27 steps | Preston (default: leave) | unchanged |

## New player-facing words (proposals, not canon)

1. Wayling, guild_scene.gd SEND_OFF: 'The Warren's down through the Mouth, by the Old Ferry Landing. Mind the roots.'
   (was '...under the levee, past the board...'; 'Old Ferry Landing' capitalized to match objective.gd).
2. The dungeon log at the stand-off, dungeon.gd: '%s is down, but the Warden has stopped.' (for example 'Kithflare is
   down, but the Warden has stopped.'; was '%s staggers up. The Warden has stopped.', which no longer matched the
   leader lying down).

Moved, not new: the shrine's 'The Warden's stone lets it grow now.' also shows on the Team page; the heading 'Team'
became 'TEAM' in the title face; the nameplate tabs show the existing titles 'Storage', 'The way down', 'Back in
Highbank' and 'Growth Shrine'.

## Notes for Preston

- The Warden's ending no longer plays three times, Kithflare stays on screen lying down until the Guildmaster arrives,
  and the Warden's EXP is paid once. It may have been paid up to three times in recent playtests.
- Arriving in Highbank and The Hollow no longer freezes. The street paints in the background while the HIGHBANK card
  shows a small flickering lantern.
- New in scenes: with no line up, pressing E, Enter, J or Space (A or X on a pad) snaps everyone walking to where they
  were headed. Starward and Wayling now talk while they walk.
- Layout change to look at: 'The way down' list hangs from the top of the screen, like the Job Board.
- Music now starts about a quarter second after each change, so two tracks never collide. Please listen once at the
  Rootbank Warren stairs and the pond entrance.
- The shrine's dimmed rows measure 4.03:1 on the real screen. The harsher worst-case model says 3.79:1; a dim of 0.75
  instead of 0.7 would clear it there too.
- Still stacked: the team after walking to the bed at Home, and the Hall line-up. Your L6-19 answer decides that one.

## Preston's calls (each has a default if unanswered)

1. L7-04 Wayling's new line (above). Default: the proposal stays; reword or revert any time.
2. The stand-off log line (above). Default: stays.
3. L7-06 should the post-pilot Objective get its own longer text? Default: the words stay; only the repeat is gone.
4. L7-15 The Hollow B2F uses the Mouth's grey ruin stone; older greener stone or the valley look? Default: leave.
5. L7-24 a new ElevenLabs morning take for the bed? Default: presence_swell at low volume, no new take.
6. L7-27 soft footsteps on town paths and room boards? Default: walking stays silent.
7. ACC-03 four rebindable one-key diagonal actions? Default: leave.
8. ACC-08 a 'Text size: Normal / Large' row in Options? Default: leave.
9. L6-19 should recruits wait outside story scenes, and does 'only you two' stay? Default: leave; the Hall has four
   marks.
10. L7-26 listen once at the Warren stairs and the pond entrance. Default: the change ships as checked.

## Codex and Grok

Appended as "10. Pass 7 lines" to [CODEX_TASKS_2026-10-22.md](../CODEX_TASKS_2026-10-22.md) and "Pass 7 lines" to
[GROK_TASKS_2026-10-22.md](../GROK_TASKS_2026-10-22.md). Codex: the title Options, type and How to play lines (L7-17
to L7-19) look closed by Codex's own C2 to C4 today; the logo crossfade, the storm and soul flashes under Reduce
motion, C7 to C9, the threaded Continue, the icon, export and arena fronts, the art queue and the foot-row data file
are open. Grok: the Hollow Mouth monster-house roll and G1 to G5, Job Board clients and the Guardian passive, and an
FYI that the Warden's EXP is now granted once. No Grok number changed this pass.

## What remains

- Waiting on Codex: C22 (then board_scene.gd:99 points into assets/, S7), C7 (then ui_style.gd HEAD goes, U9), C11
  (an export, then `town_room.art_off_main()` can return true in exports), the open title and art lines above.
- Waiting on Grok: LF7-19 and LF7-20.
- L7-21: the walking trail and the Hall line-up still overlap wide sprites (L6-19).
- Entering hollow_approach from town still holds one frame for about 1.0 s (990 ms in the re-shoot). Not in this plan.
- The title holds its first frame 0.9 s at boot and 0.45 s on Continue (Codex's LF7-15).
- Warren floors paint 5 to 13% slower than in pass 6 (within the floors bound). Worth watching if more is added.
- Pre-existing, from the dungeon lane: quitting with the crew's den on screen reports about 400 textures held at exit;
  Starward's walk-on at the stand-off makes a team growth record '6:2' (stone_scene calls `_make(6, 2, 0, ...)`).
- Small things seen in the re-shoot: the corner 'MENU [P]' stays up while a town panel is open (Job Board, shrine);
  on the pad, the learn panel docks right and covers part of one partner; victory plays twice after the crew's den.
