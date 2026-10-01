# Hollowtide Forge production standard

**2026-09-30 update:** [Forge hub](forge-hub-2026-09-30.md) is the current nine-app directory. Character models default to64x64 logical cells and36-pixel visible height; world terrain retains16x16 cells. Props have margins, terrain cells meet edge-to-edge. Attack now supports one signature CUT-IN. Walk and Effect ACTION use rectangular4x2 atlases with square cells. These are drawing targets, not guaranteed exported dimensions.

**Preston's role order, 2026-09-27:** Opal Forges generate scoped art candidates. Codex prepares and integrates approved assets; Preston approves their identity and visual fit. See `docs/team/agent-role-charter-2026-09-27.md`.

**Updated 2026-09-27.** See [current live Forge modes](forge-live-status-2026-09-27.md) for the verified editor state. This is a production checklist, not new creature canon. It incorporates the user's sprite-sheet research and the now-approved 128×128 Vitrecrag exception. Review each generated image before importing it.

## Which Forge to open

| Job | Live Opal app | Input |
|---|---|---|
| New Stage I front or same-form front redraw | [Hollowtide Sprite Forge](https://opal.google/edit/1-WLZWZcCWFr8l5YTMOFUqBq-1Da2V-eY) | Creature Brief; optional exact-form reference; optional Cinderhide style anchor |
| Stage II/III front or approved-form back | [Hollowtide Evolution Forge](https://opal.google/edit/13O5Xm_9Go-u1cKn9TUCWAZhAXDe6OKbV) | Evolution Brief; Previous Stage Front for front mode; Approved Evolved Front for back mode; optional Style Anchor |
| Battle effect pieces | [Hollowtide Effect Sheet Generator](https://opal.google/edit/1G34GLZ7O1UEBX3pX6NIXNd8LjQjKUyBt) | Creature Brief (move request or roster brief); Creature Reference (optional) |
| New or completed four-frame idle breathing | [Hollowtide Idle Sprite Forge](https://opal.google/edit/1p1-aH_DX-Ys83Fy3rxKL0fKQgChEcNs8) | Idle Motion Brief; approved Source Sprite; Existing Idle Sheet image for COMPLETE or `NONE` for NEW |

## Rules carried into the live prompts

- Most creature art uses a 100×100 logical grid on flat #FF00FF. Keep an approved larger native grid when the form needs it; Vitrecrag's official pair is 128×128. The body remains entirely in frame; the lowest contact point stays on a stable baseline. Same-form back views and redraws preserve the source form's apparent size and footprint. Evolutions can change body plan and mass while retaining that baseline. Cinderhide is the approved finish benchmark: substantial dark outline, clear shape hierarchy, dense but readable material clusters, layered light and shadow, restrained luminous accents, and planted weight. The style anchor must not transfer Cinderhide's reptile anatomy or coal palette to unrelated species.
- Effect Forge asks for **one sheet per run**. `MODE MODULES` keeps five separate parts on a square canvas: main shape, impact, and three motif particles with clear magenta spacing. `MODE ACTION` makes a rectangular4x2 atlas of eight square chronological cells for material emission, travel, contact and cooling. Creature body action remains separate. Colors and shapes come from anatomy, move and essence; Bloom is the current growth essence. Vitrecrag uses a molten-glass cannon; Molten Beam was dropped.
- Idle Forge keeps the approved four-frame breath: F0 neutral, F1 early inhale, F2 soft peak, F3 return. It uses four equal square cells in a 2x2 sheet, one shared pixel origin, and fixed foot/contact pixels. F0 follows the approved source closely. Later frames change only small breath and requested secondary-motion clusters; the creature is not redrawn or shifted as a whole. COMPLETE mode takes an earlier partial 2x2 sheet or 1x2/1x3 strip and explicit KEEP/MISSING slots; it preserves approved frames and fills only named gaps. Inspect kept cells manually because image generation cannot guarantee exact pixel copies.
- The image contains no grid lines, timing labels, or registration marks. The local converter supplies timing metadata after export.

## Cinderhide-quality review

The [Cinderhide research adoption note](../creatures/cinderhide-sprite-quality-research-adoption.md) adds a practical finish check for every essence. Inspect the creature first as a silhouette at battle size, then inspect its clusters and material planes at nearest-neighbor zoom. Look for planted contacts, a coherent light direction, restrained focal accents, and an identifiable face and torso. Reject accidental confetti pixels, pillow shading, long parallel color bands, fuzzy edges, and a different life stage masquerading as a back view. A purposeful one-pixel feature is allowed. Do not force a fixed 24-color ceiling or a universal warm-light/cool-shadow scheme. Keep the Forge background flat magenta with no baked floor shadow; contact shading belongs within the creature or in Godot's battle scene.

## Review before Godot

1. Save the original Opal image. Compare it with the brief or approved source at nearest-neighbor scale. A prompt cannot guarantee an exact logical grid or unchanged anatomy.
2. For a creature, reject clipped parts, scale drift in same-form views, wrong facing, palette drift, or soft/JPEG-like edges. Keep the original and the reviewed transparent Godot PNG.
3. For an effect, check that all five pieces are separate and consistent. Cut them from the reviewed sheet; the Forge does not automatically import or animate them.
4. For an idle sheet, check the four cells are equal and ordered F0-F3. Compare F0 directly with the approved sprite and inspect the fixed foot anchor. Convert with tools/convert_idle_sheet.py and review every transparent frame and idle_sheet.png before adding it to Godot. Its suggested frame holds are 0.55s, 0.25s, 0.45s, and 0.25s.
5. Keep the current code-driven in-game idle breathing until an approved sheet works at battle size with attack and impact animations.

The research's useful principle is registration: fixed cells, fixed origin, clear frame order, and deliberate timing. The game's usual 100×100 creature target, magenta conversion, dark outline, and restrained breathing remain the production choices, with native-grid exceptions for approved large forms. See opal-sprite-forge-prompt-v6.md, opal-effect-sheet-prompt-v1.md, idle-animation-workflow.md, and sprite-production-board.md for job-specific instructions.

## Vitrecrag exception and scale

Preston approved Vitrecrag's revised 128×128 front and true rear. Both are linked in `data/creatures/108_vitrecrag.tres`; the resource uses `battle_size = 1.75`. Preserve the face, stacked shell plates, furnace detail, planted legs, and form-specific pixel density in future animation. The remaining task is a played battle view review of its size, foot line, and overlap with the HUD. The older [redraw job](../creatures/vitrecrag-redraw-job.md) records the path to the approved design and should not be treated as a new assignment. The research document's proposed height, length, and mass are not verified canon. See [scale research adoption](../creatures/creature-scale-research-adoption.md).
