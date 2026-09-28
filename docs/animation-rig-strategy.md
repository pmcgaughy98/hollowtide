# Hollowtide animation rigs: a selective pilot

**Working production decision, 2026-09-27.** Preston asked whether 2D skeletons would improve the courier walk and make the creature roster easier to animate. This is a proposed workflow, not a mandate to replace approved sprites.

## Current diagnosis

- The male courier's side sheet has 480-pixel-high visible figures; UP/DOWN have 465-pixel-high figures. `scripts/player.gd` now draws side at 0.0727 and vertical at 0.075, for about 34.9 game pixels in every direction. The turn-size correction is separate from the remaining gait-quality problem.
- The current sprite sheets are flattened images. A bone cannot independently bend a leg or swing an arm in those files without first separating and repainting overlapping parts.
- The side cycle has AI-generated in-betweens and still needs a normal-size motion review. Its default playback is now 14 fps for eight frames, matching the 0.57-second loop of the four-frame vertical cycle at 7 fps. Do not assume the size fix makes the gait final.

## Recommended pilot: one courier side rig

1. Preserve the current approved courier sheets as fallbacks.
2. Make a separate, transparent, layered side-view source: torso/coat, head/goggles, bag/strap, near and far upper/lower legs and boots, near and far upper/lower arms and hands. Paint behind every joint so moving a limb never exposes a hole. Keep the same character, colors, and logical pixel grid.
3. Build one isolated Godot cutout scene with those pieces, hip root, leg and arm pivots, and an `AnimationPlayer` walk. Use four clear key poses per leg: contact, down, passing, push-off. Opposite legs are half a cycle apart; feet remain planted during their support phase.
4. Render with nearest filtering. Inspect at the first route's actual zoom. If joints smear, gaps appear, boots slide, or the silhouette looks less like the approved pixel art, keep the frame sheet and repair its missing poses manually instead.
5. Only after the side pilot succeeds, consider separate front/back cutout views. A side rig cannot be rotated to show a new 2D camera angle.

## Creature production rule

Use rigs selectively by anatomy and motion need. A quadruped runner, a six-legged kiln creature, a fish, a bird, and an island turtle need different part layouts and pivots. Related evolutionary stages may reuse an animation *plan*, but their proportions and silhouettes still need their own art and rig adjustments. For many small battle creatures, a few hand-authored idle/attack key frames plus restrained whole-sprite motion will retain crisper pixel clusters than deforming the body. A rig is useful for a tail, jaw, limb, antenna, or breathing layer that must move often; it does not generate a true rear view or a new evolution.

Godot supports cutout rigs and can mix them with cel/frame animation. Its [cutout tutorial](https://docs.godotengine.org/en/stable/tutorials/animation/cutout_animation.html) shows the separate-pieces workflow; the [2D skeleton tutorial](https://docs.godotengine.org/en/stable/tutorials/animation/2d_skeletons.html) shows `Skeleton2D` and `Bone2D`. The stable documentation currently warns those pages may not yet be updated for Godot 4.7, so use the project's actual editor APIs when implementing.

## Acceptance before adopting a rig widely

At native game size: no costume drift, no visible seams, grounded contacts, a repeatable loop, readable Cinderhide-level pixel clusters, and no turn-size jump. Make one pilot and compare it directly against the frame sheet before planning rigs for the 60-form roster.
