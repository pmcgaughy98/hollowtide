# Codex handoff: title and soul type roles, October 26, 2026

C3 COMPLETE/INSTALLED in main_menu.gd, creature_opening.gd and soul_prologue.gd. Shared UI.TYPE fonts, UI.style_button and UI.frame normal/focus buttons replace creature title's Vollkorn/Alegreya/custom row overrides; direct font-file hints removed. Current shared roles determine fonts (Jersey prose/headings, Silkscreen buttons/labels). Corrected the stale NewGame button comment. Carved logo exact RGBA, builder exact.

Soul lines use UI.dialogue/story with two-row pages, page-aware advance and one shared typing blip. Names/body/hints use their roles. Every original story word, input handler, choice/flight method, card geometry/scale and prior preference-save method remains exact. No new rules, words, assets or settings. This includes C7's dialogue/font portion only; C7 input/actions and `_ensure_menu_inputs` removal remain pending.

Native45/45 title/story: main, Options, both Help topics and Quit, with/without Continue, exact logo pixels, page-turn gating, starter names/description bounds, real selected-creature handoff. Native current ui_fit48/48. Both runtime logs clean. Official runner3 PASS: opening_flow21 checks, soul_prologue and ui_fit; known exit warnings retained in raw headless logs, no whole-suite claim. Options bottom586, Help602, main590/596, Quit right1108. All native captures inspected, private profiles/test saves only.

[Preview, evidence, exact diff, originals and concurrency receipt](../ui/title-type-2026-10-26/README.md). Owned files hash-guarded; ongoing Claude dungeon/story edits preserved and archived, current docs retained. No generation/paid call, real user save, Route1, game-rule or commit change.

Source issues for Claude: soul now has no runtime UI.HEAD users; only party_screen's historical comment remains elsewhere. Shared HEAD constant stays untouched in the active UI lane; remove when ready. Old Continue menu actually ended616; the new shared button metrics yield596 and were measured directly. Prior task4 pause-helper backup-rename gap stays OPEN; its8/8 tested staged diff remains under settings-save-2026-10-26/proposal, not installed. No messages sent to another chat.

Next: C4 full title Options parity (Sound effects, Screen, Text speed, rebind, shared filled sliders) and current-device ControlsText help. C7 remaining input work, C8 larger cards, C9 light shafts, opening transitions/export/art queue all remain pending. Proposed wording flags unchanged. Re-read current pass7 ownership and new notes before editing shared files.
