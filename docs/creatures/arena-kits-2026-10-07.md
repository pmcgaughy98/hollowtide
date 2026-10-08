# Arena kits and passives: drafts (Claude, 2026-10-07)

**Status: proposals.** Preston set the model on 2026-10-07: the player moves the creature and chooses when to fire its signature; the creature's own AI uses the rest of its kit strategically; not every move deals damage; every form gets a passive. Grok owns creature and move rules, so names, numbers and AI rules below are drafts for Preston and Grok to approve before they are built. Stormwick's, Scourmaw's and Rampartroot's kits are in the game (`scripts/arena/arena_prototype.gd`, `KITS` and `MOVES`).

Each kit grows out of the form's body, its essences and the job it already had in the turn-based design. Stage 1s get 1 to 2 moves, stage 2s 2, stage 3s 3, plus a passive from stage 2 (Kithflare and Tallowroot get a small one now, so every line's identity shows from the start).

> **Playtest night, 2026-10-07, Preston:** base HP 180 (fights were too short); Flashstep teleports to a mark; **Rampartroot** is a slow tank with 1 Tail Club (knockback), 2 Root Snare, 3 Root Rampart (the old signature as an ability) and the new signature **Verdant Roar** (placeholder: the green-pod roar from the title card; roots every enemy, then a club slam that leaves a vine field). The Rampartroot row below is historical. Details: `arena-feel-2026-10-07/README.md`.

> **Stormwick, second kit the same night, Preston:** Flashstep with invulnerability frames; Lantern Volley's balls bounce and mark; passive Lantern Mark (teleport to marks); 3 is Lantern Tackle (invulnerable zip between marked enemies, chosen landing); crates in the arena; SPACE switches your controlled creature. Placeholder names. Details: `arena-feel-2026-10-07/README.md`.

> **Abilities, 2026-10-07 (late), Preston:** four abilities MOBA style on keys 1-4, 4 the ultimate; the AI still moves and uses the basic attack. Stormwick is now an agile melee attacker (Raptor Pounce basic; 1 Flashstep with three charges; 2 Lantern Volley, a back-jump and a spread of lantern balls; 3 Lantern Lunge, a timed dash). Details: `arena-feel-2026-10-07/README.md`. The Stormwick row below is historical.

> **Control model, revised 2026-10-07 (evening), Preston:** the creature's AI moves and uses its kit; the player picks the target (left/right, up for auto) and fires the signature (K). The "player steers" lines below are historical.

## Roles (Preston, 2026-10-07)
"We'll have melee attackers, long range, defense piercers, tanks, assassins and all the things I can't think of." Each role sets both the kit and how the creature's AI moves (its movement profile). Working list, to grow:

| Role | What it does | Example |
|---|---|---|
| Skirmisher | evasive, short to mid range, always moving; darts in, hits, gets back out | **Stormwick** (built) |
| Assassin | burst from a safe distance, hit and run, fragile (glass cannon) | **Scourmaw** (built: long-range assassin) |
| Tank | lots of HP, hard to move, controls space, shuts down movement | **Rampartroot** (built) |
| Melee bruiser | wins up close, trades hits | **Ironvent** (built 2026-10-07: Crest Ram carries targets into walls and rocks; Stoke passive) |
| Marksman | steady long-range damage, weak up close | (open) |
| Defense piercer | ignores damage reduction (armour, shells, Rampart) | Undertow already pierces |
| Controller | stuns, roots, slows, walls | Rampartroot's roots lean this way |
| Support | heals, shields, buffs | (open) |
| Zoner | denies areas with lasting hazards | Flashstep's embers lean this way |

## Built (in the game now)
| Form | Passive | Moves (AI order) | When its AI uses them |
|---|---|---|---|
| **Stormwick**, Skirmisher (Ember/Electric from its storm lantern, which is a lightbulb: current heats a filament and the filament glows, so every move shows spark, heat and light; fast: 1.4x speed; not pure melee, a short/mid-range evasive shooter that stays in claw range without taking too much) | **Lantern Charge**: running charges the lantern (its glow runs from warm orange to white-hot); at full charge its next damaging move is overcharged (x1.6) | **Flashstep** (mobility: a 62 px dash of pure light with glowing afterimages; its heat leaves burning embers, 3 per tick) | dodges an incoming attack, leaves straight after a claw, closes in from too far |
| | | **Lantern Flash** (utility, no damage): close enemies dazzled 1.6 s (cannot act, half speed) | an enemy is close and ready to act, or is charging its signature |
| | | **Raptor Rake** (damage 14, red-hot claws, range 24) | target within claw reach; its AI then flashsteps back out |
| | | **Wick Bolt** (damage 12, a white-hot filament bolt from the lantern with electric crackle, range 115; the target smoulders for 1.6 s, 2 damage every 0.4 s) | target in range |
| | Signature **Stormlantern** (player's choice) | the lantern's light paralyses every opponent on the field for 2.2 s, then the lantern core is hurled at one target (weakest, then nearest) | |
| **Scourmaw**, long-range Assassin (Tide/Hollow; glass cannon: 0.75x HP; keeps about 135 px away and backs off when approached) | **Absence**: holes, hover over a scour hollow, silt and echoes; surfaces fully now and then; strikes from beyond 110 px hit 1.3x | **Phase** (defence: 0.6 s, attacks pass through), **Deep Jet** (damage 18, range 150) | Phase when an attack is about to land or something closes in; Jet when in range |
| | Signature **Undertow** | the dive from the turn-based game: sinks into its hollow, a wake runs under the floor, it bursts up beneath the target (pierces defences), then dives home | |
| **Rampartroot**, Tank (Bloom/Stone; 1.5x HP, 0.8x speed; walks straight at you) | **Rampart**: never knocked back; takes 25% less while above half HP (defense piercers ignore this) | **Root Snare** (roots hold the target 1.2 s and cripple its movement abilities 2.8 s: no Phase, no Flashstep, slower) | target in range, evasive ones first |
| | | **Club Slam** (damage 16, close, heavy knockback) | target within reach |
| | | **Root Wall** (a curve of 9 root pillars behind the target for 6 s: blocks movement and stops shots; each shot breaks a pillar) | target keeps its distance |
| | | **Seed Pod** (lobbed damage 12) | target in range |

| **Ironvent**, Bruiser (Ember/Stone; 1.3x HP, 0.85x speed; walks straight at its target; moves are its turn-based ones) | **Stoke**: each hit it lands heats its vents 25; at 100 the next damaging move is x1.5 and vents | **Crest Ram** (mobility: a 0.4 s straight charge, 14, carries the target: a slam if a wall or rock is behind) | target 34 to 95 px away and not phased |
| | | **Cinder Claw** (15, close, target smoulders) | target within reach |
| | | **Vent Barrage** (12, range 85) | target in range |
| | Signature **Furnace Roar** | vents jet, it rears, a cone of fire and pressure: the target takes the damage, everyone else in the cone is carried back | |
| **Clinkerhide** (1.15x HP, 0.9x speed) | none yet | **Cinder Claw**, **Vent Barrage** | |
| **Cinderhide** | none yet | **Vent Barrage** | |

## Drafts for the other forms (not built)
| Form | Passive (draft) | Moves (draft) | Body and essence it comes from |
|---|---|---|---|
| **Kithflare** (Ember/Electric) | **Pilot Light**: standing still slowly fills the lantern; its next Ember Shot is bigger | **Ember Shot** (damage) | small lantern tail, learning to hold a flame |
| **Sparkwick** | **Static Crest**: an enemy that hits it in melee range takes a small shock | **Ember Shot**; **Spark Lash** (close tail whip that knocks the target back) | spiky crest, longer lantern tail |
| **Tallowroot** (Bloom/Stone) | **Taproot**: regains HP slowly while it stands still | **Seed Pod** (lobbed damage) | rooted, patient seed-pod carrier |
| **Huskward** | **Husk Plates**: hits from the front deal less | **Seed Pod**; **Husk Up** (utility: a shell that blocks the next hit) | husk armour on its back |
| **Rimefin** (Tide/Hollow) | **Barbel Sense**: its barbels feel attacks coming; it sidesteps the first one each fight | **Pressure Jet** (damage) | young catfish, barbels |
| **Riftfin** | **Riverbed Weight**: cannot be knocked back, a little slower | **Pressure Jet**; **Silt Cloud** (utility: a cloud where enemy projectiles slow and miss more) | squat bottom-dweller, stirs up the riverbed |

## Questions for Preston and Grok
1. Should the player's creature also use its signature on its own if the player never presses it? (Now: no; only the rival's AI fires its own.)
2. Number of moves per stage (1-2 / 2 / 3) and when passives unlock.
3. Whether Hollow forms beyond Scourmaw share Phase or absence (Riftfin is also Tide/Hollow).
