# Grok result, 2026-10-26

Tasks 1 to 10. No kit numbers changed. Claude applies the task 1 house rule, the task 3 learnset cut, the task 4 delete, the task 5 display-name change, the task 7 client-floor rule, the task 8 check cut, the task 9 gameplay generator, and the task 10 retirement unchanged, then reruns `python tools/debug/run_checks.py pilot dungeon_chain lv1 move_table` and `job_board_check`. Tasks 6, 8, and the description half of 10 need no gameplay edit. No commit. Art is on hold until `GROK_ART_TASKS_2026-10-26.md` exists.

## 1. Hollow Mouth for a brand-new player

Three decisions.

1. Spawns stay as they are.
2. On the first visit, B1F and B2F roll no Monster House. After Hollow Mouth is in `beaten`, those floors use the shared 0.3 again. B3F and B4F keep 0.3 on every visit.
3. `REST_TO` stays 0.7.

The shared recipe's `"monster_house": 0.3` stays. Rootbank Warren and The Hollow are unchanged.

### Spawns (unchanged)

`DUNGEONS["mouth"]["spawns"]` stays:

```
{1: [[7, 0], [103, 0]], 2: [[7, 0], [103, 0]], 3: [[7, 0], [10, 0], [103, 0]], 4: [[7, 0], [10, 0], [103, 0]]}
```

| Floor | Who |
|---|---|
| B1F | Listener (7, stage 0), Skimlet (103, stage 0) |
| B2F | Listener, Skimlet |
| B3F | Listener, Troughspine (10, stage 0), Skimlet |
| B4F | Listener, Troughspine, Skimlet |

A level 1 Kithflare has 36 HP: `round(180 * 0.2) = 36`, and level 1 multiplies by `1 + 0.03 * 0`. Kithflare is Ember plus Electric, so a Tide hit is `1.5 * 0.9 = 1.35`. Wild damage then multiplies by `0.6 * 0.7`. The 0.9 to 1.1 roll sits on that product. `round` halves away from zero.

| Move | Who | Product before the roll | After the roll |
|---|---|---|---|
| Echo Tap, 8 | Listener | `8 * 0.6 * 1.35 * 0.7 = 4.536` | 4 or 5 |
| Needle Bite, 11 | Skimlet | `11 * 0.6 * 0.7 = 4.62` (Murk has no chart row) | 4 or 5 |
| Lunge, 12 | Skimlet | `12 * 0.6 * 0.7 = 5.04` | 5 or 6 |
| Spring Spit, 10, range 110 px | Troughspine | `10 * 0.6 * 1.35 * 0.7 = 5.67` | 5 or 6 |

Echo Tap and Needle Bite take 8 or 9 hits to empty 36 HP. Spring Spit takes 6 hits at 6, or 8 hits at 5, and it reaches from 110 px. That is why Troughspine stays off B1F and B2F, the same reason it is off The Hollow's B1F. It joins on B3F, after two floors of the short hits.

### Monster House

| Where | First visit (`"mouth"` not in `beaten`) | After Hollow Mouth has been cleared |
|---|---|---|
| Hollow Mouth B1F and B2F | 0 | shared 0.3 |
| Hollow Mouth B3F and B4F | 0.3 | 0.3 |
| Rootbank Warren, The Hollow | 0.3 | 0.3 |

A house drops at least 4 wild (`MONSTER_HOUSE_WILD`) and at most 7. Four of the B1F hits, at 4 or 5 each, are a different fight from one Listener. Pass 6's live re-shoot had a level 1 team meet 7 Monster House ambushes and go down 4 times before the Mouth was cleared, and one B1F house ended a level 1 team about 12 s after it sprang (frames 5800 to 6081).

The bump-only rate stays the careless floor. Across the published 30-seed reads, clears were 4 with one build and 7 with the other, about 1 in 5 or 1 in 6. `lv1_run` does not rest and does not use moves. This house rule is for the team that walks in, uses what the floor teaches, and should not lose the first room to an ambush. B3F and B4F still roll, so the step up on the same visit is Troughspine plus a house that can still happen.

`beaten` already gains `"mouth"` in `_finish_after_boss` when the Mouth is cleared. A run that went down does not add it, so the retry still has no house on B1F and B2F.

### REST_TO

Stays 0.7. The autopilot rests while the leader is under 70% and nothing awake is near. On the 36 HP leader that is 25 HP or less (`25 / 36 = 0.694`, `26 / 36 = 0.722`), so it stands up at 26. `lv1_run` never rests, so this number does not move that table. The measured losses are the house.

## 2. The Hollow's two spawn rows

The code stays. The pilot story table now matches it.

| Floor | Was | Now |
|---|---|---|
| B1F valley | Listener, Troughspine, Skimlet | Listener, Skimlet |
| B2F ruin | Listener, Troughspine, Ozbender, Valvekin | Ozbender, Valvekin, Troughspine |

`DUNGEONS["hollow"]["spawns"]` is `{1: [[7, 0], [103, 0]], 2: [[104, 0], [105, 0], [10, 0]]}`. The 2026-10-12 reason is under the table in `docs/design/pilot-story-2026-10-10.md`. Troughspine stays off B1F. Seed 99 went down there with one wild downed, and Seep was healing Spring Spit back. B2F has no Listener, so the floor before the Warden is not two Tide shots at once.

## 3. Status moves

The factory sentence says 13. The live learnsets hold more than that. `WAITING` has 16 zero-damage rows, `LEARN` also teaches Glass Guard (Valvekin) and Seep (Archroot, damage 0, heal 6). Stone Cocoon, Root Rampart, Kingstone Lift and Rail Recoil have damage, so they are not in this cut. There is no separate list of 13 in the repo. This pass rules on every zero-damage row that is there.

A zero-damage move with no heal currently plays on its user and the turn passes (`_self_effect`). The fight rules for these moves are the 2026-10-10 job 4 proposal. They are not in the code. Do not promote a `WAITING` row into `LEARN` in this pass. A taught ring would spend the turn.

| Move | Row today | Ruling |
|---|---|---|
| Burrow | `WAITING` Tallowroot, level 3 | Stays. A dig and a trench. |
| Root Wall | `WAITING` Huskward, level 6 | Stays. Three blocking tiles. |
| Silt Dive (`sinkhole`) | `WAITING` Rimefin, level 3 | Stays. Same dig as Burrow. |
| Riptide | `WAITING` Riftfin, on evolve | Stays. One tile that refuses a dash. |
| Glass Guard | `LEARN` Valvekin, level 1. `WAITING` Fusern, level 1 | Stays in both. It is Valvekin's only move. Half damage for 3 turns, planted, when the rule is built. |
| Static Dance | `WAITING` Punchybun, level 1 | Stays. |
| Star Guard | `WAITING` Punchybun, level 3 | Stays. Absorbs 15 for 4 turns when the rule is built. `round(25 * 0.6) = 15`. |
| Deep Brace | `WAITING` Listener, level 3 | Stays. |
| Still Water | `WAITING` Caller, on evolve | Stays. |
| Sail Cover | `WAITING` Canvaswing, level 1 | Stays. Shared signature. Absorbs 12 for 4 turns when the rule is built. `round(20 * 0.6) = 12`. Not a scroll. |
| Downdraft | `WAITING` Canvaswing, level 3 | Stays. |
| Lift | `WAITING` Windcut, on evolve | Stays. This is not Kingstone Lift. |
| Signal Mark | `WAITING` Dustkite, level 1 | Stays. The marked hit is `round(damage * 1.15)`. |
| Decoy Call | `WAITING` Dustkite, level 3 | Stays. One false warning. |
| Play Dead | `WAITING` Mirekit, level 1 | Stays in `WAITING`. It is the boss slice, not a field learn. Do not add it to `LEARN`. |
| Seep | `LEARN` Archroot, on evolve | Stays. Heal 6 already runs. |
| Vantage | `WAITING` Waywhistle, on evolve | Comes out of the learnset. |

Vantage is the only cut. The arena hops onto a rock within 4 tiles (`90 / 24 = 3.75`). `dungeon.gd` places no rock, so the move refuses. Remove the Waywhistle `WAITING` row only. Leave the move id, the arena kit, and the `signature` flag. It stays out of the scroll pool.

## 4. `data/moves/fire_move.tres`

Delete it. Do not rename it.

The file is the old placeholder. `move_name` is "Fire Move", essence Ember, power 40, and it points at `scenes/effects/fire_move_effect.tscn`. No live creature, script, or scene loads that resource. The only other path is a backup under `docs/Codex/Hollowtide/Move work/pre-move-backup/`, and that backup stays.

The ember shot the dungeon plays is already named. In `scripts/arena/arena_prototype.gd` the id `fireball` is "Ember Shot", damage 10, cooldown 0.9, range 95. Kithflare learns it at level 3. Giving the `.tres` a real name would put a second ember move on the old MoveData path, power 40, equipped by nobody.

## 5. Three display names

Two stay. One on-screen string changes. No move id, no damage, no cooldown, no range, and no charge count.

| On screen now | Ruling | Where it lives |
|---|---|---|
| Ember Feint | Stays "Ember Feint" | id `ember_feint`, name field line 255 |
| Lantern Tackle | Becomes "Lantern Relay" | id `lantern_tackle` stays, name field line 265 |
| Verdant Roar | Stays "Verdant Roar" | signature string, not a move id |

Ember Feint is the hop back through the embers it leaves. Damage 3, cooldown 5.0, range 0, two charges (`FEINT_HOP` 55). Kits: Kithflare, Sparkwick, Stormwick. It replaced Flashstep on 2026-10-08. Flashstep stays defined and no current kit uses it. The name matches the action. Claude may strike the words "placeholder name" on the comment at line 252. The name field stays.

Lantern Tackle does not match its words. The header at line 22 calls that name a placeholder. Stormwick's third ability flashes from mark to mark (the marks come from Lantern Volley), strikes for 6, and leaves an arrow of light. It is not a tackle. The family already on screen is Wick Bolt, Lantern Volley, and Stormlantern. "Lantern Relay" is the display string. Damage 6, cooldown 7.0, and range 999.0 stay.

Verdant Roar is the Rampartroot signature key. The roar roots every enemy for `ROAR_ROOT` 1.2 seconds, then the club slam leaves a vine field. It has been the built move since 2026-10-07, and the sibling signature is Furnace Roar. The string is the lookup in `LINES` (line 59), `MOVE_ESSENCE` (line 368), `scripts/arena/arena_signature.gd` (play, cue, and draw), and `tools/debug/arena_rampart_check.gd` (the expected string at line 112). Renaming it would break those keys. Leave the close-up `assets/sprites/creatures/starter_material_detail_2026_10_05/rampartroot_signature_title_material_refined.png`. Claude may strike the words "placeholder name" on the kit comment at line 137.

No new move ids. The Training Yard stays shut. No Godot this task.

## 6. Body gate

Yes. `move_table_check` should fail the suite when a current kit move fails the body gate. That is the rule in `docs/creatures/DESIGN_RULES.md` (Preston, 2026-10-02).

The rule says a creature may use or learn a move only when its body has every part the move lists. Essence is not permission. Step 3 of the test is to reject a learner that is missing a part. A new form is not approved until its body has every part listed on every move it learns. A current kit is a use. The check walks `Arena.KITS` moves and abilities, and `MoveBody.missing` is the missing-part list. The verdict `gate_fails == 0` is that rule. Leave it.

The same check fails when a kit move has no entry in `NEEDS`. That matches step 1: list the parts before the move is approved. Absence is not a pass.

Two sentences in the 2026-10-02 notes are not exemptions for this check.

- Coalcrest's Plate Rake is the one failure that file calls live. It needs a shell, and Coalcrest does not have one. The note says leave that old file alone until the kit is changed. Job 1 already kept Plate Rake out of these arena kits. Coalcrest is retired. Do not add a Plate Rake exemption, and do not equip it.
- `move-body-gate.md` says Strike needs no part and stays legal. That is an empty list, not a missing entry. `missing` already treats an empty `NEEDS` list as no required part. Rimefin's current kit is Needle Bite, Lunge, and Silt Dive, not Strike. Do not add Strike. If a later move truly needs no part, write the empty list in `NEEDS`. A missing key stays a suite failure.

No kit retune in this task. No new part names. The generator still prints "nothing was changed" above the failure table. That sentence is old draft voice. A FAIL still fails the suite. Do not edit the check to turn either verdict into a warning.

Not run. The last published line is the 2026-10-10 result: `0 kit moves fail the gate; ungated []`. Today's count was not remeasured.

## 7. Job Board clients

A client comes from the job's own floor. The team does not have to have met them.

`scripts/town/jobs.gd` says the clients are the wild creatures that live on that floor. The board is up before a new file has walked Rootbank Warren, and the file keeps no met record. A met-only pool would post nothing until a record existed. Do not add one.

`post()` already draws from Warren's `FLOOR_SPAWNS`. `HOLLOW` stays `"first"`. The first pick is that floor's list. The leak is the duplicate swap. `_fresh_client` can return a creature from another floor while `job["floor"]` stays the floor that was rolled. The comment says the pay stays with that roll. That is how Preostmar posts a B1F job.

Warren's stage-0 lists:

| Floor | Ids | Who |
|---|---|---|
| B1F | 9, 8 | Dustkite, Canvaswing |
| B2F | 9, 8, 3 | Dustkite, Canvaswing, Cinderhide |
| B3F | 3, 4, 5 | Cinderhide, Fusern, Preostmar |

Five distinct clients, and the board posts 4, so the once-each swap is on. B1F has two creatures. A third B1F roll has to leave that floor. Preostmar's only row is B3F. Dustkite and Canvaswing are on B1F and B2F. Cinderhide is on B2F and B3F.

When the swap takes a creature from floor `f`, the job's floor becomes `f` before the pay and before a delivery's turn count. The creature and the floor are one fact. A creature is not posted on a floor whose list does not contain it.

Pay for that swapped job is recomputed from the floor it lands on. `FLOOR_PTS` is 10, so the rank points are the kind's base plus `10 * (floor - 1)`.

| Kind | Base | B1F | B2F | B3F |
|---|---|---|---|---|
| Rescue | 30 | 30 | 40 | 50 |
| Lost item | 20 | 20 | 30 | 40 |
| Delivery | 25 | 25 | 35 | 45 |

Quick turns are `QUICK_TURNS_PER_FLOOR * floor`, and that constant is 70, so 70, 140, and 210. Recompute them from the new floor. The kind, the reward, and the count stay on the roll. `POSTED` stays 4. A repeated client stays off the board while five exist. The last-resort repeat, used only when every client is already posted, stays. It does not run at 5 clients and 4 posts.

`_place_jobs` already keeps a job in the Hollow its label names, and on its floor. That stays. A Warren client does not stand on Hollow Mouth or The Hollow. Those two do not get boards in this task. The sentence above `hollow_of` that says the dungeon still places a client in whichever Hollow the team runs is stale. Strike it.

No Godot. `job_board_check` forces its two test jobs onto B1F, so it does not show this swap.

## 8. The Guardian passive

It does not come back. Claude drops the printed step.

Guardian was the Punchybuns aura: an ally within `GUARDIAN_RADIUS` 40 px takes `GUARDIAN_CUT` 0.85. A 20 blow would be `round(20 * 0.85) = 17`. Preston asked for the punching passive on 2026-10-08, and Chain replaced Guardian on Sparkjab and Starward. Both kits set `"passive": "chain"`. Punchybun sets no passive. No current kit sets `"guardian"`, so the cut never runs.

Chain stays. A payout is every `CHAIN_PAYOUT` 8 hits, a shield of `CHAIN_SHIELD` 0.07 of max HP for `CHAIN_SHIELD_SECONDS` 6, stacking to `CHAIN_STACKS` 3, plus `CHAIN_HASTE` 2. Putting the aura back on the same body would soften every blow beside Starward and then let Chain's shield take what remained. The same shape already belongs to Windbreak on Windcut and Galeshear: radius 30, cut 0.9, so a 20 blow is `round(20 * 0.9) = 18`. The protector does not get a second copy of that.

The boss-music id `guardian` is a different word. Leave it.

Drop the printed Guardian step in `tools/debug/arena_protector_check.gd`: the comment, the `_hurt` of 20 on the ally beside Starward, and the print. Star Guard and Counter Jab stay judged. Strike the word Guardian from that file's header and from the Sparkjab kit comment in `scripts/arena/arena_prototype.gd` that still names it. Leave `GUARDIAN_RADIUS`, `GUARDIAN_CUT`, and the damage branch. Do not set any kit's passive to `"guardian"`. Do not retune Chain.

No Godot.

## 9. A separate random source for gameplay

Yes. The dungeon run gets its own generator. Picture rolls stay on Godot's.

The floor plan is already seeded. `Gen.generate` and the stock use `floor_seed + 7`. A nest fills from `floor_seed + 99`. The rain uses its own generator at seed 77. Those stay.

What shares Godot's generator today, and moves:

- The damage roll, `randf_range(0.9, 1.1)` in `damage()`. The range stays.
- Both recruit `randf()` calls.
- The warp's room pick, `randi() % rooms.size()`.
- Every `floor_seed = randi()`: the start when `floor_seed` is 0, the stairs, the clear that starts again at B1F, and the faint.

What stays on Godot's generator: camera shake, and the particle `randf` and `randf_range` calls. A changed frame count, a longer floor card, or a new puff must not draw the next hit or the next floor.

Seed the gameplay generator from `floor_seed` at the start of each floor. Use a new offset. Do not use `+ 7` or `+ 99`, or the layout and the nest will move. Draw the next `floor_seed` from the current floor's gameplay generator, then seed the next floor from that new value. A floor entered at the same seed, with the same actions, takes the same rolls. A check that sets `floor_seed` before the floor builds keeps that seed.

`jobs.gd` already has its own streams. Leave them. The arena stays on Godot's generator. This split is the dungeon run.

The 0.9 to 1.1 width, the recruit rates, the spawns, and `REST_TO` stay. The split changes which of those rolls come up. The next `lv1_run` is a new baseline, not a balance change.

Published tables, from `GROK_TASKS_2026-10-22.md`, with no rule change between them. Pass 5: seeds 1 to 10 at 60 fps cleared 1. Seeds 11 to 30 cleared 4 of 20 on that pass's file (49 downs) and 3 of 20 on the committed file (54 downs). Over 30 seeds, 4 clears against 7. Pass 6's suite cleared 5 of 10 with 20 downs. Seeds 11 to 30 cleared 5, with 48 downs. Read the next table the same way: a rate over the seeds. Task 1's house gate moves it too. Do not retune from that run.

No Godot.

## 10. Creature lines, and the dual-essence print

Two answers. No entry screen, and the print tool retires.

### One line, when a screen exists

No entry screen in this apply. Nothing in `scripts/` reads `CreatureData.description`. The 32 description fields under `data/creatures/` stay workshop notes: dates, paths, "provisional", "default stats", and names still marked pending. Those sentences do not go on a screen.

An entry screen waits until each of those fields is one sentence a person in the Hollow could read. Preston owns the names, so the sentences are not written in this pass. A working name that the file still calls pending stays pending. When the lines are written: one sentence, the approved name, no date, no path, no agent name, and none of the workshop words above.

### `dual_essence_check`

Retire it. It prints `EssenceChart`, and the dungeon does not play that chart.

`scripts/essence_chart.gd` is the old turn-based chart: strong 2.0, weak 0.5, a missing row 1.0. `scripts/arena/arena_prototype.gd` says `ARENA_CHART` replaced it on 2026-10-07. The dungeon multiplies `ARENA_CHART`. Main strong is 1.5 and main weak is 0.75. Second strong is 1.25 and second weak is 0.9.

Tide into Kithflare, Ember plus Electric. The old chart: Tide against Ember is 2.0, and Tide against Electric has no row, so 1.0. The product is 2.0. The live chart: `1.5 * 0.9 = 1.35`. The check prints the 2.0. A pass that reads that print as the dungeon's hit is wrong.

The suite lists it RAN because the script judges nothing. Make it retire the way `arena_scourmaw_check` does: print `RETIRED` and `quit(2)`. Leave `essence_chart.gd` and `battle_screen.gd`. The old battle still calls that chart. Do not point this check at `ARENA_CHART`, and do not turn the print into a verdict.

No Godot.

## Source issues for Claude

- Gate the Hollow Mouth house roll at the `recipe()["monster_house"]` check. Leave the shared `0.3` in `RECIPE` where it is.
- First visit means `dungeon == "mouth"` and `"mouth"` is not in `beaten`, on floors 1 and 2 only. Use `beaten`. Do not add a second flag.
- Spawns and `REST_TO` need no edit.
- The next `lv1_run` table will move. The house rule is a real change, and task 9 moves the gameplay rolls onto their own generator. Read it as a rate over the seeds, and as a new baseline. One seed's miss is not a failed apply. Do not retune from that table.
- `docs/creatures/hollow-wilds-2026-10-10.md` still says the Hollow spawns are B1F Listener, Troughspine, Skimlet and B2F Listener, Troughspine, Ozbender, Valvekin. That sentence is stale. The pilot story is the corrected one. The code was not edited.
- Status moves: delete only Waywhistle's `WAITING` row for Vantage. Do not delete the move, and do not take it off the arena kit. Do not move any other `WAITING` row into `LEARN`. The job 4 fight rules are not part of this apply. Valvekin's only dungeon move is still Glass Guard, and until that rule is built the turn is a ring.
- Delete `data/moves/fire_move.tres` and its `.uid` if one is beside it. Do not rename it, and do not add a move id. Leave `scenes/effects/fire_move_effect.tscn` and the Opal sprites. Nothing else in the live `.gd`, `.tscn`, and `.tres` set loads that scene, so it will sit unused. The docs backup that still names the path stays.
- Display names: in `scripts/arena/arena_prototype.gd`, change only `MOVES["lantern_tackle"]["name"]` from "Lantern Tackle" to "Lantern Relay" (line 265). In that same file, the comments that state the name (lines 22, 123, 1540, 4073) should say Lantern Relay, and should say Lantern Tackle was the placeholder. Strike the words "placeholder name" on the Ember Feint comment (line 252) and the Verdant Roar kit comment (line 137). Do not rename the id `lantern_tackle`, `_update_tackle`, `TACKLE_HOP`, the learnset rows, or any number. Leave the Ember Feint and Verdant Roar strings, the signature keys in `LINES`, `MOVE_ESSENCE`, `arena_signature.gd`, and `arena_rampart_check.gd`, the title card, the docs archives, and the check-script comments.
- Body gate: no edit. Leave both `_ok` lines in `tools/debug/move_table_check.gd`. A current kit move that is missing a part, or that has no `NEEDS` entry, keeps failing the suite. Do not add a Plate Rake exemption. Do not treat a missing `NEEDS` key as legal. An empty list in `NEEDS` is the no-part case, and Strike is not a current kit move.
- Job Board: in `scripts/town/jobs.gd`, when `_fresh_client` takes a creature from floor `f`, set `job["floor"]` to `f` before `pts` and before a delivery's `turns`. Pay is `KINDS[kind]["pts"] + 10 * (floor - 1)`. Quick turns are `70 * floor`. A creature is posted only on a floor whose spawn list contains it. Do not add a met record. Leave `POSTED` at 4, the kind roll, the reward, and the count. Leave `_place_jobs` in `scripts/dungeon/dungeon.gd` as it is. Strike the stale sentence above `hollow_of` that says a client is placed in whichever Hollow the team runs. `HOLLOW` stays `"first"`. Rerun `job_board_check` with the usual four.
- Guardian: drop the printed step in `tools/debug/arena_protector_check.gd` (the comment, the `_hurt` of 20, and the print). Leave the Star Guard and Counter Jab verdicts. Strike the word Guardian from that file's header and from the Sparkjab kit comment in `scripts/arena/arena_prototype.gd`. Leave `GUARDIAN_RADIUS`, `GUARDIAN_CUT`, the damage branch, Chain's numbers, and the boss-music id `guardian`. Do not set any kit's passive to `"guardian"`.
- Gameplay random: in `scripts/dungeon/dungeon.gd`, give the run its own generator, seeded from `floor_seed` at each floor with a new offset. It draws the damage `randf_range(0.9, 1.1)`, both recruit `randf()` calls, the warp room `randi()`, and every `floor_seed = randi()` (start, stairs, clear, faint). Shake and particles stay on Godot's generator. Leave the floor builder at `floor_seed + 7`, the nest fill at `floor_seed + 99`, the rain at seed 77, and `jobs.gd`'s streams. Do not split the arena. A check that sets `floor_seed` keeps that seed. The 0.9 to 1.1 width and the recruit rates stay.
- Creature lines: do not add an entry screen, and do not show `CreatureData.description`. Leave the 32 description fields as they are.
- Dual essence: retire `tools/debug/dual_essence_check.gd`. Print `RETIRED` and `quit(2)`, as `arena_scourmaw_check` does. Leave `scripts/essence_chart.gd` and `scripts/battle_screen.gd`. Do not retarget the print at `ARENA_CHART`.

## Left alone

`WILD_HP` 0.8, `WILD_DMG` 0.7, the house caps (4, 7, 12 tiles, 3 items, 30 light), Rootbank Warren, The Hollow, and the IQ and evolution numbers. Not run: `lv1_run`, `pilot`, `dungeon_chain`, `move_table`. No Godot this pass.
