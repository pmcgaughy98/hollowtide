# Code-drawn pixel VFX: what the Gemini research changes

The source is `docs/Gemini DeepResearch(Hollowtide)/Godot 4 Pixel Art VFX.docx` (Preston, 2026-09-29), which answers `docs/gemini-prompt-code-drawn-pixel-vfx-2026-09-29.md`. Treat it as research, not canon.

**Source quality is mixed.** The saint11 (Pedro Medeiros) pixel-art articles and the Godot docs are solid. Several other citations are Reddit threads, Scribd uploads and TV Tropes. Its game-specific claims are mostly general, and it names no concrete technique from Cassette Beasts, Coromon or Temtem.

## What we already do right (it confirms)

- **Grid-locked effect pixels.** The lava river is built from art-pixel squares, and the glass flood shader works in art-pixel cells.
- **Fewer, controlled effect sprites.** The effects use small hand-placed Node2D sprite groups rather than masses of GPU particles. The report calls this "vastly superior" for low-count stylized pixel effects.
- **Signature staging.** Dim plus spotlight, a strain frame that builds, a hush before release, and a white flash, all matching its turn-based staging section.
- **Screen shake.** Its strength is squared (the "trauma" model it recommends).

## Applied now (2026-09-29)

1. **Stepped animation time.** The glass flood shader and the creature sprite's glow flicker now update 12 times a second instead of sliding smoothly at 60, so they move like drawn frames.
2. **Banded glows.** The creature shader's overheat, bleed and warm cast now snap to quarter steps, so a glow is a few flat colour bands instead of a smooth blend that invents in-between colours.
3. **Pixel-snapped shake.** The screen shake jumps in whole backdrop pixels (4 screen px) and dies down over six kicks. Before, it slid between offsets, drawing the scene between pixels.

**Verified:** the Molten Glass preview ran headless with no errors, the hit landed, and the overheat glow reads as bands.

## Done in the second pass (2026-09-29)

1. **Hit-stop.** There is a new `MoveData.impact_freeze`: -1 picks it automatically, 0.12 s for a signature and 0.06 s otherwise. On impact the target holds white-hot and squashed for that long, and a drawn move's hit frame holds that much longer, while the flash and shake play on. It applies to every attack path through `_on_impact`.
2. **Clustered scatter.** Furnace Roar's field geysers now bunch along 4 fault lines with calm ground between, and its fireworks burst over those clusters instead of evenly across the sky (`pressure_field.gd`).
3. **Drawn on twos.** The mouth flames (`mouth_smolder.gd`), the lava river (`lava_river.gd`) and the meltdown embers (`glass_meltdown.gd`) simulate every frame but redraw 30 times a second.

**Verified headless:** the Furnace Roar, Kingstone Rail and Molten Glass previews ran with no errors and every hit landed. Captures show the geyser clusters, and show the target still held white 0.12 s after a signature impact.

## Still open

1. **Effect palettes of 3 to 5 steps** for code-drawn effects. The Codex style pass covers the drawn frames.
2. **Screen-reading heat haze, only if we add one.** Put a BackBufferCopy in Rect mode in front of it.
3. ~~The existing hit squash~~ **Fixed 2026-09-29.** The squash and the breathing now both use a whole-pixel stretch in `creature_sprite.gdshader`, spread evenly over the body's height and width. The hit squash goes shorter and wider through the hit-stop, rebounds, then settles. Vitrecrag breathes taller and a little narrower (`idle_breath 0.022`, the new `idle_breath_widen 0.012`), which brings back the swell of the old fractional scale without the moving 9-box grid.

## Not adopted, and why

- **Squash and stretch on the hit target** (scale 0.8 / 1.2). A non-whole scale breaks the pixel grid, the project's hard rule. A whole-pixel squash through the breathing shader's row trick would be the compatible version if we want one.
- **The HD-2D lighting and normal maps** (Octopath, Sea of Stars, Eastward). The report itself rejects these for Hollowtide.
- **The mass GPU particle recipe for geysers.** The geysers already use Preston's art, and the report agrees fewer controlled sprites look more authentic.

## Checklist for any new code-drawn effect

From the report, trimmed to what applies:
- **Grid:** positions and shader cells land on whole art pixels.
- **Timing:** time is stepped (12 to 20 updates a second), not smooth.
- **Palette:** 3 to 5 colour steps plus an outline, with no soft gradients or blurred alpha.
- **Shape:** shapes are broken up with noise, not perfect circles or mirrored ovals.
- **Filtering:** nearest-neighbour everywhere.
- **Pacing:** the effect has uneven timing (anticipation, a quick release, a held aftermath).
