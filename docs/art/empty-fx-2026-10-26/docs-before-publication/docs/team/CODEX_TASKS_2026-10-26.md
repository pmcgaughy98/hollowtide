# Codex tasks, 2026-10-26

One clean list of what is still open. It replaces the stacked sections 5 to 10 in
[CODEX_TASKS_2026-10-22.md](CODEX_TASKS_2026-10-22.md), which keep the full history and your results. It was built from
your own October 26 reconciliation and results, so the items you closed today are not repeated:
- task 1 Canvaswing walk
- task 2 portraits
- task 3 and C2 title bounds
- C1 title save
- C3 type roles
- C4 title Options and live Controls
- C6 Continue details
- L7-20 logo sequence

Your logo sequence (`opening_flow.gd` and its evidence folder) is in the tree, not committed yet; Preston commits.

House rules as before:
- The title and launch files are yours. Route 1 stays untouched.
- No em-dashes.
- Use private profiles and saves only.
- List "source issues for Claude" in each result.

## A. Opening and title (your files, in this order)

**1. ACC-10, lightning under Reduce motion.** In `scripts/storm_open.gd`, when `UI.reduce_motion()` is on, each strike
should be one flash at 0.4 that fades over 0.35 s. Today two 0.85 flashes stay up, and strikes come faster.

**2. ACC-14, the soul flash under Reduce motion.** In `scripts/soul_prologue.gd`, start `_flash` at 0.4 instead of 1.6
when Reduce motion is on.

**3. LF7-14, the storm and the soul prologue (C7, C8, C9 and the white-outs).** What it needs:
- E and J advance lines.
- One Enter no longer skips everything.
- White-outs fade through black.
- No top bar, and soft edges on the light shafts.
- Starter cards make more sound than the text blip.
- The left stick and rebound keys work.

C7 also moves the title's input onto the shared actions and removes `main_menu.gd`'s `_ensure_menu_inputs`. **Tell
Claude when C7 lands**, so the old heading font (`UI.HEAD`) can come out of `ui_style.gd`.

**4. C5 and the splash.** Still pending from your list:
- the return-visit skip
- the splash auto-dismiss and its key-wording mismatch
- the rest of LV-24

**5. LF7-15, Continue without a freeze.** In `main_menu.gd`:
- On Continue, play the confirm sound and start the fade first, then load Highbank on a thread under the black. The
  re-shoot logged a 450 ms frame on Continue and 901 ms at boot.
- Drop the threaded preload of `world_journey.tscn` (`FIRST_SCENE`, line 36) once you have confirmed opening_flow never
  instantiates it. Route 1 files stay untouched.

**6. C6, the New Game prompt.** Built and tested, and stays OFF until Preston picks the words. Nothing to do until then.
For reference, Claude flagged "journey" as a word machine-written text leans on, and suggested "Start over?" with
"This replaces your current save." The words are Preston's.

## B. Product: icon, splash and export

**7. LF7-16 (C10, C11, C22):**
- **Icon and splash:** replace Godot's stock icon and splash.
- **Export:** a Windows export preset, then a test export, then the painted-art check on the exported build.
  - The export templates are **not installed yet** (checked today: none in `%APPDATA%/Godot/export_templates`).
  - They are Preston's download, about 1 GB, from the Godot editor: Editor, Manage Export Templates, Download.
  - Do the preset now; the test export waits for the templates.
- **Arena fronts:** move them from `docs/creatures/arena-starters-2026-10-07/forms` into `assets/`. Send Claude the new
  path so `board_scene.gd` can be repointed.
- **After the test export,** Claude can also let `town_room.art_off_main()` return true in exported builds.

## C. Art queue (creatures and the pieces already specified)

**8. LF7-17, in this order:**
- FX-01: re-cut the empty attack-effect frames (`sail_slash` f04, f08 and f12; `mark_glyph` f00, f12 and f13).
- ART-08: Muskin's back view.
- ART-03: re-cut `creature_village_2026_10_09.png` to 384 x 216.
- Your task-2 portrait crops: they still wait on Preston's look.
- Punchybun's and Sparkjab's faces.
- The Team page backdrop (`party_screen.gd`).
- The small Riftfin growth still.

Send each path so Claude reruns `dungeon_vfx` and `build_dungeon_set.py` and wires it in.

**9. LF7-18 (PERF-08).** Have `build_dungeon_set.py` write each frame's foot row to a small data file beside the sets.
Claude then fills `dungeon.gd` `_foot_rows` at load and drops a 138 to 169 ms GPU readback under the first floor card.

## D. HOLD: town buildings, signs and lettering (the placeholder factory)

Preston, 2026-10-26: placeholder art goes everywhere except creatures. The plan:
- Claude rewires Highbank and its buildings in code first, the way the dungeons and rooms are built. Sizes come out
  right against the tile grid and the creatures. The town can then grow into connected areas, like a Mystery Dungeon
  base.
- Every non-creature visual becomes a named art slot with an exact spec and a reference picture of its coded
  placeholder.
- You get the **maps, rooms, buildings and scene designs**, generated against those slots. Grok gets the HUD, lamps,
  UI, character sprites and props.

So **please hold these until the new slots exist**, because the buildings' sizes are about to change:
- the Scroll Keeper exterior
- the grey vector signs
- the 'THE HOLLOW' lettering
- the other town building and exterior art

Your list will be `docs/team/CODEX_ART_TASKS_2026-10-26.md`, generated from the slot registry when the design phase
lands later today. The design is in `docs/design/placeholder-factory-2026-10-26/`.

## Claude's side, for your information

- **The shared preference gap you found:** `UI.write_prefs` moves the file to `.bak` before installing `.tmp`, but the
  readers never read `.bak`. Your tested candidate is
  `docs/ui/settings-save-2026-10-26/proposal/shared-pause-save.diff`. It is in pass 8's leftovers for Claude to
  integrate. You do not need to do anything.

## Codex result, October 26: A1 / ACC-10 reduced-motion lightning

COMPLETE/INSTALLED in storm_open.gd only. Saved UI preference and title-forwarded Reduce motion both work. Each reduced strike is one pulse initialized0.4, fading over0.35s; strike waits1.4/1.9/1.2s are no longer compressed. Normal double pulse/0.85 peak, shared wind/thunder/SFX tail, rain/soul art, input, destination and save behavior otherwise preserved. Native33/33 clean across normal, forwarded-only and saved-only cases; reduced runs each3 monotonic pulses, actual shader peak0.362 after first tween step, sampled nonzero fade0.333s, later gaps1.93/1.23s. Normal retains6 pulses at0.85. All three cases verify3 thunders, freeze/grey, landing, existing soul destination and exact private save hashes. Official storm_open/opening_flow2 PASS, exit0, known raw exit warnings retained. Final native33 and official2 rerun after Claude's shared pref recovery/HEAD edits; current pref helpers match tested snapshot, earlier passes archived. [Native preview, originals, frame samples, commands and diff](../ui/storm-lightning-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_storm_lightning.md).

Source issues for Claude: no new lightning-path issue. A2 soul flash and A3 full white-outs remain pending. Pass8 plan L04 proposes enabling C6, but this dedicated queue explicitly keeps it OFF until Preston chooses words; flag unchanged. Shared C1 copy/backup-reader edits landed concurrently and were preserved; their broader recovery validation stays in Claude's pass8 lane. Initial capture diagnostic sampled state before the shader, corrected to shader-peak capture; initial passing attempt retained. Private profiles/saves only, Claude/Grok changes preserved and listed in receipt; no art/generation/paid call/creature rules/Route1/message/commit. Next ordered slice A2 / ACC-14 reduced soul flash. Town/exterior/sign/lettering art remains on HOLD until slots exist.

## Codex result, October 26: A2 / ACC-14 reduced-motion soul flash

COMPLETE/INSTALLED in soul_prologue.gd only. The arrival flash starts0.4 under Reduce motion, normal stays1.6. Saved shared preference and forwarded setting both work and reach the next scene. Existing decay,0.9s flight,0.7s handoff wait, creature/partner/chosen flag, words, art, card layout and input source otherwise exact. Native87/87 clean across all three creatures with normal, forwarded-only and saved-only settings; real final-line advance gate, target/scale, monotonic fade, handoff timing/identity/setting and exact private save bytes checked. Reduced native corner about99/99/109 versus white255/255/255; flash clears by sample40, handoff48, normal retains its old full-white void. Official soul_prologue/opening_flow2 PASS, exit0, known raw exit warnings retained. Shared preference helper bodies match tested baseline; Claude/Grok changes preserved. [Native preview, originals, commands, frame samples and diff](../ui/soul-flash-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_soul_flash.md).

Source issues for Claude: no new ACC-14 issue. A3's input/skip, broader white-out transition, card and shaft requests remain pending; no blanket opening-flash fix claim. C6 remains OFF pending Preston's wording. Initial image diagnostic caught the state a frame before rendering; corrected to rendered brightness among adjacent frames, attempt retained. One intermediate baseline had2-instance/1-resource shutdown noise; verbose baseline and final installed run clean, no teardown source repair claimed. Private profiles/saves only, no art/generation/paid call/rules/Route1/message/commit. Shared preference recovery left intact. Town/exterior/sign/lettering art stays on HOLD until slots exist. Next ordered slice A3, beginning with shared advance/input and skip safety, one checked slice at a time.

## Codex result, October 26: A3 input slice / C7 and safe Storm skip

COMPLETE/INSTALLED: Storm/soul read UI.INPUT_ADVANCE and UI.pressed, soul choices use shared left/right including sticks and saved rebinds, one event advances once. Storm requires another press after release; echoes/held input/duplicate down do not skip. A binding-aware Skip / Press again to skip hint appears after4s or on arming, keyboard/pad/rebound names live. Title prelude/back and focused buttons accept shared inputs; obsolete _ensure_menu_inputs definition/call removed, project pad accept/back map preserved. C7 is landed; runtime UI.HEAD users absent and Claude's shared constant already removed. Native input85/85 plus real title-to-riverbank28/28 clean, including explicit first-Enter gate then second-Enter scene switch. Official opening_flow/soul_prologue/input_map/rebind4 PASS, exit0; known raw exit noise retained. First real-flow test caught viewport access after scene detach; input is now consumed before changing scenes, and all final checks reran successfully. Story, prior flash fixes, logo reveal, settings save/Continue and creature/partner handoffs preserved. [Preview, originals, commands, checks and diff](../ui/opening-input-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_opening_input.md).

Source issues for Claude: UI.pressed returns before neutral motion bookkeeping; the three owned opening entry points feed motion into existing UI._motion_edge before reading actions, so centre/repress works. Please fold that into the shared public helper when ready; shared UI source untouched. Public opening_flow_check still presses Enter once then waits for natural completion. Minimal proposal/opening-flow-two-press.diff is staged in the evidence; equivalent private driver tested28/28, live active check untouched for Claude to rebase/install. No cross-chat message sent; these notes notify C7 completion. Proposed installed instruction words: Skip; Press again to skip. C6 remains OFF until Preston picks words. Private profiles/saves only, concurrent Claude/Grok work preserved; no art/generation/paid call/rules/Route1/commit. A3 not fully closed: next white-out transitions, then C8 art/sounds/hint contrast, C9 top bar/shafts and Storm pixel light; town/exterior art HOLD unchanged.

## Codex result, October 26: A3 white-out transitions

WHITE-OUT SLICE COMPLETE/INSTALLED in storm_open.gd and soul_prologue.gd. Natural Storm holds its end light two frames, fades to shared black, then swaps under that cover; skipped Storm also fades under black. Soul draws two frames, reveals with UI.fade_in and blocks advance until that reveal ends. Soul's outgoing flash gets a short hold and shared fade, then hands cover to the flood scene's existing opaque construction veil and existing reveal. Bank source untouched. Normal shared fades about10 frames at30fps; saved Reduce motion halves them, and final Storm bloom now capped0.4. Prior soul/lightning caps intact. Native baseline10/10 and installed34/34 clean, actual current_scene handoffs in natural/skip and normal/reduced modes. Largest normal falling sampled brightness steps improved0.8845 to0.1020 (Storm) and0.8323 to0.0864 (soul). First soul frame shared-black1; first bank frame veil1 and construction stays covered. Hero/pending story partner choice/settings, first dialogue and private save bytes checked. Official storm_open/soul_prologue/opening_flow3 PASS, exit0, known raw exit warnings retained. [Sequences, native frame CSV, originals, commands and diff](../ui/opening-fades-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_opening_fades.md).

Source issues for Claude: no new fade issue. Dedicated October26 queue and newer pass7/8 direction call for fades through black; this is deliberate continuous cover rather than the abrupt cuts in the older pass6 evidence. Existing non-current-scene metadata hooks keep check behavior and are not visual proof; actual-scene native tests cover the fade. Initial fixture's provisional-partner assumption corrected to the bank's existing pending-choice behavior, failed attempt retained, no gameplay fix for it. Shared fade helpers and bank source match baseline; story/input/lightning/flash-decay methods preserved. Pass8 section11 item4 C7, item5 A1/A2 and item9 logo already closed by prior results. A3 still pending C8 cards/choice protection/sounds/hint contrast, C9 top bar/grey band/shafts and Storm pixel light. Next C9 bar/band/shaft edges. C6 OFF pending words, town/exterior art HOLD unchanged. Private profiles/saves only, Claude/Grok work preserved; no art/generation/paid call/rules/Route1/message/commit.

## Codex result, October 26: C9 / A3 top band and light shafts

COMPLETE/INSTALLED in soul_prologue.gd only. Removed the3px native speaking strip, which became the roughly9px grey top band at3x. Baseline384x216 already filled the authored16:9 viewport; no source-art recut needed. Shafts now use per-vertex alpha, zero at their lower vertices, so no hard end at native y150/view y450. Backdrop/flash cover expanded windows, UI/world stay centered on whole art pixels, and the caller's stretch policy restores on exit without overwriting a destination's new choice. Native20/20 clean:1152x648,1536x648,960x720, pixel probes, corners, flash extent, wide mouse selection, private save hashes and lifecycle. Added top-strip brightness0.302 to0; shaft-end0.0405 to0, midpoint still0.0131. Baseline3/3 clean; official soul_prologue/opening_flow2 PASS, exit0, known raw exit warnings retained. Story constants, input/advance, card art/geometry/scales, animation, flash timing and recent black-fade methods preserved. [Before/after, native sizes, originals, commands and diff](../ui/soul-light-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_soul_light.md).

Source issues for Claude: no new C9 issue; the grey band was the scaled speaking strip. Expansion is scene-local and respects a destination's stretch policy. Shared UI and active Claude/Grok sources untouched/preserved; concurrent paths listed in receipt. Earlier native passes archived, final20 includes queued-exit guard. C7 neutral-motion/public-check follow-ups remain in its handoff. A3 still pending C8 starter choice safety, card art/sounds/hint contrast and Storm pixel soul. C6 remains OFF pending words, town/exterior art HOLD until slot queue readiness. Private profiles/saves only; no assets/generation/paid call/rules/Route1/message/commit. Next C8 choice protection and presentation, one checked slice.

## Codex result, October 26: C8 starter cards and confirmation

COMPLETE/INSTALLED. First0.4s plus release/fresh press protects the cards from a reading/held/early accept. <Name>? Yes / No defaults to No, No/Cancel returns to the same creature, Yes commits once. Existing full-body front idles centred at shared whole scale1x, essence tint, title-role names, immediate original choice prompt, full-contrast live binding hints. Cursor for movement; confirm plus presence_swell for commit, all on UI. Latest section11 item2's whole-scale instruction used; older3x does not fit these detailed bodies. Hint labels review/confirm/back remain proposed; story/creature constants exact. Native47/47 clean, real title-to-riverbank all3 starters87/87 clean with both partner options/reduced motion, official opening_flow/soul_prologue2 PASS with known raw exit warnings. Fresh baseline2/2. [Before/after, originals, commands, logs and diff](../ui/starter-cards-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_starter_cards.md).

Source issues for Claude: none new. Public opening_flow now tests first-press arming/second-press Storm skip plus starter confirmation, closing C7's staged driver follow-up; existing12-frame partner gate preserved. Shared UI.pressed neutral-motion follow-up still documented; owned handlers feed neutral events already. Eight methods exact including C9 and black handoffs. Concurrent mouth_escape.gd and road_check.gd preserved/archived. Only soul_prologue.gd and opening_flow_check.gd installed. Initial fixture failures retained/documented; early guard down consumption fixed and tested. Next Storm pixel soul light, then C5 splash/return visit. C6 stays OFF, town/exterior HOLD until named slot queue; no real save/art/generation/paid call/rules/Route1/message/commit. Native captures reviewed by Codex; Preston approval not claimed.

## Codex result, October 26: C20 Storm pixel soul, A3 completed

COMPLETE/INSTALLED in storm_open.gd only. Four circle calls replaced by authored25x25 pixel cluster, white core, stepped blue-white light and faint uneven halo. Horizontal row runs and rounded rectangle edges keep the existing native384x216 transparent layer/nearest3x bloom crisp. Old outer growth reach retained. All10 other original methods, state fields, bob/opacity inputs and full-screen white draw exact; reduced lightning, descent, rain/shader, audio, skip and black handoff preserved. No new image assets or copy. Native21/21 visual assertions clean, original baseline15/15 clean; actual natural normal/reduced title-to-riverbank68/68 clean verbose logs, captured descent/landing, starter confirmation, both partner options and expected team. Official storm_open/opening_flow2 PASS, known raw exit-resource warnings retained. [Before/after, originals, diff, commands, logs and source verification](../ui/storm-pixels-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_storm_pixels.md).

Source issues for Claude: none new. Prior shared UI.pressed neutral-motion follow-up remains documented, owned handlers already feed neutral events. Public regression source untouched this turn. Concurrent hub_town.gd and walk_fix tool changes preserved/archived. First paused-fixture veil/teardown issue and first natural34-pass run with2 exit objects retained; established private shared-blip cleanup yielded clean final native flows, no production teardown fix claimed. A3's tracked input/skip, hints, white-outs, C8 cards/confirmation/sound, C9 band/shaft/backdrop and Storm pixel light are now complete. Next ordered A4/C5 splash return-visit skip, auto-dismiss/key wording and remaining LV-24. C6 New Game replacement prompt stays OFF, town/exterior HOLD pending named slot queue. No real save/new assets/generation/paid call/rules/Route1/message/commit. Native visuals reviewed by Codex, Preston approval not claimed.

## Codex result, October 26: A4/C5 splash and return visit, LV-24

COMPLETE/INSTALLED. In-session return to title skips the prelude and opens main at full opacity before first draw; baseline77 wait frames, installed0. First process launch keeps the existing timed card/reduced timing and sequential wordmark reveal. Process-local flag only, no new saved setting. Auto-splash hint now says Skip with live UI.binding_text values/click, and prelude/captions explicitly hide at alpha0. Only opening_flow.gd plus one creature_opening.gd hint assignment changed. Native campaign105/105 clean across auto/Enter/pad/mouse/reduced/Q first-launch and returns, plus actual pause-menu Enter confirmation on a disposable host. Legacy35/35 with known102-instance exit warning retained; original baseline11/11 clean. Maintained opening_flow/ui_fit2 PASS, known raw headless diagnostics retained. [Preview, commands/logs, originals, diff and preservation report](../ui/title-return-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_title_return.md).

Source issues for Claude: none new. LV-24 first-focus/Options sounds already correct in fresh baseline, now verified through actual keyboard/pad/mouse/rebound events: one confirm, quiet initial shared focus. No sound/helper change. Main menu/shared UI/title settings/project exact; input/close/journey handlers exact, C6 OFF. Both preference files byte exact on return and private save SHA exact; existing non-title preference migration respected. Concurrent Mouth/town/board/check edits preserved/archived. Fixture parse/preload/migration/frame-count corrections retained; production C5 needed no repair. Legacy exit warning/prior shared neutral-motion follow-up remain documented, no clean legacy exit claim. Next ordered A5/LF7-15 Continue sound/fade before threaded Highbank load and inspect unused FIRST_SCENE preload, Route1 untouched. Town/exterior HOLD pending named slot queue. No real save/art/generation/paid call/rules/Route1/message/commit. Native visuals reviewed by Codex, Preston approval not claimed.

## Codex result, October 26: A5 / LF7-15 Continue without visible loading freeze

COMPLETE/INSTALLED in main_menu.gd only. Confirm and existing title/music fade start before save/destination work. Opaque black is rendered before load_threaded_request/poll; getter only after LOADED, instantiate/state transfer covered. Highbank keeps shared black for its own card/build/reveal; suspended dungeon uses its existing card, shared cover releases, take_suspended called only after accepted scene change. Failure restores menu/music/focus and preserves suspend bytes; real retry resumes. Missing save disables Continue and starts no load. Proposed utility toast 'Could not continue. Please try again.' Native52/52 functional: normal/cold and reduced/cached Highbank, Warren B2F party/seed/HP/turn/suspend-once, duplicates, opaque covers at request, save preservation through load/failure, retry/missing save, lazy legacy route. Baseline8/8; official save_check/opening_flow2 PASS. Handler779.303 ms to0.175 normal/0.232 reduced/0.161 Warren; confirmation-player creation778.428 to0.065 ms, not total arrival or audible latency. Native raw exit warnings216 baseline/309 matrix retained/untriaged, no clean-exit claim. [Captures, frame/response metrics, commands/logs, originals, diff and hashes](../ui/continue-load-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_continue_load.md).

Source issues for Claude: no new functional Continue issue. The unused-route condition was false for legacy: opening_flow._begin_journey instantiates _route_scene. Campaign already no-ops that preload. Boot request removed from base; legacy New Game alone requests it, guarded against duplicate requests/polls, Begin verified. FIRST_SCENE/Route1 files retained, no campaign901 ms boot improvement claimed. Forty-seven other menu methods exact including C1/C6/input/sound/settings/journey dispatch; TeamState/Highbank/dungeon/opening/creature/shared UI/project exact, prior uncommitted Claude work preserved. Fixture half-read warm-up shutdown and freed-node lambda errors corrected, diagnostic logs retained; no production repair after install. Resource-exit retention/prior shared neutral-motion follow-up remain documented. Next actionable B7 icon/plain splash/Windows preset; check export templates before test export. C6 OFF pending words, town/exterior HOLD pending named slot queue. No real save/new art/generation/paid call/rules/Route1/message/commit. Native visuals reviewed by Codex, Preston approval not claimed.

## Codex result, October 26: B7 C10 complete, C11 preset ready

C10 COMPLETE/INSTALLED: icon.png from the exact existing title burrow/root ornament, native32x32 crop/nearest8x256. Real normal-launch Windows WM_GETICON image matches RGB exactly. Engine splash show_image=false, pure black bg matching clear colour; C5 launch card unchanged. Windows Desktop/x86_64 preset READY: separate PCK, builds/windows/Hollowtide.exe, icon/product fields; excludes tools/, addons/godot_ai/, scenes/_lab/, builds/, old icon.svg and archived docs code, keeps docs images until C22 plus JSON/dialogue data. Build outputs Git-ignored. Installed Godot AI addon already registers its export-strip hook, used unchanged; source debugger helper/plugins retained and no duplicate addon remains. Native9/9 clean, Windows icon1 exact, actual tiny PCK10/10 clean, hook matrix10/10 functional with custom-editor RID/209-object exit diagnostics retained. Five retained file changes/additions, gameplay/wordmark/UI sources exact. [Preview, normal Windows icon proof, native/package checks, sources/diff/hashes and diagnostic limits](../ui/product-setup-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_product_setup.md).

Source issues for Claude: no new gameplay issue. C11 full Windows game export and painted Highbank/Home desk/board/Hollow/cache-on-second-launch/EXE-icon QA remain PENDING TEMPLATES, not complete. Standard Roaming/Godot/export_templates still has no Windows templates; queue assigns matching4.7.2 download to Preston via Editor > Manage Export Templates > Download. Tiny PCK probe needs no executable stub and is not a game-build claim. Keep exported town_room worker-art change gated until actual exported QA. C22 arena-front relocation is next independent slice; docs assets have not moved, board path stays intact. Duplicate prototype retired safely; first loose-file/script-window/certificate/custom-editor diagnostics retained, final normal window icon and real tiny-PCK proof pass. No template download, real save, art generation/paid art, creature rules, Route1, cross-chat message or commit. C6 OFF, town/exterior HOLD; Codex-reviewed visuals, Preston approval not claimed.


## Codex result, October 26: C22 arena fronts in assets

COMPLETE/INSTALLED. Sixteen existing chosen fronts (121,988 PNG bytes) now have byte-identical runtime copies at `res://assets/sprites/arena/<form>/front_chosen.png`. Per-form folders keep palette/cleanup tools compatible. All 486 original docs form files remain hash-exact. Board fallback already repointed; its only edits are the path/comment, preserving Claude's dirty Tower dialogue, Layout.way_to routing, directional-set preference and 66px sizing. No further repoint needed. Export preset now excludes docs/*; no literal runtime res://docs/ reference remains in scripts/scenes/data/dialogue. [Native comparison, manifest, sources, hashes and logs](../art/arena-fronts-2026-10-26/README.md); [handoff](CODEX_HANDOFF_2026-10-26_arena_fronts.md).

Native 52/52 and asset-only PCK 49/49 clean for final per-form paths: source/fallback pixels identical, imported textures work through exact UI.res_image without raw PNGs, docs sentinel excluded. Maintained board_scene PASS; known raw 4 ObjectDB/2-resource exit warnings retained, no clean-teardown claim. Source issue for Claude: mirekit/whinet had no chosen front filename in original docs; current directional sets verified usable, no alias or art selection invented. Full Windows game export/painted street/Home desk/board/Hollow/cache/EXE-icon QA still pending templates under C11; asset-only PCK does not close it or enable exported town_room worker art. Next FX-01 empty Sail Slash/Mark Glyph frames. C6 OFF, town/exterior HOLD. No generation/paid art/real save/rules/Route1/message/commit; Codex review, Preston approval not claimed.
