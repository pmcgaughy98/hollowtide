# Shared move pool

Proposal, 2026-10-02. Not live. No move file or creature file was changed.

This is the learner list behind `move-body-gate.md` and the capstone-hybrid note in `docs/battle/move-structure-decisions-2026-09-28.md`. The same list per creature is `legal-learnsets.md`. The Gemini report `RPG Move Animation Scaling` suggested about 10 to 15 shared moves per essence. That number is a ceiling. It is not a quota. This file does not invent names to fill it.

A signature is in the pool only when the body gate says pass. An ultimate is not in the pool. A dropped move is not in the pool. A move that fails on the creature that equips it is not in the pool. Another creature may learn a pooled move only when it has every part in the Needs column. Essence does not waive a missing part.

Power and uses below are the live resources. Cinder Claw does not set power or essence in its file, so those are the script defaults: Ember, power 40. The balance proposal does not change this list. Molten Glass and Kingstone Rail stay ultimates, outside the pool, and their live numbers are still the old ones.

## Not in the pool

| Move | Why |
|---|---|
| Furnace Roar | Ultimate. Crest and vent. Ironvent only. |
| Molten Glass | Ultimate. Chamber and mouth. Vitrecrag only. |
| Kingstone Rail | Ultimate. Rail. Oxbowarchon only. |
| Plate Rake | Fails on Coalcrest. Needs a shell. Plate Lunge is the shell move that passes. |
| Club Cinder | On disk, 40 power, 6 uses. Not equipped. The live Ironvent kit uses Cinder Claw. |
| Fire Move | On disk, power 40, uses left at the default. Not equipped. |
| Fracture Dart, Window Flare, Kiln Star | On disk. Not equipped. Old Vitrecrag names. |

Do not delete those files from this pass.

## Ember signatures that pass

The equipped signatures below pass, and Molten Beam passes with them. No two of them are the same action on the same part. Ember is already over the ceiling of 10 to 15. Do not add Ember moves, and do not retire a name to force that count.

Crest Ram and Crest Signal share a part and a rung, and they are not the same action. Crest Ram is a contact strike. Crest Signal is a patterned broadcast. Both stay. Vent Row and Vent Barrage share a rung, and the row is not the coordinated channels. Hex Cut, the shelf moves, and Plate Lunge used to share the word shell. The bodies do not.

### Small vent

Learners: Cinderhide, Clinkerhide, Ironvent.

| Move | Power | Uses |
|---|---:|---:|
| Ember Flick | 32 | unlimited |
| Coal Spit | 50 | 4 |

Cinderhide's breaks are small. The physiology brief says it cannot sustain a large discharge, so it does not learn the next two groups.

### Vent row

Learners: Clinkerhide, Ironvent.

| Move | Power | Uses |
|---|---:|---:|
| Vent Row | 50 | 4 |
| Slagburst | 60 | 2 |

### Channels

Learner: Ironvent.

| Move | Power | Uses |
|---|---:|---:|
| Vent Barrage | 50 | 4 |

### Claw

Learners of Cinder Claw: Cinderhide, Clinkerhide, Ironvent. Vent Rake needs claw and vent, and those same three have both. Coalcrest's claw is unconfirmed, so it is not a learner.

| Move | Needs | Power | Uses |
|---|---|---:|---:|
| Cinder Claw | claw | 40 | 6 |
| Vent Rake | claw, vent | 40 | 6 |

### Ridge, brow, heavy tail

Coal Spit is with the vent moves. It needs a vent. Learners: Cinderhide, Clinkerhide, Ironvent. It is 50 power, 4 uses. Vitrecrag does not learn it.

| Move | Needs | Learners | Power | Uses |
|---|---|---|---:|---:|
| Spineflare | ridge | Cinderhide, Ironvent | 60 | 2 |
| Brow Shear | brow | Cinderhide, Clinkerhide, Ironvent | 32 | unlimited |
| Clinker Toss | heavytail | Clinkerhide, Ironvent | 40 | 6 |

The signal line does not learn Clinker Toss. A forked tail does not shed a clinker.

### Crest and throat

| Move | Needs | Learners | Power | Uses |
|---|---|---|---:|---:|
| Crest Ram | crest | Ironvent, Coalcrest | 32 | unlimited |
| Crest Signal | crest | Ironvent, Coalcrest | 32 | unlimited |
| Longfire Burst | crest, throat | Coalcrest | 60 | 2 |
| Furnace Bolt | throat | Kithflare, Wayburn, Coalcrest | 40 | 6 |

Furnace Bolt stays a throat move. The name overclaims a furnace. Ironvent has a crest and no throat, so it does not learn Longfire Burst or Furnace Bolt. Crest Ram stays a contact strike. Crest Signal stays a broadcast. Same learners, different hits.

### Signal line

Learners of a marking move: Kithflare, Wayburn, Coalcrest. No other live body has the marking.

| Move | Needs | Power | Uses |
|---|---|---:|---:|
| Relay Arc | marking | 32 | unlimited |
| Signal Spark | marking, throat | 32 | unlimited |
| Shoulder Drive | marking | 40 | 6 |
| Shoulder Kindle | marking | 50 | 4 |
| Wayflare | marking, throat | 60 | 2 |
| Handoff Dash | marking, splittail | 60 | 2 |
| Tail Brake | splittail | 40 | 6 |
| Tail Shutter | splittail | 50 | 4 |

Shoulder Drive is a body check. The marking is the requirement, not a shoulder. Tail Shutter's name overclaims a shutter. Among bodies in the gate, the three signal forms are the only learners of every row in this group, because each of them has the marking, the throat, and the splittail.

### Hex edge, shelf, seam, buttress

All three kiln forms have a shell. No equipped move asks for shell by itself, so they do not share a signature.

| Move | Needs | Learners | Power | Uses |
|---|---|---|---:|---:|
| Seam Spark | seam | Fusern | 32 | unlimited |
| Hex Cut | hexedge | Fusern | 40 | 6 |
| Ember Pellet | seam | Fusern | 50 | 4 |
| Kilnburst | seam | Fusern | 60 | 2 |
| Glass Spur | shelf | Slagglass | 32 | unlimited |
| Shield Flare | shelf | Slagglass | 40 | 6 |
| Furnace Shard | shelf | Slagglass | 50 | 4 |
| Glassburst | shelf | Slagglass | 60 | 2 |
| Plate Lunge | shell, buttress | Vitrecrag | 50 | 4 |

Furnace Shard's name overclaims a furnace. The hit leaves the shelf. Shield Flare is damage. Its file sets no kind, so it is not a guard.

### Chamber

Molten Cannon needs a chamber and a mouth. Vitrecrag is the only body in the gate with both. It stays a signature, 60 power, 2 uses. Molten Beam needs the same two parts. It is the sustained connection, 40 power, 6 uses. The cannon is the heavy launched mass. Both stay. Beam stays equipped and does not get new art. Fusern has a seam and no chamber, so it cannot learn either. Cinderhide has a mouth and a vent, and no chamber.

## Who learns nothing here

- Rimefin. Fin and jaw. None of these moves use either. A Tide jaw strike would be the honest first addition, and it does not exist yet. Do not name it here.
- Oxbowarchon. Rail only, and that move is its ultimate. Bound jade is not a shell. Slab is not a part until the approved sprite is checked, so there is no shared Stone move yet.
- Punchybun. Fist, ferret tail, and star. None of the equipped signatures use those parts. A fist contact can be added later. Do not name it here, and do not give it a claw move or anyone else's ultimate.

Gale, Bloom, Hollow, Electric, and Ice have no shared moves in this file. Their lines are not in the body gate until an approved sprite shows the parts. A brief is not a part.

## Where a shared move leaves the body

`MoveData.aim` is the name of a key in `CreatureData.aim_points`. Empty, or a key the creature does not have, keeps the old launch point. The vectors live on the creature, in art pixels from the centre of the front sprite. This file does not copy those vectors.

Vent Rake, Brow Shear, Crest Ram, Hex Cut, Tail Brake, Handoff Dash, and Plate Rake are contact. The creature lunges and the slash plays on the target. The first six name the part that hits. Plate Rake names nothing, stays equipped on Coalcrest, and battle still hides it. Cinder Claw, Shoulder Drive, and Plate Lunge were already contact. Cinder Claw, Shoulder Drive, and Plate Lunge keep `aim` empty where they already did, because the creature itself travels and the hit is at contact. Furnace Roar, Molten Glass, and Kingstone Rail keep `aim` empty. Their drawn emitters already have their own offsets. Molten Cannon names `mouth`, and its drawn offset stays, so the pour does not move. Molten Beam names `mouth` and launches from that point. Plate Rake names nothing. Coalcrest has no shell point, and battle already hides that move. `core` is on Vitrecrag's window. Molten Glass does not name it.

| Leaves | Moves |
|---|---|
| vent | Ember Flick, Coal Spit |
| claw | Vent Rake |
| ventrow | Vent Row, Slagburst |
| channels | Vent Barrage |
| ridge | Spineflare |
| brow | Brow Shear |
| heavytail | Clinker Toss |
| crest | Crest Ram, Crest Signal, Longfire Burst |
| throat | Furnace Bolt, Signal Spark, Wayflare |
| marking | Relay Arc, Shoulder Kindle, Handoff Dash |
| splittail | Tail Shutter, Tail Brake |
| seam | Seam Spark, Ember Pellet, Kilnburst |
| hex | Hex Cut |
| shelf | Glass Spur, Shield Flare, Furnace Shard, Glassburst |
| mouth | Molten Beam, Molten Cannon |
