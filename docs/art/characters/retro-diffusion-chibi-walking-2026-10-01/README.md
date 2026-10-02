# Eight-direction chibi walks | October 1, 2026

Preston requested menu walking sprites first, then walking male and female chibi models, and selected all eight directions. The menu walk-in is installed and verified. Both chibi walking sets are prepared and running in an isolated review scene.

[Actual in-engine animated review](chibi_walking_runtime_review.gif) | [Still capture](chibi_walking_runtime_review.jpg)
[Male eight-direction animation](male_chibi_eight_direction_walk_review.gif) | [Female eight-direction animation](female_chibi_eight_direction_walk_review.gif)

## Sources and generation

Male: the selected original chibi courier, from assets/sprites/player/courier_chibi_prepared_2026_09_30/source_detail/ cuts of Preston's Male.jpg. Female: C:/Users/pmcga/OneDrive/Documents/HollowTide Sprites/Character/Female.jpg, the brown ponytail/pink-bow, pink-jacket, teal-skirt model. Originals are untouched.

Prepare 80x80 source anchors by fitting the full visible body to 64 pixels tall, centered with the boot line at y=72. Retro Diffusion Advanced Rotate supplied a 240x240 eight-view sheet for each model. The verified sheet map is:
- DOWN: column 1, row 0
- DOWN LEFT: column 2, row 0
- LEFT: column 2, row 1
- UP LEFT: column 2, row 2
- UP: column 1, row 2
- UP RIGHT: column 0, row 2
- RIGHT: column 0, row 1
- DOWN RIGHT: column 0, row 0

Cut exact 80x80 cells, excluding the blank center. Remove only exterior-connected neutral white; retain face/goggle highlights. The male rotation omitted the bag in rear views. UP uses the original approved rear source. RD Pro restores UP LEFT's bag/strap. The first UP RIGHT correction still omitted the bag and is preserved as rejected; one retry using the original rear source produced the strap and partially occluded bag used for animation.

Female input cleanup changes three saturated magenta contamination colors to warm dark ink, without changing alpha or the jacket/bow ramps. Coordinates/counts are in female_fringe_cleanup.json.

Run a separate RD Advanced Walking job for each of the sixteen anchors, eight frames per direction. Rotation creates viewing angles; it is not the walking animation. Every exact request is saved in *_walk_request.json, with the selected input filename and job id.

## Prepared files and placement

Runtime assets:
- assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/male_chibi_walk_eight_directions_native80.png
- assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/female_chibi_walk_eight_directions_native80.png
- male_chibi_walk_frames.tres and female_chibi_walk_frames.tres in that folder
- scenes/chibi_walk_review.tscn
- scripts/debug/chibi_walk_review.gd

Each master is 640x640: eight frames across, directions down, down_left, left, up_left, up, up_right, right, down_right down the rows. Cells are exactly 80x80. Each SpriteFrames resource supplies eight looping walk_<direction> animations at 8 FPS. Shared canvas anchor is (40,72); for a centered AnimatedSprite2D use offset (0,-32), with a single common scale for all directions. Review scene uses 2x nearest display. Movement/collision and character-selection integration remain a separate step.

Individual 640x80 direction strips, source anchors, raw GIFs, rotation originals and rejected correction are preserved in this directory. Study32 files are secondary nearest-sampled map-size comparisons; the full-detail 80px masters remain authoritative for this candidate. They are not installed as a gameplay texture redesign.

Preparation preserves all native frames, with no resized masters or frozen foot band. All 128 frames were individually inspected in the four all-frames review sheets. Each cycle has eight unique frames and changed lower-body pixels at every step. Five isolated white body/foot artifacts were replaced using existing neighboring colors; legitimate head/eye highlights are retained. No frame touches the 80px canvas boundary. See walking_preparation.json for every frame's bounds, repairs and alpha hash.

## Actual verification and cost

Fresh Summer 0.5.68 deterministic offscreen chibi-walk-review at 60 FPS. All sixteen actors observed frames 0-7 in the correct walk animation, with no missing properties. Actual capture at process/image frame 3927 shows frame 4 for all sixteen actors. Prepared animation and actual scene capture inspected. Zero runtime, open-script or total errors; zero warnings in this review. Own review instance stopped.

Generation cost: $3.26 for this entire request, including $0.28 menu walks, $0.20 two rotations, $0.54 three satchel correction stills and $2.24 sixteen chibi walks. All 23 jobs succeeded; one still was rejected visually. No animation retry. Concurrent account spending is not attributed here.

No player.gd/player.tscn, movement, collision, gender selection, creature roster, world production or launch setting edit. Current menu scenery, idle atlases and approved battle art are preserved. No Git staging, commit or discard. No implementation blocker. Preston reviews final likeness and gait feel.

[Complete changed files](CHANGED_FILES.md) | [Copied asset/source hashes](asset_file_manifest.json) | [Generation ledger](generation_ledger.json) | [Runtime receipt](runtime_check.json)
