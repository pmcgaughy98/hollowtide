# Factory pass 6, the first hour and the words: result (2026-10-24)

Plan: [PASS6_PLAN_2026-10-24.md](PASS6_PLAN_2026-10-24.md). Five Claude lanes, then one integrator (Claude). Preston paused
the pass while the first integrator was working; a second integrator resumed it from the files. Nothing is committed or
staged. This pass sits on `36cd4b4cb` (passes 1 to 5).

## In short

- **33 of 33 lane items are done.** One half-item was skipped with reason: S4's `ui/opening_dialogue.gd` half, because
  that file has no live caller (only archived copies under docs/ preload it) and draws no choices.
- **Suite: the same as after pass 5.** 98 PASS, 1 FAIL (ui_fit's three title-panel points, Codex's C2), 0 TIMEOUT,
  0 BROKEN, 4 RAN. No reruns were needed. pilot_chain ran in 67 s (89 s after pass 5).
- **Timing did not regress.** timing_check alone: slowest floor 1.53 s (pass 5: 1.56 s), mean 0.77 s (0.84 s).
- **Live stalls are shorter.** Job Board first open: no frame over 250 ms (was 645 to 691 ms). Stairs: longest frame
  657 ms, split in two (was 1.3 to 1.7 s). Way down: 2.1 s (was 2.3 to 3.9 s).
- **Re-shot the live audit's screens.** Of the 33 findings, 15 now read fixed, 2 partly (L6-15 stalls, L6-18 team
  stacking), 11 wait on Codex, 1 on Grok (L6-02) and 4 on Preston (L6-19, L6-20, L6-28, L6-30).

## Integration

All 16 cross-lane requests were already applied by the first integrator (16:49 to 16:50). The resuming integrator
checked each new text in the files: each is there exactly once, and line endings match the file (dungeon.gd,
dungeon_warn_check.gd, dungeon_check.gd and dungeon_pace_check.gd are CRLF; the rest LF). Nothing was applied twice.

| From | File | What |
|---|---|---|
| dungeon (D1) | 10 checks under tools/debug (pilot_chain, dungeon_evolve, dungeon_warn, dungeon, dungeon_pace, dungeon_run, dungeon_trap, dungeon_teamsense, dungeon_battle, dungeon_boss) and warden_probe.gd | One line each: `check_bot = true`, so a check's autopilot still reads lines and welcomes recruits. The player's Tab never does. |
| dungeon (D3) | tools/debug/ui_fit_check.gd, two edits | The team-row width is measured with the tag in its own role (`nt[2]`), and the point now enforces "0 cut names of 39" instead of pass 4's ".." rule. |
| town (T3) | tools/debug/music_check.gd | Waits `MUSIC_SETTLE + 0.2` s before printing the 'by the Hall' and 'ferry landing' tracks (still printed, not judged). |
| story (S3) | scripts/dungeon/dungeon.gd `_finish_after_boss` | When the stairs already faded to black (the Mouth has no boss banner), skip the 2.2 s banner wait and the 0.4 s fade. A boss clear keeps both. |
| paint (P3) | docs/design/dungeon-tiles-2026-10-10/tile_checks.gd | Codex's native tile check expects the fog's unseen colour as `Color.BLACK` (was `#080b0e`). |

Not applied: the town lane's own version of the pilot_chain line (`if "check_bot" in s: s.check_bot = true`). The
dungeon lane's equivalent line was already in, so applying it would set the flag twice.

Parse checks: all 35 changed scripts parse with `--check-only`. creature_prologue.gd and mouth_escape.gd report only
"Identifier not found: DialogueManager", the autoload that this mode never loads. No em-dashes were added, and no
`print()` outside two check scripts.

## The suite, before and after

| | After pass 5 | After pass 6 (first full run) |
|---|---|---|
| PASS | 98 | 98 |
| FAIL | 1 (ui_fit, 3 title points) | 1 (ui_fit, the same 3 title points) |
| TIMEOUT / BROKEN | 0 / 0 | 0 / 0 |
| RAN | 4 | 4 |
| WINDOW / RETIRED / SKIPPED | 6 / 3 / 1 | 6 / 3 / 1 |
| pilot_chain | PASS, 89 s | PASS, 67 s |

Table: [after-pass6-checks.md](after-pass6-checks.md). Logs:
`C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\integ6\suite`.
The run (19:12 to 19:21, `--long --arena --jobs 3`) started on a quiet machine: no Godot process, CPU about 15%, Chrome
open. The first integrator's run at 17:00 on the same files gave the same totals. The checks wrote no new files into
the repo (git status lists only the pass's own changes and the two pass 6 docs).

### Timing, before and after

Before is pass 5's timing_check alone (13:59), with its full run in brackets. After is timing_check alone at 19:21 on a
quiet machine, with this pass's full run in brackets.

| Measure | Pass 5 | Pass 6 |
|---|---|---|
| Slowest floor build (20 floors) | 1.56 s (1.80) | 1.53 s (1.70) |
| Mean floor build | 0.84 s (0.98) | 0.77 s (0.84) |
| Ruin floors (Mouth, Hollow stone), mean | 0.66 s (0.77) | 0.58 s (0.63) |
| Riverbank floors (Warren), mean | 1.05 s (1.24) | 1.01 s (1.10) |
| Valley floors, mean | 1.27 s (1.43) | 1.21 s (1.34) |
| Dungeon scene ready with its first floor | 1741 ms (1910) | 1586 ms (1679) |
| Highbank first arrival, painted | 4384 ms (5046) | 4263 ms (4656) |
| Highbank warm arrival | 61 ms (78) | 60 ms (71) |
| Room 'hall', first entry | 449 ms (534) | 448 ms (493) |
| Room 'home', first entry | 107 ms (144) | 104 ms (129) |
| Static memory over 20 floors | +14.8 MB | +14.8 MB (limit 20) |
| Static memory at the end of the run | 138.4 MB | 141.2 MB |

The painters' new caps and the fog's wall reveal cost nothing measurable. The end-of-run memory is 2.8 MB higher; it
is not split by item (D7's painted-ahead floor in `_floor_cache` is the likely share). timing_check calls
`_build_floor` directly, so it does not see D7's stair split; the live stalls are below.

### Live stalls (windowed, wall-clock)

| Where | Live audit | Re-shoot, 19:22, quiet machine |
|---|---|---|
| Job Board first open | 645 to 691 ms | no frame over 250 ms (town lane's probe: 17 ms) |
| Wayline Hall door | 634 ms | 353 ms, on black after the fade; the street no longer freezes |
| Way down to Rootbank Warren | 2.3 to 3.9 s, card frozen | 2.1 s on the full card |
| Each stairs | 0.6 to 1.7 s | split in two: 545 + 288 ms, 657 + 340 ms; the card is full before the stall |

The first integrator's re-shoot at 17:42 logged 6.7 s, 7.7 s and 7.1 s stalls on the same steps. The rerun alone on a
quiet machine gave the numbers above, so those were load, not code. What remains: about 2 s of `_build_floor` under the
card on the way down, and the room build (about 0.35 s) on black.

### lv1_run, the table for Grok

lv1_run passed (it judges only that every seed gives a row). Its table: 5 of 10 seeds cleared, 20 downs, 285 turns a
seed (pass 5: 0 of 10, 30 downs). No rule changed. lv1_run never uses autopilot, so D1 does not touch it; D7 draws one
more frame per stairs, which reshuffles Godot's shared random generator. On 20 fresh seeds (11 to 30) the dungeon lane
measured 5 clears and 48 downs (pass 5: 4 and 49). Read it as a rate.

## Per lane

**dungeon (D1 to D9): all done.** Autopilot switches itself off ('Autopilot off.') when a story line or a 'wants to
join' question comes up, and the line waits for E, the question for Y or N; checks set `check_bot`. The faint screen's
still is taken with the HUD hidden. Team rows never cut a name: the level and Sense tags step down to the tight face on
every row when one name needs it. The recruit strip reads 'Y welcome it   N let it go'; the move-skip line reads
'Y skip it   N keep it'. Closing the bag plays menu_close. The message box is sized to its lines (one line: 45 px tall
at y 529, was 108 px). On the stairs, the next floor's picture is painted while the card is full, before the build
(longest stair frame 3322 ms to 1408 ms in the lane's probe). Resting by key plays `spent_pant.wav` at -16 dB once per
streak. Three word slips fixed ('ready to grow', 'reached Lv', 'The blight on').

**ui (U1 to U9): all done.** `UI.style_scroll_bar` is shared by Rebind, the shrine and the bag. Empty second-key cells
show a muted '-' ('add a key' when picked). The shrine under the Warden's stone says so and dims the counts. One table
of way names, `UI.WAY_NAMES`. 'Team orders'. Underfoot names the trap ('a silt pit'). Singular counts ('1 turn',
'1 item', '1 row up'). The faint line says 'the Hollow' and the last page has no arrow. The growth rays draw on the 3x
grid. The Team and Rebind hints name keys through the binding helper.

**town (T1 to T7): all done.** The board's client faces and request bits are built after arrival, one a frame, and
dungeon.gd is read on a thread (warm-up skipped headless). Room, dungeon and approach scenes load on a thread under the
fade. Street music waits 2 s in a new zone. Followers keep a trail with no shared tiles and arrive in a line. The
Highbank key strip drops the run line while the story holds the way down. After the first growth, the result panel
shows first and the end card rolls when it closes. Wickglow, Slipjaw and Muskin moved to lower Hall tiles.

**story (S1 to S5): done; S4's opening_dialogue.gd half skipped** (no live caller). The flood talk and the walkway fade
through UI's shared black. The black after the Mouth's last stairs is 5 frames (was 83), with the story lane's
dungeon.gd request applied. The flood talk's answers draw in the line's own face and size. The raw H shortcut on the
riverbank is gone; the south trail prompt does the job.

**paint (P1 to P3): all done.** The fall to black ends in black at the map edge (0 of 24 pictures with fall pixels on
the last row or column, was 20). Hallway wall faces were already painted; the fog canvas now also draws any wall beside
floor in sight, so they show in play. Room sides and hallway south edges end in a cap row of stones (Mouth) or turf and
a thin earth lip (Warren), then black; the fog is pure black.

## Re-shot screens and what they show now

Summer Engine did not connect this session, so the re-shoot used the windowed-probe fallback (the live audit's probe,
each phase with its own APPDATA and its own save file). Two sources:

- The first integrator's full run (opening, town, end card, walls, menus, NPC and trap, pad) at 17:37 to 17:48. No repo
  file changed after 16:50, so it ran on exactly these files. Stills and logs:
  `C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\integ\p6_reshoot\run2`.
- The resuming integrator's rerun of the town phase and the end card phase at 19:22 on a quiet machine, the end card
  from the live audit's pre-growth save (the first run had reused a save that had already grown). Stills and logs:
  `C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\integ6\reshoot`.

Contact sheets: `...\scratchpad\integ6\sheets\` (dungeon_hud.png, walls.png, faint_menus.png, endcard2.png, town.png,
story.png).

Save safety: before the rerun, Preston's user data folder (3178 files) was copied to
`...\scratchpad\integ6\userdata_backup` and every file hashed (SHA-256). After the rerun all 3178 hashes matched, so no
restore was needed. team.save, team.save.bak and menu_preferences.cfg were never touched. Earlier parse checks had let
Godot rotate four of its own engine log files in that folder; those are not game files.

| Finding | Verdict | What the re-shoot shows |
|---|---|---|
| L6-01 Autopilot reads lines and answers recruits | Fixed | The autopilot's off-click plays one frame after the first Mouth end line; the five lines move only on E, 60 to 64 frames apart (were 2); stills O101 to O105 each show their line (O65 was black). The lane's probe held each line 90 frames and a recruit question until Y. |
| L6-02 Monster house on Hollow Mouth B1F | Waiting on Grok | Unchanged: the opening run rolled 7 ambushes and went down 4 times before clearing the Mouth. |
| L6-03 to L6-12 Title, storm, soul prologue, white-outs, entrance lettering | Waiting on Codex | Unchanged: ui_fit's 3 title points; storm to soul 225, 0, 18 and soul to flood 206, 201, 0, 49 luminance as before. |
| L6-13 Missing fades, flood talk to riverbank to entrance | Fixed | Riverbank: 50 down to 8, 4 black frames, 7 up to 46. Entrance: 50 down to 8, 4 black, 6 up to 39 (was a cut, 50 to 39). |
| L6-14 2.8 s of black after the Mouth | Fixed | 5 black frames (was 83), then the dawn walk ramps up. |
| L6-15 Long single-frame stalls | Partly | See "Live stalls": board gone, stairs split under a full card, way down 2.1 s. The floor build under the card and the room build on black remain. |
| L6-16 Continue freezes the title | Waiting on Codex | 862 to 892 ms before the fade, as before. |
| L6-17 Street music ping-pong | Fixed | 3 track starts in 9.6 s by the board, each after 2 s or more in the zone (was 4 in 4.1 s). The town lane's 10 s zigzag: 0 starts. Standing at the board for 2 s switches to the Hall's track, by design. |
| L6-18 Four-creature team stacks | Partly | Arrivals stand in a line (T04: four in a row west of the leader); the lane's probe found 0 shared tiles through 3 doors and the Hall. Big sprites on neighbouring tiles still overlap at doors (T16), and the Hall story scene keeps its two-creature set spots, so four clump on the carpet (T22, see L6-19). |
| L6-19 'It's only you two' with four | Waiting on Preston | Unchanged. |
| L6-20 Empty streets | Waiting on Preston | Unchanged. |
| L6-21 Three gate names, run line during the story | Fixed (logic part) | First arrival strip: 'WASD WALK  E USE' only; after the board the run line is back. The names wait on Preston (W01). |
| L6-22 Shrine contradicts the stone | Fixed | 'The Warden's stone wakes the shrine. Kithflare and Tallowroot can grow now.' with the counts dimmed, none purple, E GROW offered. |
| L6-23 End card before the growth result | Fixed | Growth scene, then the street with 'Kithflare has grown into Sparkwick! Wick Bolt will be offered on the next run.', then E rolls the card. |
| L6-24 Walls only on the north side | Fixed | Mouth room sides and south walls end in a cap row of stones; Warren in turf and an earth lip; hallway north faces and south lips show in play. |
| L6-25 'Cutbank Liste..' | Fixed | 'Cutbank Listener' in full; the tags in the tight face. |
| L6-26 Two recruit wordings | Fixed | Box and corner strip both read 'Y welcome it   N let it go'. |
| L6-27 'hollow' lowercase, arrow on the last page | Fixed | No arrow under 'E  Try again'; the line reads 'the Hollow' in code (the re-shoot's faints lost no new partners, so it was not on screen). |
| L6-28 Save signal | Waiting on Preston | Unchanged ('Highbank remembers.'). |
| L6-29 Empty key pills | Fixed | Run and Turn show a muted '-', no outlined box, idle and listening. |
| L6-30 Long opening | Waiting on Preston | Unchanged. |
| L6-31 Bag closes with cancel.wav | Fixed (by check) | The re-shoot did not open the bag. dungeon_sfx's key test hears menu_open, menu_close, menu_open, menu_close for I, Esc, L, L; the lane's windowed probe heard the same. |
| L6-32 Smooth rays | Fixed | Every sampled row of the rays has 2 colours and edges on the 3 px grid. |
| L6-33 Big one-line message box | Fixed | 'Hollow Mouth, B1F.' in a one-line box (45 px tall). |

From the leftovers: LO6-01 (HUD in the faint still) fixed, the dimmed still shows no MENU or team frame; LO6-15 (flood
choices) fixed, the answers match the line's size.

## New player-facing words (proposals, not canon)

- Shrine under the Warden's stone: "The Warden's stone wakes the shrine. %s can grow now." (the plan's proposal) and
  "The Warden's stone lets it grow now. These counts are not needed this time." (new).
- Rebind, an empty second key: '-', and 'add a key' when that cell is picked.
- Move-skip key line: 'Y skip it   N keep it'.
- The recruit strip now uses the ask box's own 'Y welcome it   N let it go'.
- Word fixes from the plan: 'feels ready to grow...', '%s reached Lv %d!', 'The blight on %s wore off.',
  'Team orders', 'The new partners went back into the Hollow: %s.', Underfoot 'a silt pit' (the trap table's names),
  and singular counts ('1 turn', '1 item', '1 row up from the low end').
- The Team page's growth rows now use the shrine's way names ('Pincer hits', 'Hits on sleepers', 'Damage taken',
  'Slams', 'Health restored'); it said 'Pincers' before.
- Removed: the riverbank's 'H  continue to Highbank' strip line.

## Notes for Preston

- **Autopilot (Tab) now stops for story lines and join questions** and says 'Autopilot off.'. Read with E, answer with
  Y or N, then press Tab again.
- **Resting with Z has a sound now:** `spent_pant.wav`, a soft pant that was in the folder but unused, at -16 dB, once
  per streak. Listen once; say 'silent' to drop it or name another take.
- **Long names in the team** (Cutbank Listener, Quietwater Warden, Rampartroot, Oxbowarchon) switch every row's level
  and Sense tags to the smaller letters, so no name is cut.
- **The skip question** still reads 'Let <move> go unlearned? Y/N' above 'Y skip it   N keep it', so 'let go' appears
  once about a move. Rewording it is your call.
- **The message box** now fits its lines and fades after 3 s (pass 5's choice, kept; the plan said about 4 s). L pins it.
- **After the first growth** you see the result line on the street first; E then rolls the end card.
- **Walls:** hallways show their walls in play, and room edges end in cap stones (Hollow Mouth) or turf with a thin
  earth lip (Rootbank Warren). The unseen dark is pure black now. In darkness (lantern empty), the walls beside your lit
  3x3 also show; they reveal no creatures or items. Say if you want darkness to hide them.
- **Fades:** the flood talk fades into the riverbank and the walkway fades into the Hollow entrance (4 black frames at
  30 fps, on purpose, so the fade survives the build frame). The black after the Mouth is about 0.2 s of frames now;
  real time is about 0.75 s, most of it building the dawn walk.
- **The H shortcut on the riverbank is gone.** The south trail prompt takes you to Highbank.
- **Shrine and Team page:** the shrine dims the counts when the Warden's stone lets a creature grow, but the Team page's
  'Growing waits on' bars still show the unmet counts for the leader and partner. A small follow-up if you want it.
- **The dawn walk's answers** are still in the small letters; the flood talk's now match their line. Same fix, later.

## Preston's calls (each has a default if unanswered)

| Item | Question | Default |
|---|---|---|
| W01, L6-21 | One name per place (proposal: 'Hollow Mouth' for the riverbank dungeon, a gate name without 'Mouth' such as Ferry Steps, a proper name for the Warden's dungeon) | Leave as is |
| W02 | Stock lines: '%s used %s!', the four-moves lines, the '!' on plain log lines (proposals in the words audit) | Leave as is |
| W04 | The partner's code-side lines that bark orders (riverbank_journey.gd, faint_screen.gd) | Leave as is |
| W05, L6-28 | Save signal: 'Saved.' or a small Saved tag instead of 'Highbank remembers.' | Leave as is |
| W12, W13, W15, W16, W19 | Colon-joined lines, the end card's three 'And...', lines that repeat the screen, key slots in lessons, 'could not open' errors | Leave as is |
| L6-19 | 'It's only you two' with four on the carpet: recruits wait outside story scenes, or the lines count them | Leave as is |
| L6-20 | 3 or 4 townsfolk with one St. Joseph line each after the crew leave | None added |
| L6-30 | Trim the escape walk from 35 to about 15 lines; let the board scene carry the crew warning | Leave as is |
| L6-22 | The shrine's stone line | The lane's line stays |
| LO6-05 | The rest sound (`spent_pant.wav`) | Keep it |
| L6-14 | An 'Out of the Hollow' place card after the Mouth | No card |
| W14, LO6-11 | Codex's words: 'BEGIN YOUR JOURNEY' and the New Game prompt | Prompt off, caption as is |

## Codex and Grok

Codex: [CODEX_TASKS_2026-10-22.md](../CODEX_TASKS_2026-10-22.md) section 9 (the plan's 25 lines plus four from the
lanes, including the tile check change and the note that Claude took LV-27). Grok:
[GROK_TASKS_2026-10-22.md](../GROK_TASKS_2026-10-22.md), "Pass 6 lines" (L6-02 first, then G1 to G5, job clients,
Guardian, autopilot and how to read lv1_run). Pass 6 changed none of Grok's numbers.

## What remains

- ui_fit's three title-panel points (Codex's C2), and the rest of the title, storm, soul and lettering work (Codex).
- About 2 s of floor build under the card on the way down, the boss floor's unsplit stairs build (about 1.4 s), the
  room build on black (about 0.35 s) and the lower Hall's first visit (about 1 s on black).
- The riverbank painting is re-finished in every scene that draws it (about 0.34 s each; waking_bank.gd and
  waking_bank_finish.gd have no owner). Caching the finished picture once would cut it.
- The dawn walk's answers in mouth_escape.gd still draw in the small label face (same fix as S4).
- The Team page's 'Growing waits on' bars do not dim under the stone.
- The dungeon's place card shows the dim MENU [P] button over it (seen by the town lane).
- Big sprites on neighbouring town tiles still overlap visually; the Hall story scene clumps four (L6-19).
- `scripts/ui/opening_dialogue.gd` is dead code (Codex note 28).
- Gameplay rolls still share Godot's random generator with the camera shake, so lv1_run and dungeon_chain rows move
  whenever frame counts change.
- Grok's L6-02, G1 to G5, job clients and Guardian. Preston's calls above.
- Commit when Preston says so.
