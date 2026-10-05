# Coalcrest front-fin review, October 3, 2026

Preston initially said rear fin, then corrected FRONT. The active 160x160 front source is assets/sprites/creatures/rd_material_match_2026_10_01/coalcrest_front.png. Its upper sail edge is cut flat in the source image. It is not a battle viewport crop. The rear sprite, body, pose, stats, moves, battle scale and aiming points are outside the repair scope.

Preston explicitly approved upload of the current front sprite and fin-tip mask at the quoted $0.18. RD inpainting returned inference inf_be1OW29mXj4NYQn29mbQvzBZ6gl5DyKR, charged $0.18. It changed the entire body/pose and flattened the background to checkerboard: 24,216 pixels outside the requested mask changed. The result was rejected and is retained as rd-approved-output.png. No runtime art or creature resource was changed.

A smaller 64x48 crop (original coordinates x54..117, y0..47) isolates the sail and a small existing head fragment, with a flat magenta working background. fin-only-mask.png isolates the same upper-rim repair. fin-only-prompt.txt explicitly specifies the original profile and rib registration. After generation, only the validated fin region will be composited into the original; every unmasked RGBA pixel must remain exact.

This second attempt was estimated at $0.18 but automatic approval review rejected sending the derived crop/mask and incurring an additional charge without explicit authorization. A user approval request is pending. There was no second generation or charge. Do not work around the rejection or install the first candidate.

Exact source/resource backups, mask, original prompt, derived crop/mask, revised prompt, rejected output, generation records and byte hashes are saved here. No API keys or signed URLs are included. Native battle/animation verification is still required after an acceptable approved result.
