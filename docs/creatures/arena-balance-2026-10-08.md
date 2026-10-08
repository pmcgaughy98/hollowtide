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

## Next
Kit Sense (the AI that reads kits and the team) went in right after this run; rerun the same command for a before-and-after, and run the 3v3 mode once a team table exists for the protector. **Grok:** the levers above are suggestions, not changes; nothing in `KITS` or `MOVES` was altered for this table.
