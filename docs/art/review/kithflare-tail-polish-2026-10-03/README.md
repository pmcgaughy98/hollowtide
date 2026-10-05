# Kithflare line tail texture and anatomy polish, October 3, 2026

> Coalcrest FRONT/BACK are superseded by the [tail-root correction](../coalcrest-tail-root-repair-2026-10-03/README.md), following Preston's clipped-root, old-stem and rear-alignment feedback. Kithflare and Wayburn still use this polish set. The earlier connectivity/foot-rectangle checks missed those specific problems; this record is retained as historical evidence.

Preston asked to fix the revised Kithflare/Wayburn/Coalcrest sprites so the anatomy, outlines and textures look legitimate. This is the current installed six-view version, superseding the [initial attached-tail set](../kithflare-tail-attachments-2026-10-03/README.md). That earlier art and proof remain preserved.

## Actual changes

- Coalcrest FRONT: restored the original hind foot/toes. The preceding rectangular tail mask clipped 71 RGBA pixels in its foot area; this review now guards the complete native foot rectangle separately.
- Coalcrest BOTH views: replaced the stretched, sparse tail surface with native brown band/plate spacing. The rear uses its original tail material; the front follows the same native band rhythm with its own authored brown palette. Original banded lantern pixels and the completed front sail remain exact.
- Coalcrest REAR: lifted the bottom bend by two native pixels, restoring its original sprite-bottom bound rather than letting the tail dip below it.
- Kithflare FRONT/BACK and Wayburn BACK: removed buried dark contours inside widened lantern collars, using adjacent original skin pixels while keeping the external silhouette/outline and the original light organs.
- Wayburn FRONT: inspected and verified the existing rounded curve and retained it byte-identically. All six views are packaged in the same new version folder; five contain additional pixel changes.

No new generated artwork, upload or paid request. This polish costs $0.00. The earlier approved $0.18 RD attempt and its rejected output remain in the initial attachment record. Original approved source PNGs, prior attachment PNGs and historical review material are preserved.

## Verification and limits

Six native checks pass: opaque four-neighbor lantern-to-body paths, a single eight-neighbor silhouette per view, exact original light organ pixels, binary alpha, native canvas dimensions and exact RGBA outside the authorized tail masks. Coalcrest's completed sail and restored foot have separate exact-pixel guards. These checks measure real native pixels and do not substitute for aesthetic review.

Fresh actual battle verification passes all six front/rear idle views and 22 attack runs. Kithflare and Wayburn use their four existing moves from each side; Coalcrest uses its three existing legal moves from each side. Plate Rake remains excluded by the current body gate. Textures stay installed during the attacks, original zoom is retained, sprite position/texture restore and reverse state releases. Final runtime stderr is empty. Current Coalcrest move origins are crest/throat; no tail-emitter rule was changed.

Protected baseline: 2146 existing runtime files; 2143 remain exact. Only three preexisting creature resources change, solely their front/back texture paths. No battle architecture, creature/move rule, world, save, project launch or audio setting edits. The user editor was not stopped or controlled. No staging, commit or deletion. Native pixel QA and battle frames are under review/; installed copies and exact hashes are in installed/ and runtime-manifest.json.

## Exact runtime files

- assets/sprites/creatures/kithflare_tail_polish_2026_10_03/kithflare_front.png
- assets/sprites/creatures/kithflare_tail_polish_2026_10_03/kithflare_back.png
- assets/sprites/creatures/kithflare_tail_polish_2026_10_03/wayburn_front.png
- assets/sprites/creatures/kithflare_tail_polish_2026_10_03/wayburn_back.png
- assets/sprites/creatures/kithflare_tail_polish_2026_10_03/coalcrest_front.png
- assets/sprites/creatures/kithflare_tail_polish_2026_10_03/coalcrest_back.png
- data/creatures/103_kithflare.tres
- data/creatures/104_wayburn.tres
- data/creatures/105_coalcrest.tres
- assets/sprites/creatures/kithflare_tail_polish_2026_10_03/kithflare_front.png.import
- assets/sprites/creatures/kithflare_tail_polish_2026_10_03/kithflare_back.png.import
- assets/sprites/creatures/kithflare_tail_polish_2026_10_03/wayburn_front.png.import
- assets/sprites/creatures/kithflare_tail_polish_2026_10_03/wayburn_back.png.import
- assets/sprites/creatures/kithflare_tail_polish_2026_10_03/coalcrest_front.png.import
- assets/sprites/creatures/kithflare_tail_polish_2026_10_03/coalcrest_back.png.import

Handoff updates: docs/AI_COLLABORATION.md and the preceding attached-tail README point here. This is an installed polish pass with local visual/runtime review, not a claim of final aesthetic approval or a complete game/world.
