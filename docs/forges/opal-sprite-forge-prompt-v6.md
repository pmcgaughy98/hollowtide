# Hollowtide Sprite Forge: Cinderhide quality prompt (v6)

**Historical prompt snapshot:** The live Forge was updated on 2026-09-27 to use approved native grids, including 128×128 Vitrecrag, no fixed color cap, and rig-readable anatomy. See [verified live modes](forge-live-status-2026-09-27.md). The v6 text below is kept for recovery and comparison.

**Live app:** [Hollowtide Sprite Forge](https://opal.google/edit/1-WLZWZcCWFr8l5YTMOFUqBq-1Da2V-eY). Saved and verified after a full reload on 2026-09-26. The three inputs are **Creature Brief**, **Previous Stage Sprite (optional)**, and **Style Anchor (optional)**. The Generate model is Nano Banana Pro at 1:1. The style input is optional and was connected to the Generate step. The first attempted Vitrecrag run reached Opal's image quota before producing an image; generation quality has not yet been reviewed.

The placeholders below represent **linked Opal chips**, not text to paste literally. To restore the prompt, insert each link through Opal's `@` picker and then make a normal graph edit to trigger Opal's save. Verify by reloading the page. Manual text changes alone appeared saved in the editor but reverted on reload during this update.

```text
Create exactly ONE Hollowtide creature sprite from the Creature Brief. The brief determines species anatomy, pose, facing, palette and evolution changes. Draw only that creature: no props, effects, extra anatomy or labels.

REFERENCE IMAGE MODES: For a new Stage I front, leave Previous Stage Sprite empty and draw from the brief. If the brief starts TASK: REDRAW, Previous Stage Sprite is this exact form: retain its recognizable body plan, face and markings while improving the specified pose and rendering; do not evolve it. For a Stage II or III front without TASK: REDRAW, Previous Stage Sprite is the immediately prior stage of the same line. Preserve face and eye identity, palette relationships and one or two signature motifs, then transform proportions, stance, limbs, head-to-body ratio and filled silhouette according to the new brief. Draw a new stage from scratch; do not merely enlarge or bolt parts onto the old one.

VIEW: With VIEW: BACK, Previous Stage Sprite is this same form's approved front. Redraw the same anatomy from a three-quarter rear view facing away toward the upper right. Show back, spine, tail and back of head; at most a sliver of face. Preserve apparent size, palette, markings and contact footprint. Otherwise draw the front from the brief, defaulting to three-quarter right-facing.

CINDERHIDE QUALITY STANDARD: Match the approved Cinderhide front for pixel craft and finish: substantial dark outline, strong chunky silhouette, stepped shadow/midtone/highlight clusters that describe real volume, specific material texture inside major forms, restrained luminous accents and planted weight. Use the optional Style Anchor image for these rendering qualities only. Never copy Cinderhide's reptile anatomy, markings or coal palette into an unrelated species. A giant or evolved form must gain material structure and readable mass, not just larger dimensions. Mature grounded folklore; never cute, chibi or toy-like.

PIXEL ART: Depict a 100x100 logical pixel grid enlarged into one square image. Every logical cell is one flat color. Hard pixel edges and a purposeful palette of up to 24 colors. No gradients, blur, antialiasing, noise, subpixel details or soft edges.

BACKGROUND: One exact flat pure magenta #FF00FF outside the creature. No magenta inside the creature. No transparency, checkerboard, floor, shadow, border, guides or text.

ASSET ALIGNMENT: Exactly one complete creature on a stable 100x100 origin. Keep every body part in frame and the lowest foot or body contact point on a consistent baseline with at least three clear magenta cells below. Same-form redraws and backs retain the reference form's apparent size and footprint. Evolutions may gain mass and alter silhouette while staying planted. If the brief gives no size, fill about 80% of image height. Output one image only.

CREATURE BRIEF: [linked @Creature Brief chip]

LINEAGE OR SAME-FORM REFERENCE IMAGE (optional): [linked @Previous Stage Sprite (optional) chip]

STYLE ANCHOR IMAGE (optional; rendering only, never species anatomy): [linked @Style Anchor (optional) chip]
```

**First queued run:** [Vitrecrag front redraw](../creatures/vitrecrag-redraw-job.md).
