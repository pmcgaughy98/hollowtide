# Factory pass 9, the pass 8 leftovers and the Tower's look: result (2026-10-27, integrated 2026-10-28)

Plan: [PASS9_PLAN_2026-10-27.md](PASS9_PLAN_2026-10-27.md). Four Claude lanes (tower, town, dungeon, rooms), then one
integrator (Claude). The first integrator stopped when usage ran out; a second one picked its edits up and finished.
Nothing is committed or staged. The pass sits on `bf1a28876`. Before table:
[before-pass9-checks.md](before-pass9-checks.md). After table: [after-pass9-checks.md](after-pass9-checks.md).

## In short

- **The lanes finished 35 of 39 items in full.** In part: W12 (only the road's clouds; the hoist arm and the far crook
  haze had no measured target), D1 (the Warden fits on screen up to 3 tiles back; further needs your call) and R5
  (the Tower's hoist basket, cradles, chute parcels and smoke were not shown to move). Deferred: T9 (the setting-out
  card waiting for the walkway worker needs the town's warm-up reordered).
- **Suite: 112 PASS, 0 FAIL in both modes** (baseline: 107 PASS, 0 FAIL). The 5 extra rows are the lanes' new checks,
  all passing. dual_essence_check is now RETIRED on purpose (D10). The first full run with v2 off had one FAIL,
  dungeon_pace_check; the cause was the check, not the game (below). Fixed, then 2 of 2 lone reruns passed and the v2
  suite passed it.
- **Two lane checks that had never passed were fixed before the suite:** D6's new dungeon_rt_recruit_check (it never
  set `in_battle`; now it passes with the guard in and fails 2 with the guard taken out), and ui_fit_check's shrine
  rows point (its 122 px bound no longer described the page after T3).
- **pilot_chain_check --long passes both ways:** 59 s with v2 off, 88 s with v2 on, and the v2 run printed D8's new
  Tower line.
- **Timing is better than the baseline on every floor row.** Slowest floor 1.19 to 1.37 s (baseline 1.58 to 1.63),
  the valley floors 0.76 to 0.87 s (1.26 to 1.28; D2's cache fix), dungeon ready 1613 to 1744 ms (1728 to 1854).
  Memory at the end is still about 11 MB above pass 8 and still not traced.
- **Re-shot 12 windowed runs, 43 files.** All 12 exited 0. The rooms lane saw exit 139 at the end of every windowed
  probe; with the first integrator's town_room.gd fix in, none did. storage_check, which crashed at exit in every rooms
  lane run, passed in both suites.
- **Your files are unchanged** (hashes in the after table).

## Integration

Step 1, the combined diff of the four lanes' files: no collisions. Every changed file is in its own lane's list. No
file was edited by two lanes.

Edits the first integrator left in the tree, kept and checked by this run:

| File | What | Shown by |
|---|---|---|
| `scripts/town/town_room.gd` | `Music.keep_for(tree, _work_left)` passes the static method, not a lambda (the same exit 139 fix T1 made in hub_town.gd) | storage_check PASS in both suites (it crashed at exit in every rooms lane run); 12 of 12 windowed re-shoot runs exit 0 |
| `scripts/ui/shrine_info.gd` | the count column is as wide as the widest "goal / goal   done" on the page, so every gauge ends at one x (half of this edit was missing and the file did not parse; finished 2026-10-28) | ui_fit_check PASS both modes; G03 and T18 re-shot |
| `tools/debug/ui_fit_check.gd` | the shrine count model expects "n / n   done"; the Home menu point waits up to 300 frames for the pause menu (rooms paint on a worker since R2) | ui_fit_check PASS both modes |
| `tools/debug/run_checks.py` | accepts `--fixed-fps 30` (only 30), so the pass rule's habit no longer errors | both suites ran with it |
| `tools/debug/lv1_run_check.gd` | comment only: the run generator since D3 | lv1_run PASS |

Fixes made by this integrator:

| File | What broke, and why | Fix, and what it showed |
|---|---|---|
| `tools/debug/dungeon_rt_recruit_check.gd` (D6, new) | 3 of 3 FAILED "battle false". The check called `_start_battle()` directly, but the game sets `in_battle` in the leader's step before it defers that call. | The check sets `in_battle` first. Guard in: all ok. Guard taken out for one run (dungeon.gd edited, then copied back; SHA-256 fe1ca242... before and after): 2 FAILED, the minion and the boss. So it tests what it says. |
| `tools/debug/ui_fit_check.gd` | "widest count 166 of 122 px". Since T3 a met count reads "140 / 140   done", and the shrine's count column grows to fit while the gauge gives way, so a fixed 122 px no longer described the layout. | The point bounds the whole row: 180 px name, the count, the 6 px gap and at least 160 px of gauge inside the 717 px detail column. Now "widest count 166 of 359 px", PASS. |
| `tools/debug/dungeon_pace_check.gd` | v2 off suite: "5 problems (pacing 0, pull-backs 5)". Since D3 the run rolls on its own generator, and on seed 4242 the team now goes down on B1F. The floor is built again with `floor_n` still 1, a nest springs, and its five creatures drop in from 70 px above their tiles, unseen. The check remembered distances by place in `ents`, so the old floor's creatures and the drop-ins shared places 5 to 9. Measured with two scratch probes. Not a game fault. | The check keys each creature by its own sprite node. 2 of 2 lone reruns with v2 off: 0 pull-backs (13.6 s, 14.8 s); the v2 suite (run after the fix) passed. Not shown to still catch a planted real pull-back. |

Cross-lane requests and where they went:

| Request | From | Where it went |
|---|---|---|
| ui_fit Home menu wait; shrine count model | town | applied (first integrator) |
| run_checks.py rejects `--fixed-fps 30` | dungeon | applied (first integrator) |
| lv1_run_check comment at line 86 | dungeon | applied (first integrator) |
| storage_check exit crash; remove the T9X debug prints | rooms to town | gone: storage PASS in both suites; `T9X` has 0 matches in `scripts/` |
| cx-09 gap where the far Tower stands; cx-14 refs; cx-12 drawn outline | tower | Codex lines 1, 3, 4 |
| title Quit order; `creature_opening.gd:117` #161f1b against #18172c | town, tower | Codex lines 5, 8 |
| the three stick hand calls can go | rooms | Codex line 14 |
| lv1_run baseline moved by D3 | dungeon | Grok line 1 |
| W4 glow peak or blend; D1 camera; V10 north steps; runtime_rim on two props | tower, dungeon, town | Preston's calls 14 to 17 |
| town_room.gd prepared_parts makes textures on a worker (the town's quit wait has to sync) | town to rooms | not changed; What remains |
| a scene that played a .dialogue file holds it at exit (tower_reveal, flood_bank) | town to story | not changed; on the runner's noise list; What remains |
| party_screen.gd shares STONE_DIM 0.75 (its dimmed rows are a little brighter) | town | FYI only; no change needed |
| timing_check floor build over 3.5 s in a full suite | town to dungeon | timing passed in both suites and in all 5 lone runs; slowest floor 1.44 s |
| road_check first frame flaky at the 250 ms bar | tower | passed in both suites; not changed; What remains |
| B1F Hollow black frames, growth-end frame, arrival frames, Storage door frame | dungeon, rooms, town | seen again in the re-shoot (below); What remains |

## The suite, before and after

Full form, as the baseline: `python tools/debug/run_checks.py --long --arena --fixed-fps 30 --jobs 1`, once with
`HT_HIGHBANK_V2` removed and once with `HT_HIGHBANK_V2=1`, outer APPDATA on a scratch folder.

| | Baseline v2 off | Baseline v2 on | After v2 off | After v2 on |
|---|---|---|---|---|
| PASS | 107 | 107 | 112 (111 plus pace's 2 lone reruns) | 112 |
| FAIL / TIMEOUT / BROKEN | 0 / 0 / 0 | 0 / 0 / 0 | 0 / 0 / 0 after the pace fix (1 FAIL in the first run) | 0 / 0 / 0 |
| WINDOW / RAN / RETIRED / SKIPPED | 6 / 4 / 3 / 1 | 6 / 4 / 3 / 1 | 6 / 3 / 4 / 1 | 6 / 3 / 4 / 1 |
| Rows | 121 | 121 | 126 | 126 |
| Wall time | 26.5 min | 23.6 min | 24.6 min | 21.7 min |

New rows, all PASS both ways: dungeon_rng (D3), dungeon_rt_recruit (D6), road_tower_view (W3), stick_edge (R4),
tower_look (W4 to W7). RAN to RETIRED: dual_essence (D10). No other row changed its result, and no row differs between
the modes except dungeon_pace (fixed between them). The checks rewrote one repo file, as in the baseline:
`docs/world/hollow-slice-2026-10-09/layouts.png`, same bytes. move_table_check wrote the same table as the baseline
(af79fd38...), so no move, power or learnset moved.

### Timing, before and after

timing_check alone after the suites, through the runner: three runs with v2 off, two with v2 on, all TIMING: PASS. The
machine was busier than the baseline's (CPU 56% after the runs; another worker was writing mock images).

| Measure | Pass 8 | Before, v2 off | After, v2 off | Before, v2 on | After, v2 on |
|---|---|---|---|---|---|
| Slowest floor (20 floors) | 1.40 s | 1.58 to 1.63 s | 1.19 to 1.37 s | 1.70, 2.23 s | 1.34, 1.44 s |
| Mean floor | 0.74 s | 0.84, 0.85 s | 0.68 to 0.75 s | 0.86, 0.94 s | 0.73, 0.77 s |
| Valley floors (The Hollow B1F) | 1.13 s | 1.26 to 1.28 s | 0.76 to 0.87 s | 1.33, 1.58 s | 0.82, 0.82 s |
| Dungeon scene ready | 1554 ms | 1728 to 1854 ms | 1613 to 1744 ms | 1780, 1886 ms | 1572, 1677 ms |
| Highbank first arrival (headless) | 4268 ms | 4447 to 4706 ms | 4028 to 4313 ms | 1284, 1304 ms | 1240, 1252 ms |
| Hall prepare / arrival | 274 / 160 ms | 271 to 304 / 184 to 216 ms | 239 to 281 / 167 to 169 ms | 267, 287 / 183, 184 ms | 233, 246 / 160, 163 ms |
| Memory over 20 floors | +14.6 MB | +14.6 MB | +14.5 MB | +14.6 MB | +14.5 MB |
| Memory at the end | 145.6 MB | 156.4 MB | 156.9 MB | 138.7 MB | 139.1 MB |

The full table, with ruin, riverbank, warm arrival, hall_low and home rows, is in the after file. The valley floors
dropped the most, which fits D2: the art cache keeps the sets it has, so building The Hollow no longer pushes the
team's sets out and reads them again. T7's street cache does not show in the headless first arrival, because each
timing run starts with an empty APPDATA.

### Live stalls (windowed, wall clock)

From the re-shoot's own hitch logs (1152x648, fixed 30 fps):

| Place | Pass 9 lane numbers | Re-shoot |
|---|---|---|
| Growth Shrine, first open | 25 to 53 ms worst frame (before: 613 to 710 ms) | 28 ms (v2 off), 26 ms (v2 on); the town9 walk: 23 ms |
| Growth Shrine, second open | 18 to 23 ms | 18 ms, 19 ms |
| Hall door from the street | 36 to 38 ms (before: 501 ms) | 46 ms worst frame, shown 165 ms after the press |
| Job Board, Bluff Lookout | | 18 ms, 19 ms |
| Highbank arrival from Continue (behind the black card) | 709 to 784 ms (after the road) | 604 to 779 ms, in 7 of 7 runs that pressed Continue |
| End of a growth (on black) | 265 ms to 1.2 s | 947 ms, once |
| Storage door from the street | 282 ms in 1 of 5 runs | 330 ms in the town9 walk, next to a screenshot save |
| v2 Tower reveal after E | 255 to 612 ms | 383 ms, in the same frame as a screenshot save |
| Launch flow start (Codex's) | | 668 to 768 ms on its first frame, every run |

## Per lane

**tower (W1 to W12; W12 in part).** W1: at the reveal the two stand one tile further out each side, one row back from
the door pair, both facing the Tower; 0 px of overlap and 72 px apart in both modes. W2: the "down" line waits for the
pan to settle, so no talk box covers the galleries on the way down (0 frames with a box). W3: the road's willows stand
as a pair (x 100 and 190) and the far Tower is clear at all four trail talks (was 3 of 4; crew 29% to 100%); new
road_tower_view_check. W4: the Waiting Lamp's glow steps are amber, still additive, same strengths; measured on its own
it moved from green-grey to neutral-yellow, but in the game at the hold it still reads as a pale cool halo
((150,159,161) on a (98,120,138) sky). Your call 15. W5: the Reach's curl tapers harder and carries two brass lashings
and two knots. W6: the post lantern is redrawn like the route lanterns, with three states (strung hot spot, waiting
glint, quiet crack). W7: each stair root breaks out through a riser under the tread's lip. W8: checked first; cx-12's
candidate draws its own outline, so both rows stay "drawn" and request lines went out. W9: the launch colour in the
registry is #18172c, matching opening_flow.gd. W10: slots.json carries each slot's state order; 6 slots had an order the
sorted export used to lose. W11: refs, slots.json and both art task lists rebuilt at registry ee9c03563b1c (185 slots).
W12: the road's flat cloud lines are torn bands (judged by eye only). Not done: the hoist arm ("keep under row 0" names
no file or measure) and the far crook haze (no measured target, and paint_far sits near the great tree rule).

**town (T1 to T10; T9 deferred).** T1: every way of quitting waits for the town's thread work; 20 of 20 quit runs exit
0. Its first version handed Music a lambda, which crashed at exit (139) after the team left town; Music now holds the
static method. T2: the Growth Shrine read each creature file five times per open; now once and kept, and the warm-up
reads the party's forms on a thread. Worst frame on first open 25 to 53 ms (was 613 to 710). T3: shrine counts stop at
the goal and read "5 / 5   done"; dim text 0.75 for contrast (4.95 against 4.44); one close hint; the action button
shows only when it does something. T4: back-in-town news reacts first and names a recruit (words below). T5: shut doors
are solid; hub_town_check proves it per area, with a negative test. T6: v2 step arrivals moved down 3 rows so nobody
lands under the HUD (street_north and ferry_steps). The top row of the north steps is still under the Next panel; your
call 16. T7: the street cache key covers every file that paints the street; first paint 9.39 s, then read from disk in
0.94 s. T8: the v2 walk scene's own save starts after the parcel theft. T10: the pad chip reads "Menu  [Start]" (look
only). T9 deferred: the walkway worker runs after the three rooms in the warm-up, so making the card wait for it would
hold the card for the rooms too.

**dungeon (D1 to D11; D1 in part).** D2: the art cache was first in, first out, so the Warden and Listener sets pushed
the team's sets out and B3F rebuilt them under the black card; worst black frame 547 to 852 ms (was 1049 to 1495).
D3 (Grok task 9): each run has its own generator, seeded floor_seed + 4513. D4 (Grok task 7): a swapped Job Board
client brings its own floor (0 of 800 on a wrong floor, was 93). D5: hit_heavy plays at -7.5 dB. D6: the real-time
battle end no longer recruits bosses or minions. D7: hollow_check prints a STALL STATE line; the stall did not happen in
8 of 8 runs. D8: pilot_chain checks tower_seen in v2. D9 (Grok task 8): arena_protector_check text only. D10:
dual_essence_check retired. D11: the hollow wilds doc points at the real spawn table. D1 in part: the Warden is 77
world px tall, and from 4 tiles back the leader and the whole Warden cannot share the 216 px view. BOSS_LEAD_LOW 168 to
176 brings 3 tiles back into frame. Your call 14.

**rooms (R1 to R6; R5 in part).** R1: Grubbit's post moved down a row to (17,12), and the talk box picks the top spot
when the bottom one would cover the leader or him (coverage 0.56 to 0.00). R2: rooms paint on a worker behind a black
curtain, and the mail call reads its cast one creature a frame; Hall door 501 to 36 ms, stairs 1751 to 20 ms. R3: the
key strip's words use the full muted colour (worst contrast 4.22 to 5.29). R4: a second stick push the same way was
dropped; UI.track_stick fixes it on every screen (stick_edge_check: 7 FAILED to all ok). R5: last captures; Item Shop,
Training Yard, Bluff Lookout seen; the East Quarter only in the v2 debug scene; v2 street chat not reachable (v2 has no
townsfolk). R6: the work plan points at the live pass files. R5 in part: the Tower's hoist basket, cradles, chute
parcels and smoke run while the camera climbs, so their motion could not be separated from the camera's; only the lamp
and vane flag measured as moving.

## Re-shot screens and what they show now

All in [pass9-reshoot/](pass9-reshoot/), windowed, 1152x648, fixed 30 fps, isolated APPDATA. Read by the integrator.

| Shot | Lane | What it shows |
|---|---|---|
| `T3_shrine_growth_v1.png`, `T3_shrine_growth_v2.png`, `T3_shrine_town9.png`, `sheet_shrine_T3.png` | T2, T3 | Counts read "5 / 5   done" and "60 / 60   done", gauges end at one x, one Esc close hint, "E grow" only where it applies. First open 28 / 26 ms worst frame. |
| `T2_growth_result.png` | T2 | The growth result after the shrine, in the town9 walk. |
| `R1_grubbit_line0.png` to `R1_grubbit_line2.png`, `sheet_rooms_R1_R3.png` | R1, R3 | Grubbit in plain view while he talks; the box at the top; the leader beside him. Key strips in the Hall, Storage and home. |
| `T4_news_none.png`, `T4_news_recruit.png` | T4 | The two news lines exactly as written below. |
| `T5_scrolls_step.png` | T5 | A step toward the shut door at (33,12) leaves the leader at (33,11). |
| `T10_chip_pad.png` | T10 | The chip reads "Menu  [Start]" with a pad last used. |
| `T8_v2_street_arrive.png` | T8 | v2 objective: "Tell Starward at the Wayline Tower". |
| `T6_v2_street_from_rise.png`, `T6_v2_ferry_ward.png` | T6 | Arrivals clear of the HUD. |
| `T6_v2_north_steps.png` | T6 (V10) | Still open: on the top row of the north steps the leader is under the Next panel. Call 16. |
| `T1_arrive_settled.png` | T1 | Back in Highbank, settled. |
| `W_01_reveal_settle.png`, `W_v2_01_reveal_settle.png` | W1 | The two stand apart at the reveal, facing the Tower. |
| `W_02_reveal_mid_pan_down.png`, `W_v2_02...` | W2 | No talk box on the way down. |
| `W_03_reveal_hold_lamp.png`, `W_v2_03...` | W4, W5 | The lamp at the hold: the glow still reads pale and cool. Call 15. The Reach's lashings. |
| `W_04_road_bluff.png` to `W_07_road_crew.png`, `sheet_road_W3_W12.png` | W3, W12 | The far Tower clear between the willows at all four trail talks; torn cloud bands. |
| `D1_warden_dy1.png` to `D1_warden_dy7.png`, `sheet_warden_D1.png` | D1 | The whole Warden in frame from 1 to 3 tiles back; from 4 tiles back his crest is cut (crest at screen y 8, then -64, -136, -208). Call 14. |

## New player-facing words (proposals, not canon)

Only the town lane added words. The integrator added none.

- `scripts/town/hub_town.gd` NEWS_CLEARED, back in town after a clean run (%s is the dungeon):
  "Well, %s's cleared. Everything in the bag made it home."
- `scripts/town/hub_town.gd` NEWS_JOINED, back in town after a run where someone joined (%s the dungeon, then the
  creature): "Well, %s's cleared. The bag made it home, and %s came along too."

Seen in the re-shoot as "Well, Hollow Mouth's cleared. Everything in the bag made it home." and "...The bag made it
home, and Cinderhide came along too." The shrine's "done" mark is not new; it is the Team page's mark from pass 8 U4.

## Notes for Preston

1. The Growth Shrine opens without the freeze now. It used to hold about two thirds of a second; now about 30 ms.
2. Grubbit can be seen while he talks. The talk box moves to the top of the screen when the bottom one would cover him.
3. The Hall door and the stairs no longer freeze. Arriving in Highbank from Continue still holds one frame of 0.6 to
   0.8 s, but behind the black card, so it shows as a slower fade, not a frozen picture.
4. The game quit cleanly in all 12 windowed runs. Partway through the pass, two new quit hooks made the game crash on
   the way out; both are fixed.
5. Fights in a run now roll on the run's own dice (D3). Same seed, same fight. It changed the test team's practice
   numbers (3 of 10 cleared, was 5), not any creature or move number. Grok is asked to look before any balance change.
6. Three things only you can decide, all below: the Warden at range, the Tower lamp's colour, and the top of the v2
   north steps.

## Preston's calls (each has a default if unanswered)

1. Walk Highbank v2 and the Tower blockout (H9-52). Default: HIGHBANK_V2 stays false. Since 2026-10-27 late the Tower
   is being redesigned at cloud height (docs/design/vast-scale-2026-10-27/), so cx-13 to cx-15 and gb-08 wait on that
   design; the cx-12 root-foot redo still holds at any height.
2. Answered (Claude, 2026-10-28): you said yes to the tower key; cx-11-tower-key/review.json records it (2026-10-27).
3. The 37 or more review sheets (cx-01 to cx-09, cx-11 to cx-13): yes, redo or keep. Default: nothing installs;
   placeholders stay.
4. Great tree: partly answered (Claude, 2026-10-28). You chose "not too far from the town", a tree of life at the
   forest's heart whose influence reaches everywhere around town, and said yes to CODEX_ROOT_NOTE.md (now in the cx-12
   to cx-14 notes). Still open: the tree's name (H9-53). The joint Tower and tree design is in
   docs/design/vast-scale-2026-10-27/.
5. Pass 8 calls 1 to 13. Default: each stays on its pass 8 default.
6. Words already in (the road's 8 lines, the reveal's 12 plus one, the A5 toast, the Storm "Skip" hints, the C8 hint
   labels). Default: stay in, open to your veto.
7. New: the two arrival news lines above (T4). Default: stay in, open to your veto.
8. Pad: in town X uses, while menus confirm with A (A9-15). Default: leave as bound.
9. Placeholder build calls 1 to 15 and the Tower look calls. Default: each stays on its default.
10. Is ART-03 (the village re-cut) superseded? Default: held.
11. Codex task 2 portrait crops. Default: leave.
12. Answered in part (Claude, 2026-10-28): gb-01 to gb-07 are made and you said yes to all 29 (review.json,
    2026-10-27), but install_slot.py refuses every one: each fails validate_slot.py's C9 specks (5.9 to 21.7% single
    stray pixels, limit 1%) and most fail C8 (one flat colour over 25% of the cell); two shop pieces are also over the
    24-colour budget. Codex's candidates pass both checks. Choice: a free local clean-up pass, then a new review
    sheet, or send them back to Grok. Default: placeholders stay. gb-08 still waits.
13. Your jobs: delete D:\dev\hollowtide; download the export templates (about 1 GB). Default: both wait; the test
    export stays blocked.
14. New (D1): from 4 or more tiles back, the leader and the whole Warden cannot share the screen. Let the leader sit
    under the message box, zoom out on the boss floor, or accept a partial Warden at range. Default: a partial Warden
    at range (as built: whole up to 3 tiles back).
15. New (W4): the Waiting Lamp's glow is amber but reads pale and cool in the game. Raise its peak above 0.35, give the
    inner step a mix blend, or keep it. Default: keep it as built.
16. New (T6, V10): with v2 on, the top row of the north steps puts the leader under the Next panel. A HUD that tucks
    away near the top edge, or move the exit down a row. Default: as built (v2 is off by default).
17. New (W8): a runtime rim on the wayline post and rise stair props. Default: both stay "drawn" (the candidate draws
    its own outline; the prop builder adds no rim).
18. New (T9): the setting-out card waits for the walkway worker only after the town's warm-up is reordered. Default:
    deferred to a later pass.

## Codex and Grok

Appended as "Pass 9 lines" to [CODEX_TASKS_2026-10-22.md](../CODEX_TASKS_2026-10-22.md) (section 12, 14 lines) and
[GROK_TASKS_2026-10-22.md](../GROK_TASKS_2026-10-22.md) (9 lines).

- **Codex:** cx-14 can start from the new Reach, wayline post and rise stair refs, and its 2026-10-27 delivery predates
  the new Reach; cx-09 keeps a gap for the far Tower (bounds given, check named); cx-12 stays "drawn" and should match
  the new stair roots; the title's Quit should use the pause menu's order; #161f1b in creature_opening.gd against
  #18172c; How to play words (H9-41), Options and save chip (H9-42), wiring only after your yes (H9-45), the foot-row
  file (H9-43), the art queue (H9-44), the title houses and clouds wait on the great tree (H9-08, H9-09), the New Game
  warning stays off (H9-47), the export waits (H9-48), and the three stick hand calls can go.
- **Grok:** tasks 7 to 10 were applied as written and none of your numbers changed; the lv1_run baseline moved with D3
  (read it as a rate); Troughspine needs a stage 1 condition it can earn (H9-49); the open tables from pass 8 (H9-50);
  gb-01 to gb-07 have Preston's yes but fail the installer's C8 and C9 checks (see call 12), and gb-08 waits on the
  new Tower scale (H9-51); D1 moved no number.

## What remains

- T9 (the card and the walkway worker), the hoist arm and the far crook haze (W12), and the Tower's moving parts not
  yet shown to move (R5).
- D2: about 0.5 to 0.85 s of the first render still sits under the black card on the boss stairs; cause not found.
  The first Hollow B1F arrival held two black frames (1590 and 1296 ms) in the dungeon lane's live run.
- The growth-end frame (947 ms here, on black) and the Highbank arrival frame from Continue (604 to 779 ms, behind
  the black card).
- The 282 to 330 ms Storage door frame (once per walk at most, next to a screenshot save each time).
- D7: the Hollow B1F stall never reproduced, so STALL STATE has never printed from a real stall.
- Memory at the end is still about 11 MB above pass 8 and not traced.
- The dungeon_pace fix was not shown to still catch a planted real pull-back.
- The shrine's "60 / 60   done" row leaves only a small gap before its gauge at the widest count.
- The exported game was not checked (an export cannot paint rooms on a worker; waits on the templates).
- A scene that played a .dialogue file holds it at exit; road_check's first frame is flaky at its 250 ms bar (passed
  both suites); town_room.gd's prepared_parts still couples the town's quit wait to a render sync.
- Deferred by the plan: H9-17 (shared answer-list helper), H9-34 and H9-57 (capture column and painted tower checks),
  H9-36 (dungeon set rebuild drift), H9-19 (one 339 ms Warren frame, not seen), the audit gaps it named.
