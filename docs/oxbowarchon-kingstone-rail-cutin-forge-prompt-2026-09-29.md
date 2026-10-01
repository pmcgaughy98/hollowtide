# Oxbowarchon Kingstone Rail: special-move close-up (Forge prompt)

Preston, 2026-09-29: a signature should get a title card like Molten Glass and Furnace Roar. None of the Kingstone
Rail or projectile sheets has a large close-up, so it must be generated. Until it exists, Kingstone Rail plays
without a cut-in (`attack_cut_in` is empty in `data/moves/oxbowarchon_kingstone_rail.tres`).

Attach `assets/sprites/creatures/oxbowarchon.png`. Run in the Attack Animation Forge.

```text
MODE: NEW; VIEW: FRONT; ACTION CLASS: CUT-IN; FORM: Oxbowarchon; MOVE: Kingstone Rail (signature). One single large close-up, not a sheet: the special-move title card shown on screen right before the rails fire. Oxbowarchon drawn much larger than its battle sprite and filling most of the frame, with more detail but the same pixel-art style, dark outline and palette as the attached approved front. Same view and facing as the attached front. Full body in frame, all four legs braced wide and low, tail and both rails fully visible, nothing cut off at the edges. The two jade rail pillars on its back point steeply up at the sky. Between them the jade sphere is fully charged: bright mint-green at the centre, deep emerald at the rim, with thin jade energy arcs linking it to both rails. Every jade seam and crystal on the body glows bright mint as if the energy is being drawn out of the whole body into the sphere; the dark stone and slate plates stay dark so the glow reads. The same energy is the drama, not new anatomy. Flat solid magenta background. No text, no lightning, no fire, no smoke cloud, no star-burst, no extra limbs, no second creature.
```

When it arrives: cut it, snap to Oxbowarchon's palette, save as
`assets/sprites/creatures/attacks/oxbowarchon_kingstone_rail/cutin.png` and link it from the move's `attack_cut_in`.
