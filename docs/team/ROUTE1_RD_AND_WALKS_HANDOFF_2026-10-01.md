# Hollowtide walking, creature materials and Route 1 handoff
Updated October 2, 2026.

## Current authorization
Preston reopened gameplay walking, Claude's Vitrecrag/Coalcrest line materials, and Route 1 using Retro Diffusion. He approved the male left walk as the pose/size reference, supplied Nexomon and other map references for finish and perspective, requested complete tree crowns and individual prop variations, and asked for the building intended for the dispatcher. His October 2 map references and request to synthesize existing St. Joseph/Hollowtide files now guide the route geography and landing details. These instructions supersede older menu-only and shelved-Vitrecrag notes.

Menu research is complete. The Courier Lookout decision and saved menu work remain. Preston runs Gemini Deep Research; prepare research prompts only when requested.

## Installed
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

## Verification
Both genders passed all eight directions and every walk frame in the actual map. Corrected male left/right/up-left/up-right passed all 32 comparison frames. All six creatures were viewed in battle, and all three Vitrecrag signature moves were exercised using normal controls.

The final October 2 route completed the whole courier assignment through movement and real interaction keys: pouch, marker, delivery, height observation, river calls and full return report. All eight flags are true. The latest final log and screenshots are saved in route1-unique-props-2026-10-02/review. Both landing tie-offs are visible and the river corridor was traversed after their final placement. The larger hall's collision and starting framing were checked in game; the doorway remains aligned with the approach. Cinderhide's eight-cell field idle and encounter connection were verified during the route pass.

Historical import errors and rejected outputs are retained in the review archive. The fresh final diagnostics show zero observed errors, with eleven existing warnings (battle variable shadowing and Rimefin's UID fallback). This is route/playtest evidence, not a claim of a full project audit.

## Cost and preservation
Earlier October 1–2 combined art pass: $2.17 in known successful Retro Diffusion charges. This includes the rejected $0.18 office roof outpaint and the rejected $0.18 split Dispatch Hall output. The original first pass cost $1.14, later terrain props $0.30, front house $0.18, two hall generations $0.36, tree outpaint $0.18 and transparency cleanup $0.01. The male reflection and creature material preparation added no paid generation.

Prompts, task IDs, original images and exact preparation are archived. The app restarted during record saving; missing live capture records were recaptured, and the three prop receipts were recovered by looking up the existing jobs, without regeneration.

The October 2 complete-roof/unique-prop pass has $1.08 in returned confirmed Retro Diffusion charges; a timed-out tree edit may have incurred a further $0.18 and has no returned ID. No paid retry was made. Rejected roof/tree/shrub/wall outputs remain archived; native preparation preserved the approved models. Saved Grok tie-offs and the relay holder added no paid generation.

## Remaining route polish
Route 1 remains in progress. Crown clipping, the complete hall roof, correct house/tree depth and individual repeated-prop variations are implemented and checked. Next geography work should make the bluff descent/loess terrace and lower silt landing readable, then use upper-slope oak/hickory and lower-bank cottonwood/willow/sycamore variety after art review. A broad earthen far-bank levee belongs in a later cross-river view or far-bank slice. The hall's small window/partner-trough details, dedicated balanced courier idles and later building interiors remain review work. Wayburn's older angle sheet needs a separate snout/anatomy review if requested.

No staging, commit, deletion or launch-setting change was made. Preserve Claude's concurrent battle/signature work; this pass's file report is distinct from the checkout's full dirty status.
