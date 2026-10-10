# Title menu refinement, October 10, 2026

Preston requested continued main-menu hookup/refinement, clarified "Title screen first" and "visual wise too." This slice refines the playable title and its launch card. The existing village painting and carved wordmark stay intact, with no foreground actors restored and no new generated artwork.

## Play

F5 → forest-colored launch card → village title. Enter/A/click skips the launch reveal without starting New Game. New Game opens the existing creature awakening and companion story, then Highbank. The title choices are New Game, Options, How to play, Quit; Quit is last in both visible and keyboard/controller focus order.

How to play has Journey and Controls tabs, Start New Game and Back. Start New Game uses the same guarded story transition as the main choice. Back/Esc/B returns focus to How to play; the selected guide tab is retained within that title scene. The guide describes the current town/Hollow controls without implying gamepad field movement. Options retain the existing shared/persisted Master/Music and Reduce Motion controls. Quit still asks for confirmation and focuses Back to title first. Disk saving/Continue remain unimplemented, and no new save or session model is added.

## Visual pass

Forest charcoal, warm gold selection borders, inset frame lines, tiny pixel joinery and offset shadows tie panels to the village. The four-choice main panel leaves space below its frame. A short description follows the selected action; input hints switch on real keyboard, mouse or controller events. Options use matching golden slider tracks/focus rings. The Help page has readable warm headings and a distinct Start New Game action. The launch card shares the forest palette and uses the existing awakening line, "The river has gone quiet," as proposal presentation text instead of the old starter-element caption. The wordmark, village scale/filter, fireflies, existing audio and fade durations are retained.

[Title, keyboard](review/title-keyboard.png), [title, controller](review/title-controller.png), [launch card](review/launch-prelude.png), [Options](review/title-options.png), [Journey guide](review/help-journey.png), [Controls guide](review/help-controls.png), [Quit](review/title-quit.png).

## Verification

26 native title assertions use actual keyboard, mouse and controller InputEvents: controller boot skip, safe initial focus, visible/focus order, panel bounds/bottom margin, original village with no title actors, palette/device hints, help topic navigation/focus/retention, safe Back routing, both New Game routes, story return and Reduce Motion carry. 51 prior full launch/menu regression checks still pass through story choices, selected-team Highbank arrival, preferences, pause/leave/bag behavior and optional forced hybrid fight. The original title Quit confirmation closes a separate engine through a real click. Native captures inspected at 1152x648. Final installed logs and preservation results are in installation.json.

All native runtime checks are expected to have no script/resource errors; the existing Windows root-certificate-store diagnostic remains. The isolated review editor's initial import also reported a stale UID/empty-resource-save diagnostic, absent from native runtime checks. No source changes were made to hide or repair that unrelated editor cache. Tests use isolated APPDATA and do not modify the user's preferences. No natural dungeon completion claim.

## Preservation and next work

Runtime scope is scripts/creature_opening.gd and one new code-only panel trim, scripts/ui/title_panel_trim.gd. The inherited menu base and boot flow, prologue, town/layout/Hall art, pause/field menus, music/audio, Claude's current levels/learnsets/combat/state, all creature sprites/finishes/palettes and original backups are protected. Install hashes guard concurrent edits. Original title script, project, handoff and collaboration notes are archived in originals. No commit/reset/revert/stash; zero imagegen/Retro calls.

This pass follows Preston's explicit title-first preference. Field-page portraits/health/evolution bars and item icons, then Growth Shrine, remain in the October 10 handoff. Claude retains dungeon rules and save/state ownership. Read latest notes and inspect current work before proceeding; do not replace the new field pages or re-enable real-time production combat.
