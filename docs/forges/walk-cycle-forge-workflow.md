# Hollowtide Walk Cycle Forge

**Live update, 2026-09-27:** The Forge prompt and brief input now support MODE NEW and MODE COMPLETE with KEEP/MISSING F0–F7, plus matched on-screen size across directions. Both persisted after reload. See [verified live modes](forge-live-status-2026-09-27.md). No new output was generated.

The [Walk Cycle Forge](https://opal.google/edit/1hJoFcTzUTBVT-EqX8eA2eTQaUEiLEhQy) is a separate Opal app for a **true walking sheet**, one direction per run. It was duplicated from the Idle Forge on 2026-09-26; the working creature and idle apps were left intact. The required inputs are Walk Cycle Brief and Character Reference. Generate Walk Frames and Walk Cycle Preview both link to those inputs. The saved prompts were reopened and checked.

## Why this exists

The live male courier source at assets/sprites/player/character_walk_sheet.jpg has four directions. Its RIGHT row repeats nearly the same fully extended stride in all four cells; changing playback speed leaves the character gliding. LEFT has a similar weakness. The source is still the game's walking art, with measured crops in scripts/player.gd and magenta removal in the player shader. Preserve that original until a replacement is visually approved and wired into Godot.

## Generate one direction

1. Open the Forge, choose App > Start, and upload the approved character image or existing sheet to Character Reference.
2. In Walk Cycle Brief, name the character, choose exactly one of RIGHT, LEFT, DOWN, UP, and list the identity details to retain. For the courier, keep brown tousled hair, brass goggles, teal jacket, dark shirt, tan trousers, brown boots, cross-body satchel, face, proportions, outline, and palette. Keep the satchel on the same side throughout.
3. Press the send/play control after the inputs are entered. Save the original generated sheet, not a screenshot of the output webpage.

The prompt requires eight distinct frames in a 4-column by 2-row sheet, reading left to right across the top and then bottom: near-foot contact, down, passing, push-off, opposite-foot contact, opposite down, opposite passing, opposite push-off. Each cell must share the same pixel grid, foot baseline, body size, palette, and viewpoint. At least one boot plants in every frame. Torso bob is small; arm and satchel motion follow the legs. A held far-stride in every frame, duplicate poses, floating feet, or changing clothes means reject and regenerate.

Run RIGHT first to repair the visible glide, then make LEFT, DOWN, and UP from the same approved identity reference. Review each at the size it appears on the first route, not only enlarged. Compare frame 8 back to frame 1 for a seamless loop.

## Import after review

Keep the raw image and a transparent, aligned PNG sheet separate. The current player script uses four measured crops per direction; an approved eight-frame 4×2 per-direction sheet will require a new frame map, animation selection, and idle frame in scripts/player.gd. The old 4×4 sheet is not a uniform grid, so do not drop the new image into its path or assume equal existing crops. Keep the current source as a fallback while reviewing all four directions in Godot.

## Current in-game state, 2026-09-27

The refined male courier is now wired into Godot. `assets/sprites/player/male_side_walk_refined_8_v2_2026_09_27.png` is a 4×2 sheet of eight rightward poses; left uses a horizontal mirror. Two near-feet passing poses fill gaps in the earlier approved side sheet. `assets/sprites/player/male_vertical_walk_4x2_2026_09_27.png` is a 4×2 sheet with four DOWN frames in row one and four UP frames in row two. All cells are 256×512 with transparent backgrounds and registered feet. The new adult front/back art replaces the old short front/back character. `scripts/player.gd` selects the sheets; `scenes/player.tscn` uses the new DOWN idle pose. The visible side figure is 480 source pixels high and the vertical figure is 465. Side scale 0.0727 and vertical scale 0.075 make both about 34.9 game pixels high, avoiding a turn-size jump.

The raw generated source frames are preserved in `docs/HollowTide Sprites/Character/`. The processed candidate sheets and pre-edit backups are under `C:/Users/pmcga/Documents/Codex/Hollowtide/`. The old `character_walk_sheet.jpg` and `male_side_walk_harmonized_8.png` remain on disk as fallbacks. Godot imported the new PNGs and reported no player script parse errors. The side playback now runs eight frames at 14 fps, close to the same 0.57-second loop as four vertical frames at 7 fps. The four-direction walk has not yet been evaluated in a running route. In the next visual pass, check foot planting and frame order at normal play size, plus the side-to-vertical size transition. Treat the installed sheets as a working pass until Preston reviews them.
