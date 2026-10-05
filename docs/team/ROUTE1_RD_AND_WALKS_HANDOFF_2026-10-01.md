# Hollowtide walking, creature materials and Route 1 handoff

## Latest Route 1 landscape pass (October 2 evening, 2026; October 3 UTC)

Preston asked to keep refining Route 1 toward Nexomon/Coromon quality, then expanded the active goal to the Hollowtide game world and map levels, using St. Joseph as inspiration and original fictional names/style. The menu-only handoff is historical; the current authorized work is the world/Route 1. The broader goal remains active and is not claimed complete.

Installed: fifteen approved-variant cottonwoods in groves, varied city trees, small meadow tufts/thickets, reeds, stones, exposed-root details, irregular damp shore margins, subtle grass color variation and one-native-pixel foliage wind. Actual canopy/contact shadows replace the older generic extras; older sideways glints were removed so the existing river current retains one direction. A dense initial grass layout and oversized root candidate were reviewed at normal gameplay scale and revised. All candidates and original outputs remain saved.

Runtime changes: `scripts/route1_crossing.gd`, `scripts/route1_map_polish.gd`, new `scripts/route1_landscape.gd`, six exact RD PNG output copies and two shaders in `assets/sprites/world/route1_landscape_2026_10_03/`, plus normal import/UID metadata. The larger `silt_roots.png` is retained source; the smaller output is rendered. Existing quest script/scene, menu, repaired bridge, water sources, creature assets and Claude/Grok work are preserved.

Fresh ordinary-control verification completed the pouch assignment, levee sign, bridge/city arrival and direction board, post delivery, high-water marks, two calls, marker repair and full dispatcher report. Every corresponding flag was true; no teleports/flag overrides were used for that trip. Overviews and motion view are clearly marked review fixtures. Final game diagnostics: zero errors, twelve existing battle/effect/Rimefin warnings. The cold archive editor separately logged the previously documented default-audio-bus UID/empty-resource-save-path pair; all 49 byte-checked copies succeeded. Owned test instances are stopped. No Route 1 implementation blocker.

Five completed RD jobs produced six assets, confirmed charges **$1.08** for this pass. Account balance last checked at 03:12 UTC was approximately **$1.37**; concurrent activity means balance deltas are not a cost ledger. No paid job should be resubmitted. Exact saved prompts, sanitized receipts, hashes, before/current sources, before/after gameplay captures, motion GIF, final quest flags and replay inputs are archived. Optional Summer library feedback was blocked by automatic approval review because it would export project notes/session metadata; no workaround was attempted.

[Latest exact files and verification](../art/world/route1-landscape-2026-10-03/README.md). Next priorities are readable levee slopes/path contours, purposeful optional exploration, actual hometown/city transitions and distinct city-sector architecture; [world design checkpoint](../art/world/route1-landscape-2026-10-03/WORLD_DESIGN_NEXT.md). Route 1 is still in development. Codex owns Route 1/environment; Claude owns battle/save/state; Grok owns future creature/move design. No staging, commits or deletions.

## Latest Route 1 refinement: repaired bridge peg and flowing river (October 2, 2026)

Preston identified the lower peg immediately right of the one below the character. One Retro Diffusion masked inpainting edit completed its outline and foot. The installed sibling `river_bridge_peg_fixed.png` is 288x112; exactly 107 pixels changed inside x=160..175, y=78..95. All other pixels match the previous accepted bridge, which remains saved. Deck, supports and foreground registration keep their positions.

The existing approved teal water now flows slowly downward at two native pixels per scene second with sparse moving highlights. A nearest-filtered 2D canvas shader animates a fixed mask of existing water pixels, preserving the dry bank and grass contour. Runtime changes: `scripts/route1_crossing.gd`, the sibling bridge PNG, `river_water_native32.png` (unchanged approved water copy) and `river_flow.gdshader`, plus normal import/UID metadata. The route scene, quest script, collisions, city props and roads are unchanged.

A fresh ordinary-control round trip accepted the pouch, read the levee sign, crossed to the city courier and returned to (48,192). Actual probes confirm water movement from offset (0,17) at 8.9s to (0,26) at 13.4s, with the player stationary; sampled bridge/land capture regions remained identical. Final observed diagnostics: zero errors, eleven existing battle/Rimefin warnings. The archive child editor booted cleanly. A five-second GIF of actual game captures is saved. Owned test instances are stopped. No blockers for this refinement.

Confirmed RD charge $0.18; remaining balance $3.08. No paid generation for the river. Cumulative saved bridge work costs $1.47. Grok's creature/move ownership and Claude's battle/save/state ownership remain intact. Route 1 is still a prototype; further bank dressing, hometown and city-sector work remain.

[Exact files, source/art preservation, prompts, paid receipt, motion preview and verification](../art/world/route1-crossing-2026-10-02/peg-and-river-flow/README.md). Previous bridge sources and revision records remain saved.

## Latest Route 1 refinement: coherent bridge supports and city landing (October 2, 2026)

Preston said the crossing still needed refining. The pasted-looking corner extensions have been replaced with paired Retro Diffusion stone supports. The accepted right support is mirrored for the other bank; the inconsistent left edit was rejected and archived. Protected original wood/deck/rail pixels retain their positions and colors, with three pure-white rail speckles cleared to alpha. The new sibling `river_bridge_refined.png` is 288x112; no opaque pixel reaches its canvas border.

The east-bank landing now starts at 26px, widens into the existing 48px approach, and uses the same approved soil texture at the same world-coordinate phase as the west levee road. Turf/soil edges and small corner rounding replace the abrupt square tile joins. Game changes: `scripts/route1_crossing.gd` and the new PNG/import metadata. Existing quest script, authored route scene, camera and saved menu sources are preserved.

The final normal-control round trip accepted the pouch, read the levee sign, crossed and registered with the city courier, then returned to (48,192). Final observed diagnostics: zero errors, eleven existing battle/Rimefin warnings. Intermediate cold editor preparation logged a stale UID/empty save path; later archive boot was clean and final gameplay had no errors. RD cost $0.37 including the rejected edit, remaining balance $3.26. No blockers for this slice; owned offscreen instances stopped. No staging or commit.

[Exact changes, before/after images, prompts, requests, receipts and verification](../art/world/route1-crossing-2026-10-02/bridge-abutment-refine/README.md). This supersedes the prior completed-corner bridge artwork; the originals and prior revisions remain saved. Route 1 is still a prototype. Shoreline continuity, bank dressing, the actual hometown and city sectors remain further work. Grok's creature/move ownership and Claude's battle/save/state ownership still stand.

## Latest Route 1 correction: complete bridge corners and joined road (October 2, 2026)

Preston reported clipped upper/lower bridge corners and a road start that did not match the hometown lane. All four stone corners are now completed with Retro Diffusion, with clear transparent canvas edges and the original 256x80 core preserved exactly. The complete lower rail and stone feet are registered in the foreground without moving the deck.

The road entrance now shares the old lane's 48px opening, tapers to a 26px crest, and joins the original path mask before its turf and earth borders are drawn. It uses the approved native 32px soil texture at the same world-coordinate phase. Runtime changes: `scripts/route1_crossing.gd`; added `assets/sprites/world/route1_crossing_2026_10_02/river_bridge_complete.png` and `path_soil_native32.png`. Original artwork, route scene and quest script remain unchanged.

A fresh normal-control walk accepted the pouch, read the levee sign, reached and registered with the city courier, and returned home. Final runtime debugger and project/script validation: zero errors; eleven existing battle/roster warnings. One historical console preload error during staged asset installation was resolved and final cold compilation passed. RD spend $0.74, including retained rejected trials; remaining balance $3.63. No blocker for this correction. No staging, commit, battle/creature edits, or user-game interruption.

[Exact changes, final/before images, prompts, receipts and verification](../art/world/route1-crossing-2026-10-02/complete-bridge-junction/README.md). This supersedes the older bridge-source and road-junction details below. Final world names, the actual hometown map and city sectors remain separate future work; Grok's creature/move ownership and Claude's battle/save/state ownership still stand.

## Latest Route 1 correction: bridge approaches and road grounding (October 2, 2026)

Preston reported that the steps did not reach across the river and the new road looked out of place/levitating. The bridge and foreground rail are now centered over the water, with both stone approaches overlapping dry bank by 16px. The crest road connects to the hometown path, eases its bends and uses existing soil colors, narrow turf edging and softly shaded grass shoulders. The detached shadow and leftover western dirt fragment were removed. Only `scripts/route1_crossing.gd` changed in the game; original art, scene, quest, collision and camera settings remain.

The final normal-control walk crossed to the city courier and returned home. Latest combined diagnostics: zero errors, ten existing battle warnings. Temporary MoveGate errors in concurrent open battle edits cleared by the final diagnostic read. No battle code was edited. No paid generation, staging, commit or deletion occurred. [Exact correction, captures and evidence](../art/world/route1-crossing-2026-10-02/bank-road-fix/README.md). This latest record supersedes the initial bridge placement/road rendering described below.


## Latest playable crossing, October 2, 2026

Preston confirmed and authorized the fictional hometown on the west bank → Route 1 levee entrance → bridge → fictional city on the east bank. The first playable connection is now installed: dispatch-lane exit cue, broad grassy crest road, river bridge, city courier branch/clerk and direction board. Descriptive labels are placeholders; real-world names remain research references and final Hollowtide names remain open. Full hometown and city-sector maps are still future work.

World bounds are 1024×640. The original 40×24 authored terrain and original courier quest sites/code are preserved. The river is blocked outside the bridge corridor. The whole home-to-city-to-home trip and courier assignment passed through real movement/input; both report choices passed, with a report_done-only fixture for the alternate choice. Final observed diagnostics: 0 errors, 11 existing warnings. All disposable game instances were stopped.

One Retro Diffusion bridge still cost $0.18, remaining balance $4.37 at receipt. [Current implementation, captures and validation](../art/world/route1-crossing-2026-10-02/README.md); [exact changed files](../art/world/route1-crossing-2026-10-02/CHANGED_FILES.md). The city branch and clerk temporarily reuse approved hall/female art. No menu, creature/battle or launch-setting edits were made.

[Current hometown/route/bridge plan](../world/route1-bridge-and-city-sector-plan-2026-10-02.md); [verified research](../research/st-joseph-city-sectors-2026-10-02.md). Earlier Highbank/far-bank destination proposals are superseded where their geography conflicts.

## Current authorization
Preston reopened gameplay walking, Claude's Vitrecrag/Coalcrest line materials, and Route 1 using Retro Diffusion. He approved the male left walk as the pose/size reference, supplied Nexomon and other map references for finish and perspective, requested complete tree crowns and individual prop variations, and asked for the building intended for the dispatcher. His October 2 map references and request to synthesize existing St. Joseph/Hollowtide files now guide the route geography and landing details. These instructions supersede older menu-only and shelved-Vitrecrag notes.

Menu research is complete. The Courier Lookout decision and saved menu work remain. Preston runs Gemini Deep Research; prepare research prompts only when requested.

## Earlier installed baseline, preserved
- Both approved chibi couriers use all eight walking directions, eight frames per second. Male right and up-right exactly mirror the approved left and up-left frames. Original atlases remain. The female preview selects the existing Female model.
- Kithflare, Wayburn, Coalcrest, Fusern, Slagglass and Vitrecrag use consistent material ramps across rear/angle views. Front pixels and all silhouettes/alpha are preserved. Vitrecrag's twelve prepared attack frames share the finish; original gameplay values and Claude's work were retained.
- Route 1 has quieter native 16px terrain, curved path edges, loess shoreline, layered cottonwoods, shrubs, masonry, reeds, contact shadows and slow river glints. The active atlas is route1_ground_atlas_polished.png with the 99-tile route1_ground_polished.tres. All 960 cell positions and the river barrier remain.
- Seven individual complete cottonwood crowns, eight shrubs, six reed arrangements and two masonry sections replace repeated identical props. All seven tree trunks/roots (rows 62..95), contact points and original palette remain exact; upper foliage proportions and leaf-cluster positions vary subtly. The earlier unclipped source remains.
- The dispatch point now uses a practical two-storey brick/timber Dispatch Hall with a complete slate roof, straight south-facing entrance, covered porch, three-dot plaque and route board. The corrected roof preserves the original facade and threshold pixels; camera offset (0,-84) frames its full peak. This follows the proposal at docs/forges/world-asset-forge-prompts-2026-09-30.md:41 and Preston's current instruction; it does not lock the working place names. The front-facing house Preston loved is retained as wayline_office_front.png.
- Actors and props sort by their feet. Tree trunks and the hall have collision footprints. Two trees were moved clear of the hall footprint and Cinderhide's view. The bounded camera looks ahead, and the route header sits at the upper right to leave the hall roof visible. Dialogue still grows upward.

- The old ferry landing now has two visible weathered tie-offs with small foot collisions and a recessed empty return-mark holder on the relay post. These implement details already requested in the route art brief; quest sites and behavior remain. The smaller tie-off was moved clear of canopy cover.
- Existing research and design were synthesized with Preston's maps in [route1-regional-synthesis-2026-10-02.md](../world/route1-regional-synthesis-2026-10-02.md). The masonry wall is a bluff/path retaining structure; levee references mean a broad grassy earth embankment with a crest track. Regional maps/distant views retain Elwood west/left, St. Joseph east/right and the river between. Current route staging was not silently mirrored.

## Run and review
Run scenes/first_route_prototype.tscn; use scenes/first_route_female_preview.tscn for Female. The current project launch setting belongs to concurrent preview work and was not changed by this pass.

Use scenes/rd_material_review.tscn to review the six new creatures with keys 1–6 and normal move buttons.

- [Latest exact changes, prompts, references and captures](../art/world/route1-unique-props-2026-10-02/README.md)
- [Earlier exact changed files](../art/world/route1-rd-first-pass-2026-10-01/CHANGED_FILES.md)
- [Current Route 1 sources, prompts, costs and review](../art/world/route1-rd-polish-2026-10-01/README.md)
- [Earlier terrain/landmark pass](../art/world/route1-rd-first-pass-2026-10-01/README.md)
- [Creature material and battle review](../art/review/rd-material-match-2026-10-01/README.md)
- [Male turn correction](../art/characters/male-walk-turn-correction-2026-10-01/README.md)

## Earlier verification
Both genders passed all eight directions and every walk frame in the actual map. Corrected male left/right/up-left/up-right passed all 32 comparison frames. All six creatures were viewed in battle, and all three Vitrecrag signature moves were exercised using normal controls.

The final October 2 route completed the whole courier assignment through movement and real interaction keys: pouch, marker, delivery, height observation, river calls and full return report. All eight flags are true. The latest final log and screenshots are saved in route1-unique-props-2026-10-02/review. Both landing tie-offs are visible and the river corridor was traversed after their final placement. The larger hall's collision and starting framing were checked in game; the doorway remains aligned with the approach. Cinderhide's eight-cell field idle and encounter connection were verified during the route pass.

Historical import errors and rejected outputs are retained in the review archive. The fresh final diagnostics show zero observed errors, with eleven existing warnings (battle variable shadowing and Rimefin's UID fallback). This is route/playtest evidence, not a claim of a full project audit.

## Cost and preservation
Earlier October 1–2 combined art pass: $2.17 in known successful Retro Diffusion charges. This includes the rejected $0.18 office roof outpaint and the rejected $0.18 split Dispatch Hall output. The original first pass cost $1.14, later terrain props $0.30, front house $0.18, two hall generations $0.36, tree outpaint $0.18 and transparency cleanup $0.01. The male reflection and creature material preparation added no paid generation.

Prompts, task IDs, original images and exact preparation are archived. The app restarted during record saving; missing live capture records were recaptured, and the three prop receipts were recovered by looking up the existing jobs, without regeneration.

The October 2 complete-roof/unique-prop pass has $1.08 in returned confirmed Retro Diffusion charges; a timed-out tree edit may have incurred a further $0.18 and has no returned ID. No paid retry was made. Rejected roof/tree/shrub/wall outputs remain archived; native preparation preserved the approved models. Saved Grok tie-offs and the relay holder added no paid generation.

## Remaining route polish

Route 1 remains in progress. The confirmed home/levee/bridge/city connection is now playable. Refine the levee bends, path transitions, bridge bank dressing and original bluff-to-landing descent within this geography. Full hometown streets, city sectors, final naming, interiors, dedicated city architecture and further vegetation variety remain. The city hall/tree reuse is temporary first-pass staging. The hall's small window/partner-trough details and balanced courier idles remain art review work. Wayburn's older angle sheet needs a separate snout/anatomy review if requested.

No staging, commit, deletion or launch-setting change was made. Preserve concurrent creature/battle work; this pass's file report is distinct from the checkout's full dirty status.
