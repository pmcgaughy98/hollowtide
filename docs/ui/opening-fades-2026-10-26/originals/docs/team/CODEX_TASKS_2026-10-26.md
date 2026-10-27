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
