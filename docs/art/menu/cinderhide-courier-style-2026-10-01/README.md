# Cinderhide menu style revision | October 1, 2026

## Latest revision: Cinderhide matches the menu courier, October 1, 2026
Preston explicitly requested that the menu Cinderhide match the courier's rendering texture, and clarified that this menu animation may differ from the battle sprite. The menu now uses cinderhide_idle_courier_style_atlas.png. The courier retains the darker contrast atlas at 3x from the readability revision; Cinderhide remains 2x.

Retro Diffusion RD Pro Default restyled the existing 80x80 menu Cinderhide pose using the updated courier's 80x80 first frame as a STYLE-only reference. Kept the charcoal/ember identity, rear-right view, horned head, angular plate layout, orange spikes, claws and curled tail. The new rendering uses broader matte armor planes, softer warm shadows and restrained highlights. This is a menu-specific candidate, not a change to battle resources.
Style job d0a7a229-92e1-47d2-83cf-d441010dcb1f: succeeded, $0.18.
Advanced Idle job eeecb0b8-5472-4ca5-b05e-920d1498a111: succeeded, $0.14.
Total cost for this Cinderhide revision: $0.32. No paid retry; concurrent account spending is not attributed to this task.

Preparation: remove only exterior-connected neutral near-white background pixels from the generated standing PNG (RGB channels >=232, spread <=8); retain character colors and geometry. The still has 39 visible colors after background removal. Actual animated output has eight 80x80 transparent frames at 150ms each. Extract into a 640x80 horizontal atlas, preserve first frame's lower band y>=62 in every frame to stabilize claws and tail tip, and retain the menu's existing 3.2-second cycle and 0.8-second offset. All prepared lower bands are pixel-identical. No resizing of atlas frames.

Modified:
- scripts/main_menu_art_preview.gd: the Cinderhide texture filename only for this style revision.
- docs/team/MENU_RETRO_DIFFUSION_HANDOFF_2026-10-01.md: this latest state.
Added:
- assets/sprites/menu/retro_diffusion_idle_2026_10_01/cinderhide_idle_courier_style_atlas.png and engine-generated .png.import
- docs/art/menu/cinderhide-courier-style-2026-10-01/courier_style_reference_native80.png
- docs/art/menu/cinderhide-courier-style-2026-10-01/cinderhide_pose_reference_native80.png
- docs/art/menu/cinderhide-courier-style-2026-10-01/cinderhide_style_original.png
- docs/art/menu/cinderhide-courier-style-2026-10-01/cinderhide_style_input_native80.png
- docs/art/menu/cinderhide-courier-style-2026-10-01/cinderhide_style_request.json
- docs/art/menu/cinderhide-courier-style-2026-10-01/cinderhide_styled_idle_request.json
- docs/art/menu/cinderhide-courier-style-2026-10-01/cinderhide_styled_idle_original.gif
- docs/art/menu/cinderhide-courier-style-2026-10-01/cinderhide_styled_idle_preview.gif
- docs/art/menu/cinderhide-courier-style-2026-10-01/cinderhide_styled_idle_metadata.json
- docs/art/menu/cinderhide-courier-style-2026-10-01/README.md
Prior source sheets, original atlases, raw outputs and exact prompts remain preserved. No battle sprite, creature resource, gameplay, launch setting or shared collaboration-file edit in this revision. Other concurrent creature-roster edits are outside this update.

Runtime review: fresh menu run showed both actors grounded, the updated matte Cinderhide beside the larger courier, and readable title/controls. At process frame 1554, Cinderhide frame=3, position=(353,304), menu time=26.042. Diagnostics: zero errors and ten existing inherited warnings. A first capture request during startup briefly lacked the debugger handshake; retry succeeded. Main play stopped during review, so the final capture used a separate offscreen preview, 1152x648, process frame 2117, menu time=2.0, Cinderhide frame=6. Saved as menu_courier_cinderhide_style_review.jpg.
A later duplicate Reduce Motion check could not run after the debugger attachment disappeared while the editor was in use. Do not claim that duplicate test passed. The motion code did not change; prior successful callback/keyboard checks are recorded below, and the new frame extraction independently verifies planted lower bands. The disposable offscreen instance was stopped after capture. No implementation blocker; preview is available through the current scene for user review.

