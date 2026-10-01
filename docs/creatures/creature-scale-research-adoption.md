# Complete Creature Dex Generation: Hollowtide adoption notes

Source: `C:/Users/pmcga/Downloads/Complete Creature Dex Generation.docx`, supplied 2026-09-26. This file is an outside research proposal, not project instructions or established canon. The [review table](creature-scale-proposals.csv) keeps 60 roster rows without changing live resources. Preston replaced the old Nature starter with Preostmar → Oathfen → Oxbowarchon; rows 040–042 now have blank scale fields because the earlier seed-burrower measurements do not describe a river-island turtle. The original research document remains in Downloads as the source.

## Adopt now

- Separate **physical scale in the world** from **compressed presentation in battle**. A giant should retain giant anatomy, material structure, contact weight and composition cues even though its whole body must fit the battle stage.
- Keep the existing 20 three-stage lines and 60 names. Most source rows align with those names and offer scale proposals. Rows 040–042 now represent the new Nature starter and await fresh measurements.
- For Vitrecrag, use the proposed giant range as a design starting point: roughly **12–15 m high** and **18–22 m along the shell** in the world. This is a working range, not an exact claim about its biology. It should feel comparable to a building or bluff face, while its battle sprite remains legible.
- Preserve the current Vitrecrag's low face, forward crest, stacked dark-plum shell, internal furnace and fortress-arthropod silhouette. Redraw that **same form** with six visibly attached, weight-bearing pillar legs and more detailed broken-glass planes. Use approved Cinderhide as the pixel-craft benchmark, not as an anatomy or palette template. The revised Slagglass brief should grow toward this established final-form identity.
- Retain the already-set `battle_size = 1.75` for now. The current art is the main reason Vitrecrag feels too small. Evaluate the new sprite in context before any further zoom or camera change.

## Keep as proposals

The table's heights, lengths, masses, `battle_size` and `idle_breath` values are **unapproved per-form proposals**. Its first column is a row number, not a Godot creature ID; live IDs must not be reassigned. `source_length_m` is inconsistent across body length, shell extent and wingspan. Do not import that column as a uniform `length_m` field. The exact 14.5 m height matches Wailord's familiar number; Hollowtide should choose its own final value from world and battle design. The 2,450-ton mass is an unverified calculation and should not drive stats, ecology, animation or dialogue yet.

The document claims dynamic camera panning and specific resource-duplication safeguards are required. The current game has its own battle framing and stores combat HP separately from base creature resources. Review any camera or architecture change against that implementation before coding. The proposed `idle_breath = 0.012` is a useful motion reference, but the live Vitrecrag value is `0.014`; adjust only after seeing the redesigned body animate.

## Visual acceptance for the new Vitrecrag front

1. At 100x100 logical pixels, its silhouette reads as a fortress supported by six thick legs, with a planted nearest foot and broad contact footprint.
2. Its shell has layered planes, chipped edge clusters, soot and copper breaks, and controlled furnace windows at Cinderhide's level of finish. The detail describes volume rather than filling the sprite with noise.
3. The head stays small under the carapace. A small controlled tongue of heat may remain at the forward vent, but no dominant flame fan, crystal sparkle, mascot beetle face or crab pincers.
4. Beside Cinderhide in a battle view, the player reads Vitrecrag as a much larger creature compressed into frame. The HUD and action area stay readable.
5. The new front is approved before making its back, replacing its game PNG or tuning the camera.

## Research needed

See [Gemini deep research queue](../research/gemini-deep-research-queue.md) for source-checked questions about giant scale, battle composition and material rendering. Keep conclusions labeled as evidence, inference or creative proposal.
