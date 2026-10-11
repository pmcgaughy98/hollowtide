# Launch pixel frames: handoff job 8

Next open task after finished town exteriors and Home/Hall interiors. Uses Claude's existing hand-placed pixel frames from UI.frame and dialogue presentation from UI.dialogue, matching town/dungeon at the world's 3x pixel weight. No image generation, Retro spend, new bitmap, source PNG replacement or shared shader/style change.

Options, Help/Journey/Controls, Quit confirmation, inherited launch controls and partner welcome now use copied nine-slice moss/brass frames. Content inset 24px; buttons/sliders 52px so 24px frame corners do not overlap. Options raised to y180 to fit the taller controls. Focus uses the bright frame; slider focus frame sits behind the slider rather than covering its grabber. Shared cached styleboxes are duplicated before local margin changes. Old custom title joinery hidden where the new frame supplies it.

Title village, wordmark, bare four serif choices, underline/pointer, legibility wash, ambient motion, boot, theme/audio, focus/route/preferences behavior remain. Transparent title text hit areas keep their light underline instead of gaining card boxes. Main scene retains Claude's current dungeon development setting. Launch is scenes/creature_opening.tscn (F6); existing field menu Return to title also opens it. No boot/soul scene change.

Waking is now a framed dialogue box at (102,324), 948x128, with portrait above its left corner, brass speaker tab and next arrow. The existing title label sits beside the portrait; original prose label stays as a hidden text model, drawn by a small presentation helper. Words wrap against the actual shared font width. Existing story text is unchanged, including the current survivor draft; handoff job12 will revise it separately. Portraits use the installed source with the existing creature finish on an independent draw layer; frame/background/marks remain untouched. Arrow respects Reduce Motion. Choices/actions have their own 948x160 frame at (102,468) and keep the exact choice/state callbacks and focus order.

FirstPartnerArrival's existing nonblocking welcome has a wider pixel frame inset 24px; same creature/idle frame source, timing, fade and lifecycle. This is retained legacy-route presentation, not a claim that the creature-era story uses the welcome card.

## Scope and checks

Four existing presentation scripts and one small new opening_dialogue helper, plus collaboration note. All non-presentation methods compared verbatim against snapshots. Original phase/choices/title/prose are still accessible to Claude's tests. No story rewrite, rules/stats/evolution, saved state, field-menu/party/shrine systems, terrain/layout, Home/Hall/Board art, source creatures/palettes/backups, project settings, Git commit/reset/revert/stash changes.

34 native Godot input/layout/render checks pass: boot skip/title layout, original village, Options/frame/slider keyboard/focus return, both Help topics, safe Quit focus, both real New Game routes to Claude's soul, all identity/partner/waking phases, finished portraits, actual selected team into Highbank and the legacy welcome card. Current field_menu_check passes town and dungeon Team/Bag/Floor/Log plus item use spending a turn. Current soul_prologue_check reaches Tallowroot waking with starter choice already done and zero starter buttons. Copies of Claude's checks only isolate screenshot output, add cleanup and propagate failure status. Source debug checks unchanged.

Engine screenshots in review/after/ and automatic soul handoff in review/soul/. Review sandbox logs have the Windows certificate warning; no art/runtime errors. Early fixture timing assertions were corrected to allow existing boot/fade timing; they did not require a gameplay fix. Installed native proof and final active-file audit follow below.

## Handoff

User requested the next unfinished handoff task; job8 is implemented and ready for visual review. Job2 field-menu recheck refreshed as required. Latest Claude party screen/icon/shrine systems are preserved. Next slice: job12 pilot waking text/staging, read docs/design/pilot-story-2026-10-10.md first. Do not write the Guildmaster's scene or revise chosen partner behavior by inference. Future new interiors should follow the finished Home/Hall style once their event layouts exist. No additional art approval or natural dungeon-clear claim.

Claude added BoardScene/crew staging to hub_town.gd late in the final audit. That concurrent source was left intact and snapshotted; all 34 installed launch checks were rerun against it, including actual selected-team arrival in the updated town, and pass cleanly.

## Final live verification

Installed native Godot runs pass with clean final logs: 34/34 launch frame/input/layout checks; current Claude field-menu check including Bag item spending a turn; current soul check with Tallowroot chosen, awakening and zero duplicate starter buttons. No runtime, shader or cleanup errors. All six installed files match reviewed candidate hashes. 10275 protected active files and all 9725 original active asset files match the baseline. 5 concurrent active changes retained and snapshotted; prior collaboration body verbatim. Player saves/settings isolated from the tests.

Installed previews: [title](review/live/title.png), [Options](review/live/options.png), [Help](review/live/help-controls.png), [waking dialogue](review/live/wake-1.png), [welcome](review/live/partner-welcome.png). Current chosen-soul waking in [soul check](review/soul/wake.png). Source, originals, test fixtures and exact publication hashes saved. Job12 story revision remains open; visual approval pending.
