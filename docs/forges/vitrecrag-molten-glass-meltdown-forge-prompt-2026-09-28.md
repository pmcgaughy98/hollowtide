# Vitrecrag Molten Glass (signature meltdown): effect modules (Forge prompt)

Preston, 2026-09-28: "spice up" the Molten Glass signature. The meltdown currently draws its flood, embers and
light in code (`scripts/effects/glass_meltdown.gd`, `glass_flood.gdshader`). These five modules add drawn
set-pieces on top. Attach `assets/sprites/creatures/vitrecrag_official.png` as the style reference.

```text
MODE MODULES. Creature: Vitrecrag (Ember). Move: Molten Glass, its signature, a factory core meltdown like a crucible of molten metal tipping over. Source anatomy: the ring collar under the front of its shell, where its small head pulls in and the glass pours out. Material: molten orange-gold glass, thick and glossy, pale gold at the hottest core cooling through orange to deep red, with a dark outline; matching the attached Vitrecrag sprite's palette and clean pixel clusters. Direction: flows to the right along the ground. Target: an unseen creature to the right; do not draw Vitrecrag or the target. Five separate modules, each in its own cell, flat solid magenta background:
M1 Charge / rupture: the moment the crucible cracks open at the collar, a bursting crown of molten glass spraying up and forward from one point, heavy droplets flung outward.
M2 Flood front: the rolling leading edge of a molten glass flood seen from the side, a thick curling lip about to break forward, bright core, darker cooling skin on top.
M3 Contact: a tall splash crown of molten glass erupting where the flood hits the target, sheets of glass rising and folding back down.
M4 Loose globs: six separate molten glass globs and droplets of different sizes in mid-air, each with a short drip tail.
M5 Aftermath: a patch of cooling glass on the ground, dark crust plates split by glowing orange cracks, with a few cooled glass shards catching a pale highlight.
No flames, no smoke clouds, no star-burst, no lightning, no gradients or soft glow, no text or labels.
```

Planned use: M1 at the collar on the rupture frame (with the white-hot flash); M2 riding the flood's edge as it
spreads; M3 on the target at the hit; M4 thrown from M1 and M3; M5 left under the target as the flood cools.
