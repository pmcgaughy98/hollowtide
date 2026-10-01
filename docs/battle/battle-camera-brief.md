# Battle camera direction (proposal)

**Status:** implemented battle-view study, pending Preston's visual approval. The creature stage, fixed HUD, river-landing backdrop, and short focus movements are wired into `scripts/battle_screen.gd` in a 1152×648 view. The foe rests near (820, 190), the partner near (300, 350), and the opponent has an adjustable distance scale. The 288×162 river-landing study draws at an exact fourfold nearest-filtered scale. A captured battle showed the backdrop and focus rig in use; the revised name and HP layout has not yet been viewed in a fresh battle.

## What the view should communicate

A battle is a field encounter in a particular Hollowtide habitat. The partner stands close to the player on the lower left; the wild creature has its own ground on the upper right. The camera must make the opponent feel farther away without shrinking every large creature to the same size. Feet should stay planted through breathing and impact. Silhouettes, effects, and HP must remain readable at native pixel-art scale.

For the first river landing, use an original cutbank stage: a near silt ledge, a farther bank with reeds and worn retaining stone, a quiet waterline, and the hint of a relay post or height marks. Use the route's existing shapes as a reference. The frame should suggest a place with a memory of high water without depicting a real flood or turning the historical event into spectacle. Do not copy a background from another monster game.

## Motion language

- **Arrival:** reveal the habitat and settle on the two creatures quickly. Let the encounter feel discovered rather than switching to a generic arena.
- **Choice:** hold a still, legible composition. Idle animation belongs to the creature; the camera should not drift constantly.
- **Attack:** briefly favor the attacker, then let the current lunge, projectile, hit stop, flash, damage number, and recoil carry the action.
- **Impact:** shake the creature stage lightly according to hit weight while HP and buttons stay anchored. Background motion can be added with the river backdrop. Strong hits may move farther, but constant motion would bury the art.
- **Evolution:** give the transforming partner more room without covering the message or HP. Return to the same resting composition afterward.

## Build path

1. **Implemented structurally:** separate the battle's visual stage from its interface. A Node2D stage now holds sprites, effects, and damage numbers and takes the hit shake. HP, messages, and buttons stay on the fixed CanvasLayer. Existing attack and impact timings remain. Visual behavior still needs an in-game review.
2. **Implemented as a study, pending play review:** `assets/backgrounds/river_landing_battle.svg` draws the near silt ledge, water, far bank, reeds, retaining stone, and a small height marker. It is authored at 288×162 and drawn at 4× behind `BattleStage`. The player rests at (300, 350) so its feet align with the foreground ledge and clear the new HUD message frame. Confirm both creatures' ground contacts, scale, and silhouette separation in a battle before making the image final.
3. **Implemented structurally, pending visual tuning:** `FocusStage` moves the river and creature stage together on encounter entry and attacks, then returns to rest. `focus_shift_px` and `focus_zoom` are exposed for tuning. The current approach is a deliberate stage transform under the CanvasLayer; a future true Camera2D would require a world canvas or SubViewport.
4. After the river stage reads well, decide which elements generalize to bluff, rail, grainfield, and town encounters. Preston has since selected the `Main Hud.jpg` style; preserve that framing and the continuous Turbo Green HP behavior while expanding environments.

**Review points:** both sides remain visible at their battle sizes; the opponent reads farther away; HP changes continuously at the exact remaining percentage, with Turbo Green viridian at full health, yellow to orange through medium health, and red at low health; the UI stays steady when the scene shakes; and the river landing feels like Hollowtide rather than a stock arena. These require an in-game visual review before the direction is considered settled.
