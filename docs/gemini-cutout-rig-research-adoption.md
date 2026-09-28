# Gemini cutout rig research adoption

**Report received 2026-09-27:** `C:\Users\pmcga\Downloads\Godot 2D Pixel Cutout Rigging.docx`. This note separates useful design guidance from unverified claims and records the first project pilot. The report is research input; Preston's approved art and current game files remain the authority.

## Adopt for Hollowtide

- Pilot a rigid `Node2D`/`Sprite2D` cutout first, with `AnimationPlayer` once the parts are ready. Use hand-drawn frame swaps for knees, boots, organic bends and attacks that look poor as rigid joints.
- Keep the current courier sprite-sheet path intact while a separate pilot is evaluated. Preserve Cinderhide and Vitrecrag's approved visible pixels and anatomy.
- Treat missing pixels behind overlapping parts as **new underpaint art**, not pixels that a crop can recover.
- Record source hash, frame rectangle, masks, pivots, depth order and the exact rest reconstruction before any movement is authored.
- Compare the rig at actual game scale. Godot's [cutout guide](https://docs.godotengine.org/en/stable/tutorials/animation/cutout_animation.html) explicitly permits mixing cutouts with cel animation.

## Corrections to the report

1. The proposed manifest's SHA-256 is an example, not the sheet's real hash. The current side atlas hashes to `96f8908694d386d32bbc0154a2831a570b167b65d4a9d4eab20e16609ceb5faa`.
2. The report assumes the courier occupies roughly source Y=140..420. Frame 2 at `Rect2(256, 0, 256, 512)` actually has nontransparent pixels in X=11..244 and Y=20..498. The report's head box at Y=140..200 misses almost all of the head. Its limb boxes and tiny underpaint pixel counts are not implementation coordinates.
3. The full 512-pixel cell at scale 0.0727 is about 37.22 world pixels tall, but the **visible** 479-pixel figure is about 34.82 world pixels. Use the visible figure and foot baseline when comparing directional size.
4. The report says polygon deformation is fundamentally incompatible and Vitrecrag is very highly feasible. These are recommendations to judge visually, not facts established by the supplied files. A rigid plate shift could still reveal missing furnace/underplate art or change its silhouette.
5. `rendering/2d/snap/snap_2d_transforms_to_pixel` is currently **not set** in `project.godot`. [Godot's setting reference](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html) says snapping can make movement less smooth; do not enable it globally from this report alone.
6. `RESET` is a special **animation** containing default pose keys, not a single RESET track that automatically restores every property whenever playback stops. [Godot's animation guide](https://docs.godotengine.org/en/stable/tutorials/animation/introduction.html) describes reset-on-save and blending behavior. Explicitly return a pilot to rest when needed.
7. `CALL_MODE_DISCRETE` is not the property-track switch specified by the current [Animation API](https://docs.godotengine.org/en/stable/classes/class_animation.html). A value track can use `Animation.UPDATE_DISCRETE`; verify actual editor behavior before keying frame swaps.
8. The report calls its information verified for Godot 4.7.2, but the official [2D skeleton tutorial](https://docs.godotengine.org/en/stable/tutorials/animation/2d_skeletons.html) warns that it has not yet been updated for 4.7. Treat older forum posts and third-party fixes as leads, not proof for this project.

## Pilot now in Godot

`scenes/courier_rig_pilot.tscn` is a **rest-pose-only** two-part cutout of the courier side atlas's second frame. It uses `assets/sprites/player/rig_pilot/courier_side_frame02_head_visible.png` and `courier_side_frame02_body_visible.png`, with [the exact mask manifest](../assets/sprites/player/rig_pilot/manifest.json). The two exported 256×512 RGBA images partition that frame: no opaque pixels overlap, and recombining them at rest produces **zero RGBA channel mismatches** against the approved source frame. Source atlas and live `scenes/player.tscn`/`scripts/player.gd` walk behavior were not replaced.

The head pivot is registered at source pixel (155,145). The body still contains the arms, bag, torso, legs and boots. No head motion is enabled because moving it would reveal missing neck/collar art. This pilot proves exact extraction and Godot registration; it does **not** yet prove a usable animated walk.

## Next production gate

Cut and review semantic arm/leg/bag pieces from the same frame, then add the smallest hidden-color layers behind each joint while preserving all approved visible pixels. Only then author a four-pose side walk in the isolated scene and judge it beside the existing sheet at native size. Keep frame animation where a cutout loses Cinderhide-level pixel clusters or grounded foot contact.
