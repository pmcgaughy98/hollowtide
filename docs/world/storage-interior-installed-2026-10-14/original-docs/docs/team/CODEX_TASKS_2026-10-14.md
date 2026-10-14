# Codex tasks (from Claude, 2026-10-14)

Preston, 2026-10-14: "lets get codex back on hollowtide tasks." The 2026-10-11 queue is complete (all six tasks and
the Wayling margin). This is the next one. Each task comes from a "For Codex" note Claude left in
`docs/AI_COLLABORATION.md` on 2026-10-12; all of them finish something a pitch viewer can see.

Read first: this file, then the top of `docs/AI_COLLABORATION.md` (the 2026-10-12 entries: R3 to R7, the save, the
faint screen), then `docs/creatures/guild-crew-2026-10-11.md` for the crew.

## What changed since your last session

- **2026-10-12 (committed in `92aa3f43e`):** the faint screen and Second Wind, save and Continue, the suspend save,
  the genre synthesis words (a creature "grows", never "evolves"; see `docs/design/genre-synthesis-2026-10-12.md`
  and memory "Hollowtide own words": Sense, nest, Second Wind, went down, Postmaster; never "Mystery Dungeon" as a
  label), the mail call, deliveries, rising water, the Storage, the dialogue frame, the crew's expression faces,
  the pitch capture v3. Your `main_menu.gd` got one small change: Continue is listed first when a save exists.
- **2026-10-13 (not committed, Claude's):** sprite-generator work, all proposals, none in `assets/`:
  `docs/design/new-creature-ballastak-2026-10-13/` (Ballastak, Switchhold, `parts_kit/`),
  `docs/design/sprite-generator-skillup-2026-10-13.md`, `docs/art/spritecook-assets.json`,
  `tools/art/{finish_sprite,slice_grid,parts_kit,kithflare_model,gemini_sprite}.py`, `tools/trailer/*_v3.*`,
  `docs/trailer/v3/`, `docs/pitch/feedback-post-2026-10-12*`, `.claude/skills/`. Leave these as they are.
- **Running outside the repo:** a local style-model training job in `D:/ai/hollowtide-sprite-lora` (GPU busy).
  Not yours to touch; it does not read or write the repo.

## Tasks, in order

1. **DONE: A Parcel icon.** Deliveries (R4) put a Parcel in the bag, but `UI.item_icon("parcel")` returns none, so the
   Job Board row and the Bag page draw it without an icon. Make a small sealed-parcel icon at the existing item
   icons' size and palette and wire it so `item_icon("parcel")` returns it. Done when: take a "Deliver to X" job
   from the Job Board, and the board row and the Bag page both show the icon.

2. **DONE: Rising water, painted.** The Hollow's valley (B1F) floods a row every ten turns from the lowest floor row
   (`scripts/dungeon/dungeon.gd`, `water_rows` and its band, around lines 576 to 614). The water is a band drawn in
   code over the painted valley. Paint a shoreline edge and a ripple strip in the painted dungeon look (the
   hand-painted textured terrain stays; `USE_TILE_ART` stays false) and draw them at the band's top edge and over
   the flooded rows. Keep the logic and numbers exactly (the numbers are Grok's). Done when: on The Hollow B1F,
   after ten turns, the first flooded row reads as water with a shoreline, and the save/resume of `water_rows` is
   unchanged.

3. **ART COMPLETE/STAGED: The Storage room's art.** The Storage building (R6, `scripts/town/storage.gd`) opens its panel at the door,
   the way the Job Board does, so a room can be added without touching the data. Paint the interior at the Hall
   rooms' scale and style (your Wayline Hall work is the model: rooted timber, limestone, brass, black internal
   detail, sel-out). Layout, solids, the door hook and the panel's position stay Claude's: deliver the art with a
   proposed room size, wall/floor regions and where the counter or shelves sit, in a staging folder with a README,
   and Claude wires it. No keeper creature yet: that is a new creature and waits for Preston.

4. **DONE / INSTALLED: The dialogue frame's left corner.** Since R7 every dialogue box goes through `UI.dialogue` in
   `scripts/ui/ui_style.gd`, with the portrait set into the box's left side. The portrait frame now overlaps the
   9-slice's left corner ornament. Look at it in a real conversation (the flood talk) at 3x and either adjust the
   9-slice art so the corner reads well under the portrait, or propose new values for `PORTRAIT_INSET` and the
   portrait offset (30, -34) for Claude to set. Keep every box on the one shared frame.

5. **DONE: Refresh the AI asset inventory** (`docs/pitch/ai-asset-inventory.md`, yours from 2026-10-11) for
   2026-10-12 to 2026-10-14: the crew's expression faces (Retro Diffusion on your crops), the pitch capture v3 and
   its four GIFs (`docs/pitch/feedback-post-2026-10-12/`, real gameplay), and a line that the 2026-10-13 sprite
   work (Ballastak, Switchhold, the palette variants, the local model) is proposal art and not shipped. Do not
   guess unknown provenance.

## Rules that still hold

- Inspect Git dirty state first; never reset, stash, revert or commit without Preston's instruction.
- Preserve original sources and backups; new art is a proposal until Preston approves it.
- No paid Retro Diffusion, SpriteCook or PixelLab calls without Preston's explicit go-ahead.
- Do not install Ballastak, Switchhold or Flintram; DESIGN_RULES puts creature art after Grok's numbers and
  Preston's approval.
- Finish one visible, runnable slice per session with native checks and a short handoff below.

## Codex notes (write below)


Codex, October 14: Task 1 complete: native 32px sealed Parcel icon, exact existing Scroll paper/wax palette and six-colour outline recipe. Generic item lookup/Bag resolve automatically; delivery-only Board hook shows cargo beside the title while retaining the separate reward icon. Native 20/20 staging and 20/20 installed live: take a generated delivery at the real Board, exact Board cargo/reward pixels, actual Bag row and selected 3x detail, put-back cargo removal. All 17 prior icon recipes and 809 other protected source/UI files exact. Original sources, diff, native import, private drivers, captures and receipts: docs/ui/parcel-icon-2026-10-14/README.md. AI-assisted native-grid art; no image generation, paid call, rule/save/settings/other-asset edit or commit. Claude proposals and local training untouched. Task 2, painted rising water, is next; tasks 2-5 remain pending.


Codex, October 14: Task 2 complete: installed native shoreline/ripple atlases and rising_water_art helper on the existing translucent water, with four quiet 400ms frames. Exactly three presentation lines added to dungeon.gd; all water rules/numbers, suspend/resume and textured valley remain exact (USE_TILE_ART=false). Native 22/22 staging and 22/22 installed live: original six water assertions plus sixteen atlas/turn/save/real Continue checks; one-use suspend and the next rise preserved. Dry/wall pixels and floor data exact at turns9/10/20/30; all 822 other protected source files exact. Originals, diff, native captures, builder/import drivers and receipts: docs/design/rising-water-finish-2026-10-14/README.md. AI-assisted code-painted art; no generation, paid call, other art/creature/settings/audio edit or commit. Claude proposals and local training untouched. Tasks 1-2 complete. Task 3, staged Storage interior art for Claude, is next; tasks 3-5 remain pending.


Codex, October 14: Task 3 ART COMPLETE/STAGED: a proposed 17x13-tile (408x312) Storage interior matching the Hall: exact native Hall limestone floor, rooted timber, brass, two back-wall cabinets, central counter, low stock crates/basket and wall lamps; no keeper or mail parcel stock. Six separate native props, shell, mask, assembled art, placements/depths and a standalone Godot preview delivered for Claude. Shared CPU rim preserves alpha/interiors; native preview8/8 and packaged preview8/8; all unselected floor pixels exact, all108 illustrative walkable tiles connected and three-tile aisle/threshold clear. All539 protected existing game sources/current-finish files exact. No live room, collision, door, Storage panel/data or game hook installed: these stay Claude's. Two built-in imagegen calls; original outputs, exact prompts, Hall references, nearest/alpha preparation and receipts: docs/world/storage-art-proposal-2026-10-14/README.md. No external paid generator, commit, other proposal or training edit. Tasks1-3 deliverables complete; task4 dialogue-frame corner is next, then task5 AI inventory refresh. Claude room integration remains pending.


Codex, October 14: Task 4 PROPOSAL COMPLETE: native flood-talk review at 3x confirms a 12px right shift clears the brass corner stud. Proposed shared values PORTRAIT_INSET=162.0 and portrait offset Vector2(42,-34); name/text move together, vertical placement and all shared frame art unchanged. Native flood5/5 plus gallery5/5 on both live baseline and staged candidate; narration and ordinary/dim/focused panel controls pixel-exact, long text pages and fits both current widths. All814 protected existing source/data/dialogue/UI files exact. Two-line patch, original/candidate source, original frame PNGs/recipe, native before/after and receipts: docs/design/dialogue-corner-2026-10-14/README.md. Live layout application remains Claude's, as requested by task4. Storage room wiring also remains pending. Tasks1-4 deliverables complete; task5 AI inventory refresh is next. No generation, paid call, other proposal/training edit or commit.


Codex, October 14: Task 5 complete: refreshed docs/pitch/ai-asset-inventory.md for October12-14. Verified all12 Retro Diffusion crew expressions and their raw edits; six normal portraits exact to October11 prepared files. Probed both101.967s v3 MP4s and measured all four98-frame/6.54s gameplay GIFs; recorded actual engine footage/editing, generated source content and missing per-GIF encoding records separately. Ballastak (SpriteCook/Nano Banana plus GPT-Image-2 profile edits), Switchhold (PixelLab), palette/parts and local SD1.5/LoRA exams remain development proposals, not installed gameplay; the dated training note says parked, not a fresh process audit. Added installed Parcel/water provenance and staged Storage/imagegen and dialogue-value status; exact models/legacy unknowns remain explicit. Current entry scene corrected to creature_opening. Evidence, hashes and checks: docs/pitch/ai-asset-inventory-2026-10-14/README.md;98 local links resolved; all814 protected existing source/data/dialogue/UI files exact. Documentation only; no generation, paid call, policy/terms research, game/media edit or commit. All five October14 queue deliverables complete: tasks1-2 installed, task3 Storage art staged and task4 dialogue values proposed. Claude still owns those two integrations; neither is claimed live.


Codex, October14 (follow-up after Preston: "next"): Follow-up complete: the checked shared dialogue corner correction is now INSTALLED in scripts/ui/ui_style.gd (PORTRAIT_INSET162.0, portrait offset42,-34). Portrait/name/prose move12px right together, clearing the complete brass stud with6px spare. Native installed flood5/5 plus gallery5/5; narration and ordinary/dim/focused shared panels pixel-exact to baseline; long-line first/final pages pixel-exact to the checked proposal. Exactly two value replacements; reverse patch restores original source bytes;813 other protected source/data/dialogue/UI files exact. Evidence, original source, patch and native captures: docs/design/dialogue-corner-installed-2026-10-14/README.md. All five October14 queue deliverables remain complete. The dialogue integration is no longer pending; only Claude's Storage room/door/collision/panel integration remains. No new frame/art, generation, paid call, state/rule/save/other proposal/training change or commit.
