# Remaining Highbank exterior structures and larger Job Board

Preston requested finishing exterior art and remaining town structures, and specifically a larger Board. This completes finished views for all 13 existing places. Original service buildings keep their installed art, black internal detail and selective outer rim. No decorative buildings or new service rules were invented.

## Job Board

Displays the exact original 48x24 PNG at integer 2x: 96x48 canvas, centred on the existing stand. The actual alpha foot row is measured with Image.get_used_rect; lifting by its original end.y preserves the original opaque contact row despite transparent source padding. Visual offset from (624,168) is (-24,-used.end.y); no logical footprint change, door/read point remains (26,8). Clear of the Hall's two-tile doorway, steps and guild mark. Nearest sampling only; no crop, resize file, redraw or new PNG. The old small baked shadow is removed, replaced by a 2px-offset transparent shadow of the enlarged art on the final ground. Existing reading pad and its three response drawings remain exact.

## Three remaining structures

`scripts/town/landmark_exteriors.gd` paints original native pixel details in code. Lookout: low weathered masonry, bench and river mark. Landing: larger mooring posts at the existing positions/foot row, rope wraps, old gear crate and river marker. Dock: timber edge beams, posts, low rope and three worn entrance treads. Shares black internal contours, material outer rim and top-left lighting with the purposeful exteriors. Ground-coloured contact darkening is a separate 2px-offset transparent sprite; it responds to the actual grass/paving/water beneath rather than baking an old ground palette.

All three preserve Claude's exact positions, dimensions, doors/activation spots, paths and ground. Dock's existing one-tile extension over the water is retained (the ground painter already draws it). Details remain below creatures as low open-air props, with broad walking surfaces and clear standing positions. No collision or boundary rule added. Landing art leaves the Hollow Mouth and its approach clear. The original HUD place name replaces the temporary floating plaques through the existing finished-view hook. Region map and ferry crossing remain future services; this does not implement travel.

Optional integration in building_exteriors.gd registers the three views. A missing optional landmark module retains the existing ground/labels/services; no missing module is preloaded. Static landmarks are excluded from the door-animation loop. Every previous doorway, hatch, foundation, sign and other service animator is retained.

## Native verification

Godot 4.7.2 NVIDIA Compatibility renderer. 27 structure checks pass: all 13 place views; 2x original Board art; exact opaque foot and centre anchoring; no Hall door/steps/sign intersection; three reading markers exact; real E/Escape opens/closes Claude's four Board requests and active/dormant feedback; all three new services still answer; standing spots and gate approach clear; five original foundations/signs and fifteen original door/hatch drawings exact; ground outside the old Board shadow patch exact. Source PNGs and shared finish are untouched, so prior creature/palette/animation verification remains preserved, not a new animation audit.

Current Claude checks copied with outputs redirected and explicit cleanup: hub_town_check (13 reachable places, 12 services answer, follower movement, gate starts run); town_walk_check; hall_door_check; job_board_check (take requests, rescue client, recover lost item, return and receive rewards/rank). Six actual town views captured before/after. Review runs have the sandbox Windows root-certificate-store warning; corrected final runs have no shader/script errors. Initial static-landmark/fixture diagnostics retained. Each process uses isolated test preferences, never user settings/saves.

## Preservation and handoff

Only two existing town presentation scripts, one new painter and collaboration note installed. Exact originals and candidates are archived. No shared shader/palette, creature/source PNG/backups, Claude ground/interiors/controller/state/dungeon, layout, title, menu, story, balance or project settings edit. Original backups elsewhere are untouched. No image generation, commit, revert or stash. Preston's visual approval and a natural dungeon clear are not claimed. See final live verification and audit below.

Launch/UI handoff job 8 remains open, deferred when Preston asked for exteriors. Creature A/B finish remains review-only. Town structures are now filled; additional decoration or ferry/region gameplay needs its own scope.

## Final live verification

All six native live runs pass with no script/shader/certificate errors or leaks in their final logs. 27/27 structure checks, all 12 service interactions, the Board rescue/recovery/payout loop, actual town walking, both Hall door tiles, and six installed town captures. All four intended installed files match their reviewed candidate hashes. 10257 protected active files and 9710 original active asset files match the starting baseline. 5 concurrent changes are retained and snapshotted in concurrent-final/; three of them are Claude's Whinet expression PNGs, not task art edits. Previous collaboration body is retained verbatim.

Final views: [larger Job Board](review/live/board.png), [Hall clearance](review/live/hall.png), [Lookout](review/live/lookout.png), [Ferry Landing](review/live/landing.png), [Dock](review/live/dock.png), [Hollow Mouth clearance](review/live/gate.png). Original Board PNG is also copied unchanged into original-art/. Every published archive file is hashed in publication.json. Preston's visual approval is not claimed.
