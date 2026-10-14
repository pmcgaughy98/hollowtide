# Opal Forges, brought current (2026-10-14, Claude)

Preston: "The forge hasnt been used in a while. I think before arena even so before you use them skill them up and
make them current." Opal itself ends on 2026-11-17 ("custom workflows transition to skills in Gemini"; the workflow
files stay in Drive under My Drive > Opal), so these prompts are kept here too, ready to move to a Gemini skill.

## Hollowtide Sprite Forge v5

- New workflow file in the Opal Drive folder: `Hollowtide Sprite Forge v5`, Drive id `15KEfOUYirL7ELJOzgSnV58vEsTJC76WE`
  (open: https://opal.google/edit/15KEfOUYirL7ELJOzgSnV58vEsTJC76WE). The September original,
  `1-WLZWZcCWFr8l5YTMOFUqBq-1Da2V-eY`, is unchanged.
- Built by `build_sprite_forge_v5.py`; the uploaded graph is `hollowtide-sprite-forge-v5.json`.
- Same three inputs (Creature Brief; Previous Stage or Same-Form Sprite; Style Anchor), same Nano Banana Pro
  ("image-pro") generate step and bestiary showcase.

What changed from the September prompt, and why:

| Was | Now | Source |
|---|---|---|
| Style anchor: Cinderhide | Tallowroot, never Preostmar | Preston, 2026-10-13 |
| Native grid 100x100 (128 for two giants) | 128 Stage I, 144 Stage II, 160 Stage III and kings, with heights measured from the game's se views (Stage I 76 to 82) | the arena sprite canvases |
| Front and back only | adds VIEW: EIGHT, a 3x3 sheet in the layout `tools/art/slice_grid.py` cuts (ne n nw / e . w / se s sw) | the Ballastak route |
| (none) | fantasy colours, not Earth-animal ones | memory "creature palettes", 2026-10-11 |
| (none) | Hollow means absence, never ghosts | memory "Hollow is absence" |
| (none) | every body part the brief names stays visible (moves come from body parts) | Grok's body-part gate |
| (none) | wild creatures carry no gear unless a town character | NPC wild versions, 2026-10-11 |
| fill about 80% of the image | the stage heights above | measured |

## First runs (2026-10-14)

1. Flintram (roster line 10, Stage I) front, Tallowroot as anchor: a clean Stone quadruped in house style. Misses:
   four or five back stones where the brief says two loose plates, and a ground line under the feet.
2. VIEW: EIGHT with that front as reference: one 3x3 sheet, eight directions, centre empty.

Outputs come back as 1024 px JPEGs on magenta; `tools/art/gemini_sprite.py snap` finds the art-pixel grid and
removes the background. Both are proposal art: Flintram needs Grok's numbers and Preston's approval before assets.

## Running a Forge from Claude Code

The built-in browser pane has Preston's Opal sign-in. The app runs in a same-origin frame; uploads go through a
hidden file input inside that frame, so Claude hands it a file by patching the frame's `HTMLInputElement.click`
for one call. Earlier results are fetched from their `https://opal.google/board/blobs/<id>` address and fed to
the next run without touching the disk.
