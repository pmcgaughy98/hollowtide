# Title composition pass, October 10, 2026

Preston asked to continue visual refinement so the title feels like an authored game menu. This pass replaces the large framed main panel and explanatory copy with a restrained text menu, typography and intentional scenery contrast. All graphics added here are original code; no imagegen/Retro calls or new generated bitmap assets.

## The visual change

Four serif entries use the project's existing Vollkorn typeface, paired with the carved wordmark. A small stationary pixel pointer, warm selected text and thin underline indicate focus. The main frame, header and description card are hidden; the village carries the composition. A subtle lower-left forest wash keeps text readable over the river/path without changing the source image. A small Silkscreen control footer stays on the main page only. Settings and Help keep restrained modal frames, matching serif headings/actions, lighter body copy and warm slider focus. Help is moved up to accommodate the taller type. The launch card retains its forest palette and story line.

[Native title](review/title-keyboard.png), [controller title](review/title-controller.png), [wide-window rendered composition](review/title-wide.png), [Options](review/title-options.png), [Journey](review/help-journey.png), [Controls](review/help-controls.png), [Quit](review/title-quit.png).

## Play and compatibility

F5 still opens the launch card/title. New Game and Help's Start New Game open the existing awakening/survivor story and selected-team arrival in Highbank. Options retain shared audio/motion preferences. Quit retains its safe confirmation. Visible/focus order remains New Game, Options, How to play, Quit, preserving original button identities. Keyboard/mouse/controller hints and Guide topic/Back focus behavior are retained. Window aspect keeps the authored 16:9 view, with the complete composition rather than an expanded scene on wider windows. Field controls, save/state, combat and menu rules are unchanged. Continue/disk saves remain unimplemented.

## Verification

29 native title assertions pass using actual keyboard/mouse/controller InputEvents, including boot skip, both New Game routes, Help topics/focus/Back, settings/Reduce Motion carry, main/modal bounds, compact footer visibility and the rendered 16:9 aspect after a wide-window resize. Native previews inspected. 51 full launch/menu regression assertions still pass through story choices, selected team arrival, preferences, town/dungeon pause behavior, field pages and a forced optional hybrid fight. The actual title Quit confirmation closes a separate native engine. Final installed logs and preservation audit are in installation.json. Isolated APPDATA protects player preferences; the existing Windows root-certificate diagnostic remains. No natural dungeon completion claim.

The fixed-frame Quit fixture closed with exit 0 but reported eight ObjectDB instances and three resources still in use during shutdown. The verbose repeat was clean; the standard repeat reported them again. Replaced the fixture's fixed 65-frame delay with a wait for actual launch completion and settled frames. The final real-click Quit run closes cleanly. No production cleanup code was changed and no runtime memory-lifecycle fix is claimed. Verbose repeat output is preserved in logs/quit_verbose.log.

## Scope and preservation

Runtime changes: scripts/creature_opening.gd and one code-only shader, scripts/ui/title_legibility.gdshader. Original complete title script is in originals. The shade is a runtime composition layer; the village PNG, wordmark script, foreground-actor removal, source sprite pixels and all fonts/audio are unchanged. The inherited menu/boot/prologue, Claude's latest state/levels/learnsets/combat and field pages, maps/Hall art, creature refinements/palettes/animations and previous backups are protected. New source hash guards prevent concurrent-file overwrite; the latest collaboration notes are retained below the new entry. No commit/reset/revert/stash.

Claude appended the Troughspine/Archroot/Springvault/Seep handoff after installation. That append is preserved, and the entire installed collaboration prefix is verified byte-exact; no notes were rewritten to enforce a stale hash.

Claude also changed dungeon.gd and hub_town.gd during verification (shared HUD/signboard styling and the healer plan), adding scripts/ui/ui_style.gd. Those changes are inspected and retained, with hashes recorded separately from the byte-exact protected files. The live launch/menu regression is repeated against this latest code. No isolated-review controller or dungeon file is copied over them.

This remains a visual proposal for Preston's review. Next title art work should respond to that review, preserving functional routes. Field-page visual work and Growth Shrine remain later handoff items; Claude retains rules and saves. Read current collaboration notes and inspect live work before editing.
