# Retro Diffusion chibi walking assets

Male and female each have eight walk directions, eight frames per direction.

- Master atlases: 640x640, 80x80 cells.
- Rows: down, down_left, left, up_left, up, up_right, right, down_right.
- SpriteFrames: eight looped walk_<direction> animations at 8 FPS.
- Common canvas anchor: (40,72). A centered AnimatedSprite2D uses offset (0,-32) before applying one common scale.
- No per-direction resizing or frozen foot bands.
- All 128 frames inspected; all sixteen animations observed through frames 0-7 in the review scene.
- Review: res://scenes/chibi_walk_review.tscn, two rows at 2x nearest scale.
- Runtime check: zero errors and warnings in that isolated review.

Source, exact prompts, costs, preparation, original outputs and map-size studies:
[Walking record](../../../../docs/art/characters/retro-diffusion-chibi-walking-2026-10-01/README.md).

These assets are available for gameplay integration. Current player movement, collision and model selection have not been changed.
