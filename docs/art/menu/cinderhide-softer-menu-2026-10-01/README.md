# Softer Cinderhide menu texture | October 1, 2026

Preston reported that Cinderhide still felt more pixelated than the courier and map. At menu scale, the dense black armor lattice and nearly black tail bands created a sharper, busier surface than the other art.

## Installed result

The review menu now uses assets/sprites/menu/retro_diffusion_idle_2026_10_01/cinderhide_idle_soft_material_atlas.png. The only menu-script change is the Cinderhide texture filename in scripts/main_menu_art_preview.gd.

This finish comes from the existing cleaned eight-frame Retro Diffusion atlas. Exact alpha, silhouette, position and pose are preserved in every frame. The 80x80 native grid, eight cells, 2x nearest display, 3.2-second cycle, phase 0.8 and feet anchor (432,448) remain the same. The courier and landscape are unchanged.

The controlled palette pass replaces pure black with warm charcoal, lowers internal seam contrast, warms gray armor toward the courier/map lighting and quiets the orange accents. A neutral-material-only 3x3 median at 35% strength blends fine interior hatching into six related warm gray/violet shading tones. It affects about 870-900 torso material pixels per frame. It does not filter the two-pixel silhouette border, the head/horns above y=28, orange accents, or the tail from y=56 down. Those areas receive only the palette pass, preserving major anatomy and tail segmentation. There is no whole-image blur or resampling. The lower contact band from y=62 remains identical across the loop. Zero white pixels remain.

Exact parameters, source/output hashes and mask guarantees: connected_shading_manifest.json. Prepared-frame review: connected_shading_frames_review.png. Animated review: connected_shading_idle_review.gif.

## What was tested

A fresh offscreen menu-material-review instance played all eight frames through one 3.2-second loop: 2,3,4,5,6,7,0,1,2. Menu time advanced 0.017 to 3.217 while Cinderhide's position stayed (353,304). The captured actual menu at process frame 2637 shows actor frame 4 at time 0.817. The existing white-cleanup capture also shows frame 4 at time 0.817, so the side-by-side uses the same animation pose at original display scale.

Post-play diagnostics: zero runtime errors, zero open-script errors and zero total recorded errors, with 10 existing warnings. The disposable instance was stopped; the user's separate main instance was left running.

Both screenshots were saved successfully. The cold headless helper that copied them additionally reported an unknown UID (uid://blm6ps3r8bf7l) and an empty resource-save path during boot, while its own script completed without errors. These are recorded separately in runtime_check.json; they did not prevent the menu run or file saves. A readonly UID search identifies default_bus_layout.tres and its project.godot audio-bus reference; neither file was edited in this pass.

## Generation attempts retained

Two RD Pro still tests used the current Cinderhide pose plus the courier and map finish references. Both succeeded as API jobs, but both were rejected as artwork because the generated creature was cropped. Neither was animated or installed.

- Painterly: 5a0694b3-ea32-4358-bcab-2f73bea92ee9, $0.18.
- Default full-body correction: 3c10f87d-644d-4b32-88ae-b97b8f2d094e, $0.18.
- Total cost for this revision's tests: $0.36. No paid idle generation.

Original generated images, exact requests, preparation reports and local references are retained in this folder. generation_results.json distinguishes rejected outputs from the installed texture. All prior menu atlases and the white-pixel cleanup remain preserved. The main menu is the only integrated scope.

## Changed files

- assets/sprites/menu/retro_diffusion_idle_2026_10_01/cinderhide_idle_soft_material_atlas.png: new active menu texture.
- scripts/main_menu_art_preview.gd: replace only Cinderhide's texture filename.
- docs/team/MENU_RETRO_DIFFUSION_HANDOFF_2026-10-01.md: latest texture revision.
- This new folder: README.md, generation_results.json, runtime_check.json, cinderhide_pose_native80.png, courier_finish_reference.png, map_finish_reference.png, existing_finish_comparison.png, softer_still_original.png, softer_default_original.png, softer_still_request.json, softer_default_request.json, softer_still_preparation.json, softer_default_preparation.json, connected_shading_manifest.json, connected_shading_comparison.png, connected_shading_frames_review.png, connected_shading_idle_review.gif, menu_softer_material_review.jpg, menu_texture_before_after.png.

[Before and after at menu scale](menu_texture_before_after.png) | [Actual full menu](menu_softer_material_review.jpg) | [Eight-frame animation](connected_shading_idle_review.gif)
