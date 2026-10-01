# Ironvent Furnace Roar: impact effect sheet (Forge prompt)

Preston, 2026-09-28: the roar's hit on the target needs its own effect art. The battle currently reuses the old
Codex impact (`scenes/effects/ironvent_furnace_roar.tscn`). Attach `assets/sprites/creatures/ironvent.png` as the
style reference only; the creature itself must not appear on the sheet.

**Current version (Effect Forge input format: MODE ACTION, eight-frame material sequence):**

```text
MODE ACTION. Creature: Ironvent (Ember). Move: Furnace Roar. Source anatomy: the open jaws, with pressure fed from the glowing stepped dorsal vents along its ridge. Material: pressurized furnace heat, a crushing pressure wave of heat-light, not flame or a fireball; charcoal, deep red, orange and pale-gold pixels matching the attached Ironvent sprite, clean pixel clusters, dark outline. Direction: travels to the right. Target: an unseen creature at the right edge of each frame; do not draw Ironvent or the target. Charge: F1 a tight pale-gold glow gathers where the jaws would be; F2 it swells and the first curved heat band peels off. Contact: F3 two or three thick curved bands of heat roll right, concave toward the left, pale gold at the leading edge cooling to deep red; F4 the front flattens against the unseen target with a short bright pale-gold core and heat-shimmer lines bending around it; F5 the pressure bursts back and outward in a flattened ring with small glowing cinders thrown up and back. Aftermath: F6 the ring breaks into curved fragments and the cinders scatter, cooling to deep red; F7 faint wavy dark-red heat haze and a few embers drift up; F8 the last embers fade to charcoal. Eight frames, flat solid magenta background. No star-burst, no fireball, no smoke cloud, no lightning, no gradients or soft glow, no text.
```

First draft (older format, kept for reference):

```text
MODE: NEW; ACTION CLASS: EFFECT; FORM: Ironvent; MOVE: Furnace Roar (impact on the target). Effect art only: do not draw Ironvent or any target creature. Match the attached Ironvent sprite's pixel density, dark outline and ember palette: charcoal, deep red, orange, pale gold. The blast travels to the RIGHT and hits an unseen target at the right side of each cell. One effect per cell, six cells in a 3x2 grid, same size, flat solid magenta background.
F0 the leading pressure front arrives: two or three thick curved bands of heat, concave toward the left, pale gold at the leading edge cooling to deep red behind.
F1 impact: the front flattens against the unseen target, a short bright pale-gold core where it strikes, heat-shimmer lines bending around it.
F2 the pressure bursts back and outward: a flattened ring of heat and a spray of small glowing cinders thrown up and back to the left.
F3 cinders and short pressure streaks scatter, the ring breaks into a few curved fragments, orange cooling to deep red.
F4 residual heat haze: faint wavy dark-red lines and a few dim embers drifting upward.
F5 the last two or three embers fade to charcoal.
Crushing heat pressure, not an explosion: no star-burst, no fireball, no smoke cloud, no lightning, no gradients or soft glow, no text.
```

Afterwards: cut with the protocol (every frame, analyze, order), snap to Ironvent's palette, and replace the hit
effect in `data/moves/ironvent_furnace_roar.tres`.
