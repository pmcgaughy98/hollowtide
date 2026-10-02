# Route 1: terrain, perspective and crown polish
October 1–2, 2026. This is the current installed art pass on the existing courier assignment; Route 1 remains in progress.

## Current result
Quieter grass, loess path and river materials with curved boundaries and a continuous shoreline use 99 native 16px tiles. All 960 original map cell positions and terrain barriers are retained. Cottonwoods, small shrubs, retaining-wall masonry, reeds, foot contacts and slow river glints share the courier's muted riverbank finish. Actors pass behind crowns by foot-based draw order; trunks and the hall block movement.

The complete cottonwood sprite restores the clipped leaves at both sides. Retro Diffusion extended the original 64px tree into a 96px canvas, and its background tool removed the unwanted matte. Preparation restores all original inner pixels exactly and adds transparent side margins: the final 112 x 96 sprite has alpha bounds [11,9,99,89]. Trunk and foot positions are unchanged. Individual tree variations are still pending at Preston's request.

The dispatcher occupies a practical two-storey brick/timber hall with a centered south-facing entrance, covered porch, three-dot plaque and map board. The existing design proposal describes that building at docs/forges/world-asset-forge-prompts-2026-09-30.md:41; Preston authorized making the intended dispatcher building while retaining the house he liked. The front-facing house remains a reusable saved asset. Working names remain proposals. A stray miniature figure was removed from the hall using its adjacent brick pattern, with all pixels outside the small repair region preserved.

The camera keeps the map bounded while looking 48 world pixels ahead. The route readout moved to the upper right so it does not obscure the hall roof. Dialogue and report choices fit the bottom of the viewport and expand upward.

## Runtime
- scenes/first_route_prototype.tscn and inherited first_route_female_preview.tscn.
- scripts/route1_map_polish.gd: contacts, water glints and prop footprints.
- scripts/field_creature.gd: optional eight-cell field idle; Cinderhide reuses its approved softer menu atlas.
- assets/tilesets/route1_rd_2026_10_01/route1_ground_polished.tres and route1_ground_atlas_polished.png.
- assets/sprites/world/route1_rd_2026_10_01/: cottonwood_complete.png, dispatch_hall.png, retained wayline_office_front.png and other prepared route props.

## Review and source records
review/final_start.jpg shows the current opening, hall and courier. review/final_bank.jpg shows the river side. review/final_complete.jpg and final_assignment_log.json prove the completed assignment. Earlier office screenshots preserve the before/after perspective review. Scene/script snapshots end in .txt to prevent the archive being imported as runnable resources.

raw/ retains the original three prop generations, front house, tree outpaint, cleaned tree and rejected split hall. prepared/ retains the terrain, complete crown, hall preparation and comparisons. source/ contains terrain/scene preparation, original cell data and installation snapshots. The exact office/hall/tree prompts and receipts are also in source/ alongside the three terrain-prop prompts in PROMPTS.md. archive_file_manifest.json records source and copied-file hashes.

The three prop receipts were recovered from their existing request IDs after an app restart. The final live assignment was rerun and its log captured. Large capture bundles exceeded the bridge's request limit, so final screenshots were saved as individual records.

## Known charges
Combined pass: $2.17, including the earlier $1.14 pass, $0.30 props, $0.18 approved front house, $0.36 for two hall jobs (first rejected), $0.18 foliage outpaint and $0.01 background cleanup. This is recorded successful charging, not an account-balance estimate. No paid rerun was needed to recover prop outputs or receipts.

## Limits and next polish
Preston's next tree work is small individual crown/branch/color variations; no rush. Hall window and trough readability, dedicated chibi idles, interiors and broader route composition remain. The complete assignment does not make the full route finished.

The fresh diagnostics have zero observed errors and eleven pre-existing warnings. Earlier transient import errors are archived separately. Original assets and shared battle work are preserved. See ../route1-rd-first-pass-2026-10-01/CHANGED_FILES.md for this pass's exact file list.
