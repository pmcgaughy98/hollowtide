# Root Rampart, Rampartroot's signature (Claude, 2026-10-05, first version)

Preston picked it from three concepts. Rampartroot rears and roars (its shoulder shoot glowing), slams its seed-pod club down and plunges the shoot into the ground like a root; green charge cracks open across the field, root bursts and flying leaves race toward the opponent, then a towering column of roots bristling with pale husk spikes erupts under it, with dust rings and a flash. An attack, not a guard: the guard ultimate is reserved for Punchybuns (`DESIGN_RULES.md`).

Files:
- `data/moves/tallowroot3_root_rampart.tres`: Bloom, power 60, 2 uses, needs `podclub` and `shoot`. Rampartroot's body parts now list podclub, huskcollar, shoot, husk, claw. Essence, power and uses are provisional for Grok.
- `scenes/effects/tallowroot3_root_rampart.tscn`: reuses Furnace Roar's `pressure_field.gd` (field wave, suspense, big finale) with root art, using its two-frame eruption mode (no VFX sheet), `finale_scale` 5.
- Art: poses `pose_raise_raw.png`, `pose_slam_raw.png` (RD edits of Rampartroot, $0.18 each); stage `stage_0.png` (RD Pro, $0.18) as `assets/backgrounds/signature_stages/root_rampart.png`; eruption from `eruption_front_take2.png` (RD Pro, two takes $0.36) with the ground slab cut out by `build_pieces.py` (`eruption`, mirrored `eruption_alt`, small `field_roots`). Charge, dust, leaves and dust rings are Furnace Roar's pieces recoloured (free). Two RD VFX root sheets (`roots_a_0`, `roots_b_0`, $0.14) came out unusable (a static mound and a faint silhouette) and are not used.
- Sounds: `tools/build_root_rampart_sounds.py` synthesizes strain, slam, rootwave, eruption into `assets/audio/sfx/root_rampart/`, cued on frames 1, 4, 5, 7. Not listened to.

Checked: played from both sides, no script errors, 30 damage on Rimefin. `root_rampart_run1.png`, `root_rampart_v1.png`. Spend: $1.22. Balance $2.04.

Not yet: the rearing pose is mild (the club is not raised high), the root wave is small stills rather than animated growth, and the sounds have not been heard.

## Refinement pass (same day)
- New wind-up frame `raise_club.png`: rears with the seed-pod club swung high overhead (RD edit `pose_raise2_raw.png`, $0.18, then a second edit `pose_raise2_fix_raw.png`, $0.18, to remove a flat glowing patch the first one painted on the shoulder). Frames: roar, roar, club raised, slam.
- A glowing green-gold crack now splits the ground from Rampartroot to the opponent over the field wave, with short forks (`crack_color` on the effect; new optional feature in `pressure_field.gd`, off by default so Furnace Roar is unchanged).
- Sound levels rebalanced (4, 4, 2, 7).
