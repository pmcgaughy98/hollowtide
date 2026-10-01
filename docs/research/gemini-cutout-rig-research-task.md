# Gemini Deep Research: lossless cutout rigs for Hollowtide

**Status:** ready to run. Research first; do not alter approved source art or Godot files. This task extends `docs/art/animation-rig-strategy.md`.

## Current project facts to verify against the actual files

- Godot version: 4.7.2. The current player scene is `scenes/player.tscn`; animation selection is in `scripts/player.gd`.
- Courier side walk: `assets/sprites/player/male_side_walk_refined_8_v2_2026_09_27.png`, a 1024×1024 atlas of eight 256×512 cells. The vertical walk is `male_vertical_walk_4x2_2026_09_27.png`. The displayed figure is about 35 world pixels tall in all four directions after the recent scale correction, but the gait remains provisional.
- Approved creature examples: `assets/sprites/creatures/cinderhide.png` (100×100), `vitrecrag_official.png` (128×128), and their approved battle backs. Preserve silhouette, head, shell plates, furnace, material clusters, palette, and front/back distinction.
- The source PNGs are flattened RGBA images. A local alpha connectivity check found that Cinderhide and one courier side frame each form one connected opaque component; all but one pixel of Vitrecrag also forms one component. Existing alpha boundaries therefore do **not** supply separable arms, legs, or shell pieces. Masking visible parts can preserve their pixels, but new poses expose missing art behind overlaps.
- Preston wants a workflow Codex can execute to cut up current sprites for Godot **without changing their approved visible pixels**. If hidden surfaces need new pixels, identify them explicitly and keep the original PNGs immutable.

## Copy to Gemini Deep Research

> Design a practical 2D cutout rig pipeline for Hollowtide's **existing approved, flattened pixel sprites** in Godot 4.7.2. Inspect the actual files listed above and the project art guidance, rather than treating a generic sprite as equivalent. Start with the courier's right-facing side frame as a walk pilot; then assess whether Cinderhide and Vitrecrag benefit from the same method for restrained battle idle or attack motion. Vitrecrag's stacked armor plates and right-side furnace are identifying anatomy, not a smooth domed shell or a spike. Do not turn any sprite into a redesigned character.
>
> Research current official Godot documentation and editor behavior for three implementations: (A) rigid Sprite2D pieces in a Node2D hierarchy animated by AnimationPlayer, (B) Skeleton2D/Bone2D with Polygon2D deformation or weights, and (C) hybrid cutout plus hand-drawn cel frames. Check version-specific claims in Godot 4.7.2 because the stable cutout and 2D skeleton tutorials warn that they may be outdated. Recommend a pilot implementation based on crisp pixel art, authoring time, frame consistency, and ease of reuse. Explain when a simple transform of the whole sprite is sufficient and when rigging makes the art worse.
>
> Give an **executable extraction specification** for the courier pilot: exact source frame and coordinate system, named layers, semantic masks, crop boxes, pivots, z order, overlap margins, transparent export sizes, pose registration, and import/filter settings. Define a pixel-preservation check: when parts are recomposed at rest, every currently visible source pixel and its alpha must match the approved frame exactly. Include a manifest format with source file hash, crop coordinates, pivot, layer order, and whether any pixels are duplicated. Show how an assistant can cut and save layers programmatically while leaving the source untouched. Explain how to handle antialiasing, color keys, nearest-neighbor filtering, integer positioning, and rotation artifacts at the actual game scale.
>
> Explicitly inventory **occluded pixels** that cannot be recovered by cutting: behind the courier's bag strap, shoulders, elbows, coat hem, knees and boots; and, if relevant, behind Cinderhide's limbs or Vitrecrag's stacked plates and furnace. Specify the smallest supplemental repaint needed for each joint. Keep supplemental pixels on new underpaint layers; never silently rewrite an approved visible pixel. If a clean rig is impossible without visible changes, say so and give a hybrid frame-animation alternative.
>
> Provide a concrete Godot node tree and AnimationPlayer track plan for one side walk, with contact, down, passing and push-off poses; planted feet during support; consistent apparent height on left/right versus up/down; and a neutral/rest pose. State which pivots should snap to integer source pixels and whether rotation should be limited or avoided. Include an optional creature example for Vitrecrag's restrained furnace/plate idle that never invents a protruding shell spike. Give a small, reversible import plan that keeps the current sprite sheets as fallback, followed by a native-size visual acceptance checklist for seams, foot sliding, silhouette, palette drift, and back/front orientation.
>
> Return: (1) a source-linked comparison of the three methods; (2) a coordinate-level courier pilot recipe and manifest example; (3) a per-sprite feasibility table for courier, Cinderhide, and Vitrecrag; (4) an exact list of hidden-pixel art still required; (5) a Godot 4.7.2 implementation sequence for Codex and Claude; and (6) a short list of decisions Preston must approve before replacing any live animation. Separate verified documentation, observations from Hollowtide files, and your own recommendations. Do not claim an alpha crop alone produces a bendable limb.

## Success criterion

Codex can make the courier side pilot from the manifest, keep current sheets playable, recompose the rest pose pixel-for-pixel, and tell Preston precisely what supplemental hidden art would be needed before any rig replaces it.
