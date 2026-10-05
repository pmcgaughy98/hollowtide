> Current Coalcrest texture references now use the [full-effort visual recheck](../coalcrest-full-recheck-2026-10-04/README.md), which corrects the remaining material/foot issues. This earlier artwork and evidence remain preserved.

# Coalcrest refinement, October 4, 2026

Preston requested a less bulky/even attached tail, front-foot and lantern cleanup, then identified the faint incorrect shape at the left rear leg and a rear-tail alignment/left-foot problem in the first draft. The final installed version aligns the rear curl with the original root and band phase, tapers the distal tails, repaints both front feet and the visible far rear foot, removes the emitter-shaped rear-leg contour, and refines the original hanging organ's rounded cage and warm glow. The far-leg layer is behind the tail, so cleaning the foot cannot cut the root.

This supersedes Coalcrest's October 3 tail-root version only. Kithflare and Wayburn remain on their preceding polish. Completed fin/head/upper body, original PNGs, native 160x160 cells, data/rules/properties, battle code/scale/launch settings and world work are preserved. Native original-material pixel editing was used; no new RD upload, request or charge.

## Exactly five runtime files

- assets/sprites/creatures/coalcrest_refined_2026_10_04/coalcrest_front.png
- assets/sprites/creatures/coalcrest_refined_2026_10_04/coalcrest_front.png.import
- assets/sprites/creatures/coalcrest_refined_2026_10_04/coalcrest_back.png
- assets/sprites/creatures/coalcrest_refined_2026_10_04/coalcrest_back.png.import
- data/creatures/105_coalcrest.tres: only two texture paths compared with the preserved pre-session resource.

[Exact installed hashes](installed-manifest.json), [pre-session sources/resource](sources/), [full-sprite 3x review](review/coalcrest-refined-review.png), [before/final comparison](review/draft-comparison.png).

## Native and battle verification

Both native audits pass: changes stay inside predeclared tail/organ/foot/leg regions; fin/head/upper body stay exact; alpha remains binary; no detached edited pixels or clipped canvas edges; the tail, organ, roots and feet form one four-neighbor component; the old front stem is absent; the rear-leg bright remnant is removed. The free lower-curl occupancy in the fixed region x=7..56,y=113..143 decreases from 712 to 473 pixels front and 699 to 453 rear. This is a local silhouette measurement, not a claim about the entire creature's scale.

[Native audit and authored regions](native-qa.json), [front authorized regions](review/front-authorized-regions.png), [rear authorized regions](review/back-authorized-regions.png), [reproducible native functions and build](tools/).

Both actual battle idle views and all six currently legal attack/view combinations pass. Crest Signal, Furnace Bolt and Longfire Burst retain the installed texture during animation, restore texture and position, and release reverse state. Plate Rake remains excluded by the existing body gate. Front 2.0x and rear 2.5x zoom are preserved. Full-sprite diagnostic captures hide only the isolated fixture's HUD controls and then restore them; production HUD/code is unchanged. Final runtime stderr is empty and the owned fixture exited.

[Runtime checks](runtime-final/runtime-checks.json), [normal front battle](runtime-final/coalcrest-front-idle.png), [normal rear battle](runtime-final/coalcrest-back-idle.png), [unobscured front](runtime-final/coalcrest-front-full-sprite-diagnostic.png), [unobscured rear](runtime-final/coalcrest-back-full-sprite-diagnostic.png).

The headless editor import completed before the battle test. It reported the preexisting unresolved audio-bus UID and editor shutdown warnings; those logs are retained. These diagnostics did not occur in the final battle runtime, and the user setting was preserved.

## Iterations and preservation

The first preserved draft had an organ-rectangle overlap cutting the upper curl. It was corrected before installation by erasing only the original organ's occupied pixels and rebuilding the complete curve. The user then requested better rear alignment and left-foot work. Native source centerline/band phase, finer foot contours and rear-layer occlusion were corrected before the final import/probe. Intermediate artwork is retained for comparison; no intermediate draft is the current installed reference.

2168 of 2169 recorded existing runtime files remain byte-exact. The one changed preexisting file is 105_coalcrest.tres, whose only semantic change is the two texture references. No previous art was deleted or overwritten, no staging/commit and no user-editor control. [Preservation audit](preservation-audit.json).

The world goal remains active. Historic-frontage proposal files stay in the Codex work folder with no generation/upload/charge. No current blocker prevents further work. Installed/native-verified is not a substitute for Preston's final aesthetic judgment.
