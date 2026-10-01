# Gemini Deep Research task — Hollowtide combat action animation

**Status:** Ready to paste into Gemini Deep Research. This is research and production design, not approval to replace sprites or edit the game.

## Provide Gemini these project references

- `THE_CONCEPT.md`, `docs/art/art-direction.md`, `docs/forges/forge-production-standard.md`, `docs/art/idle-animation-workflow.md`
- `scripts/battle_screen.gd` (`_drawn_attack_animation` and `_drawn_impact_effect`), `scripts/move_data.gd`, and `data/moves/ironvent_cinder_claw.tres`
- Approved Ironvent front and the existing `assets/sprites/creatures/ironvent_claw_6.png`
- Original `docs/HollowTide Sprites/Idle Animation Sheets/Ironvent claw animation*.jfif` and `docs/HollowTide Sprites/Effect Sheets/IronVent Effect/IronVent Claw Attack.jfif`
- Approved Cinderhide front as the project's pixel-finish benchmark; one front and one back sprite for viewpoint examples
- Earlier `Godot Pixel Art Animation Workflow.docx` and `2D Game Sprite Sheet Research.docx` as claims to audit, not rules to follow

## Copy to Gemini

> Research a practical **2D pixel-art combat action animation pipeline** for Hollowtide, an original monster-collector game in Godot. Start with Ironvent's Cinder Claw as a concrete failure case: four Opal sheets were combined into a six-frame creature atlas, but the claw motion made through an idle-animation generator did not read as a convincing attack. Diagnose likely causes by visually inspecting the supplied frames: repeated peak pose, absent anticipation or in-betweens, whole-body sliding, unclear limb trajectory, pose drift, poor registration, or mismatch between body motion and separate slash/impact art. Distinguish what you can directly observe from what you infer.
>
> Define the right scope and vocabulary. We need an **attack/body-action Forge** now, but it should fit a wider battle animation system that can later cover guards, interruptions, hit reactions, status actions, projectiles, and recoveries. Explain which motions need new creature pixels and which are better handled by Godot transforms, impact effects, particles, camera, hitstop, and sound. Preserve the approved creature design; do not propose that every move needs an entirely new sprite sheet.
>
> Compare at least three production methods for mature, detailed, grounded pixel art: (1) a single six-cell AI sheet, (2) per-pose edits from the approved sprite with references to adjacent poses, assembled into a sheet, and (3) artist-assisted cleanup/in-between authoring. Give cost in generations, expected failure modes, and when to switch methods. Investigate whether a fixed six-frame 3×2 layout is appropriate, or whether action-specific frame counts and unequal frame holds perform better. Hollowtide currently has six attack textures, a uniform 0.09-second hold, contact/effect on the penultimate frame, and a small code-driven lunge. Treat those as current implementation facts, not timeless art rules. Recommend how to carry contact frame and timing metadata to Godot without drawing labels on the asset.
>
> Provide a concrete frame-by-frame motion plan for **Ironvent Cinder Claw** in the approved exact view: ready, anticipation, load, launch, contact, recovery (or a better evidenced sequence). Specify for each pose the weight-bearing foot, torso rotation, shoulder/elbow/wrist/claw position, silhouette change, eye/head focus, and allowed vent response. Show how claw motion reaches a distinct contact pose and returns to idle without teleporting. Keep the creature body animation separate from the already prepared target slash/impact sheet. Include a second brief example for a non-claw action so the pipeline generalizes.
>
> Investigate consistent logical pixel grid, palette and outline preservation, same-view front/back constraints, equal cell canvas and baseline, frame registration, integer placement, native 100/128-pixel art, magenta chroma key/JPEG fringe cleanup, nearest-neighbor scaling, and review at the actual 1152×648 battle size. Do not impose 64×64, a fixed palette count, transparent output from Opal, or pixel-exact AI preservation without evidence. Explain how to judge motion with a flipbook or onion-skin preview and which objective checks can be automated versus which require visual review.
>
> Recommend exact inputs, output contract, and concise prompt patterns for the duplicated **Hollowtide Attack Animation** Opal Forge. Include NEW and COMPLETE/REPAIR modes for a partial sheet, a method for preserving approved poses as anchors, and a plan for adding missing in-betweens without accidental new anatomy or changing the camera angle. If a six-frame one-shot is too unreliable, give a feasible staged workflow within Opal's image quota. Supply a failure-to-revision table specific to Ironvent's current claw attempt.
>
> Use primary sources where possible: working animators' own pixel-art breakdowns, official Godot 4.x documentation for AnimatedSprite2D/SpriteFrames/AtlasTexture/AnimationPlayer and filtering, and original developer art or animation talks. Cite links and access dates. Separate sourced practice, your visual diagnosis, and Hollowtide design proposals. Audit the two attached Gemini reports for claims that conflict with the actual project and flag any unsupported statement. Do not copy a commercial creature, move, pose sheet, or palette.
>
> Deliver: (A) one-page executive decision and terminology; (B) a production matrix; (C) Ironvent six-pose storyboard with contact timing; (D) Opal input/output and prompt templates for body poses plus separate effects; (E) Godot integration outline grounded in the current scripts; (F) frame-level acceptance checklist and failure-repair table; (G) a three-iteration experiment using the existing assets with a clear pass/fail gate; (H) source ledger distinguishing fact, inference and proposal. End with no more than five decisions that genuinely need Preston's taste. Do not modify project files.

## How we will use the answer

Codex will compare the report with the actual current assets and code, then update the Opal Forge, conversion/inspection workflow, and Ironvent action only where the evidence and Preston's visual review support it. The current Forge's provisional six-frame F4-contact contract matches today's `battle_screen.gd`; Gemini should challenge it when it harms animation quality.
