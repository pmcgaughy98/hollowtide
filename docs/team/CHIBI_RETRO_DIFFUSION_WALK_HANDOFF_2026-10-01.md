# Eight-direction chibi walking handoff | October 1, 2026

Preston expanded the active order: finish menu walking sprites, then make male and female chibi models walk, choosing all eight directions. The current completion is the installed Courier Lookout walk-in plus two prepared eight-direction walking sets and their runnable review scene.

## Implemented and verified

Menu: scripts/main_menu_art_preview.gd now plays three real stride cycles for each rear-right actor as it travels along the path, then restores the saved contrast/dusk-lit idle atlases. Courier arrives at 2.7s; Cinderhide at 3.38s. Cinderhide's contact shadow moves with it. All eight walk frames observed. Reduce Motion freezes positions, frames, shadow and menu clock; disabling it resumes. New Game called during arrival loaded FirstRoutePrototype. Zero observed errors, 11 shared warnings, none from this preview script.
[Menu record](../art/menu/retro-diffusion-walking-2026-10-01/README.md).

Chibi assets:
- assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/male_chibi_walk_eight_directions_native80.png
- assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/female_chibi_walk_eight_directions_native80.png
- male_chibi_walk_frames.tres and female_chibi_walk_frames.tres in that folder.
- scenes/chibi_walk_review.tscn and scripts/debug/chibi_walk_review.gd.

Each master has 80x80 cells, eight frames across and eight directions down: down, down_left, left, up_left, up, up_right, right, down_right. SpriteFrames uses walk_<direction> names at 8 FPS. Common canvas anchor (40,72), centered sprite offset (0,-32). All 128 frames individually inspected. Every loop has eight unique frames and changing lower-body poses; all stay inside their canvas. No frozen boot band. Five isolated white body artifacts repaired with neighboring colors; face highlights retained. Original GIFs and all exact prompts saved.

Male is Preston's selected original chibi courier, using source_detail cuts of Male.jpg. Female uses Character/Female.jpg, with brown ponytail/pink bow, dusty pink jacket, teal skirt, boots and satchel. Male rotation lost the rear satchel: UP uses the approved original rear cut; two RD Pro correction attempts plus one UP RIGHT retry supply the other rear anchors. The first UP RIGHT correction remains rejected and saved. The accepted right rear retains a strap and a partially occluded bag. Do not claim pixel-identical anatomy across generated views.

Fresh chibi-walk-review displayed all sixteen animations and observed frames 0-7 for every actor. Actual screenshot at process/image frame 3927 shows frame 4 for all. Zero runtime/open-script/total errors and zero warnings in this isolated review. Both disposable review instances were stopped; no unrelated main instance was stopped.
[Chibi record, animation previews, prompts and complete changed files](../art/characters/retro-diffusion-chibi-walking-2026-10-01/README.md).

## Preserved scope and remaining review

Walking assets and the review scene are available; player.gd/player.tscn, collision, movement speed, gender selection and launch settings are unchanged. Do not infer that eight-direction control has been integrated into gameplay. Study32 atlases are secondary size comparisons, not approved replacements for the full-detail masters. Preston reviews the likeness and gait feel before choosing gameplay display size.

Menu scenery research is complete; Courier Lookout remains the direction. Preston runs Gemini Deep Research. The current character-walking request does not reopen creature roster or world production; Vitrecrag stays shelved. Retro Diffusion remains the chosen future creature sprite pipeline. Generate angle views and motion loops as separate steps.

Recorded cost for this request: $3.26 across 23 successful jobs: $0.28 menu walks, $0.20 rotations, $0.54 satchel corrections and $2.24 sixteen chibi walks. One still rejected visually; no animation retry. Account-wide balance change includes concurrent spending and is not attributed here. API key stays outside the project.

No blocker, Git staging, commit, discard or destructive cleanup. All source art, earlier menu/idle candidates and shared work remain preserved.
