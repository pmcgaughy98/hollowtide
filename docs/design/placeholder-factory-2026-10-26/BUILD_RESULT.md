# Placeholder factory: build result (Claude, 2026-10-26 and 27)

Not committed. Plan: `00-BUILD-PLAN.md`. Design: `01-asset-census.md`, `02-town-rewire-design.md`, `03-spec-format.md`, `slot-registry-draft.md`. Full gate table: `after-build-checks.md`.

## The short version

- **Every visual outside the creatures now has an art slot.** There are 163 slots in 8 files under `scripts/art/slots/`, and 0 of 163 are installed. 82 draw their coded placeholder, 76 draw Codex's existing file (legacy), and 5 draw Claude's own finished UI frames.
- **The gate passed all three ways with nothing failing.** With v2 off: PASS 105, WINDOW 6, RAN 4, RETIRED 3, SKIPPED 1. That is pass 8's baseline plus 6 new PASS rows. With v2 on, 19 of 19 passed. With placeholders forced, 4 of 4 passed.
- **With the switch off, the screens match the committed tree.** The two exceptions are planned: the UI frames on the dungeon HUD and Team page, and the room title "Wayline Tower". Details under "Safety rule" below.
- **Nothing was installed, generated, spent or committed.** Highbank v2 stays off (`HIGHBANK_V2 = false`) until you walk it.

## What to press play on

1. **The building lineup.** Open `scenes/debug/building_lineup.tscn` and press **F6**.
   - The top row is scale 1.0 and the bottom row is 1.25 (call 1). Each class stands beside Codex's current picture, with a stage 1, 2 and 3 creature at its door.
   - Arrows or WASD pan. The mouse wheel or +/- zoom. **1** and **2** frame a row, and **0** shows everything.
   - **T** pans the camera up the Wayline Tower at the town's 3x view. **F** turns forced placeholders on and off.
2. **Highbank v2.** Open `scenes/debug/highbank_v2.tscn` and press **F6**.
   - You start on Highbank Street. The north steps go up to Tower Rise, and the south switchbacks go down to the Old Ferry Ward.
   - In this scene only, the road east past the barrier is open and leads to the empty East Quarter. In the game it stays shut.
   - The first time you walk up to Tower Rise, the two stop at the Tower's doors, and the camera pans up to the beacon and back while they talk (the awe scene). It plays once.
   - The scene saves to its own file (`user://highbank_v2_walk.save`), never to your `team.save`.
   - To play the whole game in v2 without editing a file, start it with the environment variable `HT_HIGHBANK_V2=1`.
3. **The road up to Highbank** is in the normal game. After the dawn bank, you walk the river trail with the right arrow or the stick. Highbank and the Tower sit faded on the horizon and grow as you near the rise.

## The art lists

- **Codex:** `docs/team/CODEX_ART_TASKS_2026-10-26.md`. It has 10 batches and 40 slots: the plan's 8 batches and 31 slots, plus 2 road batches (9 slots) for the road-back canon.
- **Grok:** `docs/team/GROK_ART_TASKS_2026-10-26.md`. It has 7 batches, 29 slots and 30 images: the plan's 6 batches, plus 3 trail props. Grok's spend is 30 x $0.06 to $0.13, so $1.80 to $3.90, and it is asked before anything runs.
- **References:** `refs/` holds 4 images per slot plus 17 palette strips. `slots.json` is fresh (registry `cb33c871f11f`).
- **Review:** `python tools/art/review_sheet.py <batch>` makes one sheet per batch. Nothing installs without your yes on it.
- **Codex has already started.** During the gate run, a `CODEX_IN_PROGRESS` lock and a first Tower candidate appeared in `docs/art/slot-candidates/cx-01-buildings/`. Nothing is installed.

## Safety rule: the screens with v2 off

Both sets of stills came from the same windowed probe at `--fixed-fps 30`, each with a temporary user folder. The before set was taken from a copy of the committed tree (`3f80b6265`, without `docs/`), and the after set from the working tree. Each set was shot twice, to find the run-to-run noise. The screens were: Highbank (spawn, street, terrace, landing, Tower door), the Home and the Tower's ground floor, a dungeon floor (B1F, seed 4242), and the Team page.

| Screen | Result |
|---|---|
| Highbank, 5 views | Same art. The only differences are townsfolk wandering (they also differ between two runs of the same tree) and the leader's idle frame. A 40-frame burst found each before frame repeated exactly in the after run, and whole frames matched pixel for pixel. The idle cycle simply starts a few frames later. |
| Home | Same, by the same 40-frame burst test (the hearth flickers between runs). |
| Tower ground floor | Same, except the room's title now reads "Wayline Tower" (the canon rename). |
| Dungeon B1F | The floor, creatures and log are identical. The HUD's health bars, headshot rims and floor banner use lane U's new pixel frames. These are planned exceptions (K05 to K07 and X14). |
| Team page | Identical except the Health and EXP bars and the frames, the same planned exception. |

To see the old flat UI pieces, run with `HT_FORCE_PLACEHOLDERS=1`.

Summer Engine was connected to the working tree's editor. It was not used for these shots, because it cannot open the committed copy, and a like-for-like comparison needs both sets from the same probe.

<details><summary>The three gate runs</summary>

1. **v2 off, everything** (`run_checks.py --long --arena --jobs 3`): PASS 105, WINDOW 6, RAN 4, RETIRED 3, SKIPPED 1, and no FAIL, TIMEOUT or BROKEN. The new rows are area_data, art_slots, building_template, road, tower_reveal and town_props. Pilot chain: all ok in 130 s. Timing passed (32.7 s). The table is in `after-build-checks.md`.
2. **`HT_HIGHBANK_V2=1`**, the section 5 list (hub_town town music board storage job_board pad_play stone evolution way_down dungeon_sfx story_gate ui_fit area_data art_slots pilot): PASS 19 of 19. Pilot chain: all ok in 96 s, with the Tower scene on the first arrival. art_slots read "v2 true, area street, area_of(hall) hall_rise".
3. **`HT_FORCE_PLACEHOLDERS=1`** (ui_fit art_slots hub_town town_room): PASS 4 of 4, with all 163 slots on placeholder.

All 95 changed or new scripts parse clean. The only errors are autoload names (DialogueManager, PlayerParty) that `--check-only` cannot see. Your `team.save`, `team.save.bak` and `menu_preferences.cfg` hashes were unchanged after all the runs.

</details>

<details><summary>What each lane did</summary>

| Lane | Built | Its own gate |
|---|---|---|
| Contract | `ArtSlots` loader, `PlaceholderPainter`, `AreaSchema`, the slot-file format, the cross-lane stubs, `render_slot_refs.gd`, `prepare_slot.py`, `validate_slot.py`, `install_slot.py`, `slot_registry.py`, `art_slots_check` | art_slots |
| A, town areas | Today's map moved tile for tile into `scripts/world/areas/highbank_v1.gd`. Four v2 areas: street 56x16, Tower Rise 26x14, Old Ferry Ward 34x16, East Quarter 30x14. `enter_area` with the 0.2 s fade; music, camera and the cached picture per area; the switch and the debug scene. 15 checks moved to named anchors, and `area_data_check` is new. | v2 off and on, pilot both ways |
| B, buildings | `BuildingTemplate`: classes, doors, coded shells, lots. The Wayline Tower at 300x576 (2.67 screens), with its beacon at (150,8) and a 48x64 double door that clears Galeshear. v2 buildings draw through slots. 5 sign and 3 shut-overlay slots, the lineup scene, and `building_template_check` | 9 of 9; v1 exteriors identical, 54 of 54 hashes |
| C, ground and props | `paint_area` paints any area in today's style. `TownProps` places lamps (glow and flicker), 11 props, shadows and the placement rules. 12 coded prop placeholders and `town_props_check` | 7 of 7; today's street identical; 323 ms a screen vs 339 before |
| R, rooms | All 53 room keep rows load through slots (`room_slots.gd`, safe off the main thread). The 4 unused Tower PNGs are wired but switched off. 4 squeezed props are registered at their drawn size. Placeholder shop (14x10) and cellar (12x9) rooms sit behind shut doors. | 6 of 6; every room identical |
| D, dungeon | The sealed stairs (a slate slab with a teal seal) replace the red X. A hand-placed sleeping z. 12 essence shots replace the dot. HUD calls go through the shared UI frames. | 9 of 9 |
| U, UI and story | Five hand-placed 9-slice frames (bar well and fill, focus row, headshot, banner). Team-page stages for all 12 essences, with GALE now on take1. The waking bank, Hollow entrance and dawn bank go through slots. | 9 of 9, normal and forced |
| S, road and Tower | `RouteScene` and `scenes/road_to_highbank.tscn`: a walkable trail with haze, the far Highbank and Tower, beats, and a held vista. The Tower awe scene (`scripts/story/tower_reveal.gd`, v2 only) and 12 road slots. | road, tower_reveal, flood_talk, ui_fit, art_slots, pad_play, save |
| Task lists | Both art lists, references for all 69 slots, `write_art_tasks.py`, `review_sheet.py`, the slots.json export, and the cross-lane edits still missing. It also removed a duplicated road-autopilot line in the pilot check. | art_slots, mouth_escape, road, pilot |

The lanes asked for 11 cross-lane edits. The integrator checked that 10 are in, each exactly once. Lane B's art_slots_check edit was superseded by lane A's edit to the same line. The integrator then ran the parse check, the three gates and the stills, and changed no game code.

</details>

## Your calls (the default stands if you do not answer)

| # | Call | Default |
|---|---|---|
| 1 | Building scale | 1.0. Walk the lineup; 1.25 would resize every canvas before the lists go out. |
| 2 | Town shape | Three areas behind the switch, off until you walk v2 |
| 3 | Home | On the street |
| 4 | Scroll Keeper | A south door down to a cellar room |
| 5 | Shut shop and cellar | Placeholder rooms; the doors stay shut, and so does the Yard |
| 6 | East Quarter | Empty and closed; only the debug scene reaches it |
| 7 | Tower Rise well | A prop only, with no party switch |
| 8 | Existing art | Keep all 75. The 4 unused Tower PNGs are wired but switched off, because they are drawn face-on and your 2026-10-11 note asks for the stairs as an opening. To try one, set it to true in `SHOW_CODEX` in `hall_fixtures_art.gd`. The title stays at 4.5x, and GALE uses take1. |
| 9 | Review | Nothing installs without your yes |
| 10 | Grok "character sprites" | Non-creature only, none this phase |
| 11 | UI frames | They stay Claude's hand-placed 9-slices |
| 12 | Colour budgets | Building 32, room 48, backdrop 48, prop and lamp 24, HUD 16, icon 8, frame 16 |
| 13 | Ground and terrain | Both stay painted in code |
| 14 | Names | Working labels: Tower Rise, Old Ferry Ward, East Quarter, Empty Stall, Empty Plot, Shuttered Shop, Road East |
| 15 | Grok spend | $1.80 to $3.90 for 30 images, asked before running |

**Small calls the lanes raised:**
- **New words are proposals.** The road has 8 new lines, marked `# NEW, proposal` in `dialogue/road_to_highbank.dialogue`. All 12 lines of `dialogue/tower_reveal.dialogue` are new, plus one narration line. The lot and shut-road lines are new too. The Tower's teal banner, gold chevron and pennant, and the scroll and crossed-staves pictograms, are also proposals.
- **A thrown River Stone now flies as the stone shot** instead of a pale dot. Keep it, or go back to the dot?
- **The health fill is now 6 px tall under a 3 px ink lip** (it was a 9 px flat fill), and the headshot rim is 3 px (it was 1 px). Both are worth a look in the dungeon.
- **In v2, a run ends on Tower Rise**, by the steps and the Job Board. The road's first arrival lands there too. If you want it to end on the street, the road scene needs a small change.

## What is left

1. **Walk the lineup and v2**, then answer the calls above, or let the defaults stand.
2. **Codex and Grok paint from their lists.** Each batch then gets a review sheet, and you answer yes, redo or keep the placeholder. Grok's spend is asked first. Retro Diffusion has $0.11, which is less than one prop ($0.18), so it would need a top-up before any use.
3. **Known gaps, not fixed:**
   - From the v2 street you cannot see the Tower, because the camera stops at the street's top edge. A far view painted into the street's top rows would fix it; that is art for a later pass.
   - `tower_reveal.gd` throws an error if the town is freed partway through the scene. The narrowed trigger keeps the gate clear of it, but the scene should stop cleanly.
   - The title slot's brief still names the launch card colour `#161f1b`. The card is now `#18172c`, so its stand-in uses the old colour. Codex's title task points this out.
   - The registry export sorts each slot's state names alphabetically. The task writer reads the order from the registry instead.
   - The street's ground files stay read directly, not through slots, because the street picture's disk cache key does not yet include the slot source.
4. **Your save, from lane A's run.** At 18:13 on 2026-10-26, a test run of the v2 debug scene wrote over `team.save`. The Oct 23, 15:02 save was copied back about 20 minutes later and is your `team.save` now. The older `.bak` from before that is gone. The debug scene now saves to its own file.

## Not verified

- How v2 looks in a window. It was checked by numbers and by the lanes' headless composites and stills, not walked by eye.
- Codex's files at scale 1.25. Slots accept only 1.0 canvases, so the 1.25 row always shows the coded template.
- The D-pad on the road (only the stick was tested), the road's frame times in a real window, and its Reduce motion fades (code only).
