# Codex brief: one consistent pixel style across all attack frames

Preston, 2026-09-29: many animation frames do not match each other, pixel-wise or graphically. Pick the best-looking frame style, one that complements Cinderhide's and Vitrecrag's designs, and bring every attack frame to it. Written by Claude after measuring the current art (numbers below). Preston approves the results; nothing here is canon until he does.

## The anchors

1. **Style rule: `assets/sprites/creatures/cinderhide.png`.**
   - 19 colours.
   - A dark outline on 100% of its silhouette edge.
   - Clean clustered shading: only 5% of its pixels are isolated (differ from all four neighbours).
   - This is the look the project is matching.
2. **Best attack frame to copy: Vitrecrag Plate Lunge `contact`**, in the `style_matched` folder under `assets/sprites/creatures/attacks/vitrecrag_plate_lunge/`. This is Codex's own finish pass (`tools/retouch_vitrecrag_attack_finish_2026_09_28.gd`).
   - 22 colours, a 100% dark outline and 22% isolated pixels, the same as Vitrecrag's idle (24 colours, 93% outline, 22%).
   - It reads as the same creature and the same game as both idles.
   - The Molten Glass `style_matched` frames reach the same standard: `flood` has 23 colours and a 100% outline.

**The target for every frame:** the Plate Lunge `contact` finish, measured against that creature's own approved idle.

## What is off now (measured 2026-09-29)

| Frames | Colours | Dark outline | Isolated px | What reads wrong |
|---|---|---|---|---|
| Cinderhide idle (anchor) | 19 | 1.00 | 0.05 | — |
| Vitrecrag idle | 24 | 0.93 | 0.22 | — |
| Plate Lunge `contact` (target) | 22 | 1.00 | 0.22 | — |
| Molten Glass `flood` (style_matched) | 23 | 1.00 | 0.21 | Fine |
| Molten Glass `overload`, `overload_pour_a/b`, `titlecard` | 49 | 0.95 | 0.17 | Too many colours; never got the finish pass |
| Molten Cannon `loaded` (built) | 22 | **0.51** | 0.21 | Outline broken in half the edge; the fireball is a soft blob, not pixel-shaded |
| Furnace Roar `roar` (built) | 34 | **0.58** | **0.34** | Outline broken; noisy speckled shading |
| Oxbowarchon idle | **100** | 0.82 | **0.36** | Far more colours and noise than any other creature |
| Kingstone Rail `full` (built) | **80** | **0.31** | **0.37** | Soft glows and a thin, broken outline |

## The job, in priority order

1. **Molten Cannon** (`vitrecrag_molten_cannon/built/` to a new `style_matched/`): outline, palette, and a pixel-shaded fireball.
2. **Furnace Roar** (`ironvent_furnace_roar/built/` to `style_matched/`): outline and speckle cleanup. Keep the dark head recolour (Preston, 2026-09-29: the head matches the Cinderhide line).
3. **Molten Glass leftovers:** `overload.png`, `overload_pour_a.png`, `overload_pour_b.png` and `titlecard.png` in `vitrecrag_lava_pour/`.
4. **Kingstone Rail** (`oxbowarchon_kingstone_rail/built/` to `style_matched/`): a dark outline all round, and glows (sphere, rings, flash) as stepped palette colours, not soft gradients.
5. **Oxbowarchon idle** (`assets/sprites/creatures/oxbowarchon.png`): **candidate only.** Make a reduced-palette, Cinderhide-rule version beside it for Preston to judge. Do not overwrite the idle; it is his generation.

When a set is done, point its `.tres` (in `data/moves/`) at the new `style_matched` frames, as was done for Plate Lunge and Molten Glass.

## Rules for every frame

- **Pixel positions:** keep each frame's alpha mask, canvas size, pose and registration exactly. The battle aligns frames by canvas; a moved pixel shows as a pop.
- **Palette:** use the creature's own approved idle palette, plus at most 4 to 6 effect colours. Aim for about 20 to 36 colours per frame. An effect glow is a few stepped colours, the way the lava in Vitrecrag's idle is drawn.
- **Outline:** a dark outline on at least 95% of the silhouette edge.
- **Noise:** isolated pixels at or below Vitrecrag's 22%; Cinderhide's 5% is the ideal. Merge speckle into clusters.
- **Brightness:** mean brightness within about 10 of that creature's idle, unless the frame is meant to glow. The frames already known to come out darker are the "Known finish issue" in `docs/attack-sheet-protocol.md`.
- **Magenta:** before the finish, run `python tools/clean_spill.py --check <folder>`. It removes the background's magenta without touching real purples (Vitrecrag's plum shell passes), and `--apply` cleans in place.
- **Make the pass a script:** extend `tools/retouch_vitrecrag_attack_finish_2026_09_28.gd` or write a sibling. Claude may rebuild these moves from more frames (Preston wants every good generation used), so the finish must be quick to re-run on new `built/` frames.
- **Folders:** write to `style_matched/` and never overwrite `built/`, `v2/`, `frames/` or Preston's original sheets in OneDrive.
- **Vitrecrag back view:** do not touch it (Preston's standing order).
- **Checking:** check every finished set in its preview scene (`scenes/*_preview.tscn`) at battle scale next to the idle. Report the three numbers above for each set, before and after.

## Hand back

Add a handoff in `docs/AI_COLLABORATION.md` covering:
- which sets were finished;
- the before and after numbers;
- which `.tres` now point at the new frames;
- what still waits on Preston (the Oxbowarchon idle candidate).
