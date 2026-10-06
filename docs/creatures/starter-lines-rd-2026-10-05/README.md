# Starter trio art, Retro Diffusion (Claude, 2026-10-05)

Preston: Cinderhide, Tallowroot and Rimefin are the Hollowtide starters and will be pictured together, so they must match.

Installed:
- **Tallowroot** new pose: `starter_poses/tallowroot_front_take1.png`, sitting up like a guardian, clawed forefoot across its chest (Preston's pick). Back view: cell 3 of `starter_poses/tallowroot_rotation_3x3.png`. Files in `assets/sprites/creatures/tallowroot_2026_10_05/`; the first installed pose is kept in `docs/creatures/tallowroot-rd-2026-10-05/v1_installed/`.
- **Rimefin** redesigned as a river catfish (Preston: Coromon's starter is a shark; the Missouri River has catfish; it must be cool enough to compete for popularity). Bony head plate, narrowed eyes, whip barbels, serrated pectoral spines, frost-edged fins. Pose `starter_poses/rimefin_front_take1.png` (rearing on its fins, Preston's pick); back view: cell 7 of `starter_poses/rimefin_rotation_3x3.png`, mirrored. Files in `assets/sprites/creatures/rimefin_catfish_2026_10_05/`; `001_rimefin.tres` points at them. Both new starters use `battle_size` 1.1 (1.5x zoom), matching Cinderhide's on-screen height (about 230 px near side); see `starter_poses/starters_size_matched.png`. The old shark art is untouched and unused.
- **Cinderhide** keeps its original art (Preston's pick). The rearing takes in `starter_poses/cinderhide_front_take*.png` are not used.

Rejected and kept: the shark redraw (`shark_rimefin_rejected/`), the first, too-gentle catfish round (`catfish_round1/`), the second catfish round's crouch pose, the bottom-row pose takes and their rotations (`starter_poses/unused_take2_rotations/`).

Tallowroot Stage II and III takes (`tallowroot2_*`, `tallowroot3_*`) came out as near-copies of Stage I (same pose and size) because Stage I was sent as a reference. Not used. Next time: describe the new body and pose in words, reference the earlier stage only for colour, and give later stages a larger canvas.

Spend this session on this folder: about $3.30 including one interrupted Riftfin call that charged ($0.36) and the duplicate rotations ($0.20). `tools/debug/rd_creature.py` makes fronts and rotations with receipts. Checked: all three load in battle on both sides (`starter_poses/starters_in_battle.png`), no script errors. Not checked: attacks, catching.

## Evolutions (2026-10-05, later)

Made with the lesson above: each stage's new body and pose in words, the earlier stage only as a design reference, larger canvases (Stage II 192, Stage III 224, padded to 224 and 256). Files in `evolutions/`.
- **Tallowroot II** (`1702_tallowroot2`, placeholder name): `tallowroot2_front_take1.png`, then an RD head edit ($0.18) replacing the wolf-like head with a husk-helmet, blunt-snouted head to match the turtle-like body (Preston). Back: cell 3.
- **Tallowroot III** (`1703_tallowroot3`, placeholder name): `tallowroot3_front_take2.png` + the same head edit + a vine edit so the shoot rises from a split shoulder husk instead of wrapping the foreleg (Preston). Back: cell 3.
- **Riftfin** (`502_riftfin`): `riftfin_v2_front_take1.png`, the river-monster step (Preston's pick after the first round looked like a larger Rimefin). Back: cell 6.
- **Scourmaw**: two takes in `scourmaw_v2_front_take*.png` grown from the new Riftfin; waiting for Preston's pick. Not installed; Riftfin has no evolution link yet.
- Links: Tallowroot -> II -> III and Rimefin -> Riftfin. Roster check passes. Sizes keep each line at 1.5x, so stages grow (`battle_size` 1.1 / 1.3 / 1.45). `evolutions/evolutions_in_battle.png`.
- `install_evolutions.py` installs a stage from its pad and a rotation cell. Several rotations failed with "provider busy, not charged" and were retried later.
- Not checked: an evolution happening after a won battle, attacks, catching.

## Finals, starters and essences (2026-10-05, latest)

- Starters are now **Kithflare (Ember/Electric), Tallowroot (Bloom/Stone), Rimefin (Tide/Hollow)**. Cinderhide is no longer a starter; its line keeps Ember/Stone.
- **Tallowroot III** (`1703_tallowroot3`) replaced by `tallowroot3evo_front_take1.png` (husk horns, seed-pod tail club), back cell 3. Earlier Stage III art is in `evolutions/stage3_round1/` and `stage3_superseded/`.
- **Scourmaw** (`503_scourmaw`): `scourmawevo_front_take2.png` (no wood, barbel beard, twin spine rows), back cell 3. Riftfin now evolves into it.
- **Wayburn and Coalcrest retired** (Preston): data moved to `data/retired_creatures/`; art, moves and effects kept.
- **Kithflare II**: two takes in `evolutions/kithflare2_front_take*.png`, waiting for Preston's pick; Stage III follows from it.
- Known issue: the battle name panel cuts off dual essence names ("SCOURMAW TIDE/_").

## Kithflare II and the size pass (2026-10-05, latest)

- **Kithflare II** (`109_kithflare2`, placeholder name): `evolutions/kithflare2_front_take1.png` (Preston's pick), back cell 3; Ember/Electric; Kithflare now evolves into it. No Stage III yet (Preston stopped it). A Stage III call had already started and likely charged $0.36; its result can be recovered from `list_inference_jobs` if wanted (prompt in `evolutions/kithflare3_prompt.json`). A take-2 turnaround was also already submitted before it was stopped (~$0.10).
- **Size pass for everybody** (`tools/debug/size_plan.gd`): Stage I stands as tall as Cinderhide on the near side (228 px), Stage II about 1.2x, Stage III about 1.4x, in half-zoom steps. Changed: Ironvent 283 -> 324, Kithflare 178 -> 238, Fusern 112 -> 225, Oathfen 327 -> 262, Oxbowarchon 385 -> 330, Punchybun 186 -> 232, Kithflare II -> 298. Everything else already matched. Furnace Roar and Kingstone Rail replayed fine at the new sizes (`size_pass_check.png`). The saver rewrote those .tres files; every value was checked against the last commit (only ordering and defaults differ).
- Rerun `size_plan.gd -- apply` whenever a creature's art changes height.

## Kithflare III (2026-10-05, latest)

- `110_kithflare3` (placeholder name), Ember/Electric, linked from Kithflare II. Front: `evolutions/kithflare3_front_final.png` = new take 1 (lightning-rod crest fan, bolt horns, burnished copper, glowing seams) with the tail lantern upgraded by an RD edit ($0.18) and only the lantern area kept. Tail progression: Stage I bare ember, Stage II wire-caged ember, Stage III sealed amber-glass storm lantern in forged ribs with lightning arcs (Preston). Back: cell 3 (side profile; this turnaround had no back three-quarter, and Kithflare I's back is also a profile).
- Recovered the earlier, stopped Stage III job for free: `evolutions/kithflare3_from_take2_*.png` (grown from the other Stage II; not used).
- `size_plan.gd` now requires each stage to stand at least 8% taller than the one before; Kithflare III went from 298 to 398 px (2x). `evolutions/kithflare_line_in_battle.png`.
- Size fix (same day): Kithflare III's art was shrunk about 15% with RD's free k-centroid pixel downscale (transparency from the original), so it shows at 2x like Stage II and stands about 340 px instead of 398. Full-size originals kept in `evolutions/kithflare3_full_size/`. `evolutions/kithflare3_resized_in_battle.png`.
