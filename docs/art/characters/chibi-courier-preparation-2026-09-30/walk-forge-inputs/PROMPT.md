# Walk Cycle Forge runs: chibi courier (2026-10-01)

One direction per run. For each run, paste the brief into **Walk Cycle Brief** and attach the matching image as **Character Reference**. Order: DOWN, UP, RIGHT, LEFT (down and up only fill two gaps; the sides need three).

Each image is a 2x2 sheet on flat magenta: F0 top left, F1 top right, F2 bottom left, F3 bottom right. Filled cells are Preston's original chibi poses, enlarged 4x with no redraw.

## Run 1: DOWN, attach `down_partial_2x2.png`

```text
MODE COMPLETE. DIRECTION DOWN. KIND OVERWORLD. FRAMES 4.
KEEP F0 (top left, near boot forward contact) and F2 (bottom left, opposite boot forward contact) exactly as drawn.
MISSING F1 (top right) and F3 (bottom right): the two passing poses. F1 passes from F0 to F2, F3 passes from F2 back to F0. Feet close together under the hips, one knee softly bent, boots on the same baseline as the kept cells, arms nearly at the sides.
Match the reference's own size, detail and finish exactly: same head size, face, brass goggles on the forehead, brown hair, teal jacket, dark shirt, tan trousers, brown boots, olive satchel on the strap across the chest hanging at his left hip (viewer's right). Do not simplify to a smaller pixel grid than the reference.
Be honest: if a pose cannot match the kept cells, leave that cell flat magenta instead of copying a kept pose.
```

## Run 2: UP, attach `up_partial_2x2.png`

```text
MODE COMPLETE. DIRECTION UP (back view, walking away). KIND OVERWORLD. FRAMES 4.
KEEP F0 (top left, contact) and F2 (bottom left, opposite contact) exactly as drawn.
MISSING F1 (top right) and F3 (bottom right): the two passing poses between them. Feet close together under the hips, one knee softly bent, boots on the same baseline as the kept cells.
Match the reference's own size, detail and finish exactly: back of the brown spiky hair, teal jacket, satchel strap and olive satchel on the back as shown, tan trousers, brown boots. No face, no goggles lenses visible from behind. Do not simplify to a smaller pixel grid than the reference.
Be honest: if a pose cannot match the kept cells, leave that cell flat magenta instead of copying a kept pose.
```

## Run 3: RIGHT, attach `right_partial_2x2.png`

```text
MODE COMPLETE. DIRECTION RIGHT (facing and walking to the viewer's right). KIND OVERWORLD. FRAMES 4.
KEEP F0 (top left): near leg forward contact, far leg behind.
MISSING F1, F2, F3. F1: passing, the far leg swings forward past the planted near leg, feet close together under the hips. F2: opposite contact, far leg forward and near leg behind, visibly different from F0 by which boot is in front and its darker far-side shading. F3: opposite passing, the near leg swings forward, returning to F0. Arms counter-swing. Body bob at most one pixel.
Match the reference's own size, detail and finish exactly: same face in profile, brass goggles on the forehead, brown hair, teal jacket, tan trousers, brown boots, olive satchel on the near hip at the viewer's left as shown. Same height in every cell. Do not simplify to a smaller pixel grid than the reference.
Be honest: if a pose cannot be drawn cleanly, leave that cell flat magenta instead of copying F0.
```

## Run 4: LEFT, attach `left_partial_2x2.png`

```text
MODE COMPLETE. DIRECTION LEFT (facing and walking to the viewer's left). KIND OVERWORLD. FRAMES 4.
KEEP F0 (top left): near leg forward contact, far leg behind.
MISSING F1, F2, F3. F1: passing, the far leg swings forward past the planted near leg, feet close together under the hips. F2: opposite contact, far leg forward and near leg behind, visibly different from F0 by which boot is in front and its darker far-side shading. F3: opposite passing, the near leg swings forward, returning to F0. Arms counter-swing. Body bob at most one pixel.
Match the reference's own size, detail and finish exactly: same face in profile, brass goggles on the forehead, brown hair, teal jacket, tan trousers, brown boots, olive satchel on the far hip at the viewer's right as shown. This is its own drawing, not a mirror of the right-facing walk. Same height in every cell. Do not simplify to a smaller pixel grid than the reference.
Be honest: if a pose cannot be drawn cleanly, leave that cell flat magenta instead of copying F0.
```

## When results come back

Save each one in this folder as `down_result.png`, `up_result.png` and so on, and tell Claude. Claude keeps Preston's original cells, cuts only the new poses, checks each one against the kept cells, and swaps them into `scripts/player.gd` (`CHIBI_STEP_COLUMNS`, dropping the one-pixel lift).
