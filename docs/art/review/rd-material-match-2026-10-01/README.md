# New creature material consistency pass

Applied October 1, 2026 to Claude's current Retro Diffusion Kithflare, Wayburn, Coalcrest, Fusern, Slagglass and Vitrecrag forms after Preston explicitly reopened creature work.

Each form's approved front is its material reference. Front pixels are unchanged. Rear and eight-angle views now use that front's stone, ochre, plum, heat and outline ramps, with narrow light-facing facets on broad planes. This addresses flat rear surfaces and differing material colours while retaining the approved anatomy. The outline, silhouette, alpha, canvas size and contact points are preserved. The scripts do not add speckle or invent new plates, limbs or seams.

Thirty versioned runtime PNGs are in assets/sprites/creatures/rd_material_match_2026_10_01/: front, rear and eight-angle sheet for each of six forms, plus twelve Vitrecrag attack frames. All source sprites remain at their original paths. The six CreatureData resources point to the matched front/rear versions. Molten Glass, Molten Cannon and Plate Lunge reference the matched attack frames with their existing timing and gameplay settings.

prepared/material_manifest.json records source/output hashes, changed colour counts, alpha checks and dimensions. Every image reports zero alpha changes. source/match_creature_materials.py reproduces the preparation from the retained project sources.

scenes/rd_material_review.tscn is a runnable battle review: keys 1 through 6 choose Kithflare, Wayburn, Coalcrest, Fusern, Slagglass and Vitrecrag. It uses a temporary party inside that run. Review controls stay active while the battle pauses the world. Use the normal move buttons to inspect attacks.

All six forms were viewed in the actual battle from front and rear. Vitrecrag's three rewired moves were exercised through normal battle controls; live state records are saved alongside the screenshots. The existing near-side battle cropping and each form's configured battle size are retained.

This is a texture pass. It does not reconstruct any direction's anatomy. In particular, Wayburn's eight-angle source predates Claude's separate front-snout outpaint; the preserved angle sheet still needs its own anatomical review if that becomes the next requested step. No stats, evolution rules, moves or canon were created by this pass.
