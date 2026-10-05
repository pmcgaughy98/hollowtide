# Coalcrest front-fin repair, October 3, 2026

Installed front: assets/sprites/creatures/coalcrest_front_fin_complete_2026_10_03.png.
Only the front texture path in data/creatures/105_coalcrest.tres changed. The original front PNG, rear PNG, body, badge, stats, moves, battle size, aiming points and battle code remain exact.

Preston explicitly authorized retrying the prepared fin-only crop/mask. This supersedes the prior pending approval. The $0.18 inpainting call timed out at the MCP transport's 120-second limit; the already-successful result was recovered from official API Activity without resubmission or another charge. Activity request 5bf05598-00cb-4e9e-a385-11aea22eb12b records succeeded, charged true, balance_cost 0.18. The previous $0.18 full-body candidate remains rejected and preserved.

Preston approved the new fin's position and shape, then requested original texture/design matching and a final small touchup. The raw generated strip was coarser than the authored sail. The installed tip retains the approved alpha outline and uses radial, nearest native samples from the original membrane/ribs. A final material cleanup changed 131 of the new extension pixels. No additional image generation was used for those texture finishes.

Final audit: 368 added visible pixels, zero previously visible source pixels changed, zero changes outside the supplied fin mask, approved outline exact, 160x160 canvas and 3px clear top border. The generated output, first palette composite, original-material variants and final finish remain in review for comparison.

Actual native battle verification passes far-front and near-rear idle plus Crest Signal and Longfire Burst from both sides. Front zoom remains 2.0 and rear zoom 2.5. Correct textures/positions restore, reverse state releases, and the repaired front stays in use during both front attacks. Rear texture remains the original. Final runtime stderr is empty. Initial fixture logs are preserved: it stalled after clearing tree pause between casts; the fixture was corrected without changing battle code.

## Exact game files

- assets/sprites/creatures/coalcrest_front_fin_complete_2026_10_03.png
- assets/sprites/creatures/coalcrest_front_fin_complete_2026_10_03.png.import
- data/creatures/105_coalcrest.tres

Source/resource backups, masks, prompts, sanitized generation/recovery receipts, pixel audits, comparison images, native battle frames and runtime results are in review. Installed byte hashes are in runtime-manifest.json. Prior pending handoff is retained as README-before-approved-retry.md. This repair used one additional $0.18 attempt; combined with the earlier rejected attempt the fin generation total is $0.36.
