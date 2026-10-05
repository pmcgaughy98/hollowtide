# Courier Lookout menu flow | October 3, 2026

Preston prioritized menu buttons and game flow before Route 1 work. Installed in the existing menu script, using the approved art-preview scene.

## Installed behavior
- New Game opens male/female courier selection using the existing eight-direction models, then Begin Journey fades the screen/music and opens Route 1 with that model set before Player._ready.
- Options controls Master/Music volume and Reduce Motion. Preferences save immediately to user://menu_preferences.cfg, separate from progress/party saves.
- Quit opens a confirmation with the safe return choice focused.
- Each page has its own keyboard/controller focus loop. Escape/B returns focus to the initiating main-menu choice; A confirms. Runtime pad A/B bindings supplement the project's keyboard-only accept/cancel overrides.
- Volume controls show a mint focus ring. Reduced motion freezes the scenery and actor clocks while controls remain usable.
- The existing approved backdrop, walk-in/idles, original atlases and generation prompts remain unchanged.
- Continue remains deferred until Claude's progress-save system exists. No fake saved game was introduced.

## Verification
Installed Summer native renderer (D3D12/Forward+, GTX 1660 SUPER), fixed 60 FPS, isolated --summer-offscreen runs with --summer-no-api and --summer-no-publish. The open user editor was left alone because its HTTP control connection was unavailable.
- Before capture at frame 239.
- Female run: all keyboard checks passed, bus values changed, 120 process frames with both actor frames/positions and menu clock frozen, focus/back still worked, exact settings persisted.
- Male fresh run restored those preferences, then returned volume/motion to defaults. Controller A/B and mouse courier selection/Begin worked.
- Both route entries applied the correct texture before Player._ready. Ordinary right movement moved each player from (48,192) to (74.66667,192).
- Quit run reached Quit Game and the owned process exited after Enter.
- Main/selection/options/quit panels fit 1152x648. Actual captures inspected.
- Final runs: no runtime/script errors. Existing Rimefin UID fallback and RGB8-to-RGBA8 renderer warnings remain. An early test exited with an ObjectDB/resource warning; later verbose runs had no resource/object leak diagnostic.
- Initial controller failures were real and fixed. A subsequent rerun used a stale test-created preference fixture; that failed log is retained. Final test explicitly normalizes only the task-created preference file before keyboard checks, then verifies restoration in a separate fresh run.
- No physical gamepad/audio listening claim; controller input events and AudioServer bus levels were tested programmatically.
- No paid generation for this menu pass.

## Exact scope and preservation
Runtime code changed: scripts/main_menu.gd only.
Review scene: scenes/main_menu_art_preview.tscn, unchanged. Run this scene specifically; project launch remains move_preview.tscn. The already-deleted scenes/main_menu.tscn was not restored.
Saved: before/current source, replay probe, final test logs/results/captures, retained failed logs, hash manifest.
No staging, commits, deletes or battle/save/party changes.

The subsequent courier-selection bug fix and female/sprite consistency request are completed in the [October 3 consistency record](../../review/consistency-2026-10-03/README.md). The original source snapshots/tests below remain historical evidence for the initial flow; source/main_menu.after-consistency.gd.txt records the later current script. Rimefin's UID warning was corrected in that follow-up.

The prior Route 1 terrain-relief candidate remains saved but inactive and unreviewed. The crossing helper was restored to its last verified landscape version before menu work. Do not treat the terrain candidate as installed.
