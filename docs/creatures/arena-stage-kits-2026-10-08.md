# Every stage its own kit (Claude, 2026-10-08)

**Preston:** "We can give every stage their own kits based off their physiology and how they should play in Hollowtide." And, the same hour: "Replace Flashstep; it's becoming useless, because the AI is usually moving toward the creature or it gets stuck at the border wall, so it basically teleports in place. It doesn't fit Kithflare as a stage 1 move."

The shape stays (stage 1: basic and two abilities; stage 2: basic, three and the passive; stage 3: adds the signature). What changed: each form's moves come off the parts its own art shows, and each stage plays its own way instead of carrying a trimmed copy of the final's kit. Every number is Grok's; placeholder names are marked. Code: `KITS` in `scripts/arena/arena_prototype.gd`. Check: `tools/debug/arena_stage_kits_check.gd`.

## Flashstep is retired; Ember Feint replaces it
Flashstep teleported to a mark. With the AI walking the creature toward its target, the mark was usually under its feet, and at the wall there was nowhere to go: a teleport in place. **Ember Feint** (placeholder name) is a hop out of reach that works wherever the creature stands: it picks the best open direction away from the target (straight back, angled, or along the wall when its back is against it), is untouchable for the hop (0.25 s), and leaves three ember patches where it stood so whoever chases it walks through fire. Two charges, 5 s each. Check: from 20 px it landed 73 px away on open floor and 59 px away with the wall at its back; the chaser crossing the embers took 12. It fits every stage of the Stormwick line: Kithflare already has the hot tail and the embers.

## The kits
| Form | What the art shows | How it plays | Basic (AI) | 1 | 2 | 3 | Passive |
|---|---|---|---|---|---|---|---|
| Kithflare | small fire runner, claws, hot tail, no lantern | harasser: rakes up close, feints out through embers, spits from range | Rake | Ember Feint | Ember Shot | | |
| Sparkwick | the lantern has lit on its tail | a zapper that pounces: bolts from the lantern, the volley | Pounce | Ember Feint | Wick Bolt | Lantern Volley | Lantern Charge (running charges an overcharged bolt) |
| Stormwick | the storm lantern | agile melee skirmisher | Pounce | Ember Feint | Lantern Volley | Lantern Tackle | Lantern Mark; Stormlantern |
| Tallowroot | seed burrower | pods, snares, and it burrows under to come up behind | Seed Pod | Root Snare | Burrow | | |
| Huskward | hardened husk, the tail club grown | bruiser-tank: the club, snares, a root wall behind the runner | Seed Pod | Tail Club | Root Snare | Root Wall | Rampart |
| Rampartroot | the pod club, the rampart | slow tank | Seed Pod | Tail Club | Root Snare | Root Rampart | Rampart; Verdant Roar |
| Rimefin | small river fish, pressure jet | keeps its distance, lays a riptide, dives under to come up behind | Pressure Jet | Riptide | Dive | | |
| Riftfin | faster, the jaw growing | the dive, the riptide, Deep Jet from range (x1.15 from far) | Pressure Jet | Riptide | Dive | Deep Jet | |
| Scourmaw | the heavy jaw, the hollow | assassin | Deep Jet | Phase | Riptide | Sinkhole (ambush) | Absence; Undertow |
| Cinderhide | small vent reptile with claws | rakes and pounces, a vent barrage to open | Cinder Claw | Vent Barrage | Pounce | | |
| Clinkerhide | the crest has come in | the ram, the barrage, Vent Blast | Cinder Claw | Crest Ram | Vent Barrage | Vent Blast | Stoke |
| Ironvent | crest, vents, claws | bruiser | Cinder Claw | Crest Ram | Vent Barrage | Vent Blast | Stoke; Furnace Roar |
| Fusern | small round kiln beetle | pellets, a short pour, runs its shell molten when pressed | Ember Pellet | Molten Beam | Glass Guard | | |
| Slagglass | the brick dome (redesigned), no spurs | shoves with the shell, shards, pours, guards | Plate Lunge | Furnace Shard | Molten Beam | Glass Guard | Kiln Heat |
| Vitrecrag | the crater dome | the Ember tank | Plate Lunge | Molten Cannon | Molten Beam | Glass Guard | Kiln Heat; Molten Glass |
| Preostmar | compact, jade cluster on the shoulders | shoulder shards, spikes, the cocoon | Jade Lance | Ground Spikes | Stone Cocoon | | |
| Oathfen | slabs formed, rails folded | slab brawler | Jade Lance | Ground Spikes | Stone Cocoon | Slab Vortex | Bound Slabs |
| Oxbowarchon | the rails and the Kingstone | backline artillery | Jade Lance | Rail Shot | Ground Spikes | Rail Recoil | Bound Slabs; Kingstone Rail |
| Punchybun | round kit, fists, star on the forehead | jabs, dances, puts its star on a friend | Spark Jab | Static Dance | Star Guard | | |
| Sparkjab | the boxer, charged paw pads | the protector arriving: Counter Jab | Spark Jab | Static Dance | Star Guard | Counter Jab | Guardian |
| Starward | the star-gem on the chest | the Protector | Spark Jab | Static Dance | Star Guard | Counter Jab | Guardian; Starshield |

Burrow (Bloom) and Dive (Tide) are the Sinkhole mechanic without the Hollow: sink out of sight, come up behind the target. Pounce and Rake lost their "Raptor" names so Cinderhide can use them. Nothing here changes the finals' kits except Flashstep's replacement.

## Check results
Ember Feint as above. Kithflare: basic Rake, abilities Ember Feint and Ember Shot (one shot fired). Sparkwick: Wick Bolt took 15 off Ironvent; passive Lantern Charge. Tallowroot's Burrow came up 19 px behind the target, Rimefin's Dive 68 px behind. Cinderhide: Cinder Claw; Vent Barrage, Pounce. AI 1v1 Stormwick against Rampartroot: won in 33 s with two feints (459 dealt, 202 taken). **Grok:** that last number says the skirmisher is ahead of the tank now; the embers may be the reason.
