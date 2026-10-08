# Arena balance pass: Stormwick, Rampartroot, Scourmaw (Claude, 2026-10-07)

**For Grok and Preston. Every number here is a draft.** Tool: `tools/debug/arena_sim.gd` plays AI against AI headless, each form on each side, and prints wins, match length and HP left:
`Godot --headless --path . --fixed-fps 30 --script res://tools/debug/arena_sim.gd -- <matches per side>` (25 per side = 50 per pairing, about a minute). At 50 matches, results wobble by roughly ±7%.

## The rule being balanced to (Preston, 2026-10-07)
Main cycle: **Tide beats Ember, Bloom beats Tide, Ember beats Bloom.** Second essences soften it, each weaker: **Hollow beats Bloom, Electric beats Tide, Stone beats Electric.** Target: with equal play, the side with the essence edge wins about 60 to 65%, never a wipe. Stormwick's kit stays as designed; Scourmaw and Rampartroot were tuned around it.

Arena chart used (`ARENA_CHART` in `scripts/arena/arena_prototype.gd`): main x1.5 (x0.75 the other way), second x1.25 (x0.9 the other way), two essences multiply. **This differs from `scripts/essence_chart.gd`** (the turn-based four-way cycle with Hollow strong against everything) and from `THE_CONCEPT.md`; to reconcile.

## Results (wins out of 50)
| Pairing | Favoured by the chart | No essences, old kits | Chart + final kits |
|---|---|---|---|
| Stormwick vs Rampartroot | Stormwick (Ember beats Bloom) | Stormwick 20-0 (of 20) | **Stormwick 26 - 24** |
| Stormwick vs Scourmaw | Scourmaw (Tide beats Ember) | Stormwick 17-3 (of 20) | **Scourmaw 28 - 22** |
| Rampartroot vs Scourmaw | Rampartroot (Bloom beats Tide) | Rampartroot 20-0 (of 20) | **Rampartroot 37 - 13** (after Phase breaks roots) |

## What changed
- **Essences now count** in the arena (each move has one; Stormwick's Wick Bolt is Electric, its claws and embers Ember).
- **Scourmaw:** HP 0.75x to 0.85x; Phase also reads an attack coming (enemy in range with a damaging move ready), the only answer to an instant bolt; new **Sinkhole** (sinks and resurfaces 110 px away, escape); new **Riptide** (a current pool that slows, pulls in and shuts off movement abilities); **Hollow decay**: its hits erode the target 3 s (no damage reduction, +25% damage taken); kites toward open floor instead of corners.
- **Rampartroot:** **Thorns** on its passive (5 back to close attackers; not during signatures); root walls also stop Wick Bolt; Root Wall every 9 s (was 7); cripple 2.4 s (was 2.8).

## Open
- **Phase breaks roots (Preston approved, 2026-10-07):** roots cannot hold what is not there. Phasing frees Scourmaw from the hold but it stays crippled (no Sinkhole until that wears off). Tried first: Phase clearing roots and cripple both gave Scourmaw 66% (too far), and a longer cooldown after breaking free changed nothing. Before the change Rampartroot won 92%.
- **Stormwick vs Rampartroot** sits at 52% against the 60% target; thorns are the sensitive dial (3 gave Stormwick 87%, 6 gave it 30%).
- Balance is 1v1 only. Preston is weighing 2v2, 1v1v1 and 2v2v2v2; kits should follow "no dead moves" (every support move works alone and scales with allies), and the simulator should grow to team modes once the arena supports more than two fighters.

## Team fights and a bigger sample (Claude, 2026-10-07, later)
**The 50-match results above were noise.** The arena now runs 1v1, 2v2 and 3v3. That change only altered the order the two AIs make their random rolls, and Stormwick vs Rampartroot moved from 26-24 to 14-36 on the same seeds. The simulator also reused seeds past 10 matches a side; it now gives every match its own seed. At 200 matches per pairing (about ±3.5%):

| Pairing (200 matches) | Favoured by the chart | Result |
|---|---|---|
| Stormwick vs Rampartroot | Stormwick | **Rampartroot 110 - 90** (Stormwick 45%, wrong way, target 60%) |
| Stormwick vs Scourmaw | Scourmaw | **Scourmaw 120 - 80** (60%, on target) |
| Rampartroot vs Scourmaw | Rampartroot | **Rampartroot 137 - 63** (68.5%, a little over) |

Use at least 100 a side from now on: `... arena_sim.gd -- 100 1`.

**2v2** (`-- 30 2`, 60 matches each): every two-form team against every other, all within 25-35 to 35-25. **3v3** (`-- 30 3`, the same three a side): 27-33, about 31 s a match.

Per creature, 3v3 (2v2 is similar):
| Form | Avg damage dealt | Still standing at the end | First to fall |
|---|---|---|---|
| Stormwick | 79 | 10% | **95%** |
| Rampartroot | 206 | 29% | 0% |
| Scourmaw | 140 | 42% | 5% |

**The tactical finding:** the skirmisher dies first almost every time. Its AI darts in to claw whoever it targets, even when that walks it into two or three enemies at once. That's fine 1v1 and fatal in a crowd. Options for Grok and Preston: only dive on an isolated target, or give team fights a reason to protect it. The tank does the most damage and never falls first. The assassin survives most.

**Draft team tactics in the code** (`_foe_of` in `arena_prototype.gd`, for Grok to rule on): assassins pick off the weakest enemy in reach, tanks peel for their most hurt teammate, skirmishers follow up on an enemy that is stunned, rooted or dazzled, and the rest take the nearest. Teammates spread out, and nothing hits its own side.

## Rocks and slams on (Claude, 2026-10-07, later still)
The same simulator, 200 matches per 1v1 pairing, with rocks and carrying hits on (their default):
| Pairing | Rocks off (above) | Rocks on |
|---|---|---|
| Stormwick vs Rampartroot | Stormwick 45% | **Stormwick 24.5%** |
| Stormwick vs Scourmaw | Stormwick 40% | Stormwick 37.5% |
| Rampartroot vs Scourmaw | Rampartroot 68.5% | Rampartroot 73% |

3v3 (60 matches): 32-28. Stormwick is now first to fall in 76% of matches (95% before; rocks give it some cover). Scourmaw is first to fall in 20% (was 5%), and Rampartroot in 3%.

**Why Rampartroot gained:** Club Slam now carries its target into walls and rocks for 8 slam damage plus a daze. Rampart (no knockback) means nothing slams Rampartroot back. **For Grok:** the dials are `SLAM_DAMAGE`, `CARRY_FROM`, Club Slam's push (2.0), and whether Rampart should still block carrying. To compare without rocks, press B in game or set `rocks_on = false`.

**Boulder resized to the reference (later still, 60 matches of 3v3):** 34-26. Stormwick first to fall 86% (76% with the three pebbles, 95% with no rocks); Rampartroot 3%, Scourmaw 10%. Rampartroot's damage rose to 221. The one big boulder gives less cover across the field than three small rocks did, and more wall to slam into. Cover helps Stormwick only when it is spread; a real fix is in its AI (dive only on isolated targets), which is Grok's call.

## Ironvent's first numbers (Claude, 2026-10-07, 100 matches per pairing, rocks on)
| Pairing | Favoured by the chart | Result |
|---|---|---|
| Ironvent vs Stormwick | neutral (Ember on Ember; Stormwick's Electric is resisted a little by Stone) | **Stormwick 88 - 12** |
| Ironvent vs Rampartroot | Ironvent (Ember beats Bloom; Stone neutral) | **50 - 50** |
| Ironvent vs Scourmaw | Scourmaw (Tide beats Ember both ways) | **Scourmaw 99 - 1**, 9 s a match, Scourmaw ends on 93% HP |

Same run, for reference: Stormwick vs Rampartroot 23-77, Stormwick vs Scourmaw 51-49, Rampartroot vs Scourmaw 72-28 (seeds differ from the 200-match table above, so treat differences under about 7 points as noise).

**What the numbers say, for Grok (every number here is a draft):** Ironvent cannot reach anything that keeps its distance. Scourmaw kites at 135 px with a 150 px jet; Ironvent's longest reach is Vent Barrage at 85 and Crest Ram at 95, it walks at 0.85x, and Tide hits its Ember for 1.5x while its Ember hits Scourmaw's Tide for 0.75x. That is a wipe, which the chart's own target (60 to 65% for the favoured side) forbids. Against Stormwick the problem is speed alone. Against Rampartroot, the one fight where it gets close, it is even. The kit's dials: Crest Ram's range and speed (a longer, faster charge is the bruiser's answer to kiters), Vent Barrage's range, and whether Stoke should also build when it takes hits (a bruiser that gets stronger from trading). Claude did not tune any of these; kits are Grok's.

## After telegraphs, hitstop and the pass-through rule (Claude, 2026-10-07, evening; 200 matches per pairing, rocks on)
Attacks now wind up with a ground telegraph, and Phase and Flashstep read a telegraph aimed at them. The first run after that showed **Rampartroot 200-0 over Scourmaw**: Scourmaw phased on the Root Snare telegraph, but direct moves never rechecked phase at fire time, so the snare landed anyway and Scourmaw lost its Phase, its footing and the fight. Fixed: a direct move (claws, Club Slam, Root Snare, Riptide, Wick Bolt) fired at a phased target now passes through, at half its cooldown. Shots and lobs already checked phase on arrival.

| Pairing | Favoured by the chart (target 60 to 65%) | Before telegraphs | Now |
|---|---|---|---|
| Stormwick vs Rampartroot | Stormwick | Stormwick 24.5% | **Stormwick 58%** (Flashstep now dodges the Club Slam wind-up) |
| Stormwick vs Scourmaw | Scourmaw | Scourmaw 62.5% | **Scourmaw 82.5%** (Phase now dodges Wick Bolt; too high) |
| Rampartroot vs Scourmaw | Rampartroot | Rampartroot 73% | **Rampartroot 73.5%** (back from the 100% bug) |

3v3 (60 matches): 25-35; Stormwick first to fall 88%, Rampartroot 6%, Scourmaw 5%.

**For Grok:** telegraphs are a real balance lever. A dodge that reads them (Phase, Flashstep) is now worth much more, which helped Stormwick against the tank and hurt it against the assassin. The dials: Phase's cooldown (3 s) and how early a dodger may read a telegraph (`_threat_near`: the last 0.12 s of the wind-up), and the wind-up lengths in `TELEGRAPH`. Claude set those for readability, not balance.
