# Whole-sprite battle action direction

**Preston's decision, 2026-09-27:** For contact attacks such as a claw strike or a running hit, keep the creature's approved sprite intact. Move that sprite toward the opponent like a painted game piece, show the move's strike art at the point of contact, apply the hit there, then return the creature to its battle position. Early Pokémon, Nexomon, and Miscrits are feel references for this presentation, not assets or exact timing templates. Whole-sprite breathing remains the default idle.

## Action sequence

1. Pause idle breathing for the attacking sprite. Keep its shape and current front or back image unchanged while it winds up.
2. Move the intact sprite toward the defender. Let the move's physiology set speed and path: a heavy Clinkerhide shoulder rush should feel different from a fast Wayburn dash. Stop beside the target's visible edge instead of covering it or the HUD.
3. At contact, show a move-specific slash, impact, debris, heat burst, or other material effect on the target. Trigger damage, hit flash, sound, shake, and the continuous HP change on this same beat.
4. Hold briefly when weight calls for it, return the attacker to its exact home position, and resume breathing. The defender remains readable throughout.

Ranged attacks, beams, guards, and interruptions use their own paths. Their effects should still come from the creature's anatomy and reach the target at the moment damage is applied. A drawn body pose or smear may enhance a specific move later, but it is not required to make a contact move playable. A flattened sprite does not need to be cut into a skeleton for this baseline.

## Current project fit

`scripts/battle_screen.gd` now has a first contact pilot: `_strike_animation` carries the intact `Sprite2D` along the line between creatures, computes travel from their visible alpha bounds and battle scale, plays the move effect on the target at impact, applies damage, and returns home. `MoveData.delivery` distinguishes CONTACT from the existing PROJECTILE default. `Wayburn/Shoulder Drive` and `Ironvent/Cinder Claw` are the first two tagged moves; their travel times differ. The old Ironvent action-frame atlas remains in its resource but is bypassed while Cinder Claw uses the contact route. This code has not yet been visually reviewed in a battle. Preserve turn order, guards, interruptions, HUD, and continuous HP fill while tuning it.

`data/creatures/101_clinkerhide.tres` currently sets `idle_breath = 0.026` and `idle_period = 1.9`. That whole-sprite battle breath is the preferred idle. The separate Clinkerhide preview uses the same inhale shape and values for comparison; it is not a replacement battle renderer.

## Research boundary

`docs/Gemini DeepResearch(Hollowtide)/Hollowtide Animation System Research.docx` is useful for anatomy-led move concepts, timing beats, and the warning that real cutouts need hidden-pixel underpainting. Its hybrid cutout pipeline and specific production estimates are proposals, not instructions to override Preston's simpler whole-sprite choice. Review proposed move names against the current roster and move resources before adopting them.

## First implementation review

Watch Shoulder Drive or Cinder Claw as both a player back-view strike and a foe front-view strike at actual battle scale. Confirm that contact art appears on the defender, damage and HP change occur on that frame, the attacker returns exactly home, breathing resumes, and neither creature obscures the UI. Tune the travel gap and timing from that visual review before tagging more melee moves. Missing creature texture paths in the current project must be resolved before claiming this battle review passed.
