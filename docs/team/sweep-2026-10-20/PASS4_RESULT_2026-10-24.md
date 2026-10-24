# Factory pass 4, harden and polish: result (2026-10-24)

Plan: [PASS4_PLAN_2026-10-24.md](PASS4_PLAN_2026-10-24.md). Eight Claude lanes, then one integrator (Claude). Nothing is
committed or staged. This pass sits on `12e3bccd2` plus passes 3 and 4, all uncommitted.

## In short

- **Every lane item is done; none was skipped.** 67 IDs: dungeon 10, dungeon-art 4, town-art 4, town 11, pause-ui 7,
  checks-dungeon 11, checks-arena-kits 9, checks-arena-sys 11.
- **Suite: PASS 72 to 98 (97 in the full run), RAN 32 to 4.** 28 checks that only printed numbers now judge them: 26 pass and 2 are retired on
  purpose. The hardened checks found no game bug; every zero they used to print came from the check's own staging.
- **Only ui_fit's three title-panel points stay red** (Codex's C2). timing_check failed in the full run while League of
  Legends, Roblox and Summer were running, then passed alone (see the suite section).
- **Re-shot the live audit's screens.** Of its 36 findings, 19 now read fixed (16 seen in the re-shoot, 3 shown by the
  lanes' probes), and 3 more have Claude's part done with the words waiting on Preston. 10 wait on Codex's title and
  art work and 4 wait on Preston or Grok.
- **The integrator fixed one thing the re-shoot caught:** the crew scene framed only its opening shot. After the shove
  the partner lay under the text box, and on the get-up lines the team's heads touched the top edge (LV-28). Both now
  stay in frame.

## The suite, before and after

`python tools/debug/run_checks.py --long --arena --jobs 3` (always `--fixed-fps 30`). Table:
[after-pass4-checks.md](after-pass4-checks.md), with the reruns at its foot.

| | PASS | FAIL | TIMEOUT | RAN | WINDOW | RETIRED | SKIPPED |
|---|---|---|---|---|---|---|---|
| Before: after pass 3 ([after-pass3-checks.md](after-pass3-checks.md)) | 72 | 1 | 0 | 32 | 6 | 1 | 1 |
| Pass 4, full run after the merge (09:58 to 10:12) | **97** | 2 | 0 | **4** | 6 | 3 | 1 |
| Pass 4, after the reruns | **98** | **1** | **0** | 4 | 6 | 3 | 1 |

- **The one FAIL:** ui_fit's title Options and two How to play panels end at 659 and 669, past 636. Codex's C2.
- **timing_check:** The Hollow B1F seed 102 (the valley look) built in 4.35 s in the full run and 3.61 s alone, against a
  3.5 s limit (pass 3: 2.67 to 3.31 s). A third run alone passed at 3.45 s. It is not a pass 4 slowdown. In one
  process, the valley painter took 2.26 s with the pass 4 ruin_painter helpers and 2.25 s with the copies from before
  the pass. The Mouth's paint dropped from 1.8 s to 0.7 s. The machine was busy: League of Legends, Roblox and Summer
  were running, with the CPU at 45 to 59% and no Godot open. The same valley code took 1.83 s in pass 3's profile. The
  limit was not loosened. The valley floor is the one with no margin left (see what remains).
- **RAN that stay RAN, by plan:** arena_sizes (H30), arena_vfx (H32), dual_essence (H34, Grok's print tool), and
  arena_vfx_pass (H33, a stills tool, relabelled).
- **RETIRED:** first_morning, plus arena_scourmaw (H29, superseded by arena_ambusher) and arena_stormwick (H31, its
  moves are in no kit). Deleting the two files is Preston's call.
- No tracked file under docs/ changed during the suite. hub_town_check and move_table_check now write to the logs
  folder unless run with `-- --update-doc`.

## Integration

- **Cross-lane request applied (1 of 1):** `tools/debug/save_check.gd` line 143 now also waits for the dungeon's floor
  (`ents` not empty) after Continue, from the pause-ui lane. Since D1, the floor builds two frames after the scene
  appears. save_check passes.
- **Parse check:** all 76 changed or new scripts parse. The only message is the DialogueManager autoload in
  mouth_escape.gd, which `--check-only` cannot see.
- **The integrator's fix (board_scene.gd, T5 / LV-28):** `_shot()` takes `with_board := true`, and a new `_pan()` tweens
  the camera. After the shove lands, the camera re-frames the crew, the board and both teammates. After the partner
  gets up, it frames the pair alone. Measured with a windowed probe at every one of the scene's 14 lines, from the
  south and from the west: before, west failed 8 lines (partner's feet at y 512, under the box at 452; heads at y 38 on
  the get-up). After, all 14 pass both ways (heads at 48 or lower, feet at 446 or above). Checks after the fix:
  board_scene, guild_scene, hub_town, town_loop, story_gate, pad_play, pilot_chain, then dungeon_recruit, dungeons,
  faint, field_menu, hall_floors, job_board, music, roll_call, save, timing, town_walk, warden_yield and way_down. All
  20 pass.
- **Seams the lanes met and closed:** the place cards (D1, T4) build the floor and the town two frames after the scene
  appears. pilot_chain, town_loop and save_check now wait for a built scene. ui_fit's "team rows" point was updated
  for D6: names are cut with "..", and every row shows Sense. highbank_painter.gd was broken twice for a few minutes
  mid-lane. It parses now, and hub_town passed in the full run.
- **The user's save folder:** hashed and backed up before the re-shoot, which ran against a copy (APPDATA pointed at
  scratch). It was re-hashed after each of the two re-shoot runs, and both times it was unchanged, so no restore was
  needed. Backup: `C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\integ\p4_userdata_backup`.

## Per lane

| Lane | Done | Skipped | What changed, in a line each |
|---|---|---|---|
| dungeon | D1 to D10 | none | Hollow card on black about 13 ms after the scene starts (was 3 to 4.6 s of plain black); floor items use the bag's pixel icons; a long turn keeps its "X used Y!" line on top; damage numbers at the target's feet and callouts over the user, no overlaps (309 crossing pairs before, 0 after); the nest banner fades after 1.5 s and hides under prompts; "Sense n" always, long names cut with ".."; no bare "B2F" log line; the quick bag hint is built from the bindings; T replaces its order line and flashes the three order names; the sleep loop was checked and is not a game bug |
| dungeon-art | R1 to R4 | none | Hollow Mouth walls beside floor get carved block tops from the room palette, then fall into black in three dithered steps; Rootbank Warren pebbles sit in heaps by banks and pools, open dirt clean; no white dots in the moss |
| town-art | A1 to A4 | none | The Shrine and Yard walks below Market Street are stone steps, not flat tan boxes; door aprons fray; low-frequency grass patches, worn dirt at corners, sparse tufts; the room doorway has jambs, a sill and dithered bands of light; `UI.res_image` reads every res:// picture through the imported texture (an export has no PNG) |
| town | T1 to T11 | none | Key strip and MENU button no longer overlap in Highbank or rooms; room strip lines all in caps; the "Highbank remembers." toast is freed before leaving; first arrival shows a HIGHBANK card on black (7 ms) while the street paints; crew scene opening shot framed; Return to title mid-scene raises no error; Moss Bed line after the fade, as narration; a board posts each client once; the ruin card sits above the arch; "Back to the title?" in the label role; desk and stand art read through the texture first |
| pause-ui | M1 to M7 | none | Framed sliders with a gold fill and a brass knob that stay readable when focused; "Options, Rebind keys" on the Controls page; the pause Bag's hint comes from the bindings in caps; Floor page with the dungeon name as heading and labelled rows with a lantern bar; leaving to the title fades to black first; full screen does come back at a real launch (no edit needed); the Objective drops the town directions inside a Hollow |
| checks-dungeon | H01 to H10, H27 | none | 11 checks now judge: pilot_chain (Back in Highbank, one stage grown, no boss on the Mouth or replay), dungeon_battle, hub_town, town_loop, dungeon_trap, dungeon_iq, dungeon_tactics, dungeon_action, dungeon_vfx, move_table (Grok's body gate as a verdict), lv1_run (a row per seed) |
| checks-arena-kits | H11 to H18, H25 | none | 9 arena kit checks judge 62 verdicts; the zeros came from the AI's Beads charm breaking the checks' stuns, now blocked during each hold |
| checks-arena-sys | H19 to H24, H26, H28, H29, H31, H33 | none | 8 judge, 2 retired, 1 relabelled stills tool; arena_kitsense used to name the wrong winning team |

## Re-shot screens and what they show now

The re-shoot used the live audit's windowed probe (Summer Engine did not connect this session). Parts town, warren,
fight, extra, pad and opening ran against a copy of the save folder, and town ran again after the crew fix. Before and
after sheets are in `C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\integ\`
(`p4_sheet_*.png`, before on the left). The new runs rolled different floors, and no nest sprang and no Cutbank
Listener joined. Where a finding did not come up in the re-shoot, the verdict rests on that lane's own probe and says so.

| Finding | The audit saw | The re-shoot shows | Verdict |
|---|---|---|---|
| LV-04 pause sliders | default thin slider; the focused one lost its grabber | framed track, gold fill and knob on all three, focused or not | fixed |
| LV-10 Controls page | "Options, Controls" (no such page) | "Change any key under Options, Rebind keys." | fixed |
| LV-11 key strip and MENU | frames collide in the corner; room line 2 mixed case | strip above, MENU below at the same width, in Highbank and Home; both room lines in caps | fixed |
| LV-12 flat fills | flat tan walk below the wall gap; gradient box doorway | stone steps with verges; doorway with jamb, sill and flat dithered bands | fixed |
| LV-13 Mouth corridors | blurry grey wall bands; hard rectangle cut-outs | brick block tops, then a dithered fall into black (B1F, B3F) | fixed |
| LV-14 floor items | shaded balls | the Lamp Oil's pixel icon on the floor | fixed |
| LV-15 Warren floor | even speck field; white dots in moss | heaps of pebbles by banks and pools, clean dirt, plain moss | fixed |
| LV-16 message box | "used" line scrolled off | no five-line turn was caught on a still; the dungeon lane's probe shows the "used" line on top of a 9-line turn | fixed (probe) |
| LV-17 popups overlap | "EMBE2 FEINT!" | "EMBER FEINT!" over the user, the 2 at the target's feet, apart | fixed |
| LV-18 nest banner | banner under the recruit prompt for turns | no nest sprang; the lane's probe reads alpha 0 under the recruit prompt and the bag, 0 at 1.6 s | fixed (probe) |
| LV-19 "S2" tag | SENSE on one row, S2 on the next | no long name in the party this time; the lane's probe and ui_fit show Sense on every row | fixed (probe) |
| LV-20 bare "B2F" line | "B2F" alone in the log | B2F logs go from pickups to "Stairs. Press E to go down." with no label line | fixed |
| LV-21 bag hints | "J USE" in one bag, "Enter use" in the other | both in the same caps style and read from the bindings ("J USE" in play, "ENTER USE" in the pause Bag) | better: the two bags still answer to different keys; item text waits on Q6 |
| LV-22 Floor page | four bare lines, "turn 0" | ROOTBANK WARREN heading, B1F, labelled rows, lantern bar | fixed |
| LV-23 Objective in the Warren | town directions underground | the directions are gone in the Warren | fixed |
| LV-24 ruin card | card over the leader | THE HOLLOW sits above the arch, the team below | Claude's part fixed; the four names wait on Q2 |
| LV-27 Job Board | four Canvaswing jobs | Canvaswing, Cinderhide, Dustkite, Preostmar | fixed |
| LV-28 crew camera | heads cut at the top | after the integrator's fix: crew lines, shove and get-up all framed, heads clear | fixed |
| LV-29 freed-town error | seen once at board_scene.gd:263 | no SCRIPT ERROR in the re-shoot; the town lane's probes at TEAR, OBJECT and MOCK were clean | fixed (not seen again) |
| LV-30 riverbank prompt | tiny plain question over caps answers | "BACK TO THE TITLE?" in the label role | Claude's part fixed; words wait on Q7 |
| LV-32 T orders | four order lines flood the box | one order line; the three names flash under the team panel | fixed |
| LV-34 Moss Bed | line on half black; bed as speaker | black with no text, then the line as narration, no name plate | fixed |
| L03a, L03b black screens | 4.1 s and 2.5 s of black | card on black at once (mouth and warren card stills); the lanes measured 7 ms and 13 ms | fixed |
| LV-01, 02, 03, 05, 06, 07, 08, 09, 31, 35 | title, soul prologue, storm, Team page backdrop | unchanged | open: Codex C2 to C9, C19 to C21 |
| LV-25, 26, 33 | save toasts, effectiveness lines, gate prompt | unchanged by plan | open: Q3, Q1, Q5 |
| LV-36 | autopilot went down on B3F | not re-run | open: Grok G1 |

**Seen in the re-shoot, not in the audit:**
- Rootbank Warren's bank walls still meet the black with a soft green gradient band, the same kind of edge R1 and R2
  fixed in the Mouth.
- A move callout over a creature near the top left of the view can sit under the team panel ("...EINT!" on the pad
  fight still).
- The probe's own warren part read a freed dungeon at its line 413 after the team went down. That is the probe, not
  the game.

## New player-facing words (proposals, not canon)

No sentence was added or reworded. What is new on screen:
- **HIGHBANK place card** on a session's first arrival (T4): the town's own name in capitals, in the dungeon floor
  card's look.
- **Order flash** under the team panel (D9): STAY CLOSE, PUSH ON, HOLD, the existing names in the order T steps
  through them. No meanings until Q8.
- **Floor page labels** (M4): TURN, LANTERN, UNDERFOOT, WATER (only while it rises), PARTNERS' ORDER, THE NEST (only
  once sprung). The words come from the old lines; "turn 0" became "Turn 0".
- **Hints in caps** from the bindings: quick bag "W/S  CHOOSE   J  USE   I  CLOSE" (pad "D-PAD  CHOOSE   A  USE   Y  CLOSE");
  pause Bag "ENTER  USE" or "ENTER  LEARN THE MOVE" and "ARROWS  BROWSE     ENTER  USE     ESC  BACK".
- **Team panel:** "Sense n" on every row. At level 99, four names are cut: Rampartro.., Cutbank Lis.., Quietwater..,
  Oxbowarch..
- **Controls page:** "Options, Rebind keys", a correction of fact.
- Codex's proposals still wait on Preston: the New Game confirm (C6), "Stay" (C19), the storm beat (C20).

## Notes for Preston

- **Look at:** the before and after sheets in the integrator folder above. Start with `p4_sheet_townA.png` (Highbank),
  `p4_sheet_warB.png` (pause pages) and `p4_sheet_opB.png` (Mouth walls). The town-art lane's full-street picture:
  `C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\pass4_town_art_before_after.png`.
- **A long turn in the message box** now shows the "X used Y!" line, then the newest three. The lines in between, such
  as the damage, show only in the L log.
- **Only the nest banner** got the short time and hides under prompts. VICTORY, the boss name, REST, the water and
  CLEARED are unchanged; the same switch can go on for them.
- **The crew scene** now has the partner step up beside the leader as it opens, and the camera moves twice more: when
  the partner is shoved and when it gets up.
- **Job Board clients:** jobs.gd has no record of creatures met, so the pool is every creature in the floors' spawn
  lists. A swapped client can come from another floor's list (Preostmar, a B3F creature, posting a B1F job). Asked of
  Grok.
- **The Shrine and Yard walks** are drawn as low steps. If they should be flat stepping stones, that is one function
  (`_walk_stone`).
- **The Floor page** is 600 px wide (other pages 538) so the longest water line fits on one row.
- **Objective:** the "Go down to The Hollow" goal still says "through the Mouth of the Hollow" while you are inside The
  Hollow. It is the same kind of line as LV-23, and yours to call.
- **The title's Options sliders** still look different from the pause menu's until Codex's C4.
- **Full screen** does come back at a real launch (the pause-ui lane tested it on a copy of your save folder).
- **Sleep loop (D10):** not a bug. It runs on the wall clock, so only fixed-frame-rate captures (movie recording) would
  see one picture.
- **Arena checks:** no game bugs. arena_kitsense used to name the wrong winning team, so older logs that said your team
  won that 3v3 were wrong. No creature carries the Guardian passive any more (asked of Grok, Q11).
- **Your PC was busy during the checks** (League of Legends, Roblox, Summer). Floor build times read about 25% slower
  than in pass 3 for unchanged code.

## Preston's calls (each has a default if unanswered)

| Call | Question | Default |
|---|---|---|
| Q1 | House wording for "It's super effective!" and "It's not very effective." (proposal "It bites deep!" / "It barely scratches.") | Leave as is |
| Q2 | One name for the first dungeon (THE HOLLOW, HOLLOW MOUTH, Mouth of the Hollow, THE HOLLOW'S MOUTH) | Leave all four |
| Q3 | Save toasts say plainly "Saved"; the flavour line only on the bed | Leave as is |
| Q4 | Split the two long flood talk lines (flood_bank.dialogue:38-39) | Leave as is |
| Q5 | Ask before the Highbank gate starts a run (Go down / Not yet, listing taken jobs) | Stepping on it starts the run |
| Q6 | Item text "Heals the leader 15 HP." and "Refills the lantern by 40." | Leave the text |
| Q7 | Riverbank prompt words "Stay" / "Go to title" plus "Nothing is saved until Highbank." | Leave the words |
| Q8 | One-line meanings for Push On, Hold and Stay Close | Names only |
| Q9 | "Pincers 0/4" becomes "Pincer hits 0/4" | Leave as is |
| Q10 | The Warden's 24 x 24 face crop | Keep it |
| Q11 | Unset check thresholds: partner lag, scroll share, Vitrecrag guarding, Tail Club slam, the Guardian step, Kit Sense desire, hitstop holding position, damage dealers switching | Printed, not judged |
| Codex words | C6 New Game confirm, C19 quit cancel label, C20 storm beat | Codex builds the layout and holds the words |

## Codex and Grok

- **Codex:** [CODEX_TASKS_2026-10-22.md](../CODEX_TASKS_2026-10-22.md) section 7: C1 to C22 from the plan, in its
  order, then three integrator lines. The pause slider look for C4 is one static call; C11's test export is the proof
  for A4 and T11; send the new path for C22.
- **Grok:** [GROK_TASKS_2026-10-22.md](../GROK_TASKS_2026-10-22.md), "Pass 4 lines": G1 (Mouth spawns and REST_TO)
  first, the body gate rule, dual_essence; then the Job Board client pool, the Guardian passive and one more G6 data
  point. Pass 4 changed no numbers.

## What remains

- ui_fit's three title points and the rest of Codex's title work (C2 to C9, C19, C20), the Team page backdrop (C21),
  the export test (C11), the art move (C22).
- Preston's calls Q1 to Q11; Grok's G1 to G6 and the two new questions.
- Claude, next pass: point town_room.gd and board_scene.gd at `UI.res_image` (they carry their own `_art_image` copy
  today); delete `UI.HEAD` once Codex's C7 lands; wire Codex's backdrop, signboards and faces when they arrive; give the
  Warren's bank walls the Mouth's dithered edge; keep move callouts clear of the team panel; give the valley floor
  build back some margin (the threaded prewarm deferred this pass).
- From the plan, still for the next live audit: storage, the pad Job Board, the end card, audio and the black frame
  between scenes.
- Nothing is committed. Preston commits.
