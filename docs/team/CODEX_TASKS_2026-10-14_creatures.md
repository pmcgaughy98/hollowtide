# Codex tasks, creature views (from Claude, 2026-10-14, second queue)

Preston, 2026-10-14: "Codex tasks." The first October 14 queue (`CODEX_TASKS_2026-10-14.md`) is complete. Its
five tasks, both follow-up integrations and the full V4 pitch are all done; thank you. This queue is smaller and
all creature art. All of it is proposal art in `docs/design/`, and none of it goes in `assets/`.

Read first: this file, then `docs/design/new-creature-agile-line-2026-10-14/README.md` and
`docs/design/new-creature-flintram-2026-10-14/README.md`.

## What changed since your last session (all Claude's, not committed; leave it as it is)

- **Opal Forges rebuilt.** Sprite Forge v5 and Evolution Forge v5.1 live in `docs/art/opal-forges/`. Claude runs
  them in the built-in browser.
- **The Flintram line.**
  - Flintram's canon is the eight-view sheet; its cut views are in `new-creature-flintram-2026-10-14/views_128/`.
  - Mortarback is the Stage II artillery form; its cut views are in `mortarback/views/`.
  - Cutbank Bastion take 6 is waiting on Preston.
- **A new agile line, no name yet.** Stages I to III are cut into `stage1_views_128/`, `stage2_views_144/` and
  `stage3_views_160/` in `new-creature-agile-line-2026-10-14/`. Preston chose Stage III **take 1**. Take 2's cut
  views sit in `stage3_take2_views_160/` and stay as they are.
- **Local training.** The style-model training in `D:/ai/hollowtide-sprite-lora` finished and is parked (it failed
  its exam). It no longer uses the GPU.
- **Gemini MCP.** A Gemini MCP is installed at user scope. Ignore it.

## Tasks, in order

1. **Facing audit of every cut view set.**

   `tools/art/slice_grid.py` names the 3x3 cells `ne n nw / e . w / se s sw`. It assumes the Forge drew e, se and
   ne facing screen-right, and w, sw and nw facing screen-left. That held for most sheets, but the agile Stage II
   sheet came back mirrored. Claude relabelled it when cutting: e and w swapped, se and sw swapped, ne and nw
   swapped.

   First confirm the game's convention from an installed creature, for example
   `assets/sprites/arena/kithflare/dungeon/`. Then check every view in these five sets:
   - `new-creature-flintram-2026-10-14/views_128/`
   - `new-creature-flintram-2026-10-14/mortarback/views/`
   - the agile line's `stage1_views_128/`, `stage2_views_144/` and `stage3_views_160/`

   For any set that is mirrored, keep the originals in an `_original_labels/` folder beside it before
   relabelling. Also note any pink or purple rim left from the magenta background.

   Done when: each set's README has a short table (view, the way it faces, right or wrong) and a contact sheet in
   game order (s, se, e, ne, n, nw, w, sw) on one baseline. Every e, se and ne faces right, and every w, sw and nw
   faces left.

2. **Agile Stage III: the two back corners.**

   `stage3_views_160/ne.png` and `nw.png` are meant to be walking away, but each shows the eye and snout. Repaint
   the head and shoulders as seen from behind, using `n.png` as the reference:
   - **Head:** the back of the head, with the brow crest's base and both blade-ears.
   - **Cape:** it covers the back.

   Keep the legs, sabres, tail and cape hem exactly as they are. Use only colours already in the set. A native-grid
   hand edit is preferred. If you need your built-in image tool, record the prompt and the raw output as you did
   for the Storage art. Keep the originals.

   Done when:
   - At 1x and 3x, neither view shows an eye or snout.
   - The pair reads as mirror poses of each other.
   - Every other pixel in both files is unchanged.

3. **Agile Stage I: two specks.**

   In `stage1_views_128/`, the crimson throat leaf snapped into a hollow purple ring (clearest in `e.png`), and
   there is a stray magenta dot at the hip. Check all eight views. Restore the throat leaf as a solid crimson leaf,
   as it appears in `stage1_ears_8dir_raw.jpg`, and remove the strays.

   Done when: no opaque pixel passes Claude's rim test (r > 70, b > 70, g < 0.6 × min(r, b), |r − b| < 70), apart
   from the intended crimson. The throat leaf reads like the raw sheet's at 3x, and every other pixel is unchanged.

## Rules that still hold

- Inspect the Git dirty state first. Never reset, stash, revert or commit without Preston's instruction.
- Preserve original sources and backups. New art is a proposal until Preston approves it.
- No paid Retro Diffusion, SpriteCook or PixelLab calls without Preston's explicit go-ahead.
- Install nothing from these lines. DESIGN_RULES puts creature art after Grok's numbers and Preston's approval.
- Do not edit the raw Opal sheets (`*_raw.jpg`). Work only on the cut views.
- Finish one visible, checked slice per session and write a short handoff below.

## Codex notes (write below)
