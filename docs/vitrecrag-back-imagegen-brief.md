# Vitrecrag back sprite: next image generation brief

Status: pending. The user rejected earlier rear candidates. No new Vitrecrag back sprite is linked in Godot.

## Source hierarchy

1. Design authority: `docs/HollowTide Sprites/Creatures/Vitrecrag.jfif` and its game conversion `assets/sprites/creatures/vitrecrag_official.png`.
2. Camera and silhouette reference only: `docs/HollowTide Sprites/Creatures-Back/Vitrecrag-Back.jfif`.
3. Cinderhide sets the coarse pixel craft level; do not copy its anatomy or palette.

## Image-generation prompt

Edit the approved Vitrecrag front into a genuine three-quarter REAR battle sprite of the SAME creature. The camera is behind Vitrecrag, looking toward its lowered front. The broad rear shell and hind legs dominate the image; the front body slopes DOWN and AWAY from the higher rear shell. Hide the face, eye, and mouth completely. Keep its six thick planted beetle legs, rust-orange joints, dark plum stone shell, and glowing furnace. The shell's irregular silhouette is made of several LARGE, asymmetrically STACKED and OVERLAPPING armor plates, not a horn, dorsal spike, neat tile grid, or smooth dome. Show a substantial orange furnace opening on the creature's RIGHT side as seen in this rear view. The furnace belongs under an overlapping shell plate, not on the face. Respect the approved front's proportions and high back-to-low front wedge shape. Camera angle must read unmistakably as a battle back sprite, with the viewer seeing the BACK of shell and legs, not the side profile or face. Use bold, coherent pixel clusters, few broad material planes, dark contours, restrained highlights, no microtexture, no smooth gradients, no thin antialiased lines. One complete creature on a transparent background, square canvas, no ground shadow, no magenta halo, no extra objects.

## Reject if

- The right-side head or eye is visible.
- The pose reads like another front or side view.
- A new horn or spike projects upward from the shell.
- The back is rounded like a turtle dome or covered in even armor tiles.
- The furnace is absent, tiny, moved to the center, or looks like an eye.
- The front is as high as the rear.
- Pixel density or microtexture is finer than the approved front.

Only after Preston approves a candidate: convert to transparent 128x128 PNG at the official front's pixel density, import under a new filename, then link as `back_sprite` in `data/creatures/108_vitrecrag.tres`. Preserve rejected candidates unlinked.
