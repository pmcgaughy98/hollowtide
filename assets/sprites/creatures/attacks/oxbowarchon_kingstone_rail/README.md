# Oxbowarchon: Kingstone Rail (signature)

Built 2026-09-29 from Preston's three sheets in OneDrive `Documents/HollowTide Sprites/Effect Sheets/Oxbowarchon Effect/` (`Kingstone rail 1-3.jfif`, originals untouched). Direction (Preston): the rails swing up to point at the sky, a sphere of the Kingstone's power builds between them while Oxbowarchon braces, then it releases.

- **Research read first:** `Monster Taming 2D Animation Research` and `Pixel Art Combat Animation Pipeline Research`. They call for a long anticipation hold, a very short release, a held contact, and a heavier hit for bigger moves.
- **Summer check:** the Summer MCP was connected; the editor was open.

## Cutting

- **Sheets 1 and 2:** cut with `tools/cut_forge_frames.py --grid 3x2 --block 2.62`, since their black grid lines join every cell into one frame. Block 2.62 gives a lower-body width of 121 to 124 px against the in-game 120.
- **Sheet 3:** cropped by hand in a 3-2-2 layout, because its glows join frames together.

All 19 frames are in `frames/` as `railN_fNN`.

## Every frame

The body and anatomy match the approved front in all of them, with no drift in size or legs. Differences are the rails and effects only.

| Frame | What it shows | Beat | Decision |
|---|---|---|---|
| rail1_f00 | Rails forward as on the idle; the Kingstone glows | rest | **Keep** as `rest` |
| rail1_f01 | Rails swung up to the sky, stance unchanged | anticipation | **Keep** as `raise` |
| rail1_f02 | A small sphere at the rail tops, Kingstone flaring, lilac arcs (pink bleed) | charge | Reference; rail2_f02 is cleaner |
| rail1_f03 | Swirling vortex sphere between the rails | charge | **Keep** as `swirl` |
| rail1_f04 | Beam streaking up-right from one rail, starburst at the top (clipped by the cell) | release | **Keep** as `shot` |
| rail1_f05 | Rails lowered forward, faint afterglow | recovery | **Keep** as `spent` |
| rail2_f00 | Rest, near-identical to rail1_f00 | rest | Reference |
| rail2_f01 | Rails up, near-identical to rail1_f01 | anticipation | Reference |
| rail2_f02 | Small sphere, clean, between the rail tops | charge | **Keep** as `kindle` |
| rail2_f03 | Full sphere with power rings orbiting it | peak charge | **Keep** as `full`. The tail is clipped by the sheet cell, so it takes the tail from `swirl` |
| rail2_f04 | Huge white starburst at the rail tips (pink halo removed) | release | **Keep** as `burst`. Same tail fix |
| rail2_f05 | Rails forward, puff of afterglow; tail clipped | recovery | Rejected: the tail is clipped, and spent then rest covers this beat |
| rail3_f00 to f06 | The same charge, but aimed **forward** at the target, drawn at a different scale in rows 2 and 3 | alternate | Reference only: it fires forward, not at the sky as Preston directed |

## Order and timing

`rest 0.10 → raise 0.40 (brace tremble) → kindle 0.45 → swirl 0.50 → full 1.30 (strain: shake builds, then a hush) → burst 0.12 (release, signature flash) → shot 0.30 → spent 0.90 (the slug falls) → rest 0.45 (hit)`

## Re-check before building

- **Feet:** aligned on the middle of the four feet, not the rear edge. The rings and clipped tails made the rear edge unreliable.
- **Canvas:** 144x176, with the idle at the bottom centre. `battle_screen.gd` keeps taller frames on the ground line.
- **Colours:** snapped to the idle's palette plus four glow colours.

## What was built

- **Frames:** `tools/build_oxbowarchon_kingstone_rail.py` writes the frames to `built/`.
- **Move:** `data/moves/oxbowarchon_kingstone_rail.tres`.
- **Strike effect:** `scenes/effects/oxbowarchon_sky_rail.tscn` with `scripts/effects/sky_rail_strike.gd`. After the release, the opponent trembles and a glint appears high above it. Then the jade slug (Preston's Proestmar dart, turned to point down) drops with a trail and shatters in the emerald burst. What the shot does once it reaches the sky is my proposal, pending Preston.
- **Camera shots:** `scripts/camera_shot.gd`. The camera pulls back and tilts up while the rails are raised, with the HP cards faded. It leans toward the target for the fall, then gives a short push-in on the hit.
- **Creature:** `data/creatures/903_oxbowarchon.tres` is a provisional entry. Dex number 903, the default stats and a one-move kit are placeholders for Preston.
- **Preview:** `scenes/oxbowarchon_rail_preview.tscn`.

**Verified** in a scripted run of the preview: all 9 frames play in order, the feet stay put, the hit lands (Cinderhide 60 to 45), and there are no errors.

**Not done:**
- no back-view (player-side) frames;
- the flash in `burst` is clipped where the Opal cell cut it;
- the converted frames keep the known faint magenta edge, which is left for Codex's finish pass.

## Update, later 2026-09-29: every good frame used, flawed ones repaired

Preston added sheet 4 and asked that every good generation be used, with the flawed ones repaired instead of dropped. The table above was the first pass; this section supersedes its decisions.

**Sheet 4 frames:**
- rail4_f00 is a rest near-duplicate: left out, because a redrawn identical pose adds jitter, not motion.
- rail4_f01, rails up with the Kingstone lighting them: **keep** as `glow`.
- rail4_f02, a sphere with arcs: **keep** as `kindle_arcs`.
- rail4_f03, full sphere with turned rings: **keep** as `full_b`, with the tail repaired.
- rail4_f04, the release with a high flash: **keep** as `burst_b`, with the tail and flash repaired.
- rail4_f05, afterglow: **keep** as `afterglow`, with the tail repaired.

**Now kept:** rail2_f05 as `settle` (tail repaired). rail1_f02 is still left out because its arcs were pink bleed. rail2_f00, rail2_f01 and rail4_f00 are left out as near-duplicates.

**Timeline, 14 frames:**
`rest 0.08 → raise 0.22 (brace) → glow 0.22 → kindle 0.20 → kindle_arcs 0.20 → swirl 0.25 → full 1.40 → burst 0.08 → burst_b 0.08 → shot 0.20 → spent 0.35 → afterglow 0.30 → settle 0.30 → rest 0.45 (hit)`

During the 1.4 s hold on `full`, the sphere cycles between `full` and `full_b` every 0.12 s. This uses the new `attack_strain_loop`, so the long hold stays moving.

**Repairs:**
- **Alignment:** frames are now registered on the front edge of the lower body, because the clipped tails threw off feet-based alignment.
- **Tails:** clipped tails take the whole tail from `swirl`.
- **Flashes:** every release flash was cut off by the Opal cell edge. The intact part is turned half a turn around the bright core to fill the missing part, which reads as a whole starburst.
- **Canvas:** now 256x216 so the completed flash fits.
- **Magenta:** leftover spill is removed with `tools/clean_spill.py`, which was also run on the idle front and back.

**Verified** in a scripted run: all 14 frames play, the loop cycles, the hit lands (60 to 45), and there are no errors.

## Fix, 2026-09-29: backside and tail (Preston: "its backside, backend and tail are wonky")

**Causes:**
1. Six frames had tails pasted from `swirl` in a fixed box. Their hindquarters sat in different places, so the pasted tail and rump overlapped into loose chunks and a stepped rump.
2. Frames were aligned on the front of the body only, so the tail end wobbled from frame to frame because each Opal pose is a slightly different length.

**Fixes** (in `tools/build_oxbowarchon_kingstone_rail.py`):
- Every frame is slid sideways to where its lower body best overlaps the idle's (`register`).
- The frame's own tail is cleared row by row, left of the idle's body outline, and the **idle's exact tail** is grafted on (`graft_tail`). Small floating leftovers are removed (`drop_strays`). The tail now matches the idle and stays planted through the whole move, so there is no pop at the start.

After the rebuild, Codex's `tools/retouch_attack_texture_2026_09_29.py` was re-run: the frame shapes stayed exact and `style_matched/` was refreshed. **Verified:** rear crops and whole frames of all 14, plus an engine run with no errors.

**Second fix, same day** (Preston: "still doesn't look right", where his left hind leg and tail meet). On swirl, shot and spent, Opal drew the tail base fused to the rump as a solid shelf between the tail loop and the body. Clearing "left of the frame's own body" could not see it, because it is one continuous run of pixels.
- `graft_tail` now copies the idle's tail band exactly, including the open gap, up to the idle's rump outline.
- The boundary moves back for any frame whose rump sits further back than the idle's. This is measured on rows where tail and rump are clearly apart, so no rump is shaved.
- Below the band, the idle's tail base is carried into the rump, filling empty pixels only.

**Checked:** pixel maps of the corner (idle, shot, swirl, spent now match), large crops of all 14 frames, and an engine run.
