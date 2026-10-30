# Hollowtide sprite pipeline: what we have tried (our own notes, not a source)

Hollowtide is a 2D pixel-art creature-collecting game in Godot 4 (a turn-based dungeon crawler plus an arena mode).
Every creature needs eight facing views (n, ne, e, se, s, sw, w, nw) and an 8-frame walk per direction. Arena
canvases are 128 to 160 px; dungeon sprites are about 30 to 65 px tall. Most creatures are quadrupeds, fish-like
walkers or other non-humanoid bodies. The house style is the attached Tallowroot view: dark outline, large colour
clusters, stepped shading, upper-left light, fantasy colours.

Everything below is our own measurement or experience from September and October 2026. It is context for the
research, not evidence.

## Tools and what happened

| Tool | What we used it for | What worked | What failed |
|---|---|---|---|
| Retro Diffusion (MCP, paid credits) | default sprite tool since 2026-10-01: fronts, 8-direction rotation, walk animation, image_edit for back views | native pixel grid, real pixel-art look, rotation gives 8 views in one job | rotations drift from the front; generated "takes" sometimes carry a pale grey block that poisons every later step; two jobs at once misfiled a walk sheet as the wrong output |
| PixelLab (MCP, limited generations) | 8-direction character rotation, an 8-direction walk test of the human courier | best 8-direction rotation we have seen | limited generations; creature walks not tested at scale |
| Google Opal "Forges" (Nano Banana Pro, free until 2026-11-17) | one 3x3 sheet of all eight angles from a front, then fronts and backs | the Flintram line's eight-view sheet was approved as canon | 1024 px JPEG on magenta, needs grid recovery; drifts in back three-quarter views |
| Nano Banana 2.1 (via SpriteCook) | repainting views with our own sprites as references | raw output reached 0.82 similarity on a held-out view; Preston preferred the raw output to our heavy post-processing | our finishing passes made it worse |
| OpenAI image generation (inside the Codex app) | a 3x3 eight-angle sheet for a new Stage II (Riftfin), and one missing back view | one single back view passed every check | the full sheet was rejected: side views 15% shorter than the others, mirrored pairs did not match (0.64 overlap), details changed between views (see attached review) |
| Gemini API image models | reference-guided sheets | n/a | free tier allows zero image calls |
| Blender, hand-built 3D model rendered down | Kithflare test, 2026-10-13 | exact agreement between angles | renders read as 3D ("roblox"), matched the drawn views only at 0.56 to 0.58 |
| Our code (Python) | slicing, palette lock, judging, walk_lock (body held still, only legs move) | mechanical fixes (alignment, flips, palette) are free and exact | code redrawing a creature looks wrong; walk_lock kept for Kithflare, reverted for Tallowroot and Archroot |
| AutoSprite (MCP) | 8-direction pipeline | n/a | needs a paid plan |

## What firsthand accounts on GitHub taught us (our summary)

- Generate five directions and mirror three (e/w, ne/nw, se/sw are flips for symmetric creatures).
- Run a drift judge after every generation and regenerate only the failing views, at most three times.
- Lock one palette and snap to the pixel grid across all views.
- Render-to-pixel from a 3D model gives exact consistency, at the cost of a 3D look unless the model and the
  pixel pass are tuned.

## The measured problems (attached files)

- `judge_all_sets.txt`: our eight-view judge over 50 in-game creature sets. 22 need views generated again (wrong
  facing, back view that is really a three-quarter, height or palette drift); the other 29 only need code fixes.
- `walk_audit.md`: every creature's walk. "boil" is the share of pixels that change frame to frame on the body
  (should be near zero away from the legs), "limbs" is leg movement, and the facing column lists directions whose
  walk frames look like a different direction.
- Images: the house style, two eight-view sets the judge rejected, two walk strips, the Codex sheet review, and a
  case where three back-view files were simply in the wrong slots.
