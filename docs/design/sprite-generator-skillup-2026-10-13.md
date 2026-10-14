# Skilling up toward a sprite generator at the game's level (Claude, 2026-10-13)

Preston: "find something in the synthesis that you could reverse engineer or synthesize to achieve a generator that
can just make pixel sprites on the level of the ones in game or the zoids sprite references ... It still looks like
a roblox model."

## Why the model looks like a 3D model
A renderer shades every shape by the angle of light, so each blob gets concentric bands (pillow shading) and every
joint is a seam between rounded volumes. Hand pixel art makes choices a renderer does not: shapes exaggerated on
purpose, shading laid in deliberate clusters, lines of varying weight, small details placed by hand. Those choices
live in a pixel artist or in a model trained on pixel art. More passes on the renderer will not close that gap.

## What the synthesis holds (stock-take, 2026-10-13)
| Source | What it gives | Cost |
|---|---|---|
| SpriteCook (new connector) | image models with up to 14 reference images, pixel mode, edit of an uploaded image, palette hint | free tier, 40 credits; GPT-Image-2 medium 9, low 2 |
| PixelLab pixelart_workbench | a pixel artist's rules as commands: score 0-100, lint, selout, clean-lines, banded shade, repair | free for subscribers; 5 trial generations left |
| Retro Diffusion | the game's sprite source; reference images, custom user styles trained on our sprites | $0.11 until the top-up |
| The game's own sprites | hundreds of finished views, walks and actions: the style to learn from | free |
| Zoids Legacy decompilation | how Legacy got variety at hand quality (below) | free |
| Our tools | the 3D model (consistency), palette snap, sel-out, stray cleanup, the measures | free |

**Legacy, reverse engineered (structure only).** `LoadZoidBodyGraphics(model_id, palette_variant, ...)` loads one
hand-drawn body per Zoid with a palette variant; equipment (shield, Phalanx) is a separate sprite placed at per-body
anchor points (`BattleBodyAttachmentView`); the scene places sprites in 3D (`SceneProjectedSpriteView`). Its
"generator" is a library of hand-quality bodies and parts multiplied by palette swaps and attachments, not a
renderer. For the mech game that means: draw bodies and parts at hand quality once, then generate variety by palette
and anchors.

## The exam: one held-out view
The 3D model's southeast render was repainted by GPT-Image-2 (SpriteCook, 9 credits) with three other drawn views as
the style guide and Kithflare's palette as the hint; the drawn southeast view was held out to judge against. Then
our finish: snap to Kithflare's 37 colours and clean strays. Files in `sprite3d-workshop-2026-10-12/model_kithflare/paintover/`.

| | model render | repaint, finished | drawn se |
|---|---|---|---|
| shape match to drawn se | 0.48 | 0.82 | 1.00 |
| cluster size | 7.5 | 4.2 | 4.4 |
| stray pixels | 3% | 14% | 13% |
| outline | 100% | 83% | 81% |
| colours | 19 | 34 | 18 |

It reads at the game's level: the face, eye glint, smile, cream throat, stripes, flame and tail spiral. Two limits:
it drew its own three-quarter pose instead of keeping the model's (the model became a hint, not a guide), and it
uses 34 colours where the drawn view uses 18.

## The generator, as a pipeline
1. **Design and consistency:** a hand-built model or a blockout gives pose and angle (free, ours).
2. **Finish:** a pixel-art model repaints each view with our own sprites as the style guide (SpriteCook now; Retro
   Diffusion with a custom style trained on our sprites after the top-up).
3. **Discipline:** our passes and PixelLab's workbench: palette lock to the creature's colours, a colour budget
   (18 to 24 for a 128 view), sel-out at dungeon size, stray cleanup, score and lint as gates.
4. **Variety, Legacy's way:** hand-quality bodies and parts, palette variants, anchored attachments.

## What to learn next (in order)
1. Hold the pose: give the model render as the edit image with lower freedom, or as a line-art guide, and compare
   shape match to the model render as well as to the drawn view.
2. A colour budget pass: reduce to the drawn view's 18 by merging the least-used colours into their ramp neighbours.
3. PixelLab's workbench `score` and `lint` on drawn, model and repaint, to turn its rules into our gates.
4. Retro Diffusion custom style from our finished sprites, after the top-up, and the same held-out exam.
5. For the mech project: one body and two parts at hand quality, then palette and anchor variants, Legacy's way.

## Added the same day: the pixel-art sprite skill
Preston installed `melodic-software/claude-code-plugins`' sprite skill. The `skills` installer skipped it (its file
has no name field and it belongs to the pixel-art plugin), so it sits in `.claude/skills/sprite/` as a project skill
with the plugin's scripts, reference notes and palettes, paths rewritten to that folder (MIT). It authors sprites as
palette-locked grids or small Python generators and renders them with a standard-library renderer and a review
loop. For this goal it is the discipline layer, not the finish: `reference/craft-static.md` writes down the craft
rules (one light direction, hue-shifted ramps, selective outline, no pillow shading, no banding), and
`render.py --snap` locks any image to a project palette, which is step 3 of the pipeline above.

## Added the same day: SpriteCook's own skills
Preston pointed at `github.com/SpriteCook/skills`; all ten are installed as project skills in `.claude/skills/`
(commit ad3c56e, MIT; instructions and the one offline Pillow helper only). What they change in the plan:
- **Model choice:** they recommend Nano Banana 2.1 for pixel sprites (the exam used GPT-Image-2); `style_asset_ids`
  takes at most 10 through the connection, and `reference_asset_id` is the one context image, where `edit_asset_id`
  is meant for modifying an existing asset. The pose problem may be partly that the render went in as an edit.
- **Grids:** asking for related sprites in one 3x3 or 4x4 grid gives smaller, more consistent pixel art. For a
  creature that means all eight directions in one 3x3 sheet, the way Retro Diffusion's rotate makes its sheets,
  so the model keeps the views consistent with each other.
- **Edges:** `spritecook-polish-sprites` tunes the binary alpha cutoff from a preserved source, free, which is the
  fix for the soft edges behind the exam's 2,026 colours before our palette snap.
Next exam, in that light: Nano Banana 2.1, the model render as `reference_asset_id`, drawn views as style, eight
directions in one 3x3 grid, polish the cutoff, then our finish and the held-out comparison.

## Skill-up round 2 and the first new creature (same day)
`tools/art/finish_sprite.py` is the discipline layer, gated by PixelLab's lint rules (off-palette, partial alpha,
orphans, small clusters, outline gaps, doubles, border contact). What the passes taught, each one a pixel artist's habit:
- the outline is the colour the creature's own sprites put on their edges, not the darkest colour (Kithflare's eye is darker);
- a colour budget must keep the accents (darkest, brightest, highest chroma), or it folds away the eye glint and the claw rust;
- rank accents by chroma, not saturation ratio, which calls near-blacks saturated;
- despeckle by contrast: a one- or two-pixel patch close to its neighbours is noise, one that stands out is a line or a glint;
- never rescale generated pixel art by a non-whole ratio; ask for the game's scale at generation instead.
Then Ballastak, the Stone digger's stage 1 (`docs/design/new-creature-ballastak-2026-10-13/`): a Nano Banana 2.1
master from its brief with five in-game sprites as style, then all eight directions in one 3x3 grid with the master as
the reference. Grid sheets come back facing the centre; slice by connected shapes, not thirds. The set measures a 2 px
height spread and 0.94 to 0.99 mirror pairs. Next: the dungeon-size set (sel-out), a walk from the same master, and
the same method for a mech body in Legacy's bodies-and-parts way.

**Preston's verdict on Ballastak (same day):** the raw Nano Banana output was better than the finished one, and
Preostmar is one of the weakest sprites, so it is out of the style set; Tallowroot is in. So the finisher is for
soft-edged output (GPT-Image-2) and the dungeon-size sel-out, not for NB 2.1's pixel-perfect output, which is now
delivered untouched through `tools/art/slice_grid.py`. Note for later: raw views carry about 2,000 near-identical
colours each, invisible at game scale, but a palette swap (Legacy's variants) would need a gentle palette step then.

**Stage 2 by another tool (same day).** With SpriteCook at 3 credits, Switchhold came from PixelLab Pro Flash's
character tool: the brief as text, the previous stage's master as the single style image, eight rotations in one job
(8 generations of the day's 25). The rotations agree well (mirror pairs 0.92 to 0.93) and keep the line's palette and
face; the snout softened. A fair split for later: Nano Banana 2.1 for a master, PixelLab for rotations from a front
view when credits are short, and edit passes to pull drifted features back to the brief.

## Our own art, reverse-engineered (same day, late)

Preston asked whether the synthesis could reverse-engineer Hollowtide's own pixel art instead of renting a model.
Two routes, in his order ("do but in D. then 2").

**1. A local style model on D (`D:\ai\hollowtide-sprite-lora`).** Stable Diffusion 1.5 plus a small add-on (a LoRA)
trained only on our finished creature views: 339 views of 47 creatures, Preostmar left out, Kithflare's se view held
back for the exam. Each 128 px view goes on white and is enlarged exactly 4x, so every sprite pixel is a clean 4x4
block; generations come back by finding the block phase and taking each block's most common colour (checked: a
training image, shifted or not, comes back pixel for pixel). Measured on this machine (GTX 1660 Super, 6 GB, about
2.5 GB already used by open apps): half precision gives NaN through cuDNN in both the VAE and the UNet; with cuDNN off
it is clean at 1.86 GB and the same speed. Training runs at about 10 s a step, 1200 steps, about 3.3 hours.
Install note: `diffusers[torch]` needs torch 2.6 or newer and quietly swaps in the CPU build; reinstall from the
PyTorch CUDA 12.6 index afterwards.

**2. Legacy's parts method (`tools/art/parts_kit.py`).** Palette variants move each colour family to a new hue and
keep every pixel's lightness, so they read hand-made; crest planting cuts what sticks up above a donor's back line in
each view and roots it into the recipient's outline. Test on Ballastak in
`docs/design/new-creature-ballastak-2026-10-13/parts_kit/`. Works best on side and three-quarter views.

**The local model's exam (2026-10-14).** Training finished (1200 steps, 1 h 46 min at about 7 s a step). On
Kithflare's held-out se view, plain SD 1.5 drew robots (shape match 0.45 to 0.49, the score of any blob); our model
at step 600 scored 0.30 to 0.44 and at 1200 steps 0.32 to 0.46. It learned the house frame: one full-body creature,
outlined, on a background the grid snap and cutout handle cleanly. It did not learn our creatures: every result is
dark brown and mostly upright (bears, bugs, imps), never an orange gecko, and the new Ballastak prompt gave the
same brown upright figures. 339 small sprites are too few for SD 1.5 to learn identity or palette. Verdict: parked.
The free route is the Opal Sprite Forge v5 (Nano Banana Pro, `docs/art/opal-forges/README.md`) plus
`tools/art/gemini_sprite.py snap`; the paid one is Nano Banana 2.1 through SpriteCook. Sheet:
`D:/ai/hollowtide-sprite-lora/out/exam/exam_sheet.png`.
