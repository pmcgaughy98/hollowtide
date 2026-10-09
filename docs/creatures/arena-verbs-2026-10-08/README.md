# The physical verbs: seize and hurl, lift and throw, pin and drag, beam clash (Claude, 2026-10-08 night)

Item 3 of Preston's "more dynamic like the 2D arena video" list, in his order after the Smite pass. The reference video's marquee moments (`docs/research/arena-comparison-2026-10-07/event-inventory.md`): Mewtwo grabbing and flinging, lifting a body or a boulder and bringing it down, a beam pinning Charmander to the wall and dragging it along it, and the Blastoise and Charizard beam clash. Each is now a verb in the arena. Every number is a draft for Grok.

## Seize and hurl (Plate Lunge)
Vitrecrag's Plate Lunge no longer just shoves. On a hit the target is **seized**: hoisted over the shell for 0.35 s (airborne, cannot act), then **hurled** the way Vitrecrag faces as a strong carry, so it slams into whatever is in the way (walls, rocks, root pillars) for slam damage and a daze. Rampartroot, a cocooned or Aegis-covered creature cannot be seized and is shoved instead. Labels: Seized, Thrown.

## Lift and throw (Kingstone Lift)
Oxbowarchon's second ability is now **Kingstone Lift**, replacing Ground Spikes at the final stage (Oathfen keeps the spikes). The nearest rock within 80 px rises beside it over half a second, its shadow staying on the floor and a jade ring pulsing round it, then flies to the target's spot and comes down: the rock shatters (part break: shards and dust), everyone within reach of the landing takes the rock's damage (boulder 22, stone 14, crate 9) and is launched, and the crowd banner calls it. With no rock in reach, the target itself is seized where it stands and flung away from Oxbowarchon: the psychic lift. Lifted rocks do not block movement or shots while they are up.

## Pin and drag (Molten Beam)
Vitrecrag's Molten Beam now lasts 0.9 s and **pins**: it shoves its target along its line at 70 px a second, and when the target meets the arena wall it is held there (Pinned: cannot move or act), burned in ticks of 3 every 0.15 s, while the beam swings after it at up to 1.6 radians a second and drags it along the wall, leaving scorch marks every few pixels. Rampartroot, cocoons and Aegis cannot be pinned.

## Beam clash
When two beams from opposing creatures meet head-on (a Deep Jet into a Molten Beam, a water beam into a rail), both stop at the meeting point and a **clash** forms there: a white core, rings, sparks thrown both ways, steam rising, a shake and a BEAM CLASH! banner. The stronger beam (more damage) pushes the point toward the weaker caster at 40 px a second, both beams held alive while it lasts; if it reaches the weaker caster, the stronger beam breaks through and lands its full damage ("Overpowered"). Head-on beams lie on one line, so the meeting is found by the tip reaching the other beam, not by a crossing.

## Check (`tools/debug/arena_verbs_check.gd`)
- Plate Lunge: Stormwick was seized, then thrown; it ended 11 px from the wall, took 32 in all (the lunge, then the slam) and was dazed 0.5 s.
- Kingstone Lift with a boulder in reach: the boulder rose (18 px at the sampled frame), the rock count went 5 to 4 at the landing, Stormwick took 22 and was launched.
- Kingstone Lift without a rock: Stormwick was seized and flung 38 px.
- Molten Beam: Stormwick was pinned at the wall, took 32 over the beam, 3 scorch marks on the wall.
- Beam clash between Vitrecrag's Molten Beam and Scourmaw's Deep Jet: a clash point formed; the stronger jet broke through for 55 on Vitrecrag, whose Thorns charm gave 17 back.
- Stills here: `seized.png`, `thrown.png`, `lift.png`, `landing.png`, `pinned.png`, `clash.png`.

## Known
- The seized creature rides as a sprite offset over the grabber; there is no grab animation on either creature yet.
- The clash does not yet compare power beyond the beams' damage numbers; a held-key tug (mash to push) is the next layer if Preston wants it.
- Kingstone Lift is a kit change on Oxbowarchon's final stage; the backline check's expectations were updated to match.
