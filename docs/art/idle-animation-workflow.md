# Idle sprite workflow (live Forge prompt, 2026-09-27)

The [Hollowtide Idle Sprite Forge](https://opal.google/edit/1p1-aH_DX-Ys83Fy3rxKL0fKQgChEcNs8) now has **NEW** and **COMPLETE** modes. It still makes one 2x2 idle-breath sheet with F0 neutral, F1 inhale start, F2 inhale peak, and F3 return. COMPLETE accepts an earlier partial idle sheet and asks for its approved and missing frames. The existing creature and effect generators remain separate. The revised Opal steps show as saved; a completed-sheet image has not yet been generated or reviewed.

## Create a new sheet

1. Open the idle Forge and select **App > Start**.
2. In **Idle Motion Brief**, enter the creature, exact front or back view, **MODE NEW**, and at most one small secondary motion. Example: `Cinderhide front; MODE NEW; quiet chest breath and a delayed vent pulse; feet locked.`
3. In **Source Sprite**, upload the approved original Forge image or transparent Godot PNG for that same view.
4. In **Existing Idle Sheet**, type `NONE` and submit.
5. Save the original generated image, not a screenshot of the preview webpage. Inspect all four frames at enlarged nearest-neighbor scale. Reject anatomy, footprint, palette, outline, or viewpoint drift; F3 must loop into F0.

## Complete a partial idle sheet

1. In **Idle Motion Brief**, enter **MODE COMPLETE**, the creature and exact view, the source layout, and explicit **KEEP** and **MISSING** F0-F3 slots. Example: `Cinderhide front; MODE COMPLETE; 1x2 strip; KEEP F0,F1; MISSING F2,F3; gentle chest breath with delayed vent pulse.`
2. Upload the approved still in **Source Sprite**, then the original partial sheet in **Existing Idle Sheet**. The sheet may be a 2x2 with blank/repeated placeholders, or a 1x2/1x3 horizontal strip. Do not upload a screenshot of Opal's preview page.
3. Run one generation. The Forge asks for locked existing frames to be carried into the same 2x2 positions and only named missing frames to be drawn. The review page places the source beside the result when available.
4. Compare every **KEEP** frame against the original at nearest-neighbor zoom. AI image generation cannot guarantee pixel-exact preservation: reject and retry if a kept frame changes, if cells shift or change size, or if the new motion snaps between F3 and F0. Do not import until all four final cells are filled and approved.

The local converter below accepts the finished **2x2** sheet. Do not send an unfinished 1x2 or 1x3 strip to it.

The attached *Godot Pixel Art Animation Workflow* research supports 2–4 frames, fixed feet, 1–2 logical-pixel chest motion, and uneven frame holds. Its suggestions for green backgrounds, white outlines, or fixed 64px grids do not match Hollowtide's existing art pipeline. Hollowtide uses magenta chroma key, dark one-cell outline, and the approved creature's native grid (usually 100 or 128).

## Convert for Godot

Convert the approved sheet against the already-converted transparent creature PNG:

```
python tools/convert_idle_sheet.py assets/sprites/creatures/cinderhide.png "C:/path/to/opal_idle_sheet.jpg" "C:/path/to/output/cinderhide_idle"
```

The local tool keeps each frame at the source PNG's native width and height. It removes the magenta, snaps JPEG noise to the source palette, and writes four transparent PNGs, a combined 2x2 PNG, and `idle_animation.json` with suggested timing (0.55s, 0.25s, 0.45s, 0.25s). It never crops, recenters, or flips frames independently. **Review the resulting `idle_sheet.png` before import.** The tool is newly written and has not yet been used on a real Opal idle sheet.

Copy the reviewed PNGs into a creature-specific `assets/sprites/creatures/idle/<name>/` folder. Use Godot's SpriteFrames/AnimatedSprite2D or AnimationPlayer to display the sequence at nearest-neighbor sampling and integer positioning. The battle scene keeps Sprite2D and impact motion. A creature can supply optional hand-drawn `idle_frames`; battle plays those on its front view and uses the old procedural breath for creatures without frames. Keep the original still PNG as the fallback.

## 2026-09-26 sprite-sheet research update

The live Generate Idle Frames prompt now says to treat F0 as a faithful pixel copy of the approved Source Sprite and to build F1-F3 by changing only small breathing or requested secondary-motion clusters. All four equal cells share one pixel origin, foot/contact pixels, palette, and view. The Forge must not crop, scale, recenter, or shift individual frames. F2 is the soft inhale peak and F3 settles toward F0. Frame timing belongs in Godot/converter metadata, never as labels on the image. These rules strengthen the established breath, which Preston likes; the existing code-driven battle idle remains in place until an approved sheet is reviewed in Godot. See [Forge production standard](../forges/forge-production-standard.md).

## Vitrecrag live example (2026-09-27)

Preston asked to combine all three Vitrecrag sheets, not pick only one. The source files are the two named `Vitrecrag Inhale Animation sheet*.jfif` files and `18f23c68-53d4-4c3b-b611-92430de78016.jfif` in `docs/HollowTide Sprites/Idle Animation Sheets/`. Each was converted to four 128x128 frames against the newest Vitrecrag source portrait. In sheet order, the twelve frames form `assets/sprites/creatures/idle/vitrecrag_idle_12.png`, four columns by three rows. `data/creatures/108_vitrecrag.tres` references twelve 128x128 atlas regions and plays them over 5.04 seconds. `scenes/vitrecrag_idle_preview.tscn` opens that battle directly for review. The game was launched and the resource was confirmed to load twelve 128x128 frames without reported script or runtime errors; animation feel still needs Preston’s eye in Godot.
