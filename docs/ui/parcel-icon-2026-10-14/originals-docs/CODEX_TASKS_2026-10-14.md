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

1. **A Parcel icon.** Deliveries (R4) put a Parcel in the bag, but `UI.item_icon("parcel")` returns none, so the
   Job Board row and the Bag page draw it without an icon. Make a small sealed-parcel icon at the existing item
   icons' size and palette and wire it so `item_icon("parcel")` returns it. Done when: take a "Deliver to X" job
   from the Job Board, and the board row and the Bag page both show the icon.

2. **Rising water, painted.** The Hollow's valley (B1F) floods a row every ten turns from the lowest floor row
   (`scripts/dungeon/dungeon.gd`, `water_rows` and its band, around lines 576 to 614). The water is a band drawn in
   code over the painted valley. Paint a shoreline edge and a ripple strip in the painted dungeon look (the
   hand-painted textured terrain stays; `USE_TILE_ART` stays false) and draw them at the band's top edge and over
   the flooded rows. Keep the logic and numbers exactly (the numbers are Grok's). Done when: on The Hollow B1F,
   after ten turns, the first flooded row reads as water with a shoreline, and the save/resume of `water_rows` is
   unchanged.

3. **The Storage room's art.** The Storage building (R6, `scripts/town/storage.gd`) opens its panel at the door,
   the way the Job Board does, so a room can be added without touching the data. Paint the interior at the Hall
   rooms' scale and style (your Wayline Hall work is the model: rooted timber, limestone, brass, black internal
   detail, sel-out). Layout, solids, the door hook and the panel's position stay Claude's: deliver the art with a
   proposed room size, wall/floor regions and where the counter or shelves sit, in a staging folder with a README,
   and Claude wires it. No keeper creature yet: that is a new creature and waits for Preston.

4. **The dialogue frame's left corner.** Since R7 every dialogue box goes through `UI.dialogue` in
   `scripts/ui/ui_style.gd`, with the portrait set into the box's left side. The portrait frame now overlaps the
   9-slice's left corner ornament. Look at it in a real conversation (the flood talk) at 3x and either adjust the
   9-slice art so the corner reads well under the portrait, or propose new values for `PORTRAIT_INSET` and the
   portrait offset (30, -34) for Claude to set. Keep every box on the one shared frame.

5. **Refresh the AI asset inventory** (`docs/pitch/ai-asset-inventory.md`, yours from 2026-10-11) for
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
