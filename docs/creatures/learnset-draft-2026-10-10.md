# Learnsets by level and on evolving (Grok, 2026-10-10)

Preston, 2026-10-09: keep evolve-by-level on top of the evolution conditions, and learn moves by level and on evolving. Levels are already in the game (`EVO_LEVEL` 5 and 10). This file is the move half.

**Wired by Claude, 2026-10-10:** `LEARN` and `WAITING` are copied exactly into `scripts/dungeon/dungeon.gd`; rules 5, 7, 8 and 12 are `moves_for`, `_offer` / `_next_offer` (the scroll panel with a DON'T LEARN row), `_moves_on_evolving` and the recruit join. On autopilot a full set forgets slot 1 rather than stopping the run. Check: `tools/debug/dungeon_learn_check.gd`. `WAITING` is not read by anything yet.

Claude drafted the first table on 2026-10-10 from `Arena.KITS`. The decisions below replace that draft. The old level pattern (3, 4 / 7, 8, 9 / 12, 14, 16) and the old "kit drop means the move is gone" column are withdrawn.

## Decisions

Checked against `scripts/dungeon/dungeon.gd` (`EVO_LEVEL`, `exp_to_next`, `MOVES_MAX`), `scripts/arena/arena_prototype.gd` (`KITS`, `MOVES`), and `scripts/moves/move_body.gd` (`can_learn`).

1. **Leave the evolution levels at 5 and 10.** Learn levels sit in the gaps: before 5, between 5 and 10, and after 10. Do not put a learn on 5 or 10. Those levels are already the evolution check.
2. **Stage 1:** Lv 1 basic, Lv 1 first other move, Lv 3 the next. Lv 4 stays empty unless a kit later grows a fourth move.
3. **Stage 2:** the first new move on evolving, then Lv 6, then Lv 8. Not 7, 8, 9. Three learns on three levels in a row piles forget prompts on the doorstep of Lv 10. EXP from 5 to 6 is 60 (about 5 KOs at 12 each). From 6 to 8 is 150. Lv 9 stays quiet before the gate.
4. **Stage 3:** the first new move on evolving, then Lv 12, then Lv 14. Lv 16 is out. EXP from 14 to 16 is 310, and no final has a fourth new move. The draft's own rows already stopped at 14. The prose that said 16 was ahead of the kits.
5. **Keep a move the new body can still perform.** `MoveBody.can_learn(new_form, move)` passes: it stays. It fails: it is removed, and the game says which part is missing. The kit is the learn list, not a wipe. This replaces the line in `evolution-and-signatures.md` that said the old kit is not kept.
6. **One move on the roster fails that test.** Ember Pellet needs a seam. Vitrecrag has no seam. Evolving into Vitrecrag removes Ember Pellet. Every other move an earlier kit "drops" still passes (Rake, Ember Shot, Wick Bolt, Burrow, Root Wall, Ground Spikes, Stone Cocoon, Slab Vortex).
7. **Four moves, same prompt the scrolls already use.** Slot 0 is the current form's basic (`KITS[form].moves[0]`) and is never forgotten. The other three can be forgotten. If the new basic is also the evolve move, that is one event, not two. A full set asks which move to forget. The player may refuse the new move and keep the old set. A refused move is not offered again until a reminder exists. There is no reminder yet.
8. **Catch-up.** Evolving past a level (conditions came late) offers the evolve move, then each due move in list order, each through the cap. The same catch-up runs the first time a waiting move starts working in the dungeon.
9. **Damage 0 moves stay off the live list.** Burrow, Silt Dive, Riptide, Root Wall, Glass Guard, Static Dance, Star Guard, Deep Brace, Still Water, Sail Cover, Downdraft, Lift, Signal Mark, Decoy Call, and Vantage do nothing in the dungeon. `dungeon.gd` already skips `damage <= 0`, and a zero that fell through `use_move` would become 1 damage. That teaches a lie. Their levels are locked in `WAITING`. They join `LEARN` when the dungeon plays the real effect.
10. **Moves with damage stay, even when the dungeon only has the hit.** Ember Feint, Interrupt Call, Stone Cocoon, and Rail Recoil are range 0 in the arena and do a hop, a call, a cocoon, or a vault there. The dungeon clamps reach to at least one tile and deals their damage. If that plays wrong, move those four into `WAITING` at the same levels. Do not invent stand-in effects.
11. **Five finals learn nothing.** Scourmaw, Starward, Quietwater Warden, Galeshear, and Highsignal have the same moves as their stage 2. Their passives are the same too. The stage-3 payoff in the kit notes is the ultimate (Undertow, Starshield, Hush, Gale Shear, High Signal). Ultimates are not taught and none of them run in the dungeon. Do not invent a filler move so the evolution has a lesson. Say the evolution and stop. When an ultimate works in the dungeon, that is the on-evolve learn, and it still respects the four-move prompt. It does not enter the scroll pool.
12. **Wild creatures and new recruits use the floor number as their level** (recruits already join at `floor_n` when the line has no level). Walk from the baby form through this form. Include every live learn at or below that level, plus this form's evolve move because they already are that body. Drop anything the body fails. Pin the basic in slot 0. Keep the most recent four. No forget prompt: there is no player on that creature. A second recruit of a line that already has a level uses the line's level and the moves the line already stored.

EXP behind those levels, from `exp_to_next(lv) = 10 lv + 10`:

| Reach | EXP | Sum |
|---|---|---|
| Lv 1 to 5 | 20+30+40+50 | 140 |
| Lv 5 to 6 | 60 | 60 |
| Lv 6 to 8 | 70+80 | 150 |
| Lv 5 to 10 | 60+70+80+90+100 | 400 |
| Lv 10 to 12 | 110+120 | 230 |
| Lv 12 to 14 | 130+140 | 270 |
| Lv 14 to 16 | 150+160 | 310 |

A KO gives 12, plus 6 for each stage the foe had (`EXP_PER_KO`, `EXP_PER_STAGE`). Lv 5 is about 12 stage-0 KOs. Lv 5 to 10 is about 17 stage-2 KOs or 22 stage-1 KOs. Stage-2 conditions ask for 4 floors and 5 or 6 KOs. **Level 10 is the real second gate. The conditions finish first.** Left as it is on purpose: Preston asked for level, then conditions. If the conditions should bind as hard as the level, the lever is `EVO_LEVEL` stage 2 nearer 7, or a higher `EXP_PER_KO`. Not this file.

Fusern stays short. The hex edge has no move. One live move (Ember Pellet). Glass Guard is waiting. Do not invent the hex move here.

## What a raised creature keeps

| Form | Stage | Learns now | Waiting | Earlier moves |
|---|---|---|---|---|
| Kithflare | 1 | Lv 1: Rake; Lv 1: Ember Feint; Lv 3: Ember Shot | - | - |
| Sparkwick | 2 | on evolving: Pounce (new basic); Lv 6: Wick Bolt; Lv 8: Lantern Volley | - | keeps Rake, Ember Feint, Ember Shot (claw, hottail, throat) |
| Stormwick | 3 | on evolving: Lantern Tackle | - | keeps Wick Bolt (lantern) and the rest Sparkwick kept |
| Tallowroot | 1 | Lv 1: Seed Pod; Lv 1: Root Snare | Lv 3: Burrow | - |
| Huskward | 2 | on evolving: Tail Club | Lv 6: Root Wall | keeps Burrow once it exists (roots) |
| Rampartroot | 3 | on evolving: Root Rampart | - | keeps Root Wall once it exists (roots) |
| Rimefin | 1 | Lv 1: Needle Bite; Lv 1: Lunge | Lv 3: Silt Dive | - |
| Riftfin | 2 | nothing yet | on evolving: Riptide | keeps Needle Bite, Lunge, and Silt Dive once it exists |
| Scourmaw | 3 | nothing | - | same kit as Riftfin |
| Cinderhide | 1 | Lv 1: Cinder Claw; Lv 1: Vent Blast; Lv 3: Rake | - | - |
| Clinkerhide | 2 | on evolving: Crest Ram | - | keeps Rake (claw) |
| Ironvent | 3 | on evolving: Vent Barrage | - | keeps Rake (claw) |
| Fusern | 1 | Lv 1: Ember Pellet | Lv 1: Glass Guard | - |
| Slagglass | 2 | on evolving: Plate Lunge (new basic) | - | keeps Ember Pellet (seam) and Glass Guard once it exists (shell) |
| Vitrecrag | 3 | on evolving: Molten Cannon; Lv 12: Molten Beam | - | **loses Ember Pellet** (no seam). Keeps Plate Lunge and Glass Guard (shell, buttress) |
| Preostmar | 1 | Lv 1: Jade Lance; Lv 1: Ground Spikes; Lv 3: Stone Cocoon | - | - |
| Oathfen | 2 | on evolving: Slab Vortex | - | keeps the Preostmar three (jade) |
| Oxbowarchon | 3 | on evolving: Rail Shot; Lv 12: Kingstone Lift; Lv 14: Rail Recoil | - | keeps Ground Spikes, Stone Cocoon (jade), Slab Vortex (slab). The rail moves have to win a slot |
| Punchybun | 1 | Lv 1: Spark Jab | Lv 1: Static Dance; Lv 3: Star Guard | - |
| Sparkjab | 2 | on evolving: Counter Jab | - | keeps the guards once they exist |
| Starward | 3 | nothing | - | same kit as Sparkjab |
| Cutbank Listener | 1 | Lv 1: Echo Tap; Lv 1: Interrupt Call | Lv 3: Deep Brace | - |
| Bend Caller | 2 | nothing yet | on evolving: Still Water | keeps Echo Tap, Interrupt Call, and Deep Brace once it exists |
| Quietwater Warden | 3 | nothing | - | same kit as Bend Caller |
| Canvaswing | 1 | Lv 1: Shear | Lv 1: Sail Cover; Lv 3: Downdraft | - |
| Windcut | 2 | nothing yet | on evolving: Lift | keeps Shear and the two waiting sails once they exist |
| Galeshear | 3 | nothing | - | same kit as Windcut |
| Dustkite | 1 | Lv 1: Whistle Dart | Lv 1: Signal Mark; Lv 3: Decoy Call | - |
| Waywhistle | 2 | nothing yet | on evolving: Vantage | keeps Whistle Dart and the two waiting calls once they exist |
| Highsignal | 3 | nothing | - | same kit as Waywhistle |

Riftfin, Bend Caller, Windcut, and Waywhistle will evolve with no new dungeon move until their waiting move exists. That is the empty stretch, not a missing row.

## Data

`"evolve"` means learned on evolving into that form. `LEARN` is safe to teach now. `WAITING` is not.

```
const LEARN := {
	"kithflare": [[1, "claw"], [1, "ember_feint"], [3, "fireball"]],
	"sparkwick": [["evolve", "pounce"], [6, "wick_bolt"], [8, "lantern_volley"]],
	"stormwick": [["evolve", "lantern_tackle"]],
	"tallowroot": [[1, "seed"], [1, "root_snare"]],
	"huskward": [["evolve", "club_slam"]],
	"rampartroot": [["evolve", "root_rampart"]],
	"rimefin": [[1, "needle_bite"], [1, "lunge"]],
	"riftfin": [],
	"scourmaw": [],
	"cinderhide": [[1, "cinder_claw"], [1, "vent_blast"], [3, "claw"]],
	"clinkerhide": [["evolve", "crest_ram"]],
	"ironvent": [["evolve", "vent_barrage"]],
	"fusern": [[1, "ember_pellet"]],
	"slagglass": [["evolve", "plate_lunge"]],
	"vitrecrag": [["evolve", "molten_cannon"], [12, "molten_beam"]],
	"preostmar": [[1, "jade_lance"], [1, "ground_spikes"], [3, "stone_cocoon"]],
	"oathfen": [["evolve", "slab_vortex"]],
	"oxbowarchon": [["evolve", "rail_shot"], [12, "kingstone_lift"], [14, "rail_recoil"]],
	"punchybun": [[1, "jab"]],
	"sparkjab": [["evolve", "counter_jab"]],
	"starward": [],
	"listener": [[1, "echo_tap"], [1, "interrupt_call"]],
	"caller": [],
	"warden": [],
	"canvaswing": [[1, "shear"]],
	"windcut": [],
	"galeshear": [],
	"dustkite": [[1, "whistle_dart"]],
	"waywhistle": [],
	"highsignal": []}

const WAITING := {
	"tallowroot": [[3, "burrow"]],
	"huskward": [[6, "root_wall"]],
	"rimefin": [[3, "sinkhole"]],
	"riftfin": [["evolve", "riptide"]],
	"fusern": [[1, "glass_guard"]],
	"punchybun": [[1, "static_dance"], [3, "star_guard"]],
	"listener": [[3, "deep_brace"]],
	"caller": [["evolve", "still_water"]],
	"canvaswing": [[1, "sail_cover"], [3, "downdraft"]],
	"windcut": [["evolve", "lift"]],
	"dustkite": [[1, "signal_mark"], [3, "decoy_call"]],
	"waywhistle": [["evolve", "vantage"]]}
```

Ids match `Arena.KITS` / `Arena.MOVES`. Silt Dive is `sinkhole`. Tail Club is `club_slam`. Ember Shot is `fireball`. Rake is `claw`.

## Not in this pass

- No edit to `dungeon.gd`, kits, or move numbers.
- Ultimates stay off both tables.
- Scrolls stay as they are: a shared damaging move the body allows, four-move cap, basic locked. A scroll can teach a move that is not on that creature's level list.
- `EVO_LEVEL`, the EXP curve, and `LEVEL_HP` stay where they are.
