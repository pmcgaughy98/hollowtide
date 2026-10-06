# Tallowroot, Bloom starter, Stage I (Claude, 2026-10-05)

Preston: "add new bloom starter then make it with retro". Tallowroot is the existing name and brief (Line 17, `docs/creatures/creature-roster-draft.md`; job in `DESIGN_RULES.md`: the chart answer to Stone). Later stages stay unnamed.

Art, Retro Diffusion:
- Front: `rd_pro__default`, 160x160, two takes with Cinderhide's front as the style reference (`generate_front.py`, `prompt_front.json`, `receipt_front.json`). $0.36. Take 1 kept: moss-green seed-burrower, tapered snout, rootlike claws in the earth, angular husk points, husked shoulder pod with a cream sprout. Take 2 rejected (it copied Cinderhide into an unrelated scene). `review_takes_3x.png`.
- Back: `rd_advanced_animation__rotate` from `front_pad_192.png` (`generate_rotation.py`). $0.10. Back three-quarter facing up-right is cell 3 of `rotation_3x3_0.png`; no clipped edges.
- Total $0.46. Balance after: $4.60.

Game: `data/creatures/1701_tallowroot.tres` (Line 17 stage I, Bloom), sprites in `assets/sprites/creatures/tallowroot_2026_10_05/` (front padded to 192 to share the back's pixel scale), `battle_size` 1.35 (2x zoom, about Cinderhide's size). Default 60 stats, no moves (Strike), no body parts, no evolution until Grok sets its job, kit and numbers. Roster check passes. `tallowroot_in_battle_final.png` shows both sides. Not checked: an attack, a catch.
