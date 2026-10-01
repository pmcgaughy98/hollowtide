# Cinderhide cutout rig pilot

Status: visually approved by Preston on 27 September 2026. The rig is an isolated proof of concept and has not yet been connected to live battles.

## Files

- Source: `res://assets/sprites/creatures/cinderhide.png` (100×100 RGBA; unchanged SHA-256 `4c6403594e71a93c698e453a7aef62df44bbb2c4e03cbda1ad130fe274a5e22e`).
- Pixel-exact layers: `res://assets/sprites/creatures/rig_pilot/cinderhide_body_visible.png` and `cinderhide_head_visible.png`.
- Reusable rig: `res://scenes/cinderhide_rig.tscn`.
- Side-by-side playable view: `res://scenes/cinderhide_rig_preview.tscn`.

## Method and result

The original 100×100 image was divided into non-overlapping head and body layers. Together they reproduce every RGBA channel of the source at rest, with zero overlapping opaque pixels. A pivot at source coordinate (58,53) moves the head down one source pixel and back over a 1.8-second loop. All textures use nearest filtering. The preview displays the source and rig at 2× battle scale, facing left as a foe would.

Godot 4.7.2 loaded and played the preview. A live framebuffer capture showed both forms visually aligned without visible seams; game and editor error logs were empty. Preston viewed the preview and said it looked great. The preview was stopped after inspection.

## Next integration decision

Keep the current Cinderhide battle Sprite2D until the rig is connected carefully to the battle presentation. The battle script expects a Sprite2D for attacks, flashes, scaling, and frame swaps. A rig child can follow its parent transforms, but the approved source texture must be hidden only while the rig is active; attack frame swaps and cleanup need to reveal the correct image. Integrate as a separate small change and view an actual Cinderhide battle afterward.

Do not apply this mask blindly to other creatures. Each approved sprite needs its own anatomy-based split and rest-pose exactness check.
