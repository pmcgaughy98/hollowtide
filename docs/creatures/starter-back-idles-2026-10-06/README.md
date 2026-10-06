# Starter-line back-view idles (Claude, 2026-10-06)

All nine starter-line forms now have an 8-frame animated idle on the player's side too, from Retro Diffusion's `rd_advanced_animation__idle` on each form's current back sprite ($0.14 each; $1.40 total including one redo). Stormwick's first sheet flashed the whole body white on four frames (the prompt said "crackles") and is kept in `rejected/`; the redo asked for a steady lantern glow.

- Frames: `assets/sprites/creatures/idle_2026_10_05/<file>/back_f0..back_f7.png`, cut by `tools/debug/slice_idles.py <dir> back`, placed back on the back sprite's own canvas with frame 0's feet and centre lined up (Stormwick's sheet came back 216 px for 219).
- Data: new `CreatureData.back_idle_frames`; `tools/debug/install_idles.gd` installs them. It now keeps a front loop someone else installed from another folder (Codex's Kithflare tail-outline idle).
- Battle: `battle_screen.gd` `_apply_idle` plays `idle_frames` on the foe's side and `back_idle_frames` on the player's side; a back view without a loop keeps the tuned procedural breath. Same period per form as the front loop.
- Checked: feet stay on one row except Rampartroot, whose rear legs shift up to 9 px in the second half of the loop, below the message-box line. `tools/debug/back_idle_check.gd` confirmed all 8 frames cycle in a live battle; four battle captures ran with no script errors (`back_idles_in_battle.png`).

## Front vs back (`front_back_compare.png`)
The loops match their back art. The back art itself does not always match the front:
- **Riftfin:** the front is a low, wide, big-mouthed catfish; the back is a tall, narrow ridge of spiked plates. Reads as a different creature. (Codex's rear refinement did not pass review.)
- **Rimefin:** the front has a bulky grey head; the back is a slim blue curled fish. Related but weak.
- **Rampartroot:** the front is buried in husk armour; the back shows much more green body. Acceptable.
If any back sprite is replaced, rerun `rd_idle.py <tres> <dir> "<hint>" back`, `slice_idles.py <dir> back`, then `install_idles.gd`.
