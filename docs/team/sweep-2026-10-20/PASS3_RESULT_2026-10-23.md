# Factory pass 3, the look pass: result (2026-10-23)

Plan: [PASS3_PLAN_2026-10-23.md](PASS3_PLAN_2026-10-23.md). Six Claude lanes, then one integrator (Claude). Nothing is
committed or staged. Pass 2 is committed and pushed (`12e3bccd2`, origin/master); this pass sits on top of it, uncommitted.

## In short

- **All 45 plan items are done; none was skipped.** ui-core 8, dungeon 11, town 9, rooms 4, story 8, housekeeping 5.
- **Suite after the merge: PASS 72, FAIL 1, TIMEOUT 0.** The one FAIL is ui_fit's three title-panel points, the same
  three as before the pass (Codex's C2). The two new checks, rebind and face_crop, both pass.
- **Re-shot after the merge:** of the audit's 33 findings, 20 now read fixed and 4 read better but not finished.
  The other 9 are still open: they belong to Codex's title work or wait on a call from Preston (table below).
- **Two things to look at:** the 24 x 24 face crops (Warden's crop is a guess) and the Highbank ground in the game.

## The suite, before and after

`python tools/debug/run_checks.py --long --arena --jobs 3` (always `--fixed-fps 30`). Table:
[after-pass3-checks.md](after-pass3-checks.md).

| | PASS | FAIL | TIMEOUT | RAN | WINDOW | RETIRED | SKIPPED |
|---|---|---|---|---|---|---|---|
| Before: after pass 2, with its reruns ([after-pass2-checks.md](after-pass2-checks.md)) | 70 | 1 | 0 | 32 | 6 | 1 | 1 |
| Pass 3, first full run after the merge | 70 | 3 | 0 | 32 | 6 | 1 | 1 |
| Pass 3, final full run (19:43 to 19:52) | **72** | **1** | **0** | 32 | 6 | 1 | 1 |

What the first run's two extra FAILs were, and what fixed them:

- **field_menu_check** read only Label and Button nodes. The dungeon lane's D8 makes each message log row a
  RichTextLabel (names in their side's colour), so the page looked empty to the check. The game was fine: a probe
  showed the row "Rootbank Warren, B1F." on the page. The check now reads a RichTextLabel's words too and still
  requires the B1F line, so it tests the same thing.
- **timing_check**: slowest floor 3.71 s against the 3.5 s limit (The Hollow B1F, seed 102). Two whole-disk
  `find /` searches left running by the lanes since 18:09 were holding two CPU cores; I stopped them. Alone after that:
  slowest 2.67 s, mean 1.54 s (pass 2: 2.57 s and 1.36 s). The final full run: slowest 2.99 s, mean 1.71 s, PASS.
  I measured each painter against its HEAD copy in the same process: Mouth 1456 ms now against 1170 ms (the D2 painted
  look, as the dungeon lane said), Warren 467 against 472, valley 1834 against 1800, Hollow ruin 1212 against 1180.
  So the Mouth is about 0.3 s slower to paint and the rest are unchanged.
- **pilot_chain** passed in 85 s (it was 214 s before this pass; the town's picture cache does most of that). The
  post-pilot Warren replay went down once again (level 7, B3F, turn 335, to Preostmar) and cleared on the second
  try. That is added to Grok's signals.

## Integration

**Cross-lane requests (10).** Applied 8, each matched byte for byte with its line endings kept:

| From | File | What |
|---|---|---|
| ui-core | `scripts/ui/game_pause_menu.gd` | `_save` goes through `UI.save_pref`, so text speed is written to `game_prefs.cfg` |
| ui-core | `tools/debug/pad_play_check.gd` | the waits hold a WeakRef to the room, not the room itself (the "Lambda capture freed" error) |
| dungeon | `scripts/dungeon/riverbank_painter.gd` | Rootbank Warren's stairs use `paint_stairs` |
| dungeon | `scripts/dungeon/valley_painter.gd` | The Hollow's valley floor stairs use `paint_stairs` |
| town | `tools/debug/ui_fit_check.gd` (2) | the street sign is measured in the prose role, rows counted with `UI.wrap_text` |
| rooms | `tools/debug/ui_fit_check.gd` (2) | the room panel is measured by `town_room.gd`'s own `spot_layout` |

Not applied (2):

- dungeon's pad_play request (an instance-id version of the same fix): it was superseded by ui-core's WeakRef version,
  which went in first.
- rooms' `hub_town.gd` request (use `SceneKit.follow`): its old text no longer exists. The town lane wrote its own
  follow rule (`_follow_tile`) for T4, and `town_walk_check` asserts it: no follower on a footprint, a door tile or
  the leader's tile.

**My own fixes during integration:**

- `pad_play_check.gd`: `var ref := weakref(room)` would not parse, because `weakref()` returns a Variant and the
  project treats that warning as an error. It is now `var ref: WeakRef = weakref(room)`. pad_play passes.
- `ui_fit_check.gd`: removed `head_h`, unused after the two requests, and updated section 8's comment.
- `field_menu_check.gd`: reads RichTextLabel rows (above).

**Parse check:** all 30 touched scripts parse. `mouth_escape.gd` reports `DialogueManager` not found, which is the
autoload's name and normal in `--check-only` (HEAD's copy does the same).

**Checked and left alone:** the dungeon lane's note about a double fade-in after the dawn scene. `mouth_escape.gd`
never calls `UI.fade_in`; its own black veil was already there before this pass, so there is no double fade.

## Per lane

| Lane | Done | Skipped | One line |
|---|---|---|---|
| ui-core | U1 to U8 | none | Prefs split (title keys stay, game keys in `game_prefs.cfg`), full screen restored at launch, rebind_check, `UI.event_text`, a second key per action, whole-row rebind list and one-line prompt, sentence-aware pager, face crops and face_crop_check |
| dungeon | D1 to D11 | none | Real stairs, painted Mouth, the rest-dot checker gone, painted trap marks, one floor card, sized key strip, moves in one row with keycaps, foe and team name colours, full bag descriptions, no empty-bag loss line, exits on black |
| town | T1 to T9 | none | Warm Highbank arrival 0.4 to 0.6 s (was 5.5 to 6), worn ground edges, the porch off the roof, followers off facades, the Training Yard closed, the toast only after a run or on the first arrival, shrine wording and the 24 x 24 face, prose-role signs |
| rooms | R1 to R4 | none | Hint strip inside its frame, story-face spot panels, the team behind the leader and off furniture, room exits on black |
| story | S1 to S8 | none | Fading place card, narration in the dialogue box, dawn grade with no rain, sprites above the box, the title prompt on the dawn walk, the partner a step behind, the Hollow loads on black, long lines split at sentence ends (same words) |
| housekeeping | H1 to H5 | none | Black clear colour, `project.godot.bak` deleted and ignored, the chain log out of `docs/`, Grok signals, Codex lines |

## Re-shot screens and what they show now

How they were taken: Summer Engine (connected) played Highbank live and took two frames. The lanes' probes, the
rooms check with a window, `rebind_check --shots` and the face-crop sheet were rerun in a window on the merged tree. I
backed up the game's user data folder (3173 files, SHA-256 each) before any of it, then restored it and checked:
every hash matches. The pictures are in
`C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\integ\`
(`shots\`, `win_rooms\`, and the sheets `sheetA_dungeon.png` to `sheetE_rooms.png`).

| ID | The audit's problem | What the re-shot shows | Verdict |
|---|---|---|---|
| L01 | Stairs read as a menu icon | A dark opening with a stone rim and steps going down, on the Mouth, the Warren and the valley floor | Fixed |
| L02 | Grey frame between scenes | The clear colour is black; the story probe's frame during the arch load is black. I did not view a between-scene frame in a window myself | Fixed (setting) |
| L03 | Freezes on the last frame | Warm Highbank arrival 0.43 s. The first arrival is still 4.1 s. The Hollow loads on black, 2.5 s door to first frame | Better, not finished |
| L04 | Pokemon's effectiveness lines | Still there | Open (call P1) |
| L05 | Two floor-card styles | B1F and B3F cards share one layout on black, no MENU button, no rule | Fixed |
| L06 | Pages start mid-sentence | The three evidence lines page at sentence ends. One flood line still opens a page in lower case | Mostly fixed |
| L07 | Room hint text cut by the frame | Both lines inside the frame in Home and Wayline Hall | Fixed |
| L08 | MENU button covers the key strip | All four lines show on keyboard and pad, MENU below them | Fixed |
| L09 | Bindings over the move names | Four cards in one row, each key on its own keycap | Fixed |
| L10 to L13, L15, L16 | Title, Options, How to play, starter cards, soul prologue | Not in this pass (Codex C2 to C9) | Open |
| L14 | Spot panels in small caps | Moss Bed and Chart Table in the dialogue face; the Chart Table's box grows a row | Fixed |
| L17 | Debug-looking corner headings | A RIVERBANK card that fades; nothing on screen at 5 s | Fixed (words wait on P4) |
| L18 | Narration floating over the art | Narration in the dialogue box, no nameplate; compact key strip | Fixed |
| L19 | "Gray morning" over the night rain | Lifted grey morning, no rain streaks | Fixed |
| L20 | Sprites under the dialogue box | Both sprites above the box at every stop | Fixed |
| L21 | Followers on tables, walls, each other | Home and the Hall: the team behind the leader, off the furniture. The arch: 30 px apart. Highbank: asserted by town_walk_check | Fixed |
| L22 | Highbank ground looks like a collage | No black outlines; lane ends wear into dirt; edges frayed. Large flat areas and a straight-edged path south of the Home lane remain | Better, not finished (P8) |
| L23 | Stall on the tree-house roof | The porch stands on the grass, a strip of ground between it and the roof | Fixed |
| L24 | Placeholder sign squares | Unchanged | Open (Codex C14) |
| L25 | Foe and teammate look alike in the log | "Tallowroot went down!" in the foe colour, "Tallowroot grew to Lv 2!" in the team colour | Fixed |
| L26 | "Lost: the bag (0 items)" | The line is gone after an empty-bag faint | Fixed |
| L27 | Bag text cut, font switching | The whole Second Wind line in one font; the selection is the highlight | Fixed |
| L28 | Red X on a sprung trap | Painted snare loop and warp swirl. In my re-shot crop the Silt Pit sat under the message box; the lane's crop shows its mud swirl | Fixed |
| L29 | Black checker block by the leader | It was the stacked rest bubbles; now one set of three soft dots | Fixed |
| L30 | Mouth and Warren look like two art kits | The Mouth is painted now (grain, uneven pools, a dark void edge) but keeps its cooler stone colours, as the plan asked | Better, not finished |
| L31 | Half header, split listening prompt | Whole rows only; "Press a key or a button" on one line | Fixed |
| L32 | Save toast on every load | Highbank shows it on the session's first arrival and after a run. Walk straight into Home and that first toast can still be on screen | Fixed |
| L33 | Partner lines name keys | Unchanged | Open (call P2) |
| LO-07 | 24 x 24 crops off the face | Six of the seven named (Cairnshell, Crawdukes, Riftfin, Troughspine, Vitrecrag, Rampartroot) sit on the face. Warden's face has no clear eye, so its crop is a guess | Preston to look |

**Seen in the re-shots, not on the audit list:** in Highbank the MENU [P] button's top edge overlaps the key strip by
a few pixels, and its right stud reaches the screen edge. Its position (984, 586) did not change in this pass. It is
the next pass's item.

## New player-facing words (proposals, not canon)

- Rebind keys page, key line: "Left / Right  first or second key".
- Rebind keys page, note while listening on a second cell: "<Action>, second key: press the new key or button."
- Reused words, nothing new: setting out on a replay now shows "The run is kept." (the line setting out already
  used) instead of "Highbank remembers."; the place card shows RIVERBANK and THE HOLLOW, the first halves of the old
  headings, until P4.

## Notes for Preston

- **Look at:** the face crops, after the merge:
  `C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\integ\shots\face_crops_after_merge.png`
  (each face with its cut outlined, then the cut). Warden's is the one to judge.
- **Look at, in the game:** the Highbank ground. The lanes judged it in headless pictures without the shader; I saw
  two live frames through Summer Engine.
- The dungeon's bottom bar is new: moves in one row along the bottom left with keycaps, the message box above them,
  fading when idle, and the key list above the MENU button.
- Walking into the Home or the Hall, the leader now stands two tiles inside with the team behind it.
- While the Training Yard is shut, its whole ring is closed, not just the gate tile.
- Hollow Mouth floors take about 0.3 s longer to paint (still under the 3.5 s limit).
- Not seen on screen: a real windowed launch restoring full screen (U2). The check runs stay windowed, as they should.
- `docs/world/hub-layout-2026-10-09/layout_full.png` was redrawn by hub_town_check with the new ground. It will go in
  the next commit unless you drop it.
- I stopped two leftover `find /` searches the lanes had started at 18:09 and 18:12. They were only looking for audit
  pictures, but they had been holding two CPU cores for about an hour and a half.

## Preston's calls (each has a default if unanswered)

| Call | Question | Default |
|---|---|---|
| P1 | Replace "It's super effective!" and "It's not very effective." with "That one landed right where it hurts!" and "It mostly shrugged that off." | Leave as is |
| P2 | Partner keeps in character; the key shows once on a keycap toast | Leave as is |
| P3 | "Back to the title?" everywhere (the pause menu says "Return to the title?") | Leave as is |
| P4 | Place card words "The Riverbank" and "The Hollow's Mouth" | RIVERBANK and THE HOLLOW |
| P5 | "wild" before a foe's name when a teammate shares its species | Colour only |
| P6 | Empty-bag faint says "The bag was empty anyway." | The line is skipped |
| P7 | A small quill or lantern icon instead of "Highbank remembers." on routine saves | Keep the sentence, shown after a run or on a session's first arrival |
| P8 | After this ground pass, ask Codex for transition tiles and full autotiling | Procedural pass only |

## Codex and Grok

- **Codex:** [CODEX_TASKS_2026-10-22.md](../CODEX_TASKS_2026-10-22.md) section 6, lines 1 to 15 from the plan (C1 to
  C15), then three integrator lines: C10 can go now (the clear colour is pure black); faces for Punchybun and
  Sparkjab; a real dawn painting of the waking bank. The GS-01/GS-03 "apply both at launch" is struck, because
  InputPrefs restores full screen now.
- **Grok:** [GROK_TASKS_2026-10-22.md](../GROK_TASKS_2026-10-22.md), "Signals from the factory passes", then "Pass 3
  lines" (G1 to G6, Mouth spawns and REST_TO first). No numbers changed in this pass.

## What remains

- ui_fit's three title-panel points (Codex C2), and the rest of the title work (C3 to C9).
- The first Highbank arrival (4.1 s) and entering the Hollow (2.5 s, now on black) still wait on painting on the main
  thread.
- The Highbank MENU button overlap (above).
- Highbank ground: autotiling (P8, Codex C15). Painted signboards (Codex C14); Claude wires them in the next pass.
- One flood line still opens a page in lower case; two single sentences are longer than two rows. Splitting them
  would mean changing words, which is Preston's call.
- Calls P1 to P8.
