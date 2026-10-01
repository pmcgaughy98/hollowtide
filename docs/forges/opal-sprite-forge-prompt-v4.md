# Hollowtide Sprite Forge: live creature generator (v5)

**Updated in Opal on 2026-09-26; new image quality still needs a generation review.** The full current prompt is archived in [v6 prompt notes](opal-sprite-forge-prompt-v6.md); the block below is an older v4 backup.
[Open the current Hollowtide Sprite Forge](https://opal.google/edit/1-WLZWZcCWFr8l5YTMOFUqBq-1Da2V-eY). The former backup is now the [Hollowtide Evolution Forge](https://opal.google/edit/13O5Xm_9Go-u1cKn9TUCWAZhAXDe6OKbV), with separate previous-stage and approved-current-stage image inputs for front and back work. The old backup URL is inaccessible. The main Forge saved its linked input chips after a reload. The older Opal link ending in `1G34GLZ7O1UEBX3pX6NIXNd8LjQjKUyBt` is the **Effect Sheet Generator**.

The live Generate Creature Sprite step uses Nano Banana Pro, aspect ratio 1:1, a required **Creature Brief** text input, an optional **Previous Stage Sprite (optional)** image input, and an optional **Style Anchor (optional)** image input. The style anchor is for the approved Cinderhide front and controls pixel craft only; the previous-stage input controls anatomy and lineage. All three input chips are linked in the current prompt. The generator requests a 100x100 logical pixel grid, a flat magenta background, one creature, Cinderhide-level material shading, and clear pose, proportion, and silhouette changes for evolutions. The back-view rule remains installed. Opal showed **Saved** after the edit and the prompt survived a page reload. Some small graph-card summaries still mention Cinderhide from the app's earlier setup; the saved Generate prompt and app description now apply to any roster brief. No new image was generated in this pass.

## Which input to use

| Task | Start of Creature Brief | Lineage/reference image | Style anchor image |
|---|---|---|
| New Stage I front | Paste the roster brief. `VIEW: FRONT` is optional. | Leave blank. | Attach approved Cinderhide front when you want the full-quality style reference. |
| Stage II or III front | Paste that form's roster brief. Do not write `TASK: REDRAW`. | Upload only the immediately previous stage of the same line. Prefer the approved Forge original. | Attach approved Cinderhide front for the same pixel craft; keep its anatomy out of the new species. |
| Same-form front redraw | Start with `TASK: REDRAW` and `VIEW: FRONT`, then paste that form's brief. | Upload the current approved front of that exact form. | Attach approved Cinderhide front for rendering quality. |
| Back view of an approved form | Start with `VIEW: BACK`, then paste that form's brief. | Upload the approved front of that exact form. | Optional; the same-form front remains the anatomy authority. |

The image input's title is retained for continuity with the roster, but its meaning depends on the mode. For a back view or same-form redraw, it is a same-form reference. Review every generated image before treating it as final. A good front evolution keeps recognizable identity while clearly changing body plan; a good back view is the same stage from behind.

## Backup Generate step prompt (v4 base; current Forge uses the v5 wording)

The bracketed input markers below document Opal's **linked chips**. They are already wired in the live app. If the prompt is ever replaced wholesale, type `@` at each marker and choose the matching input in Opal's picker; plain pasted text will not create a link.

```text
Create exactly one creature sprite for Hollowtide from the Creature Brief below. Follow the VIEW RULE at the end for front or back view. Draw only the requested creature: no props, effects, or extra markings.

FRONT WITH NO IMAGE: draw the creature from the brief alone.

FRONT REDRAW WITH IMAGE: when the brief begins TASK: REDRAW, the image is this exact creature, not a previous stage. Keep its core anatomy, face, palette, and identity while following the brief for the new front-view pose and cleaner pixel rendering. Do not evolve it.

FRONT EVOLUTION WITH A PREVIOUS-STAGE IMAGE (only when the brief is not TASK: REDRAW): draw the NEXT stage as the same animal grown and transformed. Keep only the recognizable face and eye shape, palette, and one or two signature features named in the brief. Change the pose to the one in the brief; do not copy the old stance, legs, or head angle. Change body proportions, including head-to-body ratio, torso, neck, and limbs. Give the new stage a clearly different filled silhouette. Transform old features by growing, fusing, splitting, or reshaping them; absorb or drop details that no longer fit. Do not bolt new parts onto the old body or merely enlarge it. Draw the next stage from scratch.

PIXEL ART: depict a true 100x100 pixel grid enlarged into a square image. Every grid cell is one flat color. No gradients, blur, anti-aliasing, noise, or soft edges. Details thinner than one grid cell are omitted.

BACKGROUND: solid pure magenta #FF00FF, one exact flat color, outside the creature. No transparency, checkerboard, shadow, floor, border, or text. Never use magenta on the creature.

STYLE: mature, grounded folklore creature art; not cute, chibi, or toy-like. Exactly one full-body creature, using the pose, facing, anatomy, and palette specified in the brief. If missing, use a three-quarter side view facing right. Center it and fill about 80% of the image height, feet three grid cells above the bottom. Use a dark one-cell outline, strong chunky silhouette, low interior detail, and no more than 16 colors.

Output exactly one image.

Creature brief:
[linked @Creature Brief chip]

Previous-stage image reference (optional):
[linked @Previous Stage Sprite (optional) chip]

VIEW RULE (overrides earlier instructions when VIEW: BACK is given)
The brief may start with VIEW: FRONT or VIEW: BACK. If it says neither, use FRONT.
FRONT: use the pose and facing in the brief (default three-quarter view facing right).
BACK: this is the player's own creature in battle, seen from behind. Three-quarter rear view: back and tail toward the viewer, head and body turned away toward the upper right, as if facing an opponent in the distance. Show the back, spine, tail and back of the head; at most a sliver of the face in profile. Same size in the frame, same grid, same outline weight and same magenta background as a front view.
If an image is attached with VIEW: BACK, it is NOT a previous stage. It is this exact creature. Redraw it from behind with the same anatomy, proportions, markings, palette and outline. Do not redesign it, evolve it, add features or change colours. Front-only details (face, chest) are hidden; back details (spines, vents, plates, tail) must match the image.
```

## Bring an approved image to Godot

Save the original Opal image, then convert it with `tools/convert_forge_sprite.py` to a transparent 100x100 PNG. Use its `--compare` output to inspect the raw and converted images together. Keep the original under `docs/HollowTide Sprites/Creatures/` and the approved transparent PNG under `assets/sprites/creatures/`. Do not use the older 64x64 HTML converter for Forge art. The current roster briefs are in [creature-roster-draft.md](../creatures/creature-roster-draft.md).

## 2026-09-26 sprite-sheet research update

The current Forge copy that was open in the browser still asked for 64x64 art. It now requests the project's 100x100 grid and includes the same redraw, evolution, and back-view modes. Both creature copies now require a stable bottom contact baseline, at least three clear magenta cells beneath it, and the full silhouette within the canvas. Same-form backs and redraws retain the approved form's apparent size and footprint; evolutions may grow and change anatomy while staying registered. These instructions improve consistency for Godot but do not replace visual review of the generated output. See [Forge production standard](forge-production-standard.md).

## 2026-09-26 Cinderhide quality upgrade (current live Forge)

Preston chose the approved Cinderhide sprite as the in-game creature finish standard. The live Generate step now asks for dense, readable material pixel clusters, layered highlights and shadow planes, controlled accents, and a grounded weight-bearing stance, with up to 24 purposeful colors instead of the old low-detail/16-color ceiling. An optional **Style Anchor (optional)** image input is linked to the Generate prompt. Upload `docs/HollowTide Sprites/Creatures/Cinderhide.jfif` there; it is a rendering reference, not a body-plan or palette reference. Keep the lineage/reference input for the immediately prior stage. The revised prompt and three linked inputs survived a full Opal reload after a graph edit triggered save. A Vitrecrag run with both references reached the daily image quota before producing an image; generation quality still needs review. The first priority is a new Vitrecrag front from Slagglass plus Cinderhide, using the revised roster brief; do not import the existing weak Vitrecrag PNG as a style parent.
