# Balance proposal

PROPOSAL only. Live creature files, move files, and `scripts/battle_rules.gd` were not changed. Route 1 was left to Codex. Checked with `tools/balance_sim.gd`, 1000 wild runs, seed unchanged. Report: `docs/battle/balance/sim-report-grok-proposal.md`. Overrides: `RESULT_task1_overrides.json`.

Damage is `int(attack * power / (defense * 4) * essence)`, minimum 1. No variance. Speed ties still go to the player. That rule was not changed, so a creature still wins its own mirror.

## What each change is for

- Every speed is different, so a cross-matchup is no longer a tie the player always wins.
- HP, attack, and defense now follow the lines. Cinderhide, Clinkerhide, Ironvent get slower and heavier. Kithflare, Wayburn, Coalcrest stay fast. Fusern, Slagglass, Vitrecrag go from a hot core to a slow cannon. Rimefin hits softer so Tide x2 is a long fight, not a three-turn delete.
- Kingstone Rail is PROPOSAL 58 power, 2 uses. It is no longer an unlimited 60.
- Molten Glass is PROPOSAL 66 power, 2 uses, so the signature is the hard hit. Molten Beam is PROPOSAL 36 power, unlimited, so Vitrecrag still has a chip after the limited moves are gone.

## Three matchups, same formula the sim uses

Rimefin Strike into Cinderhide: `int(44 * 40 / (58 * 4) * 2) = 15`. Cinderhide Spineflare back: `int(62 * 60 / (64 * 4) * 0.5) = 7`. Rimefin is faster (57 vs 55) and lands the sixth 15, which is the KO. Cinderhide has dealt 35. Sim: Rimefin wins in 6. Old sim: 3.

Cinderhide into Clinkerhide. Spineflare does 12, twice, then Coal Spit does 10. Slagburst does 17, twice, then Vent Row does 14. Cinderhide is faster and still faints on turn 6, at Clinkerhide 20 HP. The 2-use move is empty by turn 3, so the limit is doing work. Sim: Clinkerhide wins in 6.

Oxbowarchon into Cinderhide. Kingstone Rail does 19, twice, then Strike does 13. Cinderhide Spineflare into Oxbowarchon does 9. Two rails plus four strikes KO on turn 6. The rail is gone after turn 2. Sim: Oxbowarchon wins in 6. The old unlimited rail, at equal 60s, ended Ember fights in 4 and never ran out.

## What the sim actually did

| Creature | Duel wins of 11 | Average wild win rate |
|---|---:|---:|
| Rimefin | 10 | 91% |
| Cinderhide | 1 | 32% |
| Clinkerhide | 6 | 63% |
| Ironvent | 8 | 82% |
| Kithflare | 4 | 39% |
| Wayburn | 3 | 53% |
| Coalcrest | 5 | 63% |
| Fusern | 2 | 32% |
| Slagglass | 7 | 64% |
| Vitrecrag | 9 | 82% |
| Oxbowarchon | 11 | 100% |

Same-essence fights mostly land in 4 to 8 turns. Oxbowarchon's mirror is 13, which is the use limit showing up. Oxbowarchon against Rimefin is still 3, because Stone hits Tide at x2 and the wall's attack is high.

## Still wrong, on purpose left as numbers not rules

- Cinderhide wins only its own mirror. Too weak for the creature the route gives you. Needs another pass before this is playable.
- Oxbowarchon still wins every duel. Limiting the rail stopped the infinite button. It did not stop the wall.
- Rimefin still beats every Ember. Tide x2 against Ember x0.5 is a fourfold gap. Fair stats cannot close that without changing the chart, and the chart was not in scope. A plain 60/60/60/60 Strike dummy also beats this Rimefin. That is the cost of the lower attack.
- A creature still wins a mirror against itself, because a speed tie goes to the player.

Nothing here goes into the game until you approve a revision that fixes the Cinderhide and Oxbowarchon rows.

{"creatures": {"Rimefin": {"base_hp": 72, "base_attack": 44, "base_defense": 64, "base_speed": 57}, "Cinderhide": {"base_hp": 80, "base_attack": 62, "base_defense": 58, "base_speed": 55}, "Clinkerhide": {"base_hp": 84, "base_attack": 68, "base_defense": 72, "base_speed": 47}, "Ironvent": {"base_hp": 98, "base_attack": 76, "base_defense": 80, "base_speed": 39}, "Kithflare": {"base_hp": 74, "base_attack": 66, "base_defense": 56, "base_speed": 73}, "Wayburn": {"base_hp": 76, "base_attack": 70, "base_defense": 58, "base_speed": 67}, "Coalcrest": {"base_hp": 86, "base_attack": 68, "base_defense": 66, "base_speed": 61}, "Fusern": {"base_hp": 70, "base_attack": 72, "base_defense": 54, "base_speed": 63}, "Slagglass": {"base_hp": 78, "base_attack": 74, "base_defense": 70, "base_speed": 49}, "Vitrecrag": {"base_hp": 96, "base_attack": 74, "base_defense": 78, "base_speed": 33}, "Oxbowarchon": {"base_hp": 110, "base_attack": 78, "base_defense": 96, "base_speed": 41}}, "moves": {"Kingstone Rail": {"power": 58, "max_uses": 2}, "Molten Glass": {"power": 66, "max_uses": 2}, "Molten Beam": {"power": 36, "max_uses": 0}}}
