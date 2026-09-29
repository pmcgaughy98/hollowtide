# Vitrecrag lava pour: attack frames (2026-09-28)

## Live front view: v2 (2026-09-28)

Built with the approved whole-pose method (`docs/attack-sheet-protocol.md`) by `tools/build_vitrecrag_molten_glass.py`
into `v2/`: load (sheet2_f01), hole (sheet4_f01), flood (sheet2_f02), breakout (sheet2_f03), pour_a (sheet2_f04),
pour_b (sheet1_f04), recover (sheet2_f05), from `body_frames/` (sheets 1-2 `--block 3.67 --grid 2x3`, sheets 3-4
`--block 4 --grid 2x3`; sheets 3-4's bottom row is a leg close-up and is ignored). 140x128 canvas. Sequence and holds
are in `data/moves/vitrecrag_molten_glass.tres`. The sections below describe the earlier versions.

**Travel (2026-09-28, Preston: lava should flow toward the enemy, not beads):** the attack prompt calls for the pour
from the opening plus separate strand travel; the bead volley came from Claude's own Effect Forge brief and is
removed. Preston chose a **ground river**: the drawn pour lands at Vitrecrag's feet and `scripts/effects/lava_river.gd`
(`scenes/effects/vitrecrag_lava_river.tscn`) runs a river from that pool (`attack_river_offset (42, 55)`) to the
target's feet, drawn from art-pixel squares (outline, edge, body, core, bright bands travelling toward the target,
rolling lumps, swollen head). It arrives on the hit, keeps flowing while the pour lasts (target flinches), then cools
from the source end into crust with cracks and fades. The emitter is now `vitrecrag_glass_pour.tscn` (drips, splash
and pool under the pour only). Verified: hit at about 1.5 s, cooling visible, no errors.

## Recheck against the research (2026-09-28)

Only sheet 1 (`alt_old_sheet/`) was used so far. All four body sheets, front end, frame by frame (`all_frames/`):

| Frame | Shows | Use in v2 |
|---|---|---|
| sheet1/2/3/4 frame1 | Rest | Match check |
| sheet2_frame2 | Head lowers | Load |
| sheet4_frame2 | Head recessed into the opening, which glows orange with lava inside | Retraction-hole build-up (missing today) |
| sheet1_frame3, sheet2_frame3 | Whole shell floods with molten glow | Brace peak (do as a brightened in-game shell, not a pasted Opal shell) |
| sheet2_frame4 | Glass breaks out of the hole, first thin stream | Launch |
| sheet2_frame5, sheet1_frame5, sheet4_frame4 | Thick pours with pools, three different drawings | Alternate for a drawn flowing pour instead of colour scrolling |
| sheet3_frame3, sheet4_frame3 | Stream thins to a trickle (small spike artifact on the shell top) | Ending |
| sheet1_frame6, sheet2_frame6 | Head back out with a drip | Recovery (used now) |

Proposed v2 order: rest, head lowers, head retracts into the glowing hole, shell flood with brace tremble, break-out,
alternating thick pours during the volley (hit mid-pour), thinning, recovery drip, rest. In-game body throughout with
the head area transplanted per frame; eruption, rope and volley unchanged. Research extras: a 1-2 pixel recoil as the
glass erupts, and a longer hit freeze (about 0.1 s) for heavy moves.

## Live set: `transplant/` (linked in `data/moves/vitrecrag_molten_glass.tres`)

Preston asked for the head to pull into the shell while the glass pours, using the poses Opal already drew.
`tools/build_vitrecrag_pour_transplant.py` keeps the in-game body and legs from the main set below, lines
each `alt_old_sheet/` pose up with the in-game sprite (Opal drew it 3 to 9 px right and lower, differently
per frame), and pastes only the pose's head/front region plus its lava. Head: dips (01-02), tucked under
the glowing collar while pouring (03-04), back out with a drip (05). A few 1-2 px Opal splash flecks remain
near the snout and foreleg. `04_contact_b/_c` scroll the stream's colours 2 and 4 px down so a held pour flows.

Live timeline (move file): load 0.08 s, brace on 02 for 0.5 s (sinks and trembles one art pixel), launch
0.08 s, gush 04/04b/04c x4 at 0.11 s each (1.32 s), recovery 0.3 s. Hit on frame index 7, mid-gush.
`scenes/effects/vitrecrag_glass_gush.tscn` runs from launch to the end of the gush at the mouth
(offset 38,23 in frame pixels): Gush, Fling, Splash and Pool particles using the 2-4 px glass globs in
`assets/sprites/effects/vitrecrag/glass_glob*.png`, drawn from this sprite's own lava ramp.

`head_retract/` (from `tools/build_vitrecrag_head_retract.py`) slid the in-game head back instead. Preston
said it technically worked but left the leg exposed; it is kept for reference and is not linked.

## Main set (01-05): built from the in-game sprite

Every frame is `vitrecrag_official.png` itself on a 140x128 canvas (official placed at x+6), so the body,
legs and feet never change: no pop entering or leaving the attack. Only two things change:
- the shell lattice glow steps up Vitrecrag's own orange ramp (#9c3414 -> #dc5c24 -> #fc7424 -> #fc9c4c);
- the lava stream, pour and ember (cut from Preston's first Opal sheet) hang from the in-game mouth, with
  the pour's puddle on the foot line (y=125). The idle mouth flame is removed while lava flows.
All colours are the official sprite's 24. What is lost: the head dip, which would need a redrawn body.

| File | Beat | Suggested hold |
|---|---|---|
| 01_load.png | glow brightens one step | 80 ms |
| 02_windup.png | shell lattice at full glow | 250 ms |
| 03_launch.png | lava breaks from the mouth | 60 ms |
| 04_contact.png | full pour to the ground: **hit lands here** | 220 ms |
| 05_recovery.png | ember at the mouth, glow cooling | 120 ms |

## Alternates

- `alt_old_sheet/`: from Opal sheet 1, recoloured to the official palette. Has a real head dip and shell
  flood, but it is a different drawing of the body: legs change 43% entering, 37% leaving.
- `alt_forge_anchored/`: the 2026-09-28 Attack Forge run anchored to the official sprite. Good motion and
  colour, but Opal drew a longer body and wider stance anyway: legs change 50% entering, 56% leaving, and
  39% into the hit frame.
- `all_frames/`: every frame of the four original sheets.

## Wiring (not done)

`_drawn_attack_animation` hits on the second-to-last frame (04, correct) but uses one uniform
`attack_frame_seconds` and adds an engine lunge (+30 px). A pour needs unequal holds and no lunge; both are
small MoveData/battle changes still to make.
