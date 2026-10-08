# Slagglass redesign (2026-10-08)

**Preston:** "We're gonna have to make a new Slagglass, it doesn't fit Fusern or Vitrecrag's style with the claws and not looking tank-like." Asked which way, he chose **"beetle growing a kiln"**: Fusern's brick beetle grown bigger and heavier, its shell rising into a rough dome with the first cracks of the crater opening on top, six stubby armoured legs, no claws.

## Rounds
- **Round one** (`slagglass_front_take1..3.png`, $0.54): Retro Diffusion `rd_pro__default`, 192 px, Fusern and Vitrecrag fronts as references, prompt for a form between them. Came back as a Fusern-style brick beetle and two near-copies of Vitrecrag's tortoise. Preston: "don't even look close to what we want."
- **Round two** (`slagglass_v2_front_take1..3.png`, $0.54, strip `candidates_v2.png`): the prompt rewritten as Fusern grown up (same head and bricks, tall dome, crater cracks opening at the top, molten seams). All three landed the brief. **Preston chose take 2** (the tallest dome, dark brick bands, kiln eye low under the shell).

## Where it lives now
- The chosen front: `assets/sprites/creatures/slagglass_redo_2026_10_08/slagglass_front.png` (192 px, the raw RD take; **Codex:** not palette-locked).
- **Arena:** the old arena take and rotation sheet moved to `docs/creatures/arena-starters-2026-10-07/forms/old_slagglass/`; a new top-down take (112 px), rotation sheet and five walk cycles are generated from the new front with the usual tools, and `assets/sprites/arena/slagglass/` is rebuilt from them (the Codex colour-fixed facings of the old design are replaced).
- Arena stills of the result: `arena_stage2.png` (Slagglass against Clinkerhide), `arena_walk.png` (a 3v3 in motion; the white flash in it is the top boulder shattering, not the sprite), `arena_stage1/3.png` for Fusern and Vitrecrag beside it. Check: `tools/debug/arena_slagglass_still.gd`.
- **Turn-based data (`data/creatures/107_slagglass.tres`) still points at the old front and back** in `rd_material_match_2026_10_01/`. The back view and 8-direction sheet for the new design are not made yet (the back-view method: `finish_back.py` from a rotation cell); switching the front alone would mismatch the back. A later slice.
