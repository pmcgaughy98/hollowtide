---
name: hollowtide-sprites
description: Make or repair a Hollowtide creature's eight-angle views (and then its walk) in the house style, with image generation drawing and tools/art/sheet_judge.py deciding which views pass, which code can fix, and which to generate again. Use for any new creature, new stage, or broken angle set.
---

# Hollowtide creature sprites

Written by Claude on 2026-10-28 for Codex, from what the project has measured since 2026-10-12. Preston approves
every creature; nothing here replaces his eye. Read `CLAUDE.md` and `docs/AI_COLLABORATION.md` first.

## The split of work

- **Image generation draws.** Code never redraws a creature. A code renderer reads as 3D ("roblox"), and Preston
  judged Nano Banana 2.1's raw output better than our heavy finishing (2026-10-13).
- **Code judges and corrects.** `tools/art/sheet_judge.py` measures the eight views, fixes what moving or flipping
  can fix, and names the views to generate again. Nothing is copied from other games or repos; references are
  structure only.
- **Ask before paying.** Every generation costs credits. Give Preston the tool, the count and the estimate first.

## House style

- **References:** the creature's own approved views, then Tallowroot (`assets/sprites/arena/tallowroot/`). Never
  Preostmar; Preston called it one of the worst. Ask him before adding other style references.
- **Colours:** fantasy colours, not Earth-animal browns and greys. Keep the line's colour family across stages.
- **A new stage evolves, it does not grow.** Keep only two or three anchors (the face and eye motif, the signature
  part, the colour family). Change the silhouette, head shape, proportions, posture and palette shade, and turn the
  signature part into something new. Keep a line's named parts, for example the Flintram line's horn.
- **Canvas:** transparent, alpha 0 or 255 only, the creature bottom-centred. Use the size of the creature's own
  existing views: Rimefin is 128 px, Sparkwick 144, and Riftfin and Scourmaw 160. Do not assume a size from the
  creature's stage. For a new line, match the line's other stages.
- **Finishing Codex image output:** shrink the whole sheet once so that its median view height matches the target,
  give all eight views one shared palette (about 28 colours), then slice. Shrinking views one at a time, or giving
  each view its own palette, makes the views drift apart.
- **One Codex image job at a time.** Concurrent jobs share `~/.codex/generated_images`, and both logs of the
  2026-10-28 pair named the same file. Neither picked the wrong image that time, but Retro Diffusion misfiled a walk
  the same way.
- **Outline:** the game draws the black outline with a shader (`scripts/arena/creature_finish.gd`). Do not paint a
  heavy outline into the art.
- **Lighting:** from the upper left, the same in every view.

## The loop

1. **Eight angles first** (Preston, 2026-10-14). Generate one 3x3 sheet before any single front view, with the
   previous stage's sheet as the pose guide. Cell layout, the creature facing the middle:

   ```
   ne  n  nw
   e   .  w
   se  s  sw
   ```

   For a creature that is the same on both sides, the west column can be left to code (step 3). The pipelines that
   hold eight views together generate five directions and mirror three.
2. **Slice:** `python tools/art/slice_grid.py <sheet.png> <out_dir> [--canvas 128] [--feet 104]`. It cuts and
   places, and never changes pixels.
3. **Judge:** `python tools/art/sheet_judge.py <out_dir>`. It prints two verdicts:
   - **FIX:** code corrects these. Run `python tools/art/sheet_judge.py <out_dir> --fix <fixed_dir>
     [--mirror-from east|west]` and judge `<fixed_dir>` again. Mirror only a creature that is the same on both
     sides. For one-sided parts (a horn or blade on one side, a lopsided body), pass `--asymmetric`; mirror faults
     then become REDO.
   - **REDO:** generate only those views again, with the passing views as references. Try each view at most three
     times, then stop and report what is still failing. Do not loop on credits.
4. **Look.** Two things the judge cannot measure:
   - The back diagonals (ne, nw) must not show the face. A colour test for this failed in both directions on
     2026-10-28.
   - The north view must point north. The judge's `turned` check caught Sparkwick, but lopsided creatures trip it.
   - Before paying to redraw a view the judge flags, check that another file doesn't already hold it. Sparkwick's
     (2026-10-28) north file held its northeast view, its northwest file held its north view, and its northeast
     file showed the face. Putting the files back in the right slots and flipping the northeast for the northwest
     fixed the back views for free (`docs/creatures/sheet-judge-2026-10-28/sparkwick/`).
5. **Show Preston** the sheet before anything goes into `assets/`. When he approves, install it into
   `assets/sprites/arena/<name>/`, then rebuild with `tools/arena/build_small.py` and
   `tools/arena/build_dungeon_set.py`, then run `tools/art/walk_lock.py <name>` for the walk.

## What the judge checks

- **files:** all eight views, on one canvas size.
- **alpha:** no partial alpha.
- **ground:** every view on the same foot row.
- **centre:** every view on the middle column.
- **height:** no view more than 10% off the set's median height.
- **palette:** at least 85% of each view's pixels near the south view's colours.
- **specks:** few lone pixels.
- **mirror:** each pair's silhouettes overlap at 0.85 or more when flipped.
- **face:** the north view is not the south view again.
- **turned:** the north view is about as even left to right as the south view, and is not shaped like a diagonal.

The thresholds are in `LIMITS` at the top of the script. On 2026-10-28 it ran over all 50 in-game sets: 22 need
views generated again, and 29 need no new generation. Run `python tools/art/sheet_judge.py --all` for the current
list.

## Don'ts

- Do not invent creature names, lore or stats. Label new ideas as proposals.
- Do not edit Route 1.
- Do not restore the Cinderpelt evolution link.
- Do not overwrite game sprites without Preston's yes. Originals for walk work live in
  `docs/creatures/walk-lock-2026-10-28/before/`.
- Do not run two Retro Diffusion creature jobs at once.
