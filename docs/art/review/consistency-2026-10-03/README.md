# Menu and sprite consistency | October 3, 2026

Preston requested female courier texture refinement, retained Vitrecrag volcanic shell cracks during its ultimate, a wider consistency check, and repaired courier selection. He then chose his supplied Clinkerhide rear JFIF and requested Ironvent's head use the charcoal-grey armor of the Cinderhide/Clinkerhide line. These current requests supersede the historical menu-only/Vitrecrag-shelved handoffs for this targeted work. The broader Hollowtide world goal remains active.

## Installed result

- Courier selection now follows card focus, so arrows and D-pad immediately update the exclusive selected caption/toggle. Mouse selection and Begin Journey agree with the model that enters Route 1.
- Female courier finish adds clearer jacket folds and teal accents, warms hair/leather/skin and removes the darkest red fringe. The same material is used in the menu portrait, playable model, all-direction walking review and existing city courier clerk. All source atlas cells, alpha, gait, directions and male art remain unchanged.
- Vitrecrag's registered RD front attack family keeps the approved shell seam colors through Molten Glass, Molten Cannon and Plate Lunge. Its ultimate title portrait uses the same treatment. Contours, chamber window, eruption and attack timing remain authored. Rear art stays authored. The finish is released after attacks.
- Ironvent's head uses a charcoal-grey armor ramp in front, rear, attack poses and the two close-up presentation paths. Raised Furnace Roar poses have measured head bounds; horns/body rust and molten highlights stay distinct. Heat/flash lighting still intentionally warms the armor during attacks. This is an in-game material finish; original source PNGs remain intact.
- Ironvent's rear uses a 100x96 AtlasTexture region with a four-row margin, keeping its logical 100x100 canvas and all body pixels while excluding the stray opaque horizontal row at y=96.
- Clinkerhide now uses Preston's selected rear pose, converted from the supplied 1024px magenta JPEG to its recovered native 100px grid. Real alpha removes the background. The final rear uses a front-derived 22-color palette with no dithering, clearing JPEG color noise. The old 160px RD rear candidate and initial transparent conversion are retained.
- Rimefin's stale texture UID now matches its existing import. Art path and creature rules are unchanged.

## Exact runtime files

| File | Change |
| --- | --- |
| scripts/main_menu.gd | Female portrait material; focus-driven exclusive courier selection |
| scripts/player.gd | Female material on the existing playable atlas |
| scripts/debug/chibi_walk_review.gd | Female material in all eight review directions |
| scripts/effects/courier_finish.gdshader | New courier material finish |
| scripts/effects/creature_sprite.gdshader | Opt-in retained shell cracks and registered charcoal-grey head finish |
| scripts/battle_screen.gd | Apply/release seams; finish head armor, raised poses and portraits |
| scripts/route1_crossing.gd | Same female finish on existing CityCourierClerk only |
| data/creatures/001_rimefin.tres | Correct existing front texture UID |
| data/creatures/101_clinkerhide.tres | Selected rear texture reference only |
| data/creatures/102_ironvent.tres | Clean rear atlas region/margin only |

New preserved art under assets/sprites/creatures/clinkerhide_selected_rear_2026_10_03/: clinkerhide_back_native100.png is the initial transparent conversion; clinkerhide_back_matched_native100.png is the final referenced front-palette conversion. Both have normal .png.import companions. The courier shader has its normal .uid companion. [Runtime hashes](runtime-file-manifest.json) list all 15 entries. Exact task diff and before/current source copies are under source/.

Updated handoff/record files: docs/AI_COLLABORATION.md; docs/team/MENU_RETRO_DIFFUSION_HANDOFF_2026-10-01.md; docs/art/menu/menu-flow-2026-10-03/README.md, source/main_menu.after-consistency.gd.txt and its refreshed file_manifest.json (initial manifest retained); this consistency record and its source/review/verification/tools/manifest files; docs/art/world/route1-terrain-relief-2026-10-03/README.md and the retained source/route1_terrain_relief.gd.candidate.txt. Archived scripts end in .txt so they are records, not duplicate runtime scripts.

Project launch remains scenes/move_preview.tscn. Run scenes/main_menu_art_preview.tscn for the actual menu. scenes/main_menu.tscn was already deleted and was not restored. No move names, power, uses, body gates, learnsets, evolution, party/save rules, quest logic, path/collision geometry, commits, staging or deletions changed. Menu button/game-flow work was completed separately: [menu flow record](../../menu/menu-flow-2026-10-03/README.md).

## Verified in the installed native game renderer

Isolated Summer CLI runs used D3D12/Forward+ at fixed 60 FPS, offscreen, Dummy audio, with API/publishing disabled. The user's editor remained open and untouched.

- 34 final selection checks passed: keyboard arrows, D-pad events, mouse, exclusive captions/toggles, female model before Player._ready, female material on player/clerk, and ordinary route movement from (48,192) to (62.66665,192). This is programmatic controller-event coverage, not a physical-controller claim.
- All 16 walking animations observed every one of their eight frames. The 128 native 80px walking cells have no edge clipping. Female's full 64-cell native render has exact alpha; original male/female PNGs are preserved. [Actual walking capture GIF](review/courier-eight-direction-walking.gif).
- Current references: 11 creatures, 42 move resources and 75 referenced PNG textures. None missing. All 11 front/rear forms rendered in battle. Reference coverage does not mean all 42 moves were played.
- Vitrecrag: real _attack replays for foe Molten Glass, player reverse-shot Molten Glass, Molten Cannon and Plate Lunge. Charge, strain, release, recovery and ultimate portrait were inspected. All 12 native attack-frame render alphas are exact. Texture/home/reversed-shot state restored; seam retention released.
- Ironvent: real Furnace Roar replays from both sides observed all eight distinct attack textures and the titlecard. Both returned to their correct idle texture/home and head-finish owner. Nine heat-free native pose/portrait renders have exact alpha, unchanged molten pixels and no color changes outside the measured head bounds.
- Final selected Clinkerhide rear: real Brow Shear and Slagburst replays, restored selected rear/home afterward, plus current-roster captures. Final alpha equals the recovered selected silhouette, with no opaque magenta and no border clipping.
- Preservation audit checks 77 pre-existing PNG/atlas files against the initial hashes: all unchanged. Original user JFIF is copied as review/Clinkerhide-Back.original.jfif. New sources/candidates/receipts are retained.
- Final selection, clerk, walking, registered head, Ironvent, selected-palette Clinkerhide and Vitrecrag runtime stderr logs are empty. Owned check processes exited. Only the original user editor remained.

Native replay results are JSON in review/. Exact probe sources and retained logs are in tools/ and verification/. Roster contact sheet uses the cleaned rear region; the raw source scan still flags Ironvent's excluded row, three intended full-screen stages and four intentionally cropped/tiled effect sheets.

## Retro Diffusion conversion and costs

- Ironvent masked raster trial: inf_KaBmJAb6EDrz8QVpm68GRvoV7M4P3jdL, $0.18. Rejected because pose/silhouette/background changed beyond the mask. Kept in review/ironvent-front-head-rd.png; never installed. Its dark-head idea remains a reference for the native material.
- Selected Clinkerhide native-grid recovery: free standard fixer; recovered 100x100.
- Background removal: inf_M0jyORNa2PWvmwZMA1KQdAe9bzn3rEYZ, $0.01. Two remaining magenta background pixels at (87,58)/(88,59) removed during native alpha preparation, without changing RGB.
- Palette converter: inf_rR5mnVLBP7D2lqR0ZbDwv9J0pZAjKo3y, free. Uses existing Clinkerhide front as palette input, no dithering. Output has 22 colors with minor 0-4 channel rounding relative to front colors; final alpha is exact.
- Total confirmed paid cost for this consistency pass: $0.19. No paid retries. Female/Vitrecrag/Ironvent installed finishes use native materials.

## Limits and next work

No implementation blocker for these fixes. Summer's HTTP control connection was unavailable, so native CLI rendering/replays supplied the proof. Headless editor import invocations emitted engine shutdown CanvasItem/ObjectDB warnings; one initial import also emitted the previously documented audio-bus UID/empty-save-path pair. These are retained separately from clean final game-runtime logs.

Earlier fixtures sampled excluded rear row 96 outside its cropped image, and one ended before lingering effects finished; their failed/exit-diagnostic logs are retained. The final probes account for atlas margin and let effects settle. These early diagnostics are not represented as passing checks.

Coalcrest's equipped Plate Rake still fails the authored body gate as before; Molten Beam stays selectable. No creature/move design decisions changed. This is current-art/reference and affected-runtime coverage, not certification of every menu/gameplay system.

Future art integration should inspect every pose's silhouette, source margins, alpha/fringe, native pixel size, material ramps, both battle views, raised attack poses and close-up art before expanding production. The Ironvent/Vitrecrag finishes are limited to the currently registered art; new differently registered pose families need their own visual check.

The saved terrain-relief candidate remains inactive and unreviewed: [candidate status](../../world/route1-terrain-relief-2026-10-03/README.md). Next world work follows the existing [world checkpoint](../../world/route1-landscape-2026-10-03/WORLD_DESIGN_NEXT.md): readable levee slopes/path contours, purposeful exploration, actual hometown/city map connections and district architecture. Route 1 and the broader world are not complete. User runs Gemini Deep Research; prepare prompts only when requested. The accidental Summer setup command was cancelled and never executed.
