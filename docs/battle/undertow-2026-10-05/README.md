# Undertow, Scourmaw's signature (Claude, 2026-10-05, first version)

Preston picked it from three concepts. A river-monster ambush: the stage becomes flooded shallows at night; Scourmaw sinks below a foam line and vanishes; water spouts race unseen through the shallows toward the opponent; a whirlpool opens under it; then Scourmaw bursts up jaws-first out of the water in a huge splash, with foam rings and a flash, and returns.

Files:
- `data/moves/scourmaw_undertow.tres`: Tide, power 60, 2 uses, needs `dredgejaw` and `barbels`. Scourmaw's body parts now list dredgejaw, barbels, fin, spines, plates. Provisional for Grok.
- `scenes/effects/scourmaw_undertow.tscn`: Furnace Roar's `pressure_field.gd` with water art, two-frame eruption mode, `finale_scale` 3.
- Art: stage `stage_0.png` (RD Pro, $0.18) as `assets/backgrounds/signature_stages/undertow.png`; the eruption from `eruption_front_take2.png` (RD Pro with Scourmaw's front as reference, two takes $0.36), its flat water band trimmed to an oval by `build_pieces.py`. Dive frames (sink1 to sink3, gone) are Scourmaw's own front lowered below a drawn foam line (free). Whirlpool, spouts, mist, spray and foam rings are Furnace Roar's pieces recoloured (free).
- Sounds: `tools/build_undertow_sounds.py` synthesizes plunge, surge, whirlpool, burst (with a faint Hollow undertone) into `assets/audio/sfx/undertow/`, cued on frames 2, 5, 7, 8. Not listened to.

Checked: played from both sides, no script errors, damage lands (7 on Rampartroot, a resisted matchup). `undertow_run1.png`, `undertow_v1.png`. Spend $0.54. Balance $1.50.

Not yet: Scourmaw's platform shadow stays visible while it is underwater; the spouts are still images, not moving wakes.

## Refinement pass (same day)
- Scourmaw's platform shadow now disappears while it is underwater: the battle hides a creature's platform during attack frames with no visible pixels (`battle_screen.gd`: `_platform_under`, `_frame_is_empty`).
- A wake races across the surface to the opponent: two spreading foam lines, a dark body shape under the water and two trailing barbels (`wake_color` on the effect; optional feature in `pressure_field.gd`, off by default).
- Sound levels rebalanced (5, -9, -2, 8): the surge bed was the loudest sound of all and is now under the rest.
