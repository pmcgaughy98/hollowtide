# Grok Build result, 2026-10-10

Jobs 1 to 6 are done. The move-table check still reports 0 kit failures, down from 5. No commit. Job 4 is a proposal. Job 5 sets the three floor spawn tables. Job 6 tunes the arena. The 24-6 target is not met. The evolution drafts in `EVO` are kept. The trigger is conditions, not a win. The boss, Monster House and warp drafts are kept.

The check script still writes the sentence "nothing was changed" above an empty failure table. That sentence is the generator's old line. The kits below did change.

## What the check printed

Before, this session, table line only (a Godot game was already open, so the scroll half did not print):

`Table: 5 shared signatures (Rake, Pounce, Cinder Claw, Sail Cover, Vantage); 5 kit moves fail the gate; ungated []`

After, Godot free, full check, no `(WRONG)` and no `SCRIPT ERROR`:

`Table: 5 shared signatures (Rake, Pounce, Cinder Claw, Sail Cover, Vantage); 0 kit moves fail the gate; ungated []`

Scroll half, same party as the 2026-10-09 note (Kithflare and Tallowroot, seed 4242):

| Check | Result |
|---|---|
| Scroll pool | Rake, Pounce, Cinder Claw |
| Panel | KITHFLARE CAN LEARN, TALLOWROOT NO CLAW |
| Refusal and learn | Tallowroot refused. Kithflare learned Cinder Claw. Turns spent 0. |
| Full kit | Forgot Ember Feint, learned Pounce, kept Rake, Ember Shot, and Cinder Claw |
| Next floor | Those four moves stayed |
| Hit | Cinder Claw on a Rimefin for 7 damage, same hit as the 2026-10-09 note |
| Stock | 36 of 172 floor items over 30 floors were scrolls |

Job 2 measured the floor after these kit swaps. A stage-1 pair clears a normal early floor inside 100 to 200 turns. The clocks are in the job 2 section.

## The five failures

| Creature | Move | Was missing | Ruling |
|---|---|---|---|
| Cinderhide | Vent Barrage | channels | Taken off the kit. Needs stay `channels`. Ironvent is the only body with them. |
| Clinkerhide | Vent Barrage | channels | Taken off the kit. Same reason. The crest is not the channel set. |
| Fusern | Molten Beam | chamber, mouth | Taken off the kit. Needs stay `chamber` and `mouth`. |
| Slagglass | Furnace Shard | shelf | Taken off the kit. Needs stay `shelf`. No approved body has a shelf. |
| Slagglass | Molten Beam | chamber, mouth | Taken off the kit. Vitrecrag still has both parts, so Beam stays equipped there. |

Pounce came off Cinderhide as well. The art does not show springing legs, so leaving Pounce on that kit would have been a new failure.

## Parts

Confirmed against `assets/sprites/arena/<form>/se.png`. East and south frames were used where the three-quarter view was ambiguous (Cinderhide, Ironvent, Slagglass). No new part names. No art edits. The orange and gold pixels on Oxbowarchon's aura were left alone, and the back sprite was not opened.

| Line | Ruling |
|---|---|
| Kithflare | Claw, springlegs, hot tail, and throat stand. The lantern is on the tail from Sparkwick on. The old signal body is not this art. |
| Tallowroot | Seed pod and roots stand. Husk and club tail stand from Huskward on. |
| Rimefin | Fin and jaw stand on the remakes, including Scourmaw's jaw. No claw. |
| Cinderhide | Crest on Clinkerhide stands. Cinderhide's back breaks stay `vent`, not a vent row and not channels. Springlegs removed. |
| Fusern | Buttress on Slagglass stands. No shelf, no chamber, no mouth on that dome. Fusern's legs are thin, not buttresses. Vitrecrag's open chamber and pour mouth stand. Slagglass's glowing brick joints are a `seam`. |
| Preostmar | Jade on all three. Slabs from Oathfen on. Rails and the Kingstone on Oxbowarchon only. Oathfen does not show rails, so none were added. |
| Punchybun | Fist, tail, and star stand. Springlegs stand on Sparkjab and Starward. Removed from Punchybun, whose legs are short. |
| Listener | Webbed hands read as paddles. Head and side frills read as gill plates. No jaw added. No code change. |
| Canvaswing | Wing and sail both stand. The sail is the wing membrane. |
| Dustkite | Sail and springlegs stand. They glide. They do not have a flapping wing. No carved whistle is drawn. The part stays as the calling mouth, open from Waywhistle on. |

`vent_blast` now needs `vent`, not `ventrow`. It is a short gout from the back vents Cinderhide already has. The barrage still needs channels.

`glass_spur` was in the move list with no part gate. It now needs `shelf`, like Furnace Shard. It is in no kit. Both shelf moves have no learner.

## Live kits that changed

Dungeon kits keep damaging moves only (`damage > 0`), so Glass Guard never enters the dungeon. That was already true.

| Form | Before | After | Dungeon sees |
|---|---|---|---|
| Cinderhide | Cinder Claw, Vent Barrage, Pounce | Cinder Claw, Vent Blast, Rake | all three |
| Clinkerhide | Cinder Claw, Crest Ram, Vent Barrage, Vent Blast | Cinder Claw, Crest Ram, Vent Blast | all three |
| Fusern | Ember Pellet, Molten Beam, Glass Guard | Ember Pellet, Glass Guard | Ember Pellet only |
| Slagglass | Plate Lunge, Furnace Shard, Molten Beam, Glass Guard | Plate Lunge, Ember Pellet, Glass Guard | Plate Lunge, Ember Pellet |
| Vitrecrag | Plate Lunge, Molten Cannon, Molten Beam, Glass Guard | unchanged | the three damaging moves |

Arena numbers on the swaps, not retuned:

| Move | Damage | Cooldown | Range |
|---|---:|---:|---:|
| Vent Barrage, removed from the first two stages | 12 | 1.2 | 85 |
| Pounce, removed from Cinderhide | 12 | 1.4 | 58 |
| Vent Blast, now on Cinderhide | 11 | 5.0 | 44 |
| Rake, now on Cinderhide | 14 | 1.1 | 24 |
| Cinder Claw, still the basic | 15 | 1.2 | 26 |
| Molten Beam, removed from Fusern and Slagglass, still on Vitrecrag | 12 | 1.8 | 120 |
| Furnace Shard, removed, no learner | 12 | 1.3 | 100 |
| Ember Pellet, now also on Slagglass | 10 | 1.0 | 90 |

Rake and Cinder Claw are almost the same hit (14 at range 24 against 15 at range 26). Rake is there because it is the only other move Cinderhide can legally use, and stage 1 is basic plus 2. It should be replaced when a real vent spit exists. Coal Spit is already that move in `move-body-gate.md` (needs `vent`). It is not in the arena move list, so it was not added.

Fusern is the one live kit that is short of basic plus 2. The only damaging move its body can use is Ember Pellet. The hex edge has no move. I did not retune Furnace Shard onto that edge, and I did not invent a move id.

## Learnsets

Proposals. A scroll can teach a damaging shared signature: Rake, Pounce, or Cinder Claw. Sail Cover and Vantage are shared and are not in the scroll pool, because their damage is 0. An ultimate is never taught. Each birth kit is 4 moves at most.

### Kithflare

| Stage | Starts with | Can learn from a scroll | Gains at this stage |
|---|---|---|---|
| Kithflare | Rake, Ember Feint, Ember Shot | Pounce, Cinder Claw | the birth kit |
| Sparkwick | Pounce, Ember Feint, Wick Bolt, Lantern Volley | Rake, Cinder Claw | lantern moves: Wick Bolt, Lantern Volley |
| Stormwick | Pounce, Ember Feint, Lantern Volley, Lantern Tackle | Rake, Cinder Claw | Lantern Tackle. Stormlantern is never taught. |

### Tallowroot

No shared signature fits this body.

| Stage | Starts with | Gains at this stage |
|---|---|---|
| Tallowroot | Seed Pod, Root Snare, Burrow | the birth kit |
| Huskward | Seed Pod, Tail Club, Root Snare, Root Wall | Tail Club, Root Wall |
| Rampartroot | Seed Pod, Tail Club, Root Snare, Root Rampart | Root Rampart. Verdant Roar is never taught. |

### Rimefin

No shared signature fits this body. Stage 1 has the fin, and Riptide still waits until stage 2.

| Stage | Starts with | Gains at this stage |
|---|---|---|
| Rimefin | Needle Bite, Lunge, Silt Dive | the birth kit |
| Riftfin | Needle Bite, Lunge, Silt Dive, Riptide | Riptide |
| Scourmaw | Needle Bite, Lunge, Silt Dive, Riptide | Undertow is never taught. |

### Cinderhide

None of the three has springing legs, so none can learn Pounce.

| Stage | Starts with | Can learn from a scroll | Gains at this stage |
|---|---|---|---|
| Cinderhide | Cinder Claw, Vent Blast, Rake | already has Rake and Cinder Claw | the birth kit. Preferred later swap: Coal Spit for Rake, not built. |
| Clinkerhide | Cinder Claw, Crest Ram, Vent Blast | Rake | Crest Ram |
| Ironvent | Cinder Claw, Crest Ram, Vent Barrage, Vent Blast | Rake | Vent Barrage. Furnace Roar is never taught. |

### Fusern

No shared signature fits this body. Vitrecrag has no seam, so it does not learn Ember Pellet.

| Stage | Starts with | Gains at this stage |
|---|---|---|
| Fusern | Ember Pellet, Glass Guard | the birth kit. One short. The open slot is a chip off the hex edge. Not built. |
| Slagglass | Plate Lunge, Ember Pellet, Glass Guard | Plate Lunge, from the buttress legs |
| Vitrecrag | Plate Lunge, Molten Cannon, Molten Beam, Glass Guard | Molten Cannon and Molten Beam. Molten Glass is never taught. |

Furnace Shard and Glass Spur stay shelf moves with no learner.

### Preostmar

No shared signature fits this body.

| Stage | Starts with | Gains at this stage |
|---|---|---|
| Preostmar | Jade Lance, Ground Spikes, Stone Cocoon | the birth kit |
| Oathfen | Jade Lance, Ground Spikes, Stone Cocoon, Slab Vortex | Slab Vortex |
| Oxbowarchon | Jade Lance, Rail Shot, Kingstone Lift, Rail Recoil | Rail Shot, Rail Recoil, Kingstone Lift. Kingstone Rail is never taught. |

### Punchybun

Fist is not a claw, so this line does not learn Rake or Cinder Claw.

| Stage | Starts with | Can learn from a scroll | Gains at this stage |
|---|---|---|---|
| Punchybun | Spark Jab, Static Dance, Star Guard | nothing in today's pool | the birth kit |
| Sparkjab | Spark Jab, Static Dance, Star Guard, Counter Jab | Pounce. The kit is already full, so Pounce replaces a move. | Counter Jab, and the springing legs |
| Starward | Spark Jab, Static Dance, Star Guard, Counter Jab | Pounce, same as Sparkjab | Starshield is never taught. |

### Listener

No shared signature fits this body. No part change.

| Stage | Starts with | Gains at this stage |
|---|---|---|
| Listener | Echo Tap, Interrupt Call, Deep Brace | the birth kit |
| Caller | Echo Tap, Interrupt Call, Deep Brace, Still Water | Still Water |
| Warden | Echo Tap, Interrupt Call, Deep Brace, Still Water | Hush is never taught. |

### Canvaswing

| Stage | Starts with | Can learn from a scroll | Gains at this stage |
|---|---|---|---|
| Canvaswing | Shear, Sail Cover, Downdraft | Vantage | the birth kit |
| Windcut | Shear, Sail Cover, Downdraft, Lift | Vantage | Lift |
| Galeshear | Shear, Sail Cover, Downdraft, Lift | Vantage | Gale Shear is never taught. |

Sail Cover and Vantage are not in the scroll pool today. Vantage would need a non-damage scroll, or a birth gain, to be taught. The body can use it.

### Dustkite

| Stage | Starts with | Can learn from a scroll | Gains at this stage |
|---|---|---|---|
| Dustkite | Whistle Dart, Signal Mark, Decoy Call | Pounce, and Sail Cover if a non-damage scroll exists | the birth kit |
| Waywhistle | Whistle Dart, Signal Mark, Decoy Call, Vantage | Pounce, Sail Cover as above | Vantage |
| Highsignal | Whistle Dart, Signal Mark, Decoy Call, Vantage | Pounce, Sail Cover as above | High Signal is never taught. |

## Scrolls and the basic

`MOVES_MAX` stays 4. A full kit is the point where a scroll forces a choice. Do not raise it.

The basic stays unforgettable. The teach code already skips slot 0. The basic is the chip that is always there. Forgetting it would leave a kit of limited moves and no swing.

`SCROLL_SHARE` 0.25 was too high for a signature find. That run put 36 scrolls in 172 items, which is 36/172 = 0.209, and 172/30 = 5.73 items a floor, so about 1.2 scrolls a floor. Job 2 set the constant to 0.10. The new check line is 15 of 159 items over the same 30 floors. 15/159 = 0.094. The recipe places 5 items, and only those can be scrolls, so 5 x 0.10 x 30 = 15 expected. The draw matched. House bait is never a scroll. The item total fell from 172 to 159 because a missed tile is skipped and the rooms are smaller. 159/30 = 5.3 items a floor.

The 2026-10-09 note said 36 of 145. That is an older item total. I did not change how floors stock items.

## Move growth

Not for this game yet. The video note only records that Rescue Team DX dojo text says moves grow with use. It does not give a formula, and the sampled frames did not show the growth. Hollowtide's hit is already the move's number. A use counter would move the 3-to-5-hit target inside one run.

If it is wanted after the first dungeon: +1 damage at 10 uses and +1 at 25, cap +2, and the basic can grow. Not coded.

## Left alone

- Vitrecrag's Molten Beam, Molten Cannon, Plate Lunge, and Glass Guard.
- Coalcrest's Plate Rake in the old battle. It is not in these arena kits.
- Move names, form names, and the `signature` flag.
- Art, sounds, draw code, the picker, and Codex's world and launch files.
- No new creatures, and no new move entered in code.

## Job 2: dungeon numbers

Three constants changed in `scripts/dungeon/dungeon.gd`. Combat scales stayed. A normal early floor does not faint. A Monster House may.

### What changed

| Constant | Was | Now | Why |
|---|---|---|---|
| `RECIPE` cols, rows | 4 x 3, map 56x30 (1,680 tiles), 8 rooms on seed 777 | 3 x 2, map 42x20 (840 tiles) | Half the floor. This is what put a pair inside 100 to 200 turns. Wild count stays 3. Items stay 5. Traps stay 4. `monster_house` stays 0.3. |
| `RECRUIT_RATE` | 0.30 / 0.15 / 0.06 | 0.12 / 0.08 / 0.04 | 3 wilds x 0.30 = 0.90 asks a floor, so the pair stopped being a pair. 3 x 0.12 = 0.36 asks, about one ask every three floors. `TEAM_MAX` stays 4. |
| `SCROLL_SHARE` | 0.25 | 0.10 | Job 1's ruling. A find, not one a floor. |

Two asks on one floor: C(3, 2) x 0.12^2 x 0.88 = 0.038, about 4 floors in 100. Seed 5 and seed 42 both did that and finished as a team of 4.

### Hits, the scales that stayed

`HP_SCALE` 0.2, `DMG_SCALE` 0.6, `WILD_HP` 0.8, `WILD_DMG` 0.7. Stage 0 player HP is round(180 x kit.hp x 0.2): Kithflare 36, Tallowroot 40. A wild is round(that x 0.8): Dustkite 25, Rimefin 29, Cinderhide 29, Cutbank Listener 27.

Rake is 14. At stage 0 that is 14 x 0.6 x a 0.9 to 1.1 roll, then rounded. Against the Dustkite that is 8 or 9. Direct sample, seed 777, 24 rolls, no position bonus: 8 to 9, mean 8.3. 25 / 8.3 = 3.0 hits.

Ambush is x1.5 after that roll. Same sample, 12 sleeping hits, mean 12.7. 12.7 / 8.3 = 1.53, the 1.5 bonus after rounding. 25 - 12.7 leaves about 12, which is two more rakes. An ambush opener is still a 3-hit fight.

Ember into Tide is x0.75, already in the damage roll. Cinder Claw is 15, so 15 x 0.6 x 0.75 x the roll is 6 or 7. The move-table check hit a Rimefin for 7. Rake on that chart is 14 x 0.6 x 0.75 = 6.3 before the roll, so 6 or 7. 29 / 6.5 is about 4 to 5 hits. Both sit in the 3-to-5 band, so the four scales stayed.

### Floor clocks

Clean clocks reset the party to Kithflare plus Tallowroot and the bag to one Reedberry before each seed. The official check does not. It fights once, then autopilots, and `dungeon_run_check` also keeps the Rally Seed faint on the counter because `_build_floor` does not clear `turn` or `faints`.

Official `dungeon_check.gd`, seed 777. No `(WRONG)`.

Before: `Floor: 56x30 tiles, 8 rooms` and `Autopilot: reached B2F after 169 turns (24 s on screen), 0 faints on the way; overlaps 0, creatures in walls 0`. Team at the stairs: Kithflare 36/36, Tallowroot 40/40.

After: `Floor: 42x20 tiles, 3 rooms` and `Autopilot: reached B2F after 148 turns (18 s on screen), 0 faints on the way; overlaps 0, creatures in walls 0`. Same pair, both at full HP.

The bump line went from 17 to 15 and the Ember Feint line from 8 to 9. Those prints are the whole turn, partner included. The scales did not change. The single-hit number is the Rake sample above.

Clean pair, after the shrink:

| Seed | Map | Turns | Faints | Light | House | Team at stairs |
|---|---|---|---|---|---|---|
| 777 | 42x20, 3 rooms | 154 | 0 | 72 | no | the pair |
| 99 | 42x20 | 188 | 0 | 57 | no | the pair |
| 1 | 42x20 | 123 | 0 | 77 | no | the pair |
| 42 | 42x20 | 185 | 0 | 66 | no | pair plus Rimefin and Cinderhide |
| 5 | 42x20, 2 rooms | 57 | 0 | 98 | no | pair plus Cinderhide and Rimefin |
| 4242 | 42x20, 5 rooms | 276 | 1 | 63 | yes | the pair, after the retry |

Pair-only clears are 123, 154, and 188. Inside 100 to 200. Seed 42 recruited two and still took 185 turns. Seed 5 is the short one: the generator's minimum of 2 rooms, and two asks. Six cells at room density 0.7 give P(2 rooms) about 0.07, counting the floors that had 0 or 1 room and were raised to 2. That is a legal floor. I did not cut the rate again and I did not edit the generator.

Seed 4242's 276 counts the failed attempt plus the retry. A leader faint rebuilds the floor, drops recruits, and replaces the bag with one Reedberry. The turn counter keeps going.

### The faint

0 faints is the right difficulty for a normal early floor. The pair won every normal seed above, and the stairs left them at full HP. A leader faint is a failed run.

The handoff's "about once" is the Rally Seed test. That test sets `faints` to 1, then the autopilot starts, and `_build_floor` does not clear it. Official `dungeon_run_check.gd`, seed 99 after that prelude:

Before: `Autopilot: reached B2F after 303 turns, 1 faints, lantern 26, bag { "reedberry": 2, "river_stone": 1, "rally_seed": 1 }`

After: `Autopilot: reached B2F after 220 turns, 1 faints, lantern 58, bag { "reedberry": 1, "river_stone": 1, "rally_seed": 1, "lamp_oil": 1, "scroll:cinder_claw": 1 }`

The 1 faint is the scripted one. The clean seed 99 clock is 188 turns and 0 faints. 220 - 188 = 32 turns of prelude left on the counter. I did not raise `WILD_DMG` or cut rest and regen to force a faint.

A Monster House is the spike. The check still reports `Monster House: entering the room set 5 awake wild creatures`. Seed 4242 fainted there once. `monster_house` stays 0.3. `MONSTER_HOUSE_WILD` stays 4.

### Kept, and the check lines that show them

- Position: `AMBUSH` 1.5 and `PINCER` 1.5. The ambush sample is the 12.7 above. They stack only when a sleeper is also flanked. `SLAM_SHARE` 0.15 and `SLAM_STAGGER` 1 stayed. I did not run `dungeon_position_check.gd`.
- Tactics: follow 4, go 99, guard 2, `FLANK_REACH` 2, `FLANK_WORTH` 0.4. Go 99 covers a 42-wide floor. I did not run `dungeon_tactics_check.gd`.
- Sight 6, regen every 4, `TEAM_MAX` 4, `REST_TO` 0.7. Full light sees 6 tiles (`1 + ceil(100/20)`), which the check printed.
- Lantern: drain every 3, +12 on a KO. Thirty rests went from 100 to 90, which is 30/3 = 10. The old line said 100 to 100 because a KO during those rests refunded 12 and the lantern caps at 100. The KO test is unchanged: 10 to 22. On a 150-turn floor the drain matters. On seed 5's 57 turns the lantern ended at 98, which is that short floor, not a reason to drain faster.
- Items: Reedberry +15 (the check went 16 to 31). Lamp Oil +40. River Stone is a flat 8. The check's "took 18" is the whole turn again, same 18 as before the shrink.
- Snare holds 2 turns after the spring. The new run line: `Snare: sprung and shown: true; it holds for 2 turns after the one it springs on`. The old line did not spring, because the planted step missed on the 56x30 floor. I did not change the snare.
- Traps still request 4. Seed 4242 kept 2, because a house deletes traps inside its room. The same seed's stock was 8 items: the 5 recipe items plus 3 bait, and no scroll in that list. `0.9^5 = 0.59`, so a floor often has no scroll. The autopilot bag on seed 99 held one Cinder Claw scroll.
- Boss scales stayed. The target is an early floor.

`dungeon_recruit_check.gd` uses `recruit_override = 1.0`, so the new rates do not drive it. No `(WRONG)`. Ask, join at half HP (Rimefin 14/29), no turn spent, follow, decline, stairs, faint back to the pair, and a cleared run keeping the recruit all printed as those sentences say. The full-team line printed `went to the hall roster: false` with an empty roster. I did not change `act_recruit` or `TEAM_MAX`. If that attack never opened an ask, the function returns before it writes the roster.

`move_table_check.gd` after the scroll change, no `(WRONG)`: `Table: 5 shared signatures (Rake, Pounce, Cinder Claw, Sail Cover, Vantage); 0 kit moves fail the gate` and `Stock: 15 of 159 floor items over 30 floors were scrolls`. The generated table still says "nothing was changed". That sentence belongs to the generator.

I did not run `dungeon_pace_check.gd`, `dungeon_warn_check.gd`, or `dungeon_boss_check.gd`. The pace check counts hallway turnarounds. It has no numeric pass line, and I did not touch movement.

The temporary sampler `tools/debug/_grok_floor_sample.gd` is deleted.

## Job 3: how a move reaches

`move_reach()` is unchanged. This is the ruling for a later build. Ember Feint is on the stage-1 pair, so changing it now would move the job 2 clocks.

A tile is 24 px. The count is `round(range / 24)`, then clamped. I printed every move through the live function. The current column is that print.

Four shapes exist:

- **front**: the one tile ahead. The user stays. No shove.
- **dash**: run up to n tiles, stop at the first creature, hit it if it is a foe, then shove it one tile. A wall or a body is a slam.
- **line**: a shot along n tiles. It stops at the first foe. The user stays. No shove.
- **burst**: the nearest foe in the facing half, within n tiles, plus any foe on the eight tiles around that foe. n is how far the target may stand. The splash is always one tile. The user stays. No shove.

A melee telegraph forces front 1, so a longer range is thrown away. A mobility flag with no telegraph forces a dash, so a hop or a shot becomes a charge. Dash is the only shape that shoves. That is why the kind is the decision.

Three shapes are not in the function yet. **back n** steps away and does not hit. **self** is the user only. **ring n** is every foe within n tiles of the user, not of a target. A charge telegraph cannot make a dash 1, because that path clamps n to at least 2. Plate Lunge and Tail Club need a per-move reach, not a telegraph edit.

### Changes

These are the moves a kit can equip (`damage > 0`) whose kind is the wrong role.

| Move | Now | Proposed | Reason |
|---|---|---|---|
| Pounce | front 1 | dash 2 | 58/24 = 2.42, so 2. The melee telegraph makes it a second Rake. A springlegs signature closes two tiles and shoves. |
| Plate Lunge | front 1 | dash 1 | 28/24 = 1.17, so 1. The kit is a shell shove. Dash 1 hits the front tile and shoves. The user stays when the target is adjacent. |
| Tail Club | front 1 | dash 1 | 30/24 = 1.25, so 1. The club knocks back. Same shape as Plate Lunge. |
| Vent Blast | front 1 | dash 2 | 44/24 = 1.83, so 2. The gout throws back. The melee telegraph keeps one tile and drops the shove. The cone's side tiles have no shape here. |
| Ember Feint | dash 1 | back 2 | `FEINT_HOP` is 55 px. 55/24 = 2.29, so 2. Range 0 plus mobility is a one-tile charge that hits and shoves. The hop goes away from the foe. The ember on the tile it left is job 4. |
| Lantern Volley | dash 5 | back 2, then line 5 | `VOLLEY_HOP` is 38 px. 38/24 = 1.58, so the hop is 2. The shot is 120/24 = 5. Mobility currently runs it in and shoves. |
| Lantern Tackle | dash 6 | dash 4 | Range 999 is a mark anywhere. 999/24 = 41.6, and the dash clamp cuts that to 6. Marks are not on the grid. Until job 4, it is a charge of 4, the same length as Crest Ram. |
| Rail Recoil | dash 1 | back 3, blast on the tile it left | `RECOIL_HOP` is 70 px. 70/24 = 2.92, so 3. The blast hurts a foe within 32 px of the start. 32/24 = 1.33, so 1 tile. Then it lands. |
| Interrupt Call | front 1 | ring 2 | `CALL_RADIUS` is 55 px. 55/24 = 2.29, so 2. `MOVES` range is 0, so the grid pokes one tile. The call hits every foe in the ring. |
| Slab Vortex | front 1 | ring 1, and those hits shove | `VORTEX_RADIUS` is 36 px. A diagonal neighbor is 33.9 px and the next tile is 48, so the ring is the eight neighbors. The range field says 40 and the melee telegraph forces front 1. |
| Stone Cocoon | front 1 | self, then ring 2 | It pulls tight, then bursts at `COCOON_RADIUS` 44. 44/24 = 1.83, so 2. The 12 damage is that burst. Front 1 spends it on one tile. The wait is job 4. |

### Already the right shape

| Move | Reach | Reason |
|---|---|---|
| Rake | front 1 | 24 px is one tile. |
| Cinder Claw | front 1 | 26/24 = 1.08. |
| Spark Jab | front 1 | 26 px. |
| Needle Bite | front 1 | 30/24 = 1.25. |
| Shear | front 1 | 30 px. |
| Glass Spur | front 1 | 26 px. No kit has it. |
| Ember Shot | line 4 | 95/24 = 3.96. |
| Pressure Jet | line 3 | 80/24 = 3.33. No kit has it. |
| Wick Bolt | line 5 | 115/24 = 4.79. |
| Deep Jet | line 6 | 150/24 = 6.25. No kit has it. |
| Vent Barrage | line 4 | 85/24 = 3.54. |
| Ember Pellet | line 4 | 90/24 = 3.75. |
| Furnace Shard | line 4 | 100/24 = 4.17. No kit has it. |
| Molten Beam | line 5 | 120/24 = 5. |
| Jade Lance | line 5 | 110/24 = 4.58. |
| Echo Tap | line 3 | 80/24 = 3.33. |
| Whistle Dart | line 5 | 130/24 = 5.42. The perch's extra 30 px stays off the grid until Vantage has a rule. |
| Rail Shot | line 8 | 220/24 = 9.17, clamped to 8. The arena slug pierces. The grid line stops at the first foe. Piercing is a later rule, not a longer reach. |
| Crest Ram | dash 4 | 95/24 = 3.96. A charge, so the shove stays. |
| Lunge | dash 5 | 110/24 = 4.58. It shoves one tile forward. The arena fling to behind the user is not this shove. |
| Counter Jab | dash 6 | 140/24 = 5.83. The shove is the punch. Seeking the hurt ally is job 4. |
| Seed Pod | burst 3 | 70/24 = 2.92. |
| Root Snare | burst 4 | 100/24 = 4.17. The hold is job 4. |
| Root Rampart | burst 5 | 110/24 = 4.58. |
| Molten Cannon | burst 6 | 150/24 = 6.25. A lob. |
| Ground Spikes | burst 5 | 120/24 = 5. |
| Kingstone Lift | burst 6 | 150/24 = 6.25. The rock lands on that spot. The grab is job 4. |
| Riptide | burst 5 | 120/24 = 5. Damage 0, so the dungeon does not equip it. |
| Still Water | burst 5 | 120 px. Damage 0. |
| Downdraft | burst 5 | 120 px. Damage 0. |
| Signal Mark | line 7 | 160/24 = 6.67. One foe. Damage 0. It must not splash. |
| Decoy Call | line 7 | 160 px. Damage 0. |

### Damage 0, and the fallback would equip the wrong action

The dungeon skips these because `damage` is 0. The fallback is still wrong, and job 4 should not inherit it.

| Move | Now | Proposed | Reason |
|---|---|---|---|
| Burrow, Dive, Phase, Silt Dive | dash 1 | self | A sink and a reappear. Dive and Phase are on no kit. |
| Vantage | dash 1 | self | A hop onto a rock, not a charge. |
| Glass Guard, Static Dance, Deep Brace | front 1 | self | The user plants or dances. Not a poke. |
| Flashstep | dash 1 | unused | Retired. No kit. A return would be a teleport. |
| Lantern Flash | line 2 | ring 2 | 55/24 = 2.29. No kit. A flash, not a shot. |
| Root Wall | line 6 | burst 6 | 140/24 = 5.83. A wall at a spot, not a beam. |
| Star Guard, Sail Cover | line 5 | an ally within 5 | 120/24 = 5. Not a shot. |
| Lift | dash 6 | an ally within 6 | 140/24 = 5.83. Mobility makes it a charge. It must not shove. |

No check was run. No constant changed, and the reach probe was deleted.

## Job 4: damage-0 abilities on the grid

Proposal only. Claude builds this after Preston approves. No name changes. The `signature` flag stays. Sail Cover and Vantage stay shared signatures, their damage stays 0, and they stay out of the scroll pool. The pool is still Rake, Pounce, and Cinder Claw. No new move id. Fusern's missing move stays missing.

`_make` in `scripts/dungeon/dungeon.gd` keeps the basic, then appends an ability only when `damage > 0` and the list is shorter than 4. That is why some creatures show fewer than four moves. The build drops the damage test and still stops at 4. A taught list is explicit, so a creature that already learned a scroll keeps that list until the build fills a short one.

The code was not edited. No check was run.

Two conversions, used everywhere below. A duration in seconds becomes `maxi(1, ceil(seconds))` turns, the same way dungeon cooldowns already do. A length in pixels becomes `round(px / 24)` tiles. Godot rounds a half away from zero, so 2.5 becomes 3. A stun, a hide, or a hop under one second is the turn already being spent. It does not add a second lost turn. Flat shields scale by `DMG_SCALE` 0.6, because dungeon hits already do.

### Who gains a slot

Stage-1 forms, still capped at 4. Kithflare and Cinderhide already show three damaging moves. Preostmar already shows Stone Cocoon, because its damage is 12. The cocoon's wait is below. It is not a new slot.

| Form | Shows now | Adds, in kit order |
|---|---|---|
| Tallowroot | Seed Pod, Root Snare | Burrow |
| Rimefin | Needle Bite, Lunge | Silt Dive (`sinkhole`) |
| Fusern | Ember Pellet | Glass Guard. Still one short. |
| Punchybun | Spark Jab | Static Dance, Star Guard |
| Listener | Echo Tap, Interrupt Call | Deep Brace |
| Canvaswing | Shear | Sail Cover, Downdraft |
| Dustkite | Whistle Dart | Signal Mark, Decoy Call |

Later forms fill the same way, still to 4. Huskward gains Root Wall. Slagglass and Vitrecrag gain Glass Guard. Sparkjab and Starward gain the dance and the guard and keep Counter Jab. Caller and Warden gain Deep Brace and Still Water. Windcut and Galeshear gain Sail Cover, Downdraft, and Lift. Riftfin and Scourmaw gain Silt Dive and Riptide. Waywhistle and Highsignal gain the mark, the decoy, and Vantage. Slagglass stays one short, same as Fusern.

### Dives

Burrow, cooldown 6. Silt Dive, cooldown 5. The id is `sinkhole`. Both spend the turn. The user leaves its tile and is on the arrival tile when the turn ends. The 0.5 s hide (`SINK_SECONDS`) is that turn. Anyone who acts later in the round sees the arrival tile. There is no second turn of absence.

Arrival is 1 tile past the nearest foe, on the far side. 30/24 = 1.25, so 1. If that tile is blocked, the nearest open neighbor of that foe. A trench is laid on the tiles from the old tile to the new tile for 8 turns (`TRENCH_SECONDS`). A foe on those tiles cannot dash. An ally can. `TRENCH_SLOW` 0.6 does not change a step, because a step is already one tile. `TRENCH_WIDTH` is 9 px, under a tile, so the trench is the path and not a wide smear. Silt Dive's trench is water in the arena. On the grid it is the same trench. No drown.

No damage. Deep Jet's 1.8 is not on any current kit, and the sink comment ties that bonus to Deep Jet. Tallowroot has no Ambush passive, and neither does stage-1 Rimefin, so those two dives only move and lay the trench. Riftfin and Scourmaw have the Ambush passive. Their next damaging hit within 3 turns (`AMBUSH_SECONDS`) is x1.3 once, then the window is spent. If that target is asleep, the existing position tag of 1.5 applies and the window is spent. Do not multiply 1.5 by 1.3.

Dive and Phase share this arm and are on no kit. Dive's cooldown is 6. Phase's is 3. Do not equip them.

### Terrain

These replace the job 3 fallbacks. Root Wall is not a burst 6. Riptide, Still Water, and Downdraft are not a burst 5. The range field is how far the cast may reach. The radius const is the zone.

Riptide, cooldown 6. Cast at a foe within 5 (120/24 = 5). The pool is one tile on that foe. 20/24 = 0.83, so 1. It lasts 3 turns (`ceil(2.5)`). No damage. A foe on it may step off. Dashes are refused on that tile. It does not root. Over its life it drifts 18 px/s for 2.5 s, which is 45 px, and 45/24 = 1.875, so 2. It may step one tile on each of two of its three turns, toward the nearest foe within 4 (90/24 = 3.75). Then it sits. It does not chase past 4.

Root Wall, cooldown 9. Cast at a foe within 6 (140/24 = 5.83). Three tiles on the far side of that foe, for 6 turns: the tile one past it, and the two diagonals beside that tile. The arena draws 9 pillars on a 22 px arc. 22/24 = 0.92, so the arc sits in the next tile, and the arc is about 40 px wide, which is those three tiles. They block steps and line shots. They do not hurt.

Still Water, cooldown 12. Cast at a foe within 5. Ring 2 around that tile (50/24 = 2.08) for 4 turns. Confirmed in `_use_moves`: a fighter inside subtracts cooldown at `STILL_RATE` 0.5. On the grid, a foe standing in the ring counts each turn there as half a turn of cooldown, so a 5-turn cooldown takes 10 turns if they never leave. Allies are not slowed. Stepping off restores a normal tick. No damage.

Downdraft, cooldown 10. Centered on the most hurt ally within 5, or on the user if nobody else is hurt. Ring 2 (45/24 = 1.875) for 5 turns. An enemy line or burst that would pass through those tiles misses. Melee and dashes still land. The user's own team is not grounded.

Ember Feint is already equipped. Damage 3, cooldown 5, charges 2. Job 3's back 2 stays, and the hop does not strike. `FEINT_INVULN` 0.25 is the arrival turn. The three patches sit at 10%, 30%, and 50% of the hop: 5.5, 16.5, and 27.5 px. That is the tile it left. The last patch is 3.5 px into the next tile, which is not a second tile of fire. The landing tile stays clean. If every hop of 2 is blocked, it stays and the ember is on its own tile, and the charge is still spent.

Each ember tile lasts 2 turns (`ceil(1.6)`). A foe that starts a turn on it takes one hit of 3 through the dungeon damage line, with no 0.9 to 1.1 roll and no position tag. Neutral is `round(3 * 0.6)` = 2. The arena also ticks every 0.35 s, about five hurts if you stand on one patch for the whole 1.6 s. The grid does not import those five ticks, and it does not stack patches on one tile. The old arena check stacked four patches for 42. Do not repeat that.

The dungeon stores one cooldown per move and has no charge counter. Claude adds a count of 2. Spending one starts a 5-turn recharge for that charge. The move is ready while either charge is up.

Root Snare is already equipped. Job 3's burst 4 stays, and that hit still lands. Root and cripple start together. `ceil(1.2)` = 2 turns of no step and no dash. `ceil(2.4)` = 3 turns of no dash. On the third turn it can step and cannot dash. `SPIKE_ROOT` 0.8 belongs to Ground Spikes, not this snare.

### Shields and guards

Glass Guard, cooldown 9. Self. Planted for 3 turns (`ceil(2.5)`). Cannot step. Cannot be shoved. Damage taken is half, minimum 1, until a pierce rule exists. Rail Shot's pierce is still the later rule, so today the half applies to every hit.

A hit from an orthogonal neighbor splashes Glassed. The test is 32 px. An orthogonal step is 24 px and a diagonal is 33.9 px, so diagonals are outside it. Glassed lasts 2 turns (`GLASSED_SECONDS` 4 times 0.5). At the start of each of those turns the foe takes `round(2 * 0.6 * ember chart)`, minimum 1. Neutral is 1. Ember into Bloom is `round(1.8)` = 2. The arena ticks that burn every 0.5 s. The grid ticks once a turn. `GLASSED_SET` 0.5 s is inside those 2 turns, not an extra lost turn. `GLASSED_SLOW` 0.65 does not change a step.

Deep Brace, cooldown 10. Self. Planted for 3 turns. Cannot step. Damage taken is half, minimum 1, with the same pierce note. A shove aimed at it does not move it. If that hit had a shove and the attacker is within 2 tiles (48/24 = 2), the attacker is shoved one tile when that tile is open. The arena nudge is 8 px. The grid's smallest shove is one tile. A poke with no shove does not reflect.

Star Guard, cooldown 8. The most hurt ally within 5, or itself if nobody else is hurt. Absorbs 15 (`round(25 * 0.6)`) for 4 turns. The rest of a hit lands. It breaks at 0. `_shield` keeps `max` of the amount left and the new amount, and `max` of the time left and 4 turns. A second cast does not add, and a Sail Cover does not lower a Star Guard that is still up.

Sail Cover, cooldown 8. Same target. Absorbs 12 (`round(20 * 0.6)`) for 4 turns. Same `max` rule. Shared signature. Damage stays 0. Not a scroll. The flag stays.

Stone Cocoon is already equipped. Cooldown 10. Self for 2 turns (`ceil(1.2)`). Damage taken is times 0.4, minimum 1. Cannot be shoved. When the 2 turns end, the job 3 ring-2 burst fires. The burst is a normal hit of the move's 12, foes only, through the dungeon damage line. The 0.4 is the guard while it is inside, not a cut to the burst.

Static Dance, cooldown 7. Self. Allies within 2 tiles, including the user (50/24 = 2.08), for 3 turns (`DANCE_HASTE`) may step two tiles in a straight line when both tiles are open. That is the grid stand-in for `HASTE_SPEED` 1.3. There is no 1.3 tile, and this does not grant a second attack.

The next Spark Jab within 6 turns (`DANCE_WINDOW`) deals x1.5 (`CHARGED_JAB`). `CHARGED_STUN` is 0.4 s, so that stun is the jab's turn, the same ruling as Interrupt Call's 0.5 s. It is not an extra lost turn. The third-punch hook (`HOOK_BONUS` 1.3) stays on Spark Jab's chain. This rule does not add it.

### Marks, the perch, the lift

Signal Mark, cooldown 7. One foe within 7 (160/24 = 6.67). It does not splash. The job 3 line 7 was the wrong shape. The foe is marked for 8 turns. A team hit about to land becomes `round(damage * 1.15)`, after the position tag. A Rake of 8 becomes 9. A Rake of 9 becomes 10. About +1. Do not retune 1.15. Job 6 owns the Spotter trade.

`SIGNAL_DOUBLE` 2.0 is High Signal. It runs only while `signal` is set, and only on the next ability. High Signal is an ultimate and stays untaught. Do not put the x2 on Signal Mark.

While a foe is marked, Lantern Tackle may cross to that foe from any tile, then hit and shove. If several are marked, it crosses to the one aimed, else the nearest. When nothing is marked, job 3's dash 4 stays.

Decoy Call, cooldown 9. One foe within 7. A one-turn false warning of a Whistle Dart. Nothing fires. `DECOY_SECONDS` 0.5 is not a half turn. A foe that spends its move to dodge spends it.

Vantage, cooldown 10. Shared signature. Damage stays 0. Not a scroll. The flag stays. The arena hops onto the nearest rock within 4 tiles (90/24 = 3.75) and does nothing when no rock is in reach. `dungeon.gd` never places a rock. `hollow_floor.gd` sets `rocks_on = false`, and that script is the real-time floor, not this dungeon. On today's floors the move refuses.

When a later floor places a rock within 4, the user hops onto it. A front-1 melee hits the rock instead of the user. Whistle Dart's line goes from 5 to 6, because the perch adds 30 px and `round(30/24)` = 1. Do not recompute 160/24 as 7. That would count the old rounding twice. The perch ends when the user moves or the rock breaks. `PERCH_SECONDS` 6 is how long the AI will hold a perch. It is not a timer on the player.

Lift, cooldown 9. An ally within 6 (140/24 = 5.83). The one in the most trouble, else the most hurt, never itself. That ally moves 3 tiles away from its nearest foe. 60/24 = 2.5, and `round` sends that to 3. If the far tile is blocked, it moves 1 tile (half of 60 is 30 px, 30/24 = 1.25). A root and a snare on that ally clear. The user steps to the tile just past the ally. This is not a shove. The 0.3 s invuln on the ally is the arrival turn. The user lands 12 px past that ally, and 12/24 = 0.5, so one tile. Canvaswing's Lift is not Kingstone Lift.

Counter Jab stays the job 3 dash 6, and it still hits. The dash aims at the ally in trouble, else the most hurt. The punch then hits a foe on a neighbor tile of that ally. 44 px reaches the eight neighbors and stops short of two straight tiles (48 px).

Kingstone Lift stays the job 3 burst. Its damage is 10. With a rock within 3 (80/24 = 3.33) the arena throws the rock. With no rock it seizes the foe. Today's floors have no rocks, so the seize is the case it would hit. Do not build either until a floor has a rock to throw. Rail Shot still stops at the first foe. Pierce stays a later rule. Lantern Flash stays the job 3 ring 2, and it is on no kit.

## Job 5: the first dungeon's three floors

The map, the wild count, the items, the traps, and the house rate stay on the job 2 recipe. A normal floor is still 42 by 20, with 3 wild creatures, 5 items, 4 traps, and a 0.3 house chance. Every wild creature is stage 0. Kithflare and Tallowroot stay the party and do not spawn. The boss floor is unchanged: Scourmaw at stage 2, with two Rimefin minions, on floor 4.

`recipe()` copies `RECIPE` and swaps in `FLOOR_SPAWNS` for the floor number. The Monster House used to read `RECIPE["spawns"]` directly, so a house would have ignored the floor table. It now reads `recipe()`.

| Floor | Rolls | Seen in the probe |
|---|---|---|
| B1F | Dustkite, Canvaswing, Cutbank Listener | all three |
| B2F | Rimefin, Punchybun, Cutbank Listener, Dustkite | all four |
| B3F | Cinderhide, Fusern, Preostmar, Rimefin | all four |

Rimefin on B2F and B3F is the line the boss comes from. Listener and Dustkite also appear on B2F. Canvaswing, Punchybun, Cinderhide, Fusern, and Preostmar appear on one floor each.

Wild HP is `round(round(36 * kit.hp) * 0.8)`. The probe printed the same numbers: Dustkite 25, Canvaswing 26, Listener 27, Punchybun 27, Rimefin 29, Cinderhide 29, Preostmar 29, Fusern 32.

B1F is the soft floor. Gale has no row on the chart, so Dustkite and Canvaswing are neutral. A Rake is `14 * 0.6` = 8.4, and the 0.9 to 1.1 roll rounds to 8 or 9. Dustkite at 25 and Canvaswing at 26 go down in 3 hits. Listener is Tide, and Ember into Tide is 0.75, so a Rake is `14 * 0.6 * 0.75` = 6.3, which rounds to 6 or 7. Listener at 27 is 4 or 5 hits. Their own hits into Kithflare (36 HP, Ember/Electric) stay small. Whistle Dart and Shear are `9 * 0.6 * 0.7` = 3.78, which rounds to 3 or 4. Echo Tap is Tide into Ember 1.5 and Tide into Electric 0.9, product 1.35: `8 * 0.6 * 0.7 * 1.35` = 4.536, which rounds to 4 or 5.

B2F adds the two that can actually press. Rimefin's Needle Bite uses that same 1.35: `11 * 0.6 * 0.7 * 1.35` = 6.237, which rounds to 6 or 7. That is about 5 or 6 bites into the leader. A Rake into Rimefin is the 6 or 7 above, and 29 HP is 4 or 5 hits. Punchybun's Spark Jab is Electric, with no row against the leader: `10 * 0.6 * 0.7` = 4.2, which rounds to 4 or 5.

B3F is where the hard basics live. Cinder Claw into the leader has no chart row: `15 * 0.6 * 0.7` = 6.3, which rounds to 6 or 7. Into Tallowroot (Bloom/Stone, 40 HP) Ember beats Bloom at 1.5 and Stone has no row, so `15 * 0.6 * 1.5 * 0.7` = 9.45, which rounds to 9 or 10. That is 4 or 5 hits into the partner, which is why Cinderhide is not on B1F. Jade Lance is Stone, and Stone into the leader's Electric half is 1.25: `13 * 0.6 * 1.25 * 0.7` = 6.825, which rounds to 6, 7, or 8. Fusern's pellet has no row into the leader: `10 * 0.6 * 0.7` = 4.2, which rounds to 4 or 5. Fusern is here for the 32 HP, not for a heavier hit.

`dungeon_check.gd`, seed 777, same party. Job 2 printed `reached B2F after 148 turns (18 s on screen), 0 faints`. This run printed `reached B2F after 162 turns (20 s on screen), 0 faints on the way; overlaps 0, creatures in walls 0`. The pair arrived at full HP, Kithflare 36/36 and Tallowroot 40/40. The floor line was `42x20 tiles, 3 rooms` and the wilds were Canvaswing, Cutbank Listener, and Dustkite. No `(WRONG)` and no `SCRIPT ERROR`. 162 is inside the 100 to 200 band, so the scales stay.

The species probe rebuilt floors 1 to 3 on seeds 1, 5, 42, 99, 777, and 4242. Every floor was 42 by 20. Every listed species appeared. Seed 4242 still rolls a house. Stepping into it dropped 5 wilds on B1F, all Canvaswing, Cutbank Listener, or Dustkite, and 5 on B3F, all Cinderhide or Rimefin. The house no longer pulls from the old four-species pool.

Left alone: `HP_SCALE`, `DMG_SCALE`, `WILD_HP`, `WILD_DMG`, `wild` 3, items 5, traps 4, `monster_house` 0.3, recruit rates, the boss, and `rest_floor` 0. No stage 2 wilds on these three floors. The job 4 abilities are still unbuilt, so Dustkite, Canvaswing, Punchybun, and Fusern still fight with their damaging moves only.

The floor probe was deleted. No commit. Job 6 is below.

## Job 6: the arena

Arena numbers live in `scripts/arena/arena_prototype.gd`. The sample is headless Godot 4.7.2 with `--fixed-fps 30`. Stage-3 forms, both sides, seed `hash([line_a, line_b, side, k, 61])`. Times below are frames divided by 30. The points clock is slower than that, because hitstop pauses it. `arena_sim.gd`, `arena_combo_check.gd` and `arena_spotter_check.gd` were not run. The old 252 of 270 table is from before Kit Sense. The live before is the 10-match sample in this section.

### Oxbowarchon

Rail Shot was 22 damage, cooldown 6.0 s, telegraph 0.7 s, `far_bonus` 1.3. A far hit was `22 * 1.3` = 28.6, every `6.0 + 0.7` = 6.7 s, which is 4.27 damage a second.

It is now 18 damage, cooldown 8.0 s, telegraph 1.6 s, `far_bonus` 1.15. A far hit is `18 * 1.15` = 20.7, every `8.0 + 1.6` = 9.6 s, which is 2.16 damage a second. The windup is `1.6 / 0.7` = 2.3 times as long. Range stays 220. Jade Lance, Kingstone Lift, Rail Recoil and the Kingstone Rail signature were not retuned.

Job 6, 10 matches, before those cuts:

| Pairing | Result | Avg | Dealt |
|---|---|---|---|
| Oxbowarchon vs Stormwick | 9-1 | 48 s | 265 / 246 |
| vs Rampartroot | 10-0 | 58 s | 446 / 153 |
| vs Scourmaw | 10-0 | 30 s | 306 / 40 |
| vs Ironvent | 6-4 | 45 s | 282 / 165 |
| vs Vitrecrag | 10-0 | 51 s | 412 / 122 |
| vs Starward | 10-0 | 57 s | 409 / 37 |
| vs Quietwater Warden | 10-0 | 45 s | 382 / 26 |
| vs Galeshear | 10-0 | 48 s | 365 / 5 |
| vs Highsignal | 10-0 | 49 s | 372 / 2 |

Same 10 matches after the rail cuts, while a 1v1 clock of 85 s still did not fire:

| Pairing | Result | Avg | Dealt |
|---|---|---|---|
| vs Stormwick | 6-4 | 50 s | 238 / 295 |
| vs Rampartroot | 9-0, 1 draw | 73 s | 446 / 175 |
| vs Scourmaw | 10-0 | 37 s | 303 / 49 |
| vs Ironvent | 5-5 | 54 s | 271 / 263 |
| vs Vitrecrag | 10-0 | 63 s | 421 / 128 |
| vs Starward | 8-0, 2 draws | 70 s | 419 / 52 |
| vs Quietwater Warden | 10-0 | 60 s | 395 / 48 |
| vs Galeshear | 10-0 | 53 s | 372 / 5 |
| vs Highsignal | 5-0, 5 draws | 79 s | 395 / 18 |

24 wins in 30 is 8 wins in 10. Stormwick 6-4 and Ironvent 5-5 are inside that rate on this 10-match screen. They were not rerun at 15 a side. Scourmaw, Vitrecrag, Quietwater Warden and Galeshear stayed 10-0 with no draws, so the later clock cannot change those four rows.

One Scourmaw fight, the first seed, ended at 31.7 s of clock with Scourmaw on 0 HP. Oxbowarchon logged Rail Shot 6, Jade Lance 9, Kingstone Lift 2 and Rail Recoil 3. Scourmaw logged Silt Dive 4, Lunge 4, Riptide 4 and Needle Bite 1, and dealt 42. One Vitrecrag fight ended at 39.7 s of clock. Oxbowarchon logged Rail Shot 5, Jade Lance 9, Kingstone Lift 3 and Rail Recoil 2. Vitrecrag logged Molten Cannon 8 and Molten Beam 11, and dealt 71. Both clocks are under 60 s, so the points rule never gets a vote. Scourmaw and Vitrecrag lose because the shots do not land. Oxbowarchon dashes clear and Rail Recoil leaves. A further rail cut was not made.

The three Oxbow rows that still had draws were rerun after the 60 s clock, same 10 matches:

| Pairing | Result | Avg | Dealt |
|---|---|---|---|
| vs Rampartroot | 10-0, 4 on points | 69 s | 426 / 180 |
| vs Starward | 10-0, 5 on points | 63 s | 375 / 48 |
| vs Highsignal | 10-0, 8 on points | 66 s | 333 / 19 |

Those draws became Oxbowarchon wins on points. The 24-6 target is not met.

### Supports that stall

Option one. Jab, Echo Tap and Shear stay at their old damage. No signature guard was added. Team fights still end at `MATCH_SECONDS` 120. A 1v1 that is still going ends at `DUEL_SECONDS` 60, on the existing points rule: the side with more of its HP left wins, and a tie goes to team 0.

90 s and then 85 s never fired. One Quietwater Warden vs Galeshear match, the first seed, team size 1, two fighters: frame 2550 was clock 65.67, and frame 2700 ended at clock 69.13 with no winner. Hitstop pauses the clock, so the sim's 90 s of frames is about 69 s of clock in that fight. 60 lands inside it.

Job 6, before, 10 matches, draws at the frame cap:

| Pairing | Result | Avg | Dealt |
|---|---|---|---|
| Starward vs Quietwater Warden | 3-0, 7 draws | 87 s | 361 / 94 |
| Starward vs Galeshear | 3-0, 7 draws | 88 s | 357 / 88 |
| Starward vs Highsignal | 0-0, 10 draws | 90 s | 171 / 225 |
| Quietwater Warden vs Galeshear | 0-0, 10 draws | 90 s | 202 / 173 |
| Quietwater Warden vs Highsignal | 0-0, 10 draws | 90 s | 202 / 268 |
| Galeshear vs Highsignal | 0-0, 10 draws | 90 s | 56 / 273 |

After the 60 s clock, 30 matches, 15 a side, 0 draws:

| Pairing | Result | Avg | Dealt | Follow-ups |
|---|---|---|---|---|
| Starward vs Quietwater Warden | 30-0, 23 on points | 75 s | 314 / 78 | 119 |
| Starward vs Galeshear | 30-0, 25 on points | 75 s | 304 / 70 | 4 |
| Starward vs Highsignal | 18-12, 30 on points | 73 s | 154 / 170 | 10 |
| Quietwater Warden vs Galeshear | 22-8, 30 on points | 78 s | 188 / 143 | 122 |
| Quietwater Warden vs Highsignal | 11-19, 30 on points | 74 s | 158 / 225 | 80 |
| Galeshear vs Highsignal | 1-29, 30 on points | 70 s | 51 / 213 | 18 |

Every stalled pairing printed a winner.

### Follow-ups

`FOLLOW_WINDOW` went from 0.9 to 1.6. The desire multiplier on a ready basic during that window went from 1.4 to 2.0. A basic scores 0.4, so that is 0.56 before and 0.80 after, still capped at 1. `FOLLOW_MORE` stays 1.3. `FOLLOW_REFUND` stays 0.5.

The window was also running out during a signature freeze, which had already stopped attacks. It now pauses for that freeze, the same way the clock does. Hitstop already skipped the decrement.

One Stormwick vs Ironvent fight, seed 13, 60 s of frames, measured before that pause: 10 windows opened and 0 follow-up lines printed. The first Stormwick window opened at 104 px. Pounce reaches 58 and is wanted only from inside that reach, past 8 px, so the basic scored 0 there. A later window opened at 25 px, in range, and the AI picked Pounce at desire 1.00. Ironvent used Beads, and no follow-up line printed. That seed was not rerun after the pause.

The support table above is after the pause, and those rows did print follow-up lines. Oxbowarchon vs Rampartroot logged 40 in 10 matches, vs Starward 49, vs Highsignal 1. This session has no matching count from the old 0.9 and 1.4 numbers. The published "0 in 60 s" was not remeasured on those old numbers.

### The Spotter

`whistle_dart` stays at 9 damage. `MARK_BONUS` stays 1.15, so the job 4 line still holds: a Rake of 8 becomes 9, and a Rake of 9 becomes 10.

Job 6, Stormwick vs Highsignal, 30 matches: Stormwick 29-1, 1 of those on points, average 44 s, dealt 345 / 55. Highsignal loses, and it deals 55 a fight. Against Oxbowarchon, the 10-match rerun above, Highsignal dealt 19 and won 0. The dart was left at 9. The same move is Dustkite's basic on B1F, and Highsignal already takes the Galeshear points fights 29-1.

### Left alone, and what was not run

Left alone: Jade Lance, Kingstone Lift, Rail Recoil, Kingstone Rail, the four support basics, both far bonuses on the Dustkite line, dungeon scales, `FLOOR_SPAWNS`, the move table, and reach. No new moves. The other 29 of the 45 pairings were not resimmed. The duel probe was deleted. No commit.

## Evolution conditions

Preston chose Digimon option A on 2026-10-09. The system was already in `EVO`. The old creature note said the creature that won the battle evolves. That note now says a win evolves no one. The numbers below are the drafts, kept after the check. `docs/creatures/evolution-and-signatures.md` has the same table.

A stage-0 teammate's HP is `round(180 * 0.2 * kit.hp)`. Tallowroot's 1.1 gives `round(39.6)` = 40. Its "took" bar of 60 is 1.5 of those bars. Stage 2 asks for 4 floors on a fresh record, so a final form does not fit in the three-floor dungeon.

`dungeon_evolve_check.gd`, no `(WRONG)`. The headless run has no viewport texture, so the check's still was aborting on `save_png`. It now skips that still when `DisplayServer` is headless, and the numbers still print.

Scripted party, Kithflare and Tallowroot, seed 4242:

`Counters: Kithflare's knockouts 0 -> 1, flank hits 0 -> 1, ambushes 0 -> 1`

`Counters: Tallowroot took 5, its 'took' went 0 -> 5`

`Progress short of one floor: 0.00, ready false`

`After one floor: Kithflare on B2F, party [[0, 0], [1, 0]], evolutions 0`

`Evolved: log [["Kithflare", "Sparkwick"]]; leader now Sparkwick (stage 2), moves ["pounce", "ember_feint", "wick_bolt", "lantern_volley"] (Sparkwick's kit starts ["pounce"]); HP 20/36 before, 45/45 after; banner 'KITHFLARE EVOLVED!' / 'into Sparkwick'`

`Tallowroot did not evolve: true (progress 0.00)`

`After a faint: party [[0, 1], [1, 0]], leader Sparkwick`

`A final: progress 0.00, ready false`

The 20 HP did not carry. Sparkwick arrived at 45/45, which is `180 * 1.25 * 0.2` = 45. Every floor still fully heals. That heal was left as it is.

Autopilot, two runs each:

`Autopilot seed 99, 2 runs (2 cleared, 0 fainted), 1040 turns: evolutions [["Kithflare", "Sparkwick"]]; sparkwick 0:1 kos 8 floors 3 way 4 (50%); tallowroot 1:0 kos 15 floors 6 way 38 (63%); dustkite 9:0 kos 4 floors 4 way 0 (0%); punchybun 6:0 kos 0 floors 4 way 20 (0%)`

`Autopilot seed 7, 2 runs (1 cleared, 1 fainted), 922 turns: evolutions [["Tallowroot", "Huskward"]]; kithflare 0:0 kos 7 floors 5 way 0 (0%); huskward 1:1 kos 0 floors 0 way 0 (0%); canvaswing 8:0 kos 1 floors 2 way 32 (50%)`

Seed 99's Tallowroot had the knockouts and the floors and was short on damage taken, 38 of 60. Seed 7's Tallowroot did evolve, and the new Huskward record started at zero. Seed 7's Kithflare had 7 knockouts and 5 floors and 0 flank hits, so the bar stayed empty. Dustkite had 4 knockouts, 4 floors, and 0 flank hits. The flank way is doing the work the note describes: autopilot rarely sets a pincer, and a player who does evolves those lines sooner. Punchybun had 0 knockouts, so it stayed put. Rimefin's ambush count and Cinderhide's slam count were not in these parties.

No `EVO` number was changed. No commit.

## Teammate IQ (proposal, not built)

Preston asked for a partner IQ list. This is the list. Nothing here is in code. Claude builds a skill only after Preston approves it.

A skill is one extra choice inside the partner's existing turn. The partner already follows, goes after foes, or guards, on T, and it already walks up to 2 tiles toward a pincer while the foe is above 40% health. These skills only add a step that system does not take. No new move, no new creature, and no names taken from another game.

The partner learns a skill when its growth record crosses the number below. The skill stays on that party slot after a faint and after it evolves. The growth counters still reset for the new stage. Two of the same species still share one growth record, so they cross a line together, and each slot keeps what it had already learned. There is no equip screen in this draft. A partner uses every skill it has. Most will have the two floor skills plus whichever way they actually practice.

If two skills want the same turn, use this order: step off a warned tile, refuse a seen trap, pass a berry, fall in, go for a sleeper, break a wind-up, then the flank and the stone, and pick up an item only when no foe is awake inside the tactic leash.

| Skill | What the partner does on its turn | Learned when | Number |
|---|---|---|---|
| Sidestep | Does not end the step on a warned tile if any other step toward its goal is open. | 2 floors | The tile `_warned` already marks. |
| Seen Trap | Does not step onto a trap it has already seen if another step exists. A hidden trap stays hidden. | 3 floors | Seen traps only. The leader is still the one who sets a trap off. |
| Pass the Berry | If the leader is under 40% health and the bag has a Reedberry, the partner spends its turn to feed the leader. The leader does not lose a turn. | 20 damage taken | Heal stays 15. The 40% is the same line the autopilot already uses for itself. |
| Fall In | Steps back toward the leader instead of chasing. Does nothing while the order is GO AFTER FOES. | 50 damage taken | Starts when the partner itself is under half health. 50 is the lower of the two "took" evolution bars. |
| Sleeper First | Goes to the nearest sleeping foe inside its current leash, and hits that one before an awake foe. | 2 ambush hits | Leash stays the order's own: 4 on follow, 2 on guard, anywhere on go. 2 ambushes is Rimefin's first evolution bar. |
| Break the Gather | If a foe in reach is winding up, and the tile past it is a wall or a body, and the partner has a dash move, it uses the dash. | 2 slams | The slam stays 15% of max HP, 1 turn lost, and the gathered move breaks. 2 slams is Cinderhide's first bar. |
| Stay Wide | Keeps walking to the far side after the foe drops under 40% health. | 4 flank hits | The walk is still at most 2 tiles. 4 flanks is Kithflare's and Dustkite's first bar. |
| Long Flank | Will walk farther to reach that far side. | 8 flank hits | 4 tiles instead of 2. 8 is the second-stage flank bar. |
| Stone Line | Throws a River Stone when none of its own moves reach and a foe stands on a straight line from it. | 3 knockouts | Damage stays 8. 3 knockouts is the runner's first bar. |
| Bag the Find | With no awake foe inside the leash, steps up to 2 tiles to a floor item and picks it up into the same bag. | 4 floors | 2 tiles. Pickup today checks the leader's tile only, so this one also has to count the partner's tile. |

Left alone on purpose: Lamp Oil, the Rally Seed, and scrolls. The lantern and a faint are the leader's, and a scroll already opens a panel. No health is carried between floors in this proposal. No commit.

## Boss floor, Monster House, warp cap

These drafts stay. `dungeon_boss_check.gd` printed no `(WRONG)` and no `SCRIPT ERROR`. The headless run skips the stills, same as the evolution check, because the viewport has no texture.

Scourmaw's stage-2 body before the wild cut is `round(180 * 1.5 * 1.15 * 0.2)` = `round(62.1)` = 62. A plain wild one is `round(62 * 0.8)` = 50. The boss is `round(62 * 0.8 * 3.0)` = `round(148.8)` = 149. `BOSS_DMG` 0.9 replaces the wild 0.7.

A Needle Bite from that boss into Kithflare, before the 0.9 to 1.1 roll: `11 * 1.4 * 0.6 * 1.35 * 0.9` = 11.23, so the roll is 10 to 12. Kithflare has 36 HP, which is 3 bites at the high roll and 4 at the low one. The starting Reedberry adds 15, so 51, which is 4 or 5 bites. A pincer on that bite is another 1.5. A Rake before the chart is `14 * 0.6` = 8.4, so 8 or 9, and a pincer Rake is 12 or 14. The 149 HP boss is about 11 to 12 of those hits. Two partners connecting is about 6 turns. The leader lives about 4 bites. The pair wins that race only if the hits land and the boss is not also pincering them.

The check:

`Monster House: seed 3, room (8, 6), items lying in it before it springs: 5`

`Sprung: 4 dropped in (4 started above their tile, 4 landed); banner 'MONSTER HOUSE!'`

`Cleared: lantern 50 -> 80; banner 'CLEARED!'; cleared flag true`

`Rest floor: kind rest, rooms 1, wild 0, items 0, traps 0, leader 36/36, banner 'REST'`

`Boss floor B4F: kind boss, 1 room, items 0, traps 0, other wild 0; Scourmaw with 149 HP (a plain wild one has 50), 2 helpers`

`Scene: 3 lines, first 'Tallowroot: The air is heavy down here... something is waiting for us.'; boss asleep during it true`

`After the scene: banner 'SCOURMAW' / 'BOSS', boss awake true, helpers awake 2`

`Stairs while it stands: floor 4 -> 4 (sealed)`

`Charge into it while it gathers: moved false, wind-up broken true, staggered 0`

`Charge into it otherwise: moved false`

`Beaten: banner 'VICTORY!'; asked to join false`

`Then: cleared 0 -> 1, back on floor 1`

`Autopilot run seed 99: cleared 0, faints 0, 4457 turns, 600 s on screen; met the boss false, fought it 0 s; team [[0, 0], [1, 0]]`

`Autopilot run seed 7: cleared 0, faints 1, 429 turns, 58 s on screen; met the boss true, fought it 12 s; team [[0, 0], [1, 0]]`

`Autopilot run seed 31337: cleared 1, faints 0, 636 turns, 97 s on screen; met the boss true, fought it 12 s; team [[0, 0], [1, 0], [2, 0]]`

The room is 8 by 6, 48 tiles. `48 / 12` is 4, which is the minimum drop, and 4 dropped. The lantern went 50 to 80, the 30 from `MONSTER_HOUSE_LIGHT`. The 5 items in the room are the floor's own items plus the bait, so `MONSTER_HOUSE_ITEMS` stays 3. The two helpers and the sealed stairs behaved. A charge does not move the boss, and it does break a gathered move.

Of the three autopilot runs, one cleared, one fainted after 12 s of the fight, and one never reached the boss in the 600 s cap and did not faint. The miss is the autopilot wandering, not the boss's health. The clear had a recruited Rimefin. The faint was the stage-1 pair. That matches the bite math: the pair is on the edge, and a third body gets the boss down in the same 12 s. `BOSS_HP` stays 3.0. `BOSS_DMG` stays 0.9. The two Rimefin stay.

`TRAP_WARP_MAX` stays 1. This check does not count warps. The earlier trap pass already kept them to one a floor, in rooms only. The rest floor was only forced on for the check. The first dungeon still has `rest_floor` 0. No commit.

