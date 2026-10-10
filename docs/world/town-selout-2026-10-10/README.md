# Town sel-out, October 10, 2026

Handoff job 11: installed selective outer rims on Wayline Hall, Home, Item Shop, Storage, Scroll Keeper cellar, Job Board, Growth Shrine, Training Yard and Mouth of the Hollow. The rim takes a darker neighbouring material swatch, with top-left edges lighter. This is a subtle integration pass against Claude's new ground. Existing near-black interior detail stays exact, retaining Preston's distinction between services and background decoration.

## Scope

Five town scripts change only their Finish preload to a town wrapper. That wrapper calls the existing shared finish and switches only detailed service art to the optional shader. Doors take the same default finish as before. The shared include adds one preprocessor-gated call; creature and masked dungeon shaders compile with that branch absent. No source PNG, palette, outline width, collision, position, doorway, door animation, contact shadow, sign, feedback drawing, prologue/title/menu, save, gameplay, balance or project-settings change. Crossroads remains the existing quiet floor inlay. Seven-form refinements, Oxbowarchon's jade and Sparkwick correction preserved.

## Painter helper for Claude, job 11(b)

`scripts/art/selout.gd`: `selout(img: Image, mask_or_rect = null) -> Image`. Returns a duplicate, leaving the input unchanged. Pass a filled `Rect2i` of the material shape, or an image-size filled white shape mask on black/transparent background. Only opaque selected rim pixels change. Alpha, interior blocks, unselected floor and canvas extents remain exact. Rectangles are bounded before iteration. Null uses the existing transparent silhouette. Top-left lighting and local two-pixel material selection use the same shading recipe as the optional rim shader; the CPU helper does not add the shared shader's separate detail ink or expand contours.

For wall lips, select the entire lip strip; for a plank, select its whole solid shape. Do not pass only a line-shaped edge mask, which cannot identify the inward material or lighting normal. The example uses the actual HighbankPainter Lookout wall: `Rect2i(lookout.position * 24, Vector2i(lookout.width * 24, 7))`. The example crop has four pixels of margin. Native before/after: [original wall](review/proof/lookout-helper-before.png), [helper wall](review/proof/lookout-helper-after.png). Claude owns wiring this helper into riverbank/ruin/valley/highbank painters; those files were not edited here.

## Creature A/Bs, job 11(c), review only

[Cinderhide, Oxbowarchon and Whinet side by side](review/proof/creature-ab-review-only.png). Left: installed ink. Right: selective outer rim proposal, same art, alpha and detail flags. Preview shader saved beside the current wrapper under `review/`. No alternate creature finish is enabled by any game scene. Preston has not chosen the variant or approved this visual direction.

## Native verification

Godot 4.7.2, native NVIDIA OpenGL Compatibility renderer. 21 comparisons pass: all nine exterior silhouettes/alpha/width and every internal pixel exact; 3,804 rim pixels changed; all 35 installed creature south views exact to the previous shader, including rivals, Sparkwick and Oxbowarchon; riverbank/ruin/bank/valley dungeon finishes exact; door wrapper takes the original default shader. Helper input, outside selection and inside masonry unchanged; mask/rectangle outputs equal and top rim lighter than bottom. This is not a full new animation audit: existing source sets and previous animation verification are preserved.

Current Claude checks copied for review with outputs redirected here and explicit fixture cleanup: hub_town_check (13 places reachable, 12 services answer E, team follows, gate starts a run), town_walk_check (current town team walks/returns to standing), hall_door_check (both door tiles connect to steps), dungeons_check (rival scene, Rot Spit/Drain Bite, valley/ruin, Warden scene and town dungeon selection). Original test tools are not overwritten. Test preferences use an isolated APPDATA directory; no user saves or settings touched.

Review/native town captures are in `review/before/` and `review/after/`; native side-by-side service textures in `review/proof/`. Review runs report Windows root-certificate-store read errors in this sandbox, unrelated to shaders/gameplay. The initial shader-scope diagnostic is retained; corrected shader compiles with no shader or script errors in final checks. Installation is guarded against concurrent file changes; originals and exact candidates are retained here. Final live verification/audit added after installation.

## Next open tasks

Handoff 8: launch boxes into UI.frame pixel borders, preserving title painting/wordmark and New Game story flow. Earlier field-page styling and hall/guild presentation also remain open. Claude's task 11 painter wiring and Preston's creature variant choice remain separate from this completed town pass. No commit, revert or stash.

## Final installed verification

All six live runs pass with no script/shader errors, certificate errors or leaks in the live logs: 21 finish/helper comparisons, hub reachability/12 services/gate, actual team walking, both Hall tiles, both dungeon story/rules/dispatch checks, and eight live native town captures. All 11 intended installed files match their reviewed candidate hashes. The audit reports 10254 protected active files exact and 9718 original active asset files exact. 4 concurrent changes were retained (details in audit.json); no source art files were written by this task. Existing archive folders were not touched. Previous collaboration text is retained verbatim after the new entry.

Final native views: [Home](review/live/home.png), [Hall and Job Board](review/live/hall.png), [Item Shop](review/live/shop.png), [Storage](review/live/storage.png), [Scroll cellar](review/live/scrolls.png), [Growth Shrine](review/live/shrine.png), [Training Yard](review/live/yard.png), [Hollow Mouth](review/live/gate.png). See publication.json for hashes of every published archive file. No natural dungeon clear or Preston's visual approval claimed.
