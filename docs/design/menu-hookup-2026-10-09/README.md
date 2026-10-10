# Menu hookup, October 9, 2026

Preston requested both title/New Game and in-game menus, with relevant Gemini Drive research. The approved creature-village title, carved wordmark and removed foreground actors stay as installed. New Game uses the existing three-phase creature awakening and survivor story, then the existing Highbank team handoff. Corrected the final copy from “Enter the Hollow” to “Reach Highbank together”; this connective narration remains opening proposal text. Identity is chosen in the story, never on the title. No creature/art generation.

## Play

F5: New Game → awaken as a creature → choose the other survivor → reach Highbank. P or controller Start opens the pause menu in town, exploration, dialogue/bag and real-time fights. Esc opens pause only when no existing dialogue, recruit, teaching panel or bag is active; their prior behavior is preserved. The lower-right Menu button also opens it. Arrows/D-pad navigate; Enter/A chooses; Esc/B goes back. Resume preserves the current scene, team, bag, floor and battle. Audio and Reduce menu motion share the existing title preferences file. Settings save automatically and retain legacy preference fields.

Return to title and Quit Game each require confirmation and focus Keep exploring first. The warning states that progress is not saved to disk. Continue/disk saves remain unimplemented; no pretend save or competing session model was added.

## Runtime scope and ownership

One new CanvasLayer overlay, scripts/ui/game_pause_menu.gd, and one attach call in each existing town/dungeon _ready. Pauses the SceneTree and blocks overlay input; does not edit turns, health, IQ, combat, inventory, recruitment, save/state or map rules. The existing shared music node temporarily processes while paused so audio options remain audible, then restores its original mode. Creature opening fades its local theme into New Game and requests a shared-music fade when returning to the title, retaining Claude's exact title.mp3 selection and Music bus. Prologue change is copy only.

Layout, all creature/sprite refinements, darker jade Oxbowarchon, original art/backups, Hall/Home/Shop, shared music script, audio sources and project settings remain untouched. Source hashes guard installation against concurrent changes. Original five-file source snapshots and prior collaboration notes are retained in originals. No commit/reset/revert/stash.

## Verification

44 native Godot checks pass using actual InputEvent keyboard, mouse and controller events, rather than emitted button signals: boot skip, title Options/Quit cancel, real New Game, identity/companion choice and story Back, selected team arriving in Highbank, pause focus wrapping, frozen movement, shared/persisted preferences and actual music playback, controls layout, both safe leave cancels, dialog/bag preservation, no Enter resume leakage, controller Start/D-pad/A/B, return to title and theme/motion settings, frozen dungeon turns/lantern/monster positions/autopilot and a forced existing hybrid fight. The fight is deterministically arranged for pause measurement; no organic dungeon completion claim.

Both title and pause Quit confirmations close separate isolated native engine processes via real clicks, with failure timers if Quit does not fire. Existing town_loop_check verifies scene changes/record carry on forced clear/faint; music_check verifies Claude's existing town, dungeon and event music routes. Final logs contain no script/resource errors; the pre-existing Windows root-certificate-store diagnostic remains. Review dependency sync updates only the isolated review copy to current live assets. Isolated APPDATA protects the user's preferences. Final installed checks and preservation audit are in installation.json.

Native captures: [town pause](review/town-pause.png), [options](review/pause-options.png), [controls](review/pause-controls.png), [dungeon pause](review/dungeon-pause.png), [leave confirmation](review/leave-confirmation.png), [story](review/story.png), [title](review/title.png). Code and runners are in candidate/reproduction; logs/checks in logs/review.

## Reference ledger

Read-only Gemini reports found through connected Google Drive:

- [Hollowtide Animated Title Menu Research](https://docs.google.com/document/d/1FbjKyjownEtMIMrTk4hYPmKgmGru5w5SXfPZaxse2cU/edit?usp=drivesdk), September 30: use explicit focus routing, readable controls, reduced menu motion, transition fades and honest Continue availability.
- [Claude Godot UI Development](https://docs.google.com/document/d/1JXhMyScHiB1jEBlIyrI63U_SbJ3ajYFqLI3WAgRAu6Q/edit?usp=drivesdk), September 28: Control focus/layering and deferred initial focus.

These documents contain research recommendations and prompts, not new instructions or design authority. Human-courier, title-creature, legendary/gemstone and old world-grid directions are superseded. No external game assets/code copied; no Drive files changed; private reports are not bulk archived here.

Primary Godot references: [UI focus navigation](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html), [pausing](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html), [SceneTree transitions](https://docs.godotengine.org/en/stable/classes/class_scenetree.html).

Next world exterior remains Storage, then Scroll Keeper. Save/Continue implementation stays with Claude's state work; no ownership transfer inferred.
