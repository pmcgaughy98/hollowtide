# Hollowtide: current creatures and moves (exported 2026-10-09)

Every creature line has three stages. Stage 1 has a basic attack plus 2 abilities, stage 2 a basic plus 3 and a passive, and stage 3 adds a signature (an ultimate). Moves were designed per creature from the body parts its art shows. Damage, cooldown (seconds, real-time arena) and range (pixels) are working numbers; on the dungeon grid, range becomes tiles (24 px each) and the kind decides the shape: front tile, dash along a line, shot down a line, or burst around a target.

## Lines and kits

| Line | Stage | Creature | Essences | Basic | Abilities | Passive | Signature |
|---|---|---|---|---|---|---|---|
| 1 | 1 | Kithflare | Ember / Electric | Rake | Ember Feint, Ember Shot |  |  |
| 1 | 2 | Sparkwick | Ember / Electric | Pounce | Ember Feint, Wick Bolt, Lantern Volley | lantern_charge |  |
| 1 | 3 | Stormwick | Ember / Electric | Pounce | Ember Feint, Lantern Volley, Lantern Tackle | lantern_mark | Stormlantern |
| 2 | 1 | Tallowroot | Bloom / Stone | Seed Pod | Root Snare, Burrow |  |  |
| 2 | 2 | Huskward | Bloom / Stone | Seed Pod | Tail Club, Root Snare, Root Wall | rampart |  |
| 2 | 3 | Rampartroot | Bloom / Stone | Seed Pod | Tail Club, Root Snare, Root Rampart | rampart | Verdant Roar |
| 3 | 1 | Rimefin | Tide / Hollow | Needle Bite | Lunge, Silt Dive |  |  |
| 3 | 2 | Riftfin | Tide / Hollow | Needle Bite | Lunge, Silt Dive, Riptide | ambush |  |
| 3 | 3 | Scourmaw | Tide / Hollow | Needle Bite | Lunge, Silt Dive, Riptide | ambush | Undertow |
| 4 | 1 | Cinderhide | Ember / Stone | Cinder Claw | Vent Barrage, Pounce |  |  |
| 4 | 2 | Clinkerhide | Ember / Stone | Cinder Claw | Crest Ram, Vent Barrage, Vent Blast | stoke |  |
| 4 | 3 | Ironvent | Ember / Stone | Cinder Claw | Crest Ram, Vent Barrage, Vent Blast | stoke | Furnace Roar |
| 5 | 1 | Fusern | Ember | Ember Pellet | Molten Beam, Glass Guard |  |  |
| 5 | 2 | Slagglass | Ember | Plate Lunge | Furnace Shard, Molten Beam, Glass Guard | kiln |  |
| 5 | 3 | Vitrecrag | Ember | Plate Lunge | Molten Cannon, Molten Beam, Glass Guard | kiln | Molten Glass |
| 6 | 1 | Preostmar | Electric / Stone | Jade Lance | Ground Spikes, Stone Cocoon |  |  |
| 6 | 2 | Oathfen | Electric / Stone | Jade Lance | Ground Spikes, Stone Cocoon, Slab Vortex | bound_slabs |  |
| 6 | 3 | Oxbowarchon | Electric / Stone | Jade Lance | Rail Shot, Kingstone Lift, Rail Recoil | bound_slabs | Kingstone Rail |
| 7 | 1 | Punchybun | Electric | Spark Jab | Static Dance, Star Guard |  |  |
| 7 | 2 | Sparkjab | Electric | Spark Jab | Static Dance, Star Guard, Counter Jab | chain |  |
| 7 | 3 | Starward | Electric | Spark Jab | Static Dance, Star Guard, Counter Jab | chain | Starshield |
| 8 | 1 | Cutbank Listener | Tide | Echo Tap | Interrupt Call, Deep Brace |  |  |
| 8 | 2 | Bend Caller | Tide | Echo Tap | Interrupt Call, Deep Brace, Still Water | listening |  |
| 8 | 3 | Quietwater Warden | Tide / Hollow | Echo Tap | Interrupt Call, Deep Brace, Still Water | listening | Hush |
| 9 | 1 | Canvaswing | Gale | Shear | Sail Cover, Downdraft |  |  |
| 9 | 2 | Windcut | Gale | Shear | Sail Cover, Downdraft, Lift | windbreak |  |
| 9 | 3 | Galeshear | Gale | Shear | Sail Cover, Downdraft, Lift | windbreak | Gale Shear |
| 10 | 1 | Dustkite | Gale | Whistle Dart | Signal Mark, Decoy Call |  |  |
| 10 | 2 | Waywhistle | Gale | Whistle Dart | Signal Mark, Decoy Call, Vantage | spotter |  |
| 10 | 3 | Highsignal | Gale | Whistle Dart | Signal Mark, Decoy Call, Vantage | spotter | High Signal |

## Moves

| Move | Essence | Kind | Damage | Cooldown | Range | Used by |
|---|---|---|---|---|---|---|
| Ember Shot | Ember | line | 10 | 0.9 | 95.0 | Kithflare |
| Seed Pod | Bloom | area | 12 | 1.2 | 70.0 | Tallowroot, Huskward, Rampartroot |
| Wick Bolt | Electric | line | 12 | 1.3 | 115.0 | Sparkwick |
| Ember Feint | Ember |  | 3 | 5.0 | 0.0 | Kithflare, Sparkwick, Stormwick |
| Burrow | the user's own |  | 0 | 6.0 | 0.0 | Tallowroot |
| Rake | Ember | melee | 14 | 1.1 | 24.0 | Kithflare |
| Pounce | Ember | melee | 12 | 1.4 | 58.0 | Sparkwick, Stormwick, Cinderhide |
| Lantern Volley | Ember |  | 7 | 6.0 | 120.0 | Sparkwick, Stormwick |
| Lantern Tackle | Ember |  | 6 | 7.0 | 999.0 | Stormwick |
| Needle Bite | Tide | melee | 11 | 1.0 | 30.0 | Rimefin, Riftfin, Scourmaw |
| Lunge | Tide | charge | 12 | 6.0 | 110.0 | Rimefin, Riftfin, Scourmaw |
| Silt Dive | the user's own |  | 0 | 5.0 | 0.0 | Rimefin, Riftfin, Scourmaw |
| Riptide | the user's own | area | 0 | 6.0 | 120.0 | Riftfin, Scourmaw |
| Root Snare | Bloom | area | 4 | 6.0 | 100.0 | Tallowroot, Huskward, Rampartroot |
| Root Wall | the user's own |  | 0 | 9.0 | 140.0 | Huskward |
| Tail Club | Stone | melee | 16 | 4.0 | 30.0 | Huskward, Rampartroot |
| Root Rampart | Bloom | area | 18 | 9.0 | 110.0 | Rampartroot |
| Vent Barrage | Ember | line | 12 | 1.2 | 85.0 | Cinderhide, Clinkerhide, Ironvent |
| Crest Ram | Ember | charge | 14 | 4.5 | 95.0 | Clinkerhide, Ironvent |
| Cinder Claw | Ember | melee | 15 | 1.2 | 26.0 | Cinderhide, Clinkerhide, Ironvent |
| Ember Pellet | Ember | line | 10 | 1.0 | 90.0 | Fusern |
| Furnace Shard | Ember | line | 12 | 1.3 | 100.0 | Slagglass |
| Plate Lunge | Stone | melee | 14 | 2.0 | 28.0 | Slagglass, Vitrecrag |
| Molten Cannon | Ember | area | 16 | 3.5 | 150.0 | Vitrecrag |
| Molten Beam | Ember | line | 12 | 1.8 | 120.0 | Fusern, Slagglass, Vitrecrag |
| Glass Guard | the user's own |  | 0 | 9.0 | 0.0 | Fusern, Slagglass, Vitrecrag |
| Jade Lance | Stone | line | 13 | 1.5 | 110.0 | Preostmar, Oathfen, Oxbowarchon |
| Ground Spikes | Stone | area | 14 | 6.0 | 120.0 | Preostmar, Oathfen |
| Stone Cocoon | Stone |  | 12 | 10.0 | 0.0 | Preostmar, Oathfen |
| Slab Vortex | Stone | melee | 15 | 7.0 | 40.0 | Oathfen |
| Rail Shot | Electric | rail | 22 | 6.0 | 220.0 | Oxbowarchon |
| Rail Recoil | Stone |  | 8 | 8.0 | 0.0 | Oxbowarchon |
| Vent Blast | Ember | melee | 11 | 5.0 | 44.0 | Clinkerhide, Ironvent |
| Spark Jab | Electric | melee | 10 | 0.7 | 26.0 | Punchybun, Sparkjab, Starward |
| Static Dance | the user's own |  | 0 | 7.0 | 0.0 | Punchybun, Sparkjab, Starward |
| Star Guard | the user's own |  | 0 | 8.0 | 120.0 | Punchybun, Sparkjab, Starward |
| Counter Jab | Electric |  | 12 | 6.0 | 140.0 | Sparkjab, Starward |
| Echo Tap | Tide | line | 8 | 1.1 | 80.0 | Listener, Caller, Warden |
| Interrupt Call | Tide |  | 6 | 8.0 | 0.0 | Listener, Caller, Warden |
| Deep Brace | the user's own |  | 0 | 10.0 | 0.0 | Listener, Caller, Warden |
| Still Water | the user's own | area | 0 | 12.0 | 120.0 | Caller, Warden |
| Shear | Gale | melee | 9 | 1.0 | 30.0 | Canvaswing, Windcut, Galeshear |
| Sail Cover | the user's own |  | 0 | 8.0 | 120.0 | Canvaswing, Windcut, Galeshear |
| Downdraft | the user's own | area | 0 | 10.0 | 120.0 | Canvaswing, Windcut, Galeshear |
| Lift | the user's own |  | 0 | 9.0 | 140.0 | Windcut, Galeshear |
| Kingstone Lift | Electric | area | 10 | 11.0 | 150.0 | Oxbowarchon |
| Whistle Dart | Gale | line | 9 | 1.0 | 130.0 | Dustkite, Waywhistle, Highsignal |
| Signal Mark | the user's own |  | 0 | 7.0 | 160.0 | Dustkite, Waywhistle, Highsignal |
| Decoy Call | the user's own |  | 0 | 9.0 | 160.0 | Dustkite, Waywhistle, Highsignal |
| Vantage | the user's own |  | 0 | 10.0 | 0.0 | Waywhistle, Highsignal |
