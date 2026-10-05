# Coalcrest front-fin repair, October 3, 2026

Current front/back resource references now use the [attached-tail version](../kithflare-tail-attachments-2026-10-03/README.md). The fin PNG below remains preserved exactly, and its completed sail is retained in the new front sprite.

Installed front: assets/sprites/creatures/coalcrest_front_fin_complete_2026_10_03.png.
Only the front texture path in data/creatures/105_coalcrest.tres changed. The original front PNG, rear PNG, body, badge, stats, moves, battle size, aiming points and battle code remain exact.

Preston explicitly authorized retrying the prepared fin-only crop/mask. This supersedes the prior pending approval. The $0.18 inpainting call timed out at the MCP transport's 120-second limit; the already-successful result was recovered from official API Activity without resubmission or another charge. Activity request 5bf05598-00cb-4e9e-a385-11aea22eb12b records succeeded, charged true, balance_cost 0.18. The previous $0.18 full-body candidate remains rejected and preserved.

Preston approved the new fin's position and shape, then requested original texture/design matching and a final small touchup. The raw generated strip was coarser than the authored sail. The installed tip retains the approved alpha outline and uses radial, nearest native samples from the original membrane/ribs. The earlier material cleanup changed 131 new extension pixels. Preston then requested fixing the black line at the back and the top black outline. The installed contour finish removes the obsolete clipped-border seam inside the sail and uses its existing dark palette for a continuous one-native-pixel top rim. This final pass changed 138 pixels from the preceding material finish, including 64 formerly visible source-edge pixels within the requested fin region. No additional image generation was used for these texture/contour finishes.

Final contour audit: 368 added visible pixels; 64 original visible edge pixels retextured within the authorized fin mask; zero changes outside that mask. The approved occupied silhouette remains exact, with the same 160x160 canvas and 3px clear top border. Earlier zero-existing-pixel-change audits describe the preserved intermediate material stages. The generated output, first palette composite, original-material variants and final finish remain in review for comparison.

Actual native battle verification passes far-front and near-rear idle plus Crest Signal and Longfire Burst from both sides. Front zoom remains 2.0 and rear zoom 2.5. Correct textures/positions restore, reverse state releases, and the repaired front stays in use during both front attacks. Rear texture remains the original. Final contour runtime stderr is empty; its battle frames and results are in review/contour-runtime. Earlier material-stage runtime evidence remains in review/final-runtime. Initial fixture logs are preserved: it stalled after clearing tree pause between casts; the fixture was corrected without changing battle code.

## Exact game files

- assets/sprites/creatures/coalcrest_front_fin_complete_2026_10_03.png
- assets/sprites/creatures/coalcrest_front_fin_complete_2026_10_03.png.import
- data/creatures/105_coalcrest.tres

Source/resource backups, masks, prompts, sanitized generation/recovery receipts, pixel audits, comparison images, native battle frames and runtime results are in review. Installed byte hashes are in runtime-manifest.json. Prior pending handoff is retained as README-before-approved-retry.md. This repair used one additional $0.18 attempt; combined with the earlier rejected attempt the fin generation total is $0.36.
