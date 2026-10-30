# cx-13 Tower body, 2026-10-27

Five slots / six images pass. Nothing installed.

[Review sheet](review_sheet.png) | [Static overview](overview.png) | [Semantic checks](semantic-checks.json)

- town.building.hall.drum: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C8 PASS, C9 PASS, C12 PASS
- town.building.hall.galleries: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C8 PASS, C9 PASS, C12 PASS
- town.building.hall.hoist: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C8 PASS, C9 PASS, C12 PASS
- town.building.hall.root_vein: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C8 PASS, C9 PASS, C12 PASS
- town.building.hall.chute: PASS; C1 PASS, C2 PASS, C3 PASS, C4 PASS, C5 PASS, C8 PASS, C9 PASS, C12 PASS

Source issues for Claude:
- Shared slots.json remains stale after the later route.gd edit. These unchanged tools use the real candidate-only Godot export at registry 235abb6156b1 with the normal freshness guard; no registry file changed.
- Image_gen returned larger-than-native originals. Every raw image is untouched, with actual prompt, five references, source path, hash and preparation/cleanup receipts. No alternate paid generator used.
- prepare_slot recenters occupied bounds for top_left parts. Exact native blockout registration was restored after preparation where needed; final bytes were then validated.
- Palette snapping collapsed the drum deck into a 29% one-colour region, failing C8. Coherent two-pixel stone courses in the existing palette reduced the largest region to 7%; original raw and initial failed report retained.
- Hoist frame 1 derives from painted frame 0; only 16 sheave pixels change in a 6x6 region. The generated second-frame body remains in raw.png. Rope entry is unchanged at frame (385,488).
- The reference hoist brace contains eight mask pixels without an orthogonal opaque neighbour across both cells. Exact alpha was retained; C9 passes after colour-cluster cleanup. This does not establish a Finish-shader silhouette review.
- Root/chute requests used neighbour bands rebuilt from the checked painted drum/galleries and foot. Their exact masks and frame positions were retained; all three root runs and both chute endpoints were measured.
- No in-game capture, native runtime test or painted-seam approval is claimed. The assembly is static reference art; crown and coded effects remain stand-ins. Nothing installed.
- New slot answers are pending. Next cx-14-tower-crown; cx-10 still waits for crown approval.
