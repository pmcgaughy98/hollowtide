# Move body gate

Preston, 2026-10-02. This is the check behind the ultimate and signature rule in `DESIGN_RULES.md`. A creature learns a move only when it has every part listed here. Essence does not fill a missing part. Parts come from the approved sprites and from `ember-creature-physiology-and-action-brief-2026-09-27.md`. A roster brief for a line with no approved sprite is not a part. Do not add a part the sprite does not show.

No live move or creature file was changed.

## Parts that exist

claw, brow, fusedbrow, crest, vent, ventrow, channels, mouth, ridge, heavytail, splittail, tail, throat, marking, shell, hexedge, shelf, buttress, seam, chamber, fin, jaw, rail, fist, star

A new part is added only when a real body has it. Shoulder is not a part. Old text uses that word for forelimb mass, a crust seam, or the retired shoulder sacs and chambers. Those sacs and chambers were rejected. Slab is not a part yet. The stone-line proposal binds jade and forbids a turtle shell, and the approved sprite has not been checked into this list.

A tail is not one part. Heavytail is the thick tail that sheds a clinker. Splittail is the signal line's forked counterweight. Tail, with no prefix, is only Punchybun's ferret tail. It is neither of the other two, and no equipped move uses it.

Shell alone teaches no equipped move. Fusern's cut is a hexagonal edge. Slagglass's glass moves leave a shelf that lifts. Plate Lunge is a front plate driven by buttress legs. A short brow plate is not a fused brow. A small heat break is not a vent row, and a vent row is not Ironvent's coordinated channels.

## Who has what

| Creature | Parts | Does not have |
|---|---|---|
| Cinderhide | claw, brow, vent, mouth, ridge | fusedbrow, ventrow, channels, shell, chamber, fin, rail |
| Clinkerhide | claw, fusedbrow, vent, ventrow, heavytail | channels, ridge, crest, shell, chamber, fin, splittail |
| Ironvent | claw, fusedbrow, crest, vent, ventrow, channels, mouth, ridge, heavytail | shell, fin, splittail |
| Kithflare | splittail, throat, marking | claw, shell, chamber, vent, fin, heavytail |
| Wayburn | splittail, throat, marking | claw, shell, chamber, vent, heavytail |
| Coalcrest | crest, throat, marking, splittail | shell, chamber, vent, fin, heavytail |
| Fusern | shell, hexedge, seam | shelf, buttress, claw, mouth, chamber, fin |
| Slagglass | shell, shelf | hexedge, seam, buttress, claw, mouth, chamber, fin |
| Vitrecrag | shell, buttress, chamber, mouth | hexedge, shelf, seam, claw, fin, rail, vent |
| Rimefin | fin, jaw | claw, shell, vent, mouth, chamber |
| Oxbowarchon | rail | claw, fin, vent, chamber, shell |
| Punchybun | fist, tail, star | claw, shell, chamber, vent, fin, heavytail, splittail |

Punchybun is the Stage I design only. Fist is not a claw. Star is the ultimate's part, and no other line has it.

Coalcrest's claw is unconfirmed. The physiology brief says Plate Rake reads as a crest or a claw, not a plate. Do not list claw, and do not teach Cinder Claw, until the sprite is checked. Plate Rake still fails because there is no shell. The full learner list is `shared-move-pool.md`. That file is a proposal. It does not change who equips what.

Oxbowarchon does not learn Plate Lunge or any other shell move. Bound jade is not the kiln carapace. Kingstone Rail still needs the rail.

## Equipped moves

Ultimate means the scene-taking move. It is not teachable. Signature means another body may learn it if it has the parts.

| Move | Kind | Needs | On | Result |
|---|---|---|---|---|
| Ember Flick | signature | vent | Cinderhide | pass |
| Vent Rake | signature | claw, vent | Cinderhide | pass |
| Coal Spit | signature | vent | Cinderhide | pass |
| Spineflare | signature | ridge | Cinderhide | pass |
| Brow Shear | signature | fusedbrow | Clinkerhide | pass |
| Clinker Toss | signature | heavytail | Clinkerhide | pass |
| Vent Row | signature | ventrow | Clinkerhide | pass |
| Slagburst | signature | ventrow | Clinkerhide | pass |
| Crest Ram | signature | crest | Ironvent | pass |
| Cinder Claw | signature | claw | Ironvent | pass |
| Vent Barrage | signature | channels | Ironvent | pass |
| Furnace Roar | ultimate | crest, vent | Ironvent | pass |
| Signal Spark | signature | marking, throat | Kithflare | pass |
| Tail Brake | signature | splittail | Kithflare | pass |
| Shoulder Kindle | signature | marking | Kithflare | pass |
| Handoff Dash | signature | marking, splittail | Kithflare | pass |
| Relay Arc | signature | marking | Wayburn | pass |
| Shoulder Drive | signature | marking | Wayburn | pass |
| Tail Shutter | signature | splittail | Wayburn | pass, name overclaims |
| Wayflare | signature | marking, throat | Wayburn | pass |
| Crest Signal | signature | crest | Coalcrest | pass |
| Furnace Bolt | signature | throat | Coalcrest | pass, name overclaims |
| Plate Rake | signature | shell | Coalcrest | fail |
| Longfire Burst | signature | crest, throat | Coalcrest | pass |
| Seam Spark | signature | seam | Fusern | pass |
| Hex Cut | signature | hexedge | Fusern | pass |
| Ember Pellet | signature | seam | Fusern | pass |
| Kilnburst | signature | seam | Fusern | pass |
| Glass Spur | signature | shelf | Slagglass | pass |
| Shield Flare | signature | shelf | Slagglass | pass |
| Furnace Shard | signature | shelf | Slagglass | pass, name overclaims |
| Glassburst | signature | shelf | Slagglass | pass |
| Molten Glass | ultimate | chamber, mouth | Vitrecrag | pass |
| Molten Beam | signature | chamber, mouth | Vitrecrag | pass, stays equipped |
| Plate Lunge | signature | shell, buttress | Vitrecrag | pass |
| Molten Cannon | signature | chamber, mouth | Vitrecrag | pass |
| Kingstone Rail | ultimate | rail | Oxbowarchon | pass |

Rimefin has no equipped move. Strike needs no part. It stays legal.

## What fails

**Plate Rake on Coalcrest.** The move needs a shell. Coalcrest's approved body is crest, throat, marking, and splittail. The physiology brief already said this reads as a crest or a claw, not a plate. Leave the live file alone until Preston wants the kit changed. Do not teach Plate Rake to Coalcrest, Kithflare, Wayburn, or Rimefin. Plate Lunge is a different move. It needs a front plate and buttress legs, which Vitrecrag has. Plate Rake stays out of the shared pool.

**Furnace Bolt, Furnace Shard, and Tail Shutter.** The names say furnace or a mechanical shutter. Coalcrest has no chamber, Slagglass's hit comes off the shell, and Wayburn's tail flash is the signal at the split tip. The forge prompt for Tail Shutter forbids a shutter. All three stay legal as the parts in the table: throat, shelf, and splittail. Do not retune them into chamber moves, and do not rename the files in this pass.

**Molten Beam on Vitrecrag.** The move needs a chamber and a mouth. Vitrecrag has both, so the gate leaves it equipped and selectable. An older note said it was dropped on 2026-09-28. That note does not unequip it. Beam does not get new art. Molten Glass still pours from the mouth.

**Furnace Roar** passes. It needs the crest and the vents. The forge pose opens Ironvent's existing jaw. That jaw is not a second gate. Cinderhide has a vent and no crest. Coalcrest has a crest and no vent. Neither learns this ultimate. Slagburst stays a vent move. Its old "shoulder crust" is the grown seam, not a part named shoulder.

## Who else may learn a signature

A pass in the table is not an exclusive. Another creature may learn that move when it has every part in the Needs column.

- Rimefin can learn none of the claw, vent, shell, chamber, rail, or marking moves. A jaw strike of Tide essence would be the honest addition, and it does not exist yet.
- Cinderhide can learn Coal Spit, Vent Rake, Spineflare, and Cinder Claw. Coal Spit leaves a heat break, so it needs a vent. Its brow plates are short, so it does not learn Brow Shear. Its breaks are small, and the brief says it cannot sustain a large discharge, so it does not learn Vent Row, Vent Barrage, or Slagburst. Vitrecrag's mouth pours and casts. It does not learn Coal Spit. Cinderhide cannot learn Molten Cannon. It has a mouth and a vent, and it does not have a chamber. It cannot learn Shoulder Drive. It has no marking.
- Shoulder Drive is a body check. The marking is what makes it this line's move. Kithflare and Coalcrest may learn it. A forelimb without the marking may not.
- Ironvent can learn Cinder Claw and the vent moves. It cannot learn Plate Lunge.
- The kiln forms do not share a current signature. Fusern has the hex edge and the narrow seam. Slagglass has the lifting shelf. Vitrecrag has the buttress and the chamber. Fusern cannot learn Molten Cannon, the shelf moves, or Plate Lunge. No kiln form can learn Cinder Claw, Shoulder Drive, or a tail move.
- Clinker Toss stays on the heavy tails. The signal line does not learn it. Tail Brake and Tail Shutter stay on the split tails. Clinkerhide and Ironvent do not learn them.
- Oxbowarchon can learn Kingstone Rail only as its own ultimate. It cannot learn a shell move.
- Punchybun learns none of the equipped signatures. Its tail is not a heavytail or a splittail. It can learn a fist contact later, and that move does not exist yet. It cannot learn a claw move, Shoulder Drive, Molten Cannon, or anyone else's ultimate. The star shield stays its ultimate.
