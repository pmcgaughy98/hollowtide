# C6: Continue details and default-off New Game prompt

October 26, 2026. **Continue details installed. Prompt implemented/tested, OFF pending Preston's wording choice.**

Continue now shows its real saved destination and leader level: Highbank, or suspended Rootbank Warren / Hollow Mouth / The Hollow with floor. Read-only validated save/backup access preserves running TeamState data and both files. Campaign menu row height is accounted for; checked menus end by y596, including the recovery note.

Main New Game and Help's Start New Game share one framed No/Yes panel when a save exists and the private preview flag is enabled. No gets focus; No, Escape and controller B return to the original page/button without writing the save. Controller A on Yes launches once through the existing storm transition. No-save launch bypasses the question. `@export var new_game_confirm_enabled := false` remains the installed default; no scene overrides it.

Proposed title: **Start a new journey?** Body: **Saving the new journey will replace your current save.** Replaced the earlier proposal's Highbank timing because `dungeon.suspend()` can autosave in the Mouth before town. Save timing/rules are unchanged; the actual Yes-to-storm smoke preserves saved bytes.

Checks: final native Compatibility **47/47**, full native UI-fit **48/48**, clean native logs. Official opening_flow, save_check and ui_fit **3 PASS**, exit0; known ObjectDB/resource exit warnings retained. UI-fit/official runs precede only the final proposal-body/comment correction; final native47 compiles/renders/checks that correction. All fixtures use private profiles and saves. [Evidence, preview, originals, commands and source diff](../ui/title-new-game-2026-10-26/README.md).

Production scope: main_menu.gd and creature_opening.gd only. Existing C1 settings load/safe save, Continue dispatch, journey entry and scenery methods are exact; TeamState source unchanged. Dirty Claude sources preserved; fresh hashes and concurrent paths in evidence. No art/generation/paid call/rules/Route1/message/commit. Retired opening layout was not redesigned.

Source issue still open for Claude's active UI lane: shared preference backup-rename gap from C1. The tested8/8 candidate remains staged in settings-save-2026-10-26/proposal, not installed. No cross-chat message was sent.

Next ordered slice is section 9 item5: Storm UI.INPUT_ADVANCE, guarded skip/advance hint and pixel soul light; then white-out transitions. Keep C6's prompt flag off until Preston chooses words. Remaining C7/C8/C9/opening/export/art work stays pending.
