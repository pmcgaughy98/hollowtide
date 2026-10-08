# Ironvent line, Furnace Roar, rocks and slams in the arena (Claude, 2026-10-07)

## The Ironvent line (Cinderhide, Clinkerhide, Ironvent; Ember/Stone)
- **Arena takes:** `tools/arena/rd_arena_sprite.py`, one take each from the in-game fronts at 96, 112 and 128 px ($0.54). Raw takes are in `docs/creatures/arena-starters-2026-10-07/forms/`. Background removal left a white fringe on Clinkerhide's top spikes; 254 pale pixels touching the outside were cleared, and the raw take is kept as `clinkerhide_raw.png`.
- **8 directions:** `tools/debug/rd_creature.py rotate` ($0.30). All three sheets came back in Tallowroot's layout (`TALLOW` in `tools/arena/slice_rotations.py`), checked cell by cell by eye.
- **Walks:** `tools/arena/rd_walk.py`, five facings each ($2.10; the other three are mirrors). They hold shape and colour across frames. Known flaw: Clinkerhide's south walk shows a thin tail curl above its head in a few frames.
- **Pipeline change:** `slice_rotations.py` and `build_small.py` now take creature names. A bare run reslices every creature and would overwrite Codex's colour-fixed facings, so always name the creatures.
- **Not done:** Codex's palette lock (`normalize_arena_palette.py`) has not been run on these three. Its form list is fixed to the first nine. **Codex:** this is yours if you want them colour-locked like the starters.
- **In game:** key 4 picks the line (F for its stage). Codex colour-locked all three forms the same day (`consistency/README.md`).
- **Kit (later on 2026-10-07, a draft for Grok):** built from the line's own turn-based moves and its design-rule roles ("starter, then bulk, then closer"), nothing invented.
  - **Cinderhide:** Vent Barrage (a gout of heat from the back vents, Ember, 12).
  - **Clinkerhide** ("bulky mid": 1.15x HP, 0.9x speed): Cinder Claw, Vent Barrage.
  - **Ironvent, BRUISER** (1.3x HP, 0.85x speed, walks straight at its target): **Crest Ram** (a 0.4 s straight charge at 230 px/s; the first enemy it reaches takes 14 and is carried, so a wall or rock behind it means a slam; stopped by rocks, root walls and the edge; a mobility move, so roots and Riptide stop it), **Cinder Claw** (15, close, leaves the target smouldering), **Vent Barrage** (12, range 85). Passive **Stoke:** every hit it lands heats its vents by 25; at 100 the vents stream embers and the next damaging move is x1.5, then it vents (a flash and "Vented"). The HUD shows heat under its meter.
  - Checked with `tools/debug/arena_ironvent_check.gd`: a staged Crest Ram carried Stormwick into the boulder (150 to 122 HP, slammed and dazed, boulder 60 to 44); four claws fill Stoke, the fifth does 32 instead of 21 and vents. Stills `kit_*.png`. Matchup numbers are in `docs/creatures/arena-balance-2026-10-07.md`.
- **Spent:** $2.94. RD balance after: $3.86.

## Furnace Roar (the line's signature, arena version, a draft)
Built from the turn-based move ("a full warning vent becomes a crushing blast": a pressure wave, not a projectile):
1. The arena dims to furnace light.
2. Heat pools in a cracked, glowing ring under Ironvent, with shimmer rings pulled inward.
3. The back vents jet heat columns, white at the root.
4. It rears and roars.
5. A cone of fire arcs edged in smoke blasts toward the target, scorching streaks into the floor and throwing debris.

The target takes the signature damage. **Every other enemy in the cone is carried back and dazed** (draft rule; Grok's call). It uses the existing Ironvent sounds (cry, buildup, vent hiss, roar, vent jet, blowdown, cool). Stills: `roar_*.png` here (3v3: Scourmaw took 32 damage, and a Stormwick in the cone was carried and slammed).

## Rocks and slams (steps 1 and 2 of the build plan in `docs/research/arena-comparison-2026-10-07/event-inventory.md`)
- **Rocks, resized from the video (later on 2026-10-07):** Preston said the first rocks were small, and they were: half a creature. Measured on the 1080p frames (`docs/research/arena-comparison-2026-10-07/boulder/`), the reference's boulder is about 2.3 creature-widths wide and 1.7 creature-heights tall, so there is now **one boulder (56 x 48 map pixels, 60 HP) against the top wall and two creature-sized stones (26 x 22, 30 HP)**. Drawn in code: flat facets lit from the upper left (cream to dark grey-brown), moss on top, seams, a heavy outline and a deep floor shadow, as in the reference. Its debris is now big angular shards (15 from the boulder) that fly, spin, land and stay, over a dark crater. The video's "rolling boulder" at 11 s turned out to be Golem's Rollout, a creature move; the inventory is corrected. No art spend: these are polygons, so the facet layout is one list in `ROCK_FACETS` if Preston wants it reshaped.
  - They block movement and shots: fireballs, beams and Wick Bolt hit the rock instead.
  - They take damage, crack at two thirds and one third, then shatter into flying chunks that land as rubble and stay for the fight.
  - **B** toggles rocks. They are on by default, including in the simulator.
- **Carrying hits:** pushes of 1.5 or more carry the target instead of nudging it. That's Club Slam (2.0), Deep Jet (1.6, new) and the Furnace Roar wave (4.0). Carried into a rock, a root wall or the arena wall, it is **slammed**: 8 damage credited to the attacker, 0.8 s daze with circling stars, a dust burst, and either a crack mark on the wall (stays) or damage to the rock. Rampartroot's Rampart still means no knockback.
- **Stills:** `wall_slam.png`, `rock_slam.png`, `rock_cracked.png`, `rock_rubble.png`, and the boulder beside Ironvent in `line_stage3.png`. Check script: `tools/debug/arena_rocks_capture.gd` (Godot `--fixed-fps 30`).
- **Not built yet:** step 3, the lift (raise a rock, slam it, throw it). That session suggested Rampartroot's roots tear it out; who gets it is Preston's and Grok's call.
