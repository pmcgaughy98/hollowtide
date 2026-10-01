# Claude: integrate Preston's original chibi courier

**Preston's order, 2026-09-30:** use the earlier chibi model as the main character; Codex prepares the files and Claude adds them to the game.

## Read these first

1. `chibi_full_detail_contact_sheet.png` in this folder: all16 cut source poses, one at a time.
2. `manifest.json`: actual crop coordinates, registration, source hash and per-pose analysis.
3. This handoff. No need to read the older walk research archive before picking up these assets.

## Main art: full-detail transparent source cuts

`res://assets/sprites/player/courier_chibi_prepared_2026_09_30/source_detail/`

- `source_pose_atlas_4x4.png`:1088x1088; sixteen272x272 cells.
- Rows0-3 = DOWN, LEFT, RIGHT, UP. Columns0-3 retain the original source order.
- `{direction}/source_pose_00.png` through03: individual transparent source cuts.
- `{direction}_source_poses_4x1.png`:1088x272 direction strips.

All four views were cut independently; LEFT is not a mirror of RIGHT. Satchel sides and source face/head are retained.
Magenta background is keyed, detached compression noise removed, and magenta-contaminated outline color replaced
with dark ink. Every frame has binary alpha0/255. No image generation, body redraw, head redesign or pose invention.
Source sizes are registration canvases, not claimed native art-grid dimensions.

## Placement contract

Shared source cell272x272, head center x136, lowest boot pixel y260. For a region-enabled centered Sprite2D:

```gdscript
# Same scale for every direction. About30px maximum visible source height.
var chibi_scale := 30.0 / 254.0
sprite.scale = Vector2.ONE * chibi_scale
sprite.position = Vector2(0.0, -(260.0 - 136.0) * chibi_scale)
sprite.region_enabled = true
sprite.region_rect = Rect2(column * 272, row * 272, 272, 272)
sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
```

This positions the source foot line at the player's origin. Keep the existing foot collision/movement speed and
route geometry. Do not reuse the current256x512 adult regions or direction-dependent adult scale constants.
The source's own pose heights vary slightly with stride; avoid compensating by enlarging side views.
The optional32px set below is available if fractional source-display sampling looks poor at actual map scale.

## Small map study: secondary, not approved replacement art

The package root's128x128 atlas,32x32 directional rows and individual32px poses are a deliberate size study.
They use one shared32-color character palette and hard alpha. Codex saw loss of face/goggle detail compared
with the chosen model: **do not silently install these as an approved texture redesign.**
The authoritative source cuts are in `source_detail/`. Compare an actual scene-sized preview with Preston
before settling on the final native-size conversion. `chibi_source_pose_contact_sheet.png` and
`chibi_source_pose_review.gif` show the32px study; neither proves a finished gait.

## The animation gaps are real

Codex inspected all16 source cells separately, recorded each action, then reconsidered the sequence.

- **DOWN/UP:** columns0 and1 are opposite contact candidates; columns2 and3 repeat those ideas. Need the two close-foot passing poses for contact/passing/opposite contact/opposite passing.
- **LEFT/RIGHT:** all four cells hold the same extended-leg stance. Need an opposite contact and both passing poses. Do not loop them and call the old glide fixed.
- No truly balanced new idle has been drawn. A source pose may be used as a temporary direction preview, not claimed as an approved neutral stand.

The walk Forge is configured for four-frame chibi cycles. Its Character Reference must be this original chibi
identity, not the later tall adult courier. Ask for each direction separately; preserve face, body proportions,
goggles, teal jacket, satchel side and matching size. New Forge poses still need cutting/review, and should not
replace the source's approved face or outfit. Single-frame source references are available above.

## Current integration status

Art prepared and visually inspected. **Not installed in player.gd/player.tscn and not played.**
Codex did not edit movement, collision, camera, main scene or the current walk atlases. Claude owns the runtime
integration; preserve existing adult art as a recoverable fallback while building the chibi version.

Original art remains `OneDrive/Documents/HollowTide Sprites/Character/Male.jpg`. Easy-to-find byte copy:
`Main Courier - Chibi Source.jpg`; four-view identity file: `Main Courier - Chibi Identity - Four Views.png`.
