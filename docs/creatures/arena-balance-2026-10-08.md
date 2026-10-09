# Arena duels, all seven finals, after the ability era (Claude, 2026-10-08)

`tools/debug/arena_sim.gd -- 25 1`: 50 AI-against-AI duels per pairing (25 with each creature on each side), fixed 30 fps, headless, before Kit Sense went in (the raw log with the numbers below is `arena-sim-2026-10-08.log`). Every kit, stat and status in these fights is a draft; **the table is Grok's to act on.** The previous table (`arena-balance-2026-10-07.md`) covered three finals before abilities existed.

| | Stormwick | Rampartroot | Scourmaw | Ironvent | Vitrecrag | Oxbowarchon | Starward |
|---|---|---|---|---|---|---|---|
| **Stormwick** | | 46-4 | 7-43 | 26-24 | 43-7 | 7-43 | 50-0 |
| **Rampartroot** | 4-46 | | 47-3 | 0-50 | 0-50 | 9-41 | 50-0 |
| **Scourmaw** | 43-7 | 3-47 | | 20-30 | 48-2 | 0-50 | 39-11 |
| **Ironvent** | 24-26 | 50-0 | 30-20 | | 25-25 | 11-39 | 50-0 |
| **Vitrecrag** | 7-43 | 50-0 | 2-48 | 25-25 | | 0-50 | 25-0 (25 draws) |
| **Oxbowarchon** | 43-7 | 41-9 | 50-0 | 39-11 | 50-0 | | 50-0 |
| **Starward** | 0-50 | 0-50 | 11-39 | 0-50 | 0-25 (25 draws) | 0-50 | |

Wins for the row creature, out of 50. Average fight 27 to 64 s; the Vitrecrag against Starward fights hit the 90 s cap half the time.

## What the table says
- **Oxbowarchon is the outlier.** It wins 39 to 50 of 50 against everyone and finishes with 58 to 86% HP against the ranged and the slow. The backline rework stacked four things that each make sense alone: everything hits x1.3 from beyond 110 px, Rail Shot pierces a 220 px line for 22, Bound Slabs swallow two blows and re-form every 7 s, and the kite profile keeps it at the range where all of that applies. Against a kiter with 1.3x HP, the melee creatures cross a long open floor eating lances. **Levers, in the order I would pull them:** drop the far bonus from its basic (keep it on Rail Shot only), 1.3x HP to 1.15x, slabs re-form in 10 s not 7. Any one of those probably brings it to the pack.
- **Starward cannot win a duel.** 0 of 300 and half its Vitrecrag fights time out. That is the protector doing its job alone: its damage is a 10 jab and its tools shield other people. In 3v3 it won or drew every team fight in its own check. The duel table is the wrong test for it; a team table is the right one. If a lone Starward should still be able to win sometimes, the lever is the charged jab (x1.5 and a hold) coming round more often.
- **The Bloom tank loses to both Ember tanks 0-50.** Rampartroot against Ironvent and Vitrecrag never wins. Ember beats Bloom on the chart (x1.5), Ironvent's rams carry it into walls, and Vitrecrag's field burns it where it stands. The chart is doing what it should; the question for Grok is whether a tank should be a hard counter to another tank at all.
- **Stormwick is up.** 46-4 over Rampartroot and 43-7 over Vitrecrag, where the 2026-10-07 table had 58% over Rampartroot. The new part is Ember Feint's embers: a pressing tank walks through them again and again. Lever: fewer patches (two) or a shorter burn (1.0 s).
- **Scourmaw does what an assassin should:** wins against the skirmisher and the Ember tank, loses to the Bloom tank (Bloom beats Tide) and to the railgun (it cannot close on a kiter with slabs).
- **Ironvent is the healthiest row:** 24-26, 50-0, 30-20, 25-25, 11-39, 50-0. Beats the tanks, trades with the skirmisher and the assassin, loses only to the outlier.

## After Kit Sense (same command, `arena-sim-2026-10-08-kitsense.log`)
| | Stormwick | Rampartroot | Scourmaw | Ironvent | Vitrecrag | Oxbowarchon | Starward |
|---|---|---|---|---|---|---|---|
| **Stormwick** | | 41-9 | 4-46 | 24-26 | 42-8 | 8-42 | 50-0 |
| **Rampartroot** | 9-41 | | 44-6 | 0-50 | 0-50 | 8-42 | 50-0 |
| **Scourmaw** | 46-4 | 6-44 | | 19-31 | 49-1 | 0-50 | 43-7 |
| **Ironvent** | 26-24 | 50-0 | 31-19 | | 25-25 | 11-39 | 50-0 |
| **Vitrecrag** | 8-42 | 50-0 | 1-49 | 25-25 | | 0-50 | 50-0 |
| **Oxbowarchon** | 42-8 | 42-8 | 50-0 | 39-11 | 50-0 | | 50-0 |
| **Starward** | 0-50 | 0-50 | 7-43 | 0-50 | 0-50 | 0-50 | |

Within noise of the table above everywhere except one row: the 25 Vitrecrag against Starward draws became 50 Vitrecrag wins, because finish mode closes a fight that used to stall at the cap. That is what a duel table should show for an AI change: duels have no team to synergise with. Kit Sense's effect is in 3v3 (called targets, peel, the Crest), which needs the team table the simulator does not print yet. **Grok:** the levers in the section above still stand; the AI did not move the outliers.

## After frame data and role passives (same command, `arena-sim-2026-10-08-frames.log`)
| | Stormwick | Rampartroot | Scourmaw | Ironvent | Vitrecrag | Oxbowarchon | Starward |
|---|---|---|---|---|---|---|---|
| **Stormwick** |  | 34-16 | 20-30 | 29-21 | 26-24 | 15-35 | 48-0 (2 draws) |
| **Rampartroot** | 16-34 |  | 50-0 | 25-25 | 0-50 | 28-22 | 50-0 |
| **Scourmaw** | 30-20 | 0-50 |  | 22-28 | 46-4 | 0-50 | 30-19 (1 draws) |
| **Ironvent** | 21-29 | 25-25 | 28-22 |  | 25-25 | 22-28 | 25-0 (25 draws) |
| **Vitrecrag** | 24-26 | 50-0 | 4-46 | 25-25 |  | 2-48 | 41-0 (9 draws) |
| **Oxbowarchon** | 35-15 | 22-28 | 50-0 | 28-22 | 48-2 |  | 45-0 (5 draws) |
| **Starward** | 0-48 (2 draws) | 0-50 | 19-30 (1 draws) | 0-25 (25 draws) | 0-41 (9 draws) | 0-45 (5 draws) |  |

What moved, against the Kit Sense table: **Oxbowarchon came down** (Rampartroot now beats it 28-22, Ironvent loses only 22-28, Stormwick 15-35 from 8-42): hitstun after a Jade Lance is short but Rail Shot's 0.6 s recovery is a window, and the Tank passive moves the tanks less across its open floor. **Rampartroot against Ironvent went 0-50 to 25-25**: it is knocked 30% less and gives 40% less meter, so the ram-into-wall loop that beat it stopped paying. Rampartroot against Vitrecrag is still 0-50 (the glass field, not knockback). **Scourmaw's edge on Stormwick narrowed** (46-4 to 30-20): light claws are plus on hit now and Stormwick's basics land as counters inside its wind-ups. **Starward still cannot win alone** but draws 42 of 300 now that it regenerates when left alone. **Grok:** the Oxbowarchon levers above can wait for a 3v3 table; the one thing I would look at first is Rampartroot against Vitrecrag.

## After the Smite pass, manual control's movement model and charms (`arena-sim-2026-10-08-smite.log`)
Eight finals now (the Warden and Galeshear joined), everything AI-driven with momentum, dashes, the dodge step, charms by role, the Ravana chain, diminishing returns.
| | Stormwick | Rampartroot | Scourmaw | Ironvent | Vitrecrag | Oxbowarchon | Starward | Warden | Galeshear |
|---|---|---|---|---|---|---|---|---|---|
| **Stormwick** |  | 0-40 (10 dr) | 6-44 | 14-24 (12 dr) | 0-46 (4 dr) | 0-0 (50 dr) | 29-0 (21 dr) | 6-0 (44 dr) | 28-0 (22 dr) |
| **Rampartroot** | 40-0 (10 dr) |  | 50-0 | 34-16 | 2-48 | 50-0 | 50-0 | 50-0 | 49-0 (1 dr) |
| **Scourmaw** | 44-6 | 0-50 |  | 43-7 | 11-39 | 0-50 | 47-3 | 32-18 | 50-0 |
| **Ironvent** | 24-14 (12 dr) | 16-34 | 7-43 |  | 16-34 | 5-43 (2 dr) | 21-0 (29 dr) | 36-14 | 41-0 (9 dr) |
| **Vitrecrag** | 46-0 (4 dr) | 48-2 | 39-11 | 34-16 |  | 49-1 | 50-0 | 50-0 | 50-0 |
| **Oxbowarchon** | 0-0 (50 dr) | 0-50 | 50-0 | 43-5 (2 dr) | 1-49 |  | 23-2 (25 dr) | 33-0 (17 dr) | 27-0 (23 dr) |
| **Starward** | 0-29 (21 dr) | 0-50 | 3-47 | 0-21 (29 dr) | 0-50 | 2-23 (25 dr) |  | 1-0 (49 dr) | 5-0 (45 dr) |
| **Warden** | 0-6 (44 dr) | 0-50 | 18-32 | 14-36 | 0-50 | 0-33 (17 dr) | 0-1 (49 dr) |  | 0-0 (50 dr) |
| **Galeshear** | 0-28 (22 dr) | 0-49 (1 dr) | 0-50 | 0-41 (9 dr) | 0-50 | 0-27 (23 dr) | 0-5 (45 dr) | 0-0 (50 dr) |  |

Wins out of 400: Stormwick 83, Rampartroot 325, Scourmaw 227, Ironvent 166, Vitrecrag 366, Oxbowarchon 177, Starward 11, Warden 32, Galeshear 0. **Grok:** read this one with the charms in mind: Blink on the skirmisher and assassin, Thorns on both tanks, Aegis on the railgun, Beads on the bruiser and the Warden, Shell on Starward, Wings on Galeshear. The supports (Starward, the Warden, Galeshear) still cannot win duels, which is the role, not a bug; the 3v3 table is still the one the simulator does not print.

What moved, and it moved a lot:
- **Draws everywhere.** 50 of 50 between Stormwick and Oxbowarchon, 44 between Stormwick and the Warden, 21 to 29 wherever Starward meets a ranged creature. Two kiters with dashes, a dodge step and a Blink or an Aegis cannot close on each other inside the 90 s cap. The 1v1 has no clock and no decision on points (only team fights do); the first lever is to give 1v1 the same 120 s clock and points decision so a stall ends with a verdict, in play as in the simulator. The second is the dodge chance (already cut to 55%) and Blink's reach.
- **The tanks run the table.** Vitrecrag 366 of 400 and Rampartroot 325: Thorns on both (40% back on every hit) bleeds anyone who trades blows, and momentum makes it harder to dance out of their reach. Stormwick fell from 42-8 to 0-40 against Rampartroot. Levers: Thorns to 25%, or Thorns only answering hits above a size so pokes do not feed it.
- **Scourmaw and Ironvent held their shape**; Oxbowarchon lost its outlier status (177) now that kiters dodge its rails and tanks carry Thorns and Beads.
These are the numbers for Grok to act on; nothing in KITS, MOVES or CHARMS was altered for this table.

## After the AI dash fix, ten finals (`arena-sim-2026-10-09-dustkite.log`, 30 matches a pairing)
**Read the Smite-pass table above as tainted.** Last night's motion pass gave the AI a mid-dash early return that skipped the walk step that runs the dash down, so every AI creature that dodge-stepped or dashed once stood frozen for the rest of the fight. Tanks never dodge, which is a large part of why they ran that table. Fixed on 2026-10-09 while building the Dustkite line; this is the first clean table since momentum, dashes, the dodge step and charms went in. Highsignal (the Spotter) joined.
| | Stormwick | Rampartroot | Scourmaw | Ironvent | Vitrecrag | Oxbowarchon | Starward | Warden | Galeshear | Highsignal |
|---|---|---|---|---|---|---|---|---|---|---|
| **Stormwick** |   | 29-1 | 2-28 | 8-22 | 13-17 | 2-28 | 30-0 | 26-1 (3 dr) | 30-0 | 30-0 |
| **Rampartroot** | 1-29 |   | 19-11 | 4-26 | 2-28 | 0-29 (1 dr) | 18-12 | 30-0 | 27-0 (3 dr) | 24-0 (6 dr) |
| **Scourmaw** | 28-2 | 11-19 |   | 9-21 | 23-7 | 0-30 | 23-1 (6 dr) | 30-0 | 30-0 | 30-0 |
| **Ironvent** | 22-8 | 26-4 | 21-9 |   | 26-4 | 14-16 | 18-0 (12 dr) | 30-0 | 30-0 | 30-0 |
| **Vitrecrag** | 17-13 | 28-2 | 7-23 | 4-26 |   | 0-30 | 2-0 (28 dr) | 6-0 (24 dr) | 23-0 (7 dr) | 23-2 (5 dr) |
| **Oxbowarchon** | 28-2 | 29-0 (1 dr) | 30-0 | 16-14 | 30-0 |   | 29-0 (1 dr) | 30-0 | 30-0 | 30-0 |
| **Starward** | 0-30 | 12-18 | 1-23 (6 dr) | 0-18 (12 dr) | 0-2 (28 dr) | 0-29 (1 dr) |   | 11-0 (19 dr) | 11-0 (19 dr) | 0-0 (30 dr) |
| **Warden** | 1-26 (3 dr) | 0-30 | 0-30 | 0-30 | 0-6 (24 dr) | 0-30 | 0-11 (19 dr) |   | 0-0 (30 dr) | 0-0 (30 dr) |
| **Galeshear** | 0-30 | 0-27 (3 dr) | 0-30 | 0-30 | 0-23 (7 dr) | 0-30 | 0-11 (19 dr) | 0-0 (30 dr) |   | 0-0 (30 dr) |
| **Highsignal** | 0-30 | 0-24 (6 dr) | 0-30 | 0-30 | 2-23 (5 dr) | 0-30 | 0-0 (30 dr) | 0-0 (30 dr) | 0-0 (30 dr) |   |

Wins out of 270: Stormwick 170, Rampartroot 125, Scourmaw 184, Ironvent 217, Vitrecrag 110, Oxbowarchon 252, Starward 35, Warden 1, Galeshear 0, Highsignal 2.

What the clean table says:
- **The draws between damage dealers are gone.** Stormwick against Oxbowarchon was 50 draws of 50; now 2-28 with none. The dashes and dodge steps work as motion, not as a freeze. The draws that remain are support against support (30 of 30 in every pairing of the Warden, Galeshear and Highsignal, and Starward against them) and Vitrecrag against a support (24 to 28). Those are the real stall: two creatures that cannot kill each other. The 1v1 clock and points decision (proposed above) is still the lever.
- **The tanks came back down.** Rampartroot 325 of 400 became 125 of 270, Vitrecrag 366 became 110. Thorns did not need the cut I proposed; the frozen dashers were feeding it.
- **Oxbowarchon is the outlier again** (252 of 270, and 30-0 over Scourmaw, 30-0 over Vitrecrag). With the dash working the railgun's kiting beats everything but Ironvent (14-16). **Grok:** Kingstone Rail's telegraph and the rail's damage are the levers; Ironvent is the one creature that closes on it.
- **Ironvent second** (217), the bruiser's armour on charges paying off now that dodgers move.
- **Supports lose duels**, as the role says: Starward 35, Warden 1, Galeshear 0, Highsignal 2. Highsignal's perch keeps it alive (6 draws against Rampartroot, 5 against Vitrecrag) without scoring. Fine for a support in a 1v1 table; the 3v3 team table is still the one that would show their worth, and the simulator still does not print it.
Nothing in KITS, MOVES or CHARMS was altered for this table; the dash fix is the only change.

## Next
Kit Sense (the AI that reads kits and the team) went in right after this run; rerun the same command for a before-and-after, and run the 3v3 mode once a team table exists for the protector. **Grok:** the levers above are suggestions, not changes; nothing in `KITS` or `MOVES` was altered for this table.
