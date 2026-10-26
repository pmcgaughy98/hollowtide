# Grok result, 2026-10-26

Tasks 1 to 5. No gameplay numbers changed. Claude applies the task 1 house rule, the task 3 learnset cut, the task 4 delete, and the task 5 display-name change unchanged, then reruns `python tools/debug/run_checks.py pilot dungeon_chain lv1 move_table`. No commit. Tasks 6 to 10 are not answered. Art is on hold until `GROK_ART_TASKS_2026-10-26.md` exists.

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

## Source issues for Claude

- Gate the Hollow Mouth house roll at the `recipe()["monster_house"]` check. Leave the shared `0.3` in `RECIPE` where it is.
- First visit means `dungeon == "mouth"` and `"mouth"` is not in `beaten`, on floors 1 and 2 only. Use `beaten`. Do not add a second flag.
- Spawns and `REST_TO` need no edit.
- The next `lv1_run` table will move because the house rule is a real change. Read it as a rate over the seeds. One seed's miss is not a failed apply. Task 9 (a separate gameplay random source) is not answered here, so the shared generator can still reshuffle rows between builds.
- `docs/creatures/hollow-wilds-2026-10-10.md` still says the Hollow spawns are B1F Listener, Troughspine, Skimlet and B2F Listener, Troughspine, Ozbender, Valvekin. That sentence is stale. The pilot story is the corrected one. The code was not edited.
- Status moves: delete only Waywhistle's `WAITING` row for Vantage. Do not delete the move, and do not take it off the arena kit. Do not move any other `WAITING` row into `LEARN`. The job 4 fight rules are not part of this apply. Valvekin's only dungeon move is still Glass Guard, and until that rule is built the turn is a ring.
- Delete `data/moves/fire_move.tres` and its `.uid` if one is beside it. Do not rename it, and do not add a move id. Leave `scenes/effects/fire_move_effect.tscn` and the Opal sprites. Nothing else in the live `.gd`, `.tscn`, and `.tres` set loads that scene, so it will sit unused. The docs backup that still names the path stays.
- Display names: in `scripts/arena/arena_prototype.gd`, change only `MOVES["lantern_tackle"]["name"]` from "Lantern Tackle" to "Lantern Relay" (line 265). In that same file, the comments that state the name (lines 22, 123, 1540, 4073) should say Lantern Relay, and should say Lantern Tackle was the placeholder. Strike the words "placeholder name" on the Ember Feint comment (line 252) and the Verdant Roar kit comment (line 137). Do not rename the id `lantern_tackle`, `_update_tackle`, `TACKLE_HOP`, the learnset rows, or any number. Leave the Ember Feint and Verdant Roar strings, the signature keys in `LINES`, `MOVE_ESSENCE`, `arena_signature.gd`, and `arena_rampart_check.gd`, the title card, the docs archives, and the check-script comments.

## Left alone

`WILD_HP` 0.8, `WILD_DMG` 0.7, the house caps (4, 7, 12 tiles, 3 items, 30 light), Rootbank Warren, The Hollow, and the IQ and evolution numbers. Not run: `lv1_run`, `pilot`, `dungeon_chain`, `move_table`. No Godot this pass.
