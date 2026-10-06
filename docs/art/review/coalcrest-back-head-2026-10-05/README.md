# Coalcrest back view with a painted head (Claude, 2026-10-05), NOT USED

Preston kept Codex's back view the same day; this is a retained candidate only. The real problem is the back's too-thin tail and stub rear leg, which the default message-box framing hides.

Problem: the installed back (`kithflare_line_rechecked_2026_10_04/coalcrest_back_occluded_leg_v3.png`) came from RD rotation cell 3, where the neck stops in a flat cut at row 28. No RD rotation cell (`docs/creatures/kithflare-line-rd-2026-10-01/`) shows a readable head from behind, so a re-roll was not bought.

Fix, free: `build_back_head.py` clears the flat neck top and sets Coalcrest's own head from the installed front (`coalcrest_rechecked_2026_10_04/coalcrest_front.png`, crop x 100-130, y 29-47, no cream throat) onto the neck at offset (-10, -6), then removes the sail-edge nub behind the skull and one stray stripe speck. The result is a side-profile head, the same convention as Kithflare's back. Codex's leg-occluded body, sail and lantern tail are unchanged.

Installed: `assets/sprites/creatures/coalcrest_back_head_2026_10_05/coalcrest_back.png`, wired as `back_sprite` in `data/creatures/105_coalcrest.tres`. The old file is untouched. Comparison: `front_old_new_3x.png` (front, old back, new back).
