# Moves as hitboxes (Claude, 2026-10-08 night, item 4)

Item 4 of Preston's "more dynamic like the 2D arena video" list, and the place where Smite's aimed, dodgeable abilities land in the arena (`docs/research/smite-references-2026-10-08.md`, section 6). Until now a move resolved on its target the instant its telegraph ended, wherever the target stood. Now:

## Melee moves are sweeps
Every melee move (claw, pounce, Cinder Claw, Club Slam, Glass Spur, Plate Lunge, Slab Vortex, Vent Blast, Spark Jab, Shear) becomes a **sweep** when its telegraph ends: an arc 1.25 radians either side of the aim, the move's reach plus 8 px, drawn as a pale wedge in front of the user that brightens at the **active moment** 0.07 s later. If the target is still inside the arc then, the move lands exactly as before (its own damage, push, holds, the chain, the hook). If it has stepped out, the move **whiffs**: "Whiff" over the user, a slash in the air, and the user still pays the cooldown and the recovery, which is the punish window from the frame-data pass. The active moment is the "active" slot the frame table lacked.

## Area moves and lobs land where the telegraph showed
Seed, Riptide, Root Rampart's run, Ground Spikes, Still Water and Molten Cannon now land on the spot their telegraph ring showed when the wind-up began, not on the target's live position. A target that walks off the ring is missed (Ground Spikes hit whoever stands within 18 px of the spot; Riptide says "Caught" only if the target is still in it). Lifted rocks (Kingstone Lift) still fly to the target's live spot on purpose: that one is a pull.

What this means in play: the dodge step, the dash, Blink and plain walking all beat melee and area moves now, for the steered creature and the AI alike. The AI's dodge reads the telegraph and steps at the right moment; a player does the same with Space. Beams, rails and shots were already things in space; lobs already flew to a point.

## Check (`tools/debug/arena_hitbox_check.gd`)
- A Cinder Claw landed for 21 on a target that stayed in the arc; when the target stepped behind Ironvent during the telegraph the claw whiffed (the 2 it took was the earlier smoulder).
- Ground Spikes erupted 0 px from where the telegraph showed after the target had walked 40 px off it, and the target took nothing; on a target that stayed they took 21 and held it 0.77 s.
- Stills here: `sweep_land.png`, `sweep_whiff.png`, `spikes_miss.png`.
- `cast_as(i, m)` was added to the arena as the hook that starts a telegraphed move the way J and the AI do.

## Known
- Counter Jab (a dash then a punch) and the untelegraphed guards are not sweeps; they go at once.
- A sweep lands on its intended target only; the hook's cleave and Slab Vortex's ring still reach the others through their own logic once the move lands.
- Mouse aim is still not in; the steered creature auto-faces its target (Q/E) when a move goes.
- **Grok:** the arc, the 0.07 s active delay and the reach margin are drafts.
