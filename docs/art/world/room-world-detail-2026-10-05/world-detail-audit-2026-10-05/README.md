# Active world detail audit, October 5, 2026

Read-only audit of the six currently connected Hollowtide areas. The user's later world direction supersedes historical menu-only notes. Project AGENTS.md, CLAUDE.md, current AI_COLLABORATION.md and role charter were read. No project/documentation writes, engine launches, image uploads, generation requests or charges occurred.

## Exact inventory and evidence

- [Current world reference inventory](active-world-inventory.json), [CSV](active-world-inventory.csv): 83 world/tileset resources, including 72 currently used/native-material PNG sources. Five old resources are explicitly historical/dormant, rather than current visual defects. Each source has exact path, file hash, native size/bounds, edge-alpha flags and source references.
- [Eight ranked findings](ranked-findings.json) classify visible integration defects separately from style/detail opportunities.
- [Visual evidence](visual-evidence.json) records exact saved native capture hashes and crop rectangles. These are saved game images, not fresh engine verification.
- [Source check](audit-end-source-check.json): all inventoried asset hashes remained unchanged while the audit ran.
- [Active tree family](render/active-trees.png), [building family](render/active-building-models.png), [props/foliage](render/active-props-and-foliage.png), [hall/home material](render/active-hall-and-home.png) are inspection-only nearest-pixel contact sheets. The home source sheet shows its layered background, rather than a recomposed full room; ongoing room detail is the root's task.

The current sharper courtyard home, courier hall facade, shop and ledger house are installed and sharp. Neighbor/garden houses, workshop and rowhomes also have firm source lines. No repeat sharpening of all eight facades is justified.

## First concrete refinement: ground the hall approaches

[Measured gaps](approach-gap-measurements.json): hometown hall foot at (768,418), old soil begins y438; riverfront branch foot at (512,362), paving begins y378. These 20/16 native-pixel gaps look disconnected from the doorways.

The two candidate patches are exact literal crops of existing native road cap RGBA, shifted upward 24 pixels. No color generation, resampling, source overwrite or geometry/state change was made.

| Candidate | Native size | World origin | Current source crop (exclusive right/bottom) |
| --- | --- | --- | --- |
| [Hometown soil approach](candidate-approaches/hometown_hall_approach.png) | 37 x 44 | (750,414) | hometown_streets.png [750,438,787,482] |
| [Riverfront paving approach](candidate-approaches/riverfront_branch_approach.png) | 45 x 48 | (490,354) | riverfront_streets.png [490,378,535,426] |

[Contracts](candidate-approaches/contracts.json) include source/patch hashes, protected world rectangles, layer proposal and gate semantics. [Reproducible builder](build_approach_candidates.py) only reads current project art and writes these audit outputs. Context comparisons preserve the captured facades and actors, and are explicitly approximate previews requiring actual native engine verification:
[Hometown](candidate-approaches/hometown_hall_approach-context-comparison.png), [Riverfront](candidate-approaches/riverfront_branch_approach-context-comparison.png).

Install proposal: nearest Sprite2D, centered=false, scale 1, position at each origin, depth -6 behind RouteDecor. Preserve old paving and all code outside this bounded placement. Hometown gate remains (768,424), 20 x 8. The riverfront branch is an outdoor clerk interaction and has no entrance gate.

Also move existing hall labels clear of roof apices: hometown label y306 overlaps the roof beginning y305.5; branch label y254 overlaps roof beginning y249.5. Suggested label y290/y234 requires current native review. This is placement, not new lettering art.

## Subsequent detail order

1. Courier hall interior: one exact 256 x 256 detail candidate for canvas ties/folds, cubby separation, wood seams and counter material. The single wide noticeboard and registered counter layers must remain.
2. Paving and ground joins: the large repetitive stone slabs are crisp but coarser than facade brick detail. The tan north lane/paver crossing needs a local material transition. Use a native swatch/local strip, preserving every road mask/width and gate.
3. Riverfront bank: compare [plain bank](render/riverfront-bank.png) with Route 1's existing wet margins/roots/stones. A restricted shore strip reusing those materials would add depth without altering river geometry or collision.
4. Foliage: current seven cottonwoods have complete native bounds and irregular crisp clusters; no current leaf cutoff was observed. Broad repeated lobe silhouettes are a family-variation limit. Lime shrubs/rounded root stones contrast with muted tree materials; review their native palette before proposing a common-family pilot.
5. Garden: tiny native grass notch [463,601,479,608] below the sign interrupts soil. Three cloned plant clusters per row can eventually gain subtle variation. Preserve planting/idempotence/cache and all NPC size contracts.
6. Props: route signs/relay/tieoff textures could gain material hierarchy; current bridge caps/rails/pegs are complete and the deck has deliberate wood grain. Riverfront bridge continuing off the area entrance is intentional.

Large grass yards and limited residents/services are later content/composition work. Global edge sharpening will not fill that gap. Existing six areas, future districts and the full world are not complete.

## Optional art request proposal, not submitted

[Exact hall source/hash/spec](request-proposal/spec.json) and [prompt](request-proposal/courier-hall-detail-prompt.txt). Estimated $0.18 for ONE registered full-room image_edit, assuming the same recent project rate; no live quote was obtained and no new upload/charge was authorized here. The highest-impact immediate batch remains the free approach/label corrections.

This audit excludes the root's currently approved room/Coalcrest three edits. It does not authorize more requests, restore old battle resources, alter creature data or touch Claude/Grok-owned architecture. Current source hashes must be rechecked before integration because the project is shared and dirty.
