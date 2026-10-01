# Courier Lookout menu preview | October 1, 2026

MAIN MENU ONLY. Gemini research is complete and run by Preston. No new images, creatures, props, research, commits, staging, or launch-setting changes in this session.

## Implemented
New isolated review scene: res://scenes/main_menu_art_preview.tscn
New script: res://scripts/main_menu_art_preview.gd
New 576x324 texture: res://assets/sprites/menu/courier_lookout_dusk_candidate_576.png
Engine generated the texture .import and script .uid companions.

The script inherits main_menu.gd. It replaces only scenery and actor composition for this preview. Existing title, controls, rain, stars, embers, breathing, music, sounds and transition remain inherited. An empty _windows sprite satisfies base animation; _star_layer is initialized; _drifting stays empty. No old stand-in scenery is drawn. The flat candidate has no parallax, separate fog layer or animated window lights.

The original 1672x941 source and exact prompt remain unchanged in docs/art/menu/courier-lookout-2026-10-01/.
Source SHA256: EE502E8388023C0D2645C9A2EC50F9DB0B574BB393E6635C299B2E17CFB65D07.
Preparation: Godot Image.resize(576,324,Image.INTERPOLATE_NEAREST), saved as a new PNG. This samples a logical grid; it is not proof of hand-authored native pixel finish.

Current chibi courier: first UP cell (0,816,272,272) from courier_chibi_walk_2026_10_01.png, nearest sampled to 96x96 for menu composition only. Source atlas unchanged. Cinderhide uses the approved existing cinderhide_back.png. Feet at screen (300,424) and (432,448), visibly on the path. Actor scale and spacing are preview choices awaiting Preston's review.

Preview temporarily sets Window.CONTENT_SCALE_ASPECT_KEEP and restores the previous aspect on exit, eliminating gray overflow in a tall review window without changing project.godot.

## Actually run and inspected
Summer 0.5.68, C:/Users/pmcga/dev/hollowtide, explicit preview scene.
Actual runtime screenshot: courier-lookout-menu-runtime.jpg, 953x536, captured from the running game. Landscape, both actors, upper-left title and lower-right controls visibly present, no clipped controls, feet grounded.
Keyboard Down selected Reduce Motion (has_focus true at frame 1789). Enter enabled it. _time stayed 30.092 at frames 1800 and 2510; disabling resumed the clock. Action-only synthetic inputs did not move GUI focus; actual key events worked.
Up returned focus to New Game (frame 3552). Enter triggered leaving; frame 3563 showed fade alpha 0.067 and music volume -9.289 dB, then frame 4044 showed FirstRoutePrototype and restored original aspect value 4. Route was loaded only to verify menu transition, not edited or played through.
Music player reported playing=true. Physical controller and audible quality were not independently tested; existing controller focus routing is inherited.
Final fresh run after enum-warning fix: zero errors, 10 warnings from existing main_menu.gd and battle_screen.gd; none from main_menu_art_preview.gd. Transition run additionally exposed an existing Rimefin UID fallback warning. No out-of-scope fixes.
Game stopped; preview scene left open. Run current scene to review, since the launch scene was not changed.

## Next decision
Preston reviews this composition and native finish before making it the main menu or preparing real scenery layers. The candidate is installed only in the isolated preview, not approved final scenery. Source detail is dense and nearest downsampling is not a pixel cleanup pass.
Shared dirty docs/AI_COLLABORATION.md and all pre-existing untracked work preserved. A new separate handoff avoids overwriting another agent's notes.
Optional Summer library-feedback telemetry was rejected by automatic approval review due to external metadata transfer. No retry or workaround; local work completed.
