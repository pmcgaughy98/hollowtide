# Wayline Hall and launch regression, October 10, 2026

Preston clarified that the lane already aligned and the defect was the pasted doorway drawing. The localized entrance insert was rejected and is archived only. Runtime now uses one coherent full Hall sprite, with a centered wide arch, gable, intact side windows and continuous foundation. No entrance fragment is layered over the old facade. Architecture remains a visual proposal for review.

The new Hall is a separate 240x144 PNG inside Claude's unchanged world footprint (456,24). The original October 9 PNG is untouched and retained as the missing-art fallback. Both existing doorway tiles (23,6) and (24,6) enter the Hall service, and both exit onto their authored steps. The ground painter reads Layout.door_tiles for door marks. The obsolete extra paving strip is removed so the approach follows Claude's current two-tile PATHS. Layout, collision and movement/service logic are unchanged.

## Play and preview

F5 now starts scenes/creature_opening.tscn. New Game uses the existing creature awakening/survivor story and selected-team arrival in Highbank. Go north to Wayline Hall and press E from either doorway tile. P/controller Start opens the shared pause menu. Claude's Team, Bag, Floor and Message Log pages are retained; the dungeon's nine main buttons now fit within the 1152x648 screen. Controls describe the current turn-based dungeon. The separate Training Yard and optional hybrid fixture are unchanged.

[Native Hall](review/hall_front.png), [town overview](review/town_native.png), [Hall interaction, left](review/hall_service_23.png), [Hall interaction, right](review/hall_service_24.png), [dungeon pause](review/dungeon-pause.png).

## Verification and limits

14 native entrance checks pass: whole Hall replacement, opaque/dark doorway centers, deterministic paint, actual movement and native E from both door tiles, exact retained layout contract, and exact pixel equality outside the Hall and bounded approach/seam. 51 native launch/menu checks use keyboard/mouse/controller InputEvents and verify the configured F5 scene, story choices, selected-team arrival, focus, preferences, pause freezing, leave confirmations and retained field pages. Both real Quit confirmations close isolated engine processes. Claude's existing field-menu check verifies carried Team/Bag, Floor/Log and bag item use; existing hall_door_check and hub_town_check verify both entrances and town services. Those existing fixtures use direct menu actions, unlike the input regression. No natural dungeon completion or disk save claim.

Turn-based combat stays the production default. A forced optional real-time fight is used only for pause regression. Review/live runs use isolated APPDATA to protect the player's preferences. The pre-existing Windows root-certificate diagnostic remains. Claude's field-menu fixture also leaves music resources at shutdown; this is recorded, not a runtime change. Final verification and preservation results are in installation.json.

## Asset provenance and preservation

Three built-in imagegen edits, zero Retro calls. Source output PNGs are archived unchanged in sources. Selected source: coherent_centred_original.png. Final prompt: [prompts/selected.txt](prompts/selected.txt); earlier prompts are retained. Native preparation trims transparent padding and fits the whole sprite with nearest-neighbor sampling. No section copying or pixel recoloring. Preparation details: asset-preparation.json. Rejected localized insert and off-center whole redraw remain review history and are not installed as runtime assets.

Runtime scope: one new PNG, wayline_hall_painter.gd, highbank_ground_painter.gd, two presentation changes in Claude's latest game_pause_menu.gd, and the project main_scene setting. Original source snapshots are in originals. All existing creature refinements, darker jade Oxbowarchon, approved Punchybun, wing repairs, sprite/animation originals, audio, state/combat/levels/evolution, controller, other exteriors and earlier backups are preserved. Guarded source hashes prevent overwriting concurrent edits. No commit/reset/revert/stash.

## Next handoff

Continue from docs/team/CODEX_HANDOFF_2026-10-10.md: style the existing field pages with approved portraits/front idles and readable health/progression/item presentation, then Growth Shrine using the existing service/rule constants. Do not rebuild the menu pages, re-enable real-time production combat, change the team/save model or regenerate creature assets. Read current collaboration notes and inspect Claude's work before editing. Storage and Scroll Keeper remain later exterior proposals.
