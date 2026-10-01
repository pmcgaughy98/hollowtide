# Hollowtide Forge hub

The seven existing Generate prompts were read in Opal on2026-09-30. Character and World Asset Forges were created and configured. Changed prompts and real input links were checked after reopening. This confirms the saved setup, not the quality of future generations.

| Forge | Current job |
|---|---|
| [Creature](https://opal.google/app/1-WLZWZcCWFr8l5YTMOFUqBq-1Da2V-eY) | One new front or approved-form redraw; Cinderhide finish, reference anatomy. Existing prompt retained. |
| [Evolution](https://opal.google/app/13O5Xm_9Go-u1cKn9TUCWAZhAXDe6OKbV) | One distinct StageII/III front or same-form rear. Existing prompt retained. |
| [Back View](https://opal.google/app/1z5BCWzkXGopEBrsYO2F39Eg5uv394hJF) | Front-led rear reconstruction. Prior rear is review-only. Hind/middle pads differ from foreclaws. Existing prompt retained. |
| [Idle](https://opal.google/app/1p1-aH_DX-Ys83Fy3rxKL0fKQgChEcNs8) | Restrained four-frame2x2 breath, NEW/COMPLETE. Existing prompt retained; whole-sprite engine breathing remains approved. |
| [Walk](https://opal.google/app/1hJoFcTzUTBVT-EqX8eA2eTQaUEiLEhQy) | Eight poses in one direction; rectangular4x2 atlas of square cells. Defaults64x64 cells and36-pixel adult visible height. No forced goggles; equal height across directions. |
| [Attack / Title Card](https://opal.google/app/1mcPSsql5N9rj53Nbg0FFqFEh-e39c_f-) | Six body poses in3x2 OR one full-body signature card with ACTION CLASS CUT-IN/TITLE CARD. Review follows the selected mode. |
| [Effect](https://opal.google/app/1G34GLZ7O1UEBX3pX6NIXNd8LjQjKUyBt) | MODULES: five pieces on a square canvas. ACTION: eight square cells in a rectangular4x2 atlas. Bloom retained; Vitrecrag molten glass is a cannon. |
| [Character Model](https://opal.google/app/1n9s7JHBcc7O3FJx-TdohZZ71HJbYcsd2) | NEW standing person or REDRAW exact identity. SINGLE one direction; TURNAROUND2x2 DOWN, UP / LEFT, RIGHT. Default64x64 cells,36-pixel visible height. |
| [World Asset](https://opal.google/app/1gkKkSpg8Pakg7888e05tKqAhps9wFl19) | PROP, TILESET, WATER, PROP SET. Current16x16 world tiles retained; prop margins and edge-to-edge terrain have separate rules. |

## New workflows and review files

- Character: `new-courier-character-forge-prompt-2026-09-30.md`. Identity Reference NONE for NEW; approved exact person for REDRAW. Style Reference governs finish only. Approve standing identity, then turnaround, then walks.
- World: `world-asset-forge-spec-2026-09-30.md` and `world-asset-forge-prompts-2026-09-30.md`. Approved art supplies finish; saved exploration studies supply projection. Generate one terrain family before expanding it.
- Ironvent: `ironvent-furnace-roar-cutin-forge-prompt-2026-09-30.md`. Raw result: `ironvent-titlecard-candidates/ironvent_furnace_roar_opal_candidate_2026-09-30.jfif`. It crowds the tail at the edge, is unapproved and did not replace the live card.
- Vitrecrag: `ludo-vitrecrag-back-foot-fix-2026-09-30.md`. The back-foot image edit is a candidate, not an installed rear.

## Decisions preserved

Most creature native targets are100x100; Vitrecrag and Oxbowarchon are128x128. These are logical drawing targets, not guaranteed exports. Match approved source anatomy and pixel density. Bloom is the growth essence; Oxbowarchon's line is Stone. Turbo Green is an HP/UI accent. Preserve local material ramps.

Attack review now carries Preston's four-sheet protocol: save originals, cut each frame, inspect each action/pose and identity individually, order, inspect the sequence again, then finalize. Emission and target hit are separate. Intact-sprite approaches with contact effects remain approved. Kithflare locomotion is not a mandatory power theme; approved flush heat/light markings and the move brief govern it.

All results are candidates. COMPLETE cannot guarantee identical kept pixels. No Forge automatically creates transparent Godot assets, rigs, collision or working TileSets. No image runs were made for the two new forges or revised walk/effect contracts in this pass.

Prompt snapshots: `forge-records/forge-installed-prompts-2026-09-30.json` and `forge-records/forge-audit-prompts-2026-09-30.json`. These are text records, not full app backups. Proof screenshots are beside them. Old graph-card summaries sometimes still say Cinderhide or two sprites; the selected Generate prompt is authoritative.
