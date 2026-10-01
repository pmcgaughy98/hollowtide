# Vitrecrag back sprite: next image generation brief

Status: two head-visible candidates in `docs/art/review/`: `vitrecrag_back_head_visible_candidate_2026-09-28.png`
keeps more of the supplied reference's side angle; `vitrecrag_back_rear_angle_candidate_v2_2026-09-28.png`
turns farther away. Both are unapproved and unlinked. The older rear remains linked in Godot.

## Source hierarchy

1. Design authority: `assets/sprites/creatures/vitrecrag_official.png`.
2. Preston's head-visibility and furnace-placement reference:
   `docs/art/review/vitrecrag_back_head_reference_2026-09-28.png`. Its side-heavy angle is not the target camera.
3. Camera and silhouette reference only: `assets/sprites/creatures/vitrecrag_rear_2026_09_27.png`.
4. Cinderhide sets the coarse pixel craft level; do not copy its anatomy or palette.

## Image-generation prompt

Edit the approved Vitrecrag front into a genuine three-quarter REAR battle sprite of the SAME creature. The camera is behind Vitrecrag's left hindquarter, looking past the broad rear shell toward its lowered front at the far upper right. The near hind legs and back of the shell dominate the image; the front body slopes DOWN and AWAY from the higher rear shell. Show the small head as a recognizable back/top or narrow side sliver emerging from its ring collar at the far front-right, pointed away from the camera. Preston explicitly wants the head visible; avoid a forward-facing eye or face. Keep its six thick planted beetle legs, rust-orange joints, dark plum stone shell, and glowing furnace. The shell's irregular silhouette is made of several LARGE, asymmetrically STACKED and OVERLAPPING armor plates, not a horn, dorsal spike, neat tile grid, shingle skirt, or smooth dome. Show a substantial orange lattice furnace opening on the creature's RIGHT flank as seen in this rear view, under the shell rather than on the face. Respect the approved front's proportions and high back-to-low front wedge shape. The viewer must see the BACK of shell and near hind legs, not a side profile or front-facing claws. Use bold, coherent pixel clusters, few broad material planes, dark contours, restrained highlights, no microtexture, no smooth gradients, no thin antialiased lines. One complete creature on a transparent background, square canvas, no ground shadow, no magenta halo, no extra objects.

## Reject if

- The head is completely hidden, or it appears as a detached curl/eye rather than a small form connected through the collar.
- A forward-facing eye or face appears.
- The pose reads like another front or side view.
- A new horn or spike projects upward from the shell.
- The back is rounded like a turtle dome or covered in even armor tiles.
- The furnace is absent, tiny, moved to the center, or looks like an eye.
- The front is as high as the rear.
- Pixel density or microtexture is finer than the approved front.

Only after Preston approves a candidate: convert to transparent 128x128 PNG at the official front's pixel density, import under a new filename, then link as `back_sprite` in `data/creatures/108_vitrecrag.tres`. Preserve rejected candidates unlinked.
