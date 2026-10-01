# Hollowtide: start here in the next conversation
Updated October 1, 2026. Prepared at Preston's request. This is a current-state handoff; historical notes in CLAUDE.md and AI_COLLABORATION.md can conflict with newer decisions.

## Preston's current order
**Work on the MAIN MENU ONLY for now.**
Preston initially requested menu and world art, then narrowed it to "Do menu only" / "for now." Route 1 props, terrain, player walks, new creatures and battle work are outside the active task.
Preston is shelving Vitrecrag because repeated back-view generation consumed too much usage. Stop further Vitrecrag work. Preserve the existing files and resources; no destructive removal has been authorized. Creature generation is paused.

## Gemini Deep Research: the rule that the previous new chat missed
**Codex writes a focused Markdown prompt file for Preston to upload to Gemini's Deep Research function. Preston runs Gemini himself and brings back the Word report.**
Do not open Gemini and run Deep Research, start a substitute web-research project, or treat a research prompt as an instruction to execute the research yourself.
Main-menu research has ALREADY been completed, and Preston chose its Concept C, "The Courier Lookout." Do not create a duplicate research task.
Completed reports are in:
`C:/Users/pmcga/dev/hollowtide/docs/Gemini DeepResearch(Hollowtide)/`.
Research is input, not automatic canon. Apply relevant findings to the actual project. The color report's universal 100x100 grid, old turtle examples and some claims are superseded by current decisions.

## Actual project and coordination
Runtime project: `C:/Users/pmcga/dev/hollowtide/`.
OneDrive `Documents/HollowTide Sprites/` is Preston's working source-art collection. Much of the magenta-background art there was made by him. Preserve it.
Read repository AGENTS.md and CLAUDE.md, then this handoff. In AI_COLLABORATION.md, start with the current pointer and latest entries, rather than rereading the whole historical log.
THE_CONCEPT.md is design authority; world-bible.md contains proposals. Preston's latest direct decisions take precedence.
Shared Git is dirty. Inspect it before editing shared files; do not stage, commit, discard or overwrite another agent's work.
Default role owners: Claude complex Godot architecture and battle systems; Codex precise asset preparation, Forge contracts and targeted integration; Grok balance/research and non-creature concepts; Gemini research; Opal scoped art candidates. Preston has directly assigned this menu task to Codex.
Latest Claude update: the original teal/goggles chibi courier is installed as the player. Four-direction new walk results are in `assets/sprites/player/courier_chibi_walk_2026_10_01.png`; UP passing, true opposite side strides and balanced idle remain incomplete. This is context, not the current job.

## Existing menu: already built, do not rebuild from scratch
- Scene: `scenes/main_menu.tscn`.
- Script: `scripts/main_menu.gd`.
- Stand-in layer art: `assets/sprites/menu/`; generator `tools/build_menu_blockout.py`.
- Existing menu includes New Game, Reduce Motion and Quit, keyboard/controller focus, sounds, menu music and a fade into `scenes/first_route_prototype.tscn`.
- Claude implemented drifting clouds/fog/water light, rain, stars, embers, warm window flicker, title bobbing and whole-sprite breathing.
- Current design is violet/rose dusk, whimsical synth/chiptune atmosphere, muted teal river and amber windows. The old grey-storm brief is superseded.
- A grassy loess bluff overlooks an inland river and a small ferry ward. Approved courier and Cinderhide appear from behind. UI title is upper-left; controls bottom-right.
- Canvas is 1152x648. Existing scenery is 576x324 at 2x nearest filtering. Layer strips have separate heights/offsets; read _build_scenery before replacing them.
- Current title uses AlegreyaSansSC-Bold; small text Silkscreen. Existing menu code and styles are the starting point.
- menuScene is not the project's launch scene. Last connected main_scene pointed at a Vitrecrag preview. Use a specific menu scene for review; don't accidentally launch that battle preview.

## New menu art generated in the interrupted session
One wide Courier Lookout dusk landscape was generated with the built-in image tool and displayed to Preston. It has the river, grass/loess lookout, three-dot route marker and lit ferry houses. No characters, title or UI are baked into it.
**It is a candidate, not visually approved or installed.**
Verified original size: 1672x941, RGB PNG. It is not yet a guaranteed 576x324 native pixel-grid asset.
Saved handoff artwork for continuation:
`C:/Users/pmcga/dev/hollowtide/docs/art/menu/courier-lookout-2026-10-01/courier_lookout_dusk_source.png`.
Exact generation prompt:
`C:/Users/pmcga/dev/hollowtide/docs/art/menu/courier-lookout-2026-10-01/generation_prompt.txt`.
Earlier working copy:
`C:/Users/pmcga/Documents/Codex/2026-09-24/wh/world-art-first-batch-2026-10-01/courier_lookout_dusk_source.png`.
Original built-in output:
`C:/Users/pmcga/.codex/generated_images/01a0d63c-61c8-70b1-9155-9cf5910832ab/exec-c95147c9-ab15-43d0-a17d-569bcf0d219a.png`.
No menu script, scene, project setting, source layer or actor was changed. No menu preview or runtime check was performed in this interrupted session.

A Route 1 cottonwood was generated in Opal before the scope narrowed; a native-size browser capture is in the working folder, with the original at https://opal.google/board/blobs/acf5f228-d870-47f2-93b2-e8d82cc06c17 . It was not downloaded as a byte-identical source, prepared or installed. Defer it.
A relay-post run was stopped at the Style Anchor upload question. Only its text brief was submitted; no relay image generation was started. Do not resume it under the current menu-only instruction.

## Resume with this small visible completion
1. Open and inspect the saved menu landscape and current main_menu.gd. Show a menu composition using the generated scenery, the existing title/controls and the approved courier/Cinderhide. Review native pixel finish, actor ground contact and UI readability.
2. Prepare a 576x324 candidate while preserving the high-resolution original. One flat backdrop does not automatically replace separate parallax strips. Either use an isolated art-preview scene that reuses the existing menu behavior or prepare real layers after composition approval. If subclassing the existing script, account for _windows, _star_layer and _drifting used by its process/motion controls; avoid null references or double scenery.
3. Check the menu in Godot/Summer and capture the actual result. Preserve New Game, music/fade, keyboard focus and Reduce Motion. Save a short factual handoff stating what is generated, installed, visually inspected and actually run. No new creature or world-prop work.

There is no need to generate another landscape before inspecting the saved one. Do not claim existing stand-in layers were replaced, that parallax layers were extracted, or that an unrun preview works.

## Art and engine rules that matter
- Approved Cinderhide is the creature pixel-finish benchmark: readable clusters, material planes, dark contour, grounded mass. Copy its craft, not its anatomy/fire palette onto scenery.
- Environment uses local material ramps and shared lighting/shadow anchors. Turbo Green is a full-health UI accent, not a universal world palette.
- Six essences are Ember, Tide, Stone, Gale, Nature and Hollow. Nature replaced Bloom. Some old Forge/docs still say Bloom; don't revert the user's rename.
- Selected courier identity is teal jacket/shirt, brown hair, brass forehead goggles, tan trousers, boots and satchel. Overworld uses adult chibi proportions, 32x32 cell/about 30px height; 96x96 adult waist-up portraits are a separate tier.
- Source art, candidate finish and gameplay approval are separate. Keep originals. Pixel-editing scripts were explicitly authorized for precise texture passes. Use image generation for new raster art; use deterministic preparation for cutting/conversion.
- Forges are linked in `docs/forges/forge-hub-2026-09-30.md`. The World Forge is https://opal.google/app/1gkKkSpg8Pakg7888e05tKqAhps9wFl19 . It supports PROP/TILESET/WATER/PROP SET, not a verified menu-layer mode. No live Forge prompts were changed in this session.
- Browser automation must use the available computer-use skill/tool. A browser snapshot is not proof a file downloaded.
- Read Summer project context first; its cold headless editor-script writer can save project files but cannot render screenshots. Live scene scripts see the current scene. Don't mix those up.
- At the October 1 project save, Summer Engine is connected to C:/Users/pmcga/dev/hollowtide and the game is stopped. Its active scene is res://scenes/vitrecrag_plate_preview.tscn. Check the connection afresh in the next chat. This handoff and the artwork can be read without the editor.
- Shell reads now work, but direct project writes were still denied after scoped permission was granted. Use the connected Summer Engine guarded project-file tools for project saves. The verified workspace fallback packet remains at C:/Users/pmcga/Documents/Codex/Hollowtide/Handoffs/2026-10-01-menu/. Do not claim an unsaved change succeeded.
- docs/.gdignore prevents backup scripts/art from entering Godot imports. Actual textures belong under assets, scripts under scripts, scenes under scenes.
- Preserve existing battle HUD: continuous HP, Turbo Green full health, yellow/orange medium, red low/critical, fixed creature-name font. Battle camera/signatures are not part of the menu task.
- The broad automatic game-building goal is paused. This handoff authorizes continuation of Preston's menu task, not an automatic goal resume, research run or recurring automation.
