# Route 1 spaced landing and Maps grounding, October 3, 2026

Preston's active goal is a Hollowtide world that can compete with Nexomon and Coromon. He said areas and stops were too close together, supplied new reference maps, required each area to be a separate scene and now explicitly asked to utilize Google Maps MCP. This pass follows the installed separate hometown/Route 1/riverfront work and improves the crowded original route core.

Implemented: the route sign is beside the meadow-to-crest entrance, Cinderhide occupies a grassy hollow reached by a short spur, and the relay post, original mooring art and listening spot are in a distinct southern landing pocket. A rounded native-soil track branches from the crest, reaches the landing and rejoins the bridge approach. The height post and repair marker remain in their established northern positions. Route bounds, bridge/deck/rails, river flow, source artwork, player scale/speed and all quest rules remain unchanged.

## Exact changed game files

- scripts/first_route_prototype.gd: relocate the post, river, entrance and notice interaction points; show OLD LANDING below y480; update the landing notice's spatial directions. The other 28 functions are text-identical, including assignment, delivery, observations, report choices, notes, party and marker behavior.
- scenes/first_route_prototype.tscn: RelayPost (398,530), RiverCall (416,582), CinderhideEncounter (258,352), FerryTieoffFull (438,558), FerryTieoffShort (438,586). Only these five position lines changed; existing offsets, scales, textures, collision shapes and script assignments remain intact.
- scripts/route1_crossing.gd: entrance mark (64,186), label (84,168), beside the approaching lane.
- scripts/route1_landscape.gd: three existing-texture grass tufts frame the hollow; shoreline stone moved from (433,600) to (435,618), clear of the loop.
- scripts/route1_landing_loop.gd: add the southern path layer, move notice to (296,438) beside the trail and label to (248,486) clear of tall grass. Fade the southern cottonwood as well as the original bank tree; rebind both canopy materials when the cached scene re-enters, because _ready does not run again.
- assets/sprites/world/route1_spaced_landing_2026_10_03/landing_south_loop.png and its normal .import: one 200x288 RGBA native-material assembly at (244,336), using the existing soil tile and rounded path masks. The existing upper bank path is retained.
- docs/AI_COLLABORATION.md: current decisions, evidence and next-step handoff.
- This review archive, including source-before snapshots, runtime-after copies, initial corrected cases, Google Maps responses and native screenshots.

runtime-manifest.json lists all seven changed/new runtime files and final hashes.

## Google Maps MCP used

Three successful live tools/call searches on https://mapstools.googleapis.com/mcp:
1. Roseport Landing boat ramp, Elwood/Kansas/Missouri River.
2. Elwood Gladden Levee, Elwood/Kansas/Missouri River.
3. Pony Express Bridge, St. Joseph/Missouri/Elwood/Kansas.

The returned Roseport Landing point is south of the returned bridge point. This is an inference from returned WGS84 coordinates, consistent with Preston's screenshots, and supports the southern landing placement. The levee result resolves a broad road location in Washington Township; it does not establish the precise entrance or embankment cross-section. Screenshot geometry and prior regional synthesis remain the stronger references for those details. No real-world access or elevation claim was inferred.

Maps attribution links and returned coordinates are in review/maps-design-evidence.json. The exact public queries, tool schemas and replies are preserved. The current chat did not yet expose the newly registered tools, so the official MCP protocol was used directly with the installed encrypted-header helper. No key or private project content was sent in the public-place queries or saved in this archive. Real place names remain research references; no fictional district names were promoted to canon.

## Native ordinary-control proof

Both selected couriers walked from the hometown, accepted the assignment, entered Route 1, read the entrance/landing notice, delivered the pouch, crossed to the riverfront, registered arrival, read directions, returned, repaired the marker, reported and reached their own doorstep. Four real gates each. No fixture teleports or quest flag overrides. The existing route/home/controller/party instances and one starter remain intact.

Male full report: all eleven flags true, including old height marks and both calls.
Female simple report: the four optional observation/report flags remain false; all required progress flags true.
Reading the notice does not alter quest flags. Notes and party still freeze/resume movement. House and entrance-side collision checks pass.

From the levee sign to the relay, recorded movement takes 12.38s with the height/bank detour, and 8.47s by the more direct branch, at fixed 60fps and unchanged player speed. These are measured fixture paths, not forced delays or a minimum-time promise. The height-to-relay straight-line separation grows from 46.75px to 325.96px, removing the old overlap between their 30px interaction zones.

Both couriers independently approach the new hollow and press the actual interaction key. The existing battle opens with the assigned Cinderhide resource, the selected courier intact and no changed quest flags. No battle/rule implementation was changed.

The landing canopy reaches 0.35 behind the courier and restores to 1.0 outside it. After the actual city round trip, both trees still bind their canopy materials and reach 0.35 on ordinary approaches. Both journey and encounter stderr logs, and the final render stderr log, are empty.

1,021 pre-existing asset/data/protected-code files remain byte-identical, including all creature art/resources, player, party, battle, menu, scene-travel controller, terrain relief and project launch setting. Import-only engine shutdown warnings are retained separately from clean game-runtime logs.

## Initial findings and saved work

The first full walk found the notice footprint across its own approach. The post was moved beside the lane instead of bypassing its collision. The second found the short mooring on the shore track; it was moved to the river edge. The first label was partly obscured by tall grass and was shifted clear. Initial failed logs/JSON/images and earlier candidate snapshots remain saved. The fin, creature source art and existing map surfaces were not repainted.

Overview/manual review placements are for visual review only. The full journeys and encounter fixtures are separate ordinary-input evidence. Open scenes/world_journey.tscn for New Game/home, or scenes/first_route_prototype.tscn for the connected route entrance.

## Remaining world work

The broader world goal remains active. Route 1 is not yet declared complete: repeated foliage/hero-art individuality, further collision/depth/ambience review and encounter balance remain. The hometown still needs distinct households, yard detail, residents/interiors and services; city sectors need their own playable entrances and activities. Save/reward/state architecture stays with its established owner. User runs Gemini Deep Research; prompt files only when requested.

Coalcrest's fin-only RD retry remains a separate pending explicit upload/charge approval. This route pass used existing artwork; no new Retro Diffusion charge. The three Google Maps service calls are recorded without claiming an unverified billing total. No commits, staging, deletions or user-editor control. No route implementation blocker remains.
