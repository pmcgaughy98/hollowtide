# Coalcrest full recheck, October 4, 2026

Preston asked for a full-effort recheck of the installed tail/feet/lantern repair. Magnified visual inspection found that the rear-leg repaint still looked like a flat strip, tail material bunched at the proximal transition, and the foot surfaces needed finer texture. Those were corrected rather than treating the earlier green connectivity checks as aesthetic proof.

The new version uses Coalcrest's native skin ramp with coherent curved tail bands and a gradual original-material root transition. The shaded far rear leg reuses original shin texture and small scale clusters; both front feet and the visible far rear foot have finer ankle/toe material, and the lantern ribs have restrained native material highlights. The existing taper, root alignment, hanging organ identity, completed fin/head/upper body, native dimensions and stance remain. No new generated image, RD upload/request/charge or gameplay edit.

## Exact five runtime files

- assets/sprites/creatures/coalcrest_rechecked_2026_10_04/coalcrest_front.png
- assets/sprites/creatures/coalcrest_rechecked_2026_10_04/coalcrest_front.png.import
- assets/sprites/creatures/coalcrest_rechecked_2026_10_04/coalcrest_back.png
- assets/sprites/creatures/coalcrest_rechecked_2026_10_04/coalcrest_back.png.import
- data/creatures/105_coalcrest.tres: two texture paths only relative to the saved pre-session resource.

[Installed hashes](installed-manifest.json), [complete front/back review](review/coalcrest-rechecked-review.png), [before/after](review/before-after.png), [light/dark/neutral mattes](review/matte-review.png), [exact pre-session inputs/resource](sources/).

Front: 350 edited native pixels. Rear: 413. These are localized material/foot refinements of the preceding installed version. They are not whole-creature redesigns.

## Stronger native checks and actual battle evidence

Both views pass all twelve native checks. Tail curl-to-root connectivity is verified within the authored tail corridor, preventing a false pass through another body connection. The 5x5 proximal root contact has all 25 pixels connected in each view. Predetermined edit regions, exact fin/head/upper-body RGBA, native palette, binary alpha, detached edited pixels, white tail fringes, clipped canvas edges, old front stem and rear emitter are checked. [Native results](native-qa.json), [front mask](review/front-authorized-regions.png), [rear mask](review/back-authorized-regions.png).

Both actual battle idle views and six legal attack/view combinations pass, retaining original front 2.0x/rear 2.5x zoom, current textures throughout the run, restored position/texture and released reverse state. Thirty-six intermediate rendered frames were captured and visually inspected: frames 1,15,30,60,90,120 for Crest Signal, Furnace Bolt and Longfire Burst from both sides. These are sampled observations plus continuous texture checks, not a claim of manually inspecting every rendered frame. Plate Rake remains excluded by the existing body gate.

[Battle check records with sampled transforms](runtime-final/runtime-checks.json), [all six close-up timelines](animation-review/), [unobscured front](runtime-final/coalcrest-front-full-sprite-diagnostic.png), [unobscured rear](runtime-final/coalcrest-back-full-sprite-diagnostic.png), [normal front HUD](runtime-final/coalcrest-front-normal-hud-restored.png), [normal rear HUD](runtime-final/coalcrest-back-normal-hud-restored.png).

Only the isolated fixture's HUD controls were hidden during diagnostic attacks to reveal the root/feet; they were restored afterward. No production HUD, battle, animation, move or state file changed. Final game-runtime stderr is empty; the owned fixture exited.

The importer finished before the battle run. It retained the historical unresolved audio-bus UID/editor shutdown diagnostics, recorded separately in the import logs. The current project setting remains byte-exact.

## Preservation and repeatability

2172 of 2173 recorded existing runtime files remain byte-exact. The sole preexisting change is Coalcrest's two texture references; all other properties, rules, move/evolution data, player/battle/world/launch files and existing artwork remain. [Audit](preservation-audit.json). All preceding Coalcrest versions, Kithflare/Wayburn and rejected/draft evidence remain saved.

[Portable native-material builder](tools/rebuild_material.py) reads only this review's sources and writes only its rebuild/ folder. It does not change game files. The pure geometry helper is beside it. Other original fixtures/install scripts are archived for provenance and retain their original absolute paths; do not run those as portable builders.

This is an installed corrective pass with native and visual evidence. It does not declare Preston's final aesthetic approval or the broader world goal complete. No staging, commit, deletion, user-editor control or new paid request. No current implementation blocker.
