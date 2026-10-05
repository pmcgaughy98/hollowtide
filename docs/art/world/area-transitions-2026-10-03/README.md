# Separate areas and travel scale, October 3, 2026

Preston directly corrected the continuous hometown attachment: every area should be its own scene, entered by walking through an entrance. He then said destinations were too close and supplied Coromon hometown/Hayville/Route 1 references. These direct instructions supersede the older attached-courtyard handoff.

Implemented and verified: New Game opens a separate 1024x768 hometown. Its three courtyard homes, shared garden, dispatcher hall, eastern street and marked levee entrance occupy several camera screens. Building/tree/courier textures and player speed remain native and unchanged. Route 1 is now 1472x640, including a 768x640 meadow approach with a main bend and optional lower loop. The city riverfront is its own 1024x768 scene with a complete bridge view, courier branch, spaced brick frontage, records house and direction board.

Walk through an entrance to fade into the next scene. Only one cached area is in the live scene tree. The original Route 1 assignment controller is retained off-tree when elsewhere; its existing HUD and music stay with the journey. Returning restores the same area/controller instances. The party remains the existing PlayerParty autoload. This is live-run travel, with no new disk-save model.

## Exact runtime changes

New scripts:
- scripts/world_journey.gd: one active area, cached scene instances, explicit gate arrivals, fade, retained original HUD/music, common interaction forwarding.
- scripts/world_area.gd: hometown/riverfront camera bounds, sites and interaction hints.
- scripts/area_landscape.gd: separate hometown/riverfront terrain, native-size buildings/trees, footprints, bounds, river flow and canopy fade.
- scripts/route1_approach.gd: native meadow and longer approach lane.

New scenes: scenes/world_journey.tscn, scenes/hometown.tscn, scenes/city_riverfront.tscn.

Targeted edits:
- scripts/main_menu.gd: open WorldJourney and set the selected courier before area readiness. Down from either portrait now reaches Begin; Up from Begin returns to the selected portrait.
- scripts/first_route_prototype.gd: route-only sites/camera/labels; descriptive home/city text. All fourteen assignment/report/notes/party functions listed in review/verification.json remain exact.
- scenes/first_route_prototype.tscn: remove the attached hometown; attach the longer route approach; route review spawn moved to (-720,512).
- scripts/route1_crossing.gd: wider route bounds and entrance openings; remove city staging and old dispatcher/hall presentation. Include dynamically created bodies when disabling the removed hall footprint.
- scripts/route1_landscape.gd: tolerate city trees being absent from the route.
- scripts/route1_map_polish.gd: suppress shadows of the removed/hidden hall and dispatcher.

Six new runtime PNGs under assets/sprites/world/area_transitions_2026_10_03/: hometown_streets.png, route1_meadow_approach.png, riverfront_streets.png, riverfront_water_mask.png, brick_shop.png, ledger_house.png. Path masks use existing native soil and the new RD paver tile; the water mask uses the existing flowing-water texture/shader. No supplied game reference art is used as runtime artwork. Normal PNG imports and four script UIDs accompany these files. runtime-manifest.json lists every installed runtime file and hash.

## Verified behavior and timing

Male: full ordinary-input home assignment, side-wall collision, marked entrance, meadow approach, levee sign, relay delivery, undated height marks, two calls, bridge/city arrival/directions, return, marker repair, full report and doorstep return. All eleven flags true.

Female: same scene entrances and return assignment/report, with optional calls/height observations deliberately omitted. The four optional observation/report flags stay false. Both reports use the actual GUI choices.

Both runs preserve cached home/route instances and the same active party member, with one starter. Notes/party freeze movement and resume it when closed. Four real entrance transitions per run, no test teleports or quest flag overrides. Engine arrival placement is explicitly recorded.

The tested home walk before leaving is 15.97 seconds of movement at fixed 60fps, including the dispatcher detour and side-wall check. The route meadow approach before the levee sign is 15.38 seconds of movement. These are measured test routes, not forced delays or a minimum travel-time promise. Scene readiness before the opening fade: 1435ms male and 1103ms female on this PC.

New Game passed with both exclusive courier selections and opens the hometown at (224,280). The menu fixture inherits actual scenery/flow and suppresses preference writes to preserve user settings. Direct Route 1 launch also passed ordinary-control travel into the hometown with the selected female courier preserved. Final male/female/menu/layout/direct-launch stderr logs are empty.

Layout audit: one area, one HUD and one music node; all 64 newly positioned cottonwood alpha silhouettes stay inside their area bounds. A focused ordinary-input check passes through the former route hall footprint after its removal. Review overviews/manual review arrival positions are explicitly separate from ordinary-input traversal evidence.

## Preservation and initial corrections

816 existing art/material files remain byte-identical; player, party and battle scripts are unchanged. The editor changed only project.godot's launch pointer during the turn, from the Oxbow Archon review back to Route 1. Codex preserved that external change and did not write the setting. Direct Route 1 launch now opens WorldJourney at the route entrance; New Game still begins at home. No staging, commits, deletion or user-editor control.

Initial render caught uninitialized shader fade values; corrected by explicitly setting canopy_opacity. A real gate caught source-area disabling during the physics callback; corrected by deferring it. The initial male menu check revealed Down switched selection; corrected focus neighbors. The layout fixture had one inferred-type parse error; corrected explicit Vector2 declaration. Initial failed logs/results are retained alongside clean final logs.

## Generation and cost

Confirmed RD charges total $0.90: initial angled shop $0.18 (rejected), records house $0.18, seamless pavers $0.18, angled shop edit $0.18 (rejected), final straight shop $0.18. Exact prompts and sanitized IDs are in review/generation-records.json. The office synchronous result was unreadable but the successful job output was recovered from history without a second generation. A first final-shop estimate had unsupported fields; the successful job receipt and corrected estimate were retained. No credential or signed output URL is archived.

The accepted shop/records fronts are padded native RGBA assets. The shop's exterior paving strip was removed from alpha below row162 before padding, preserving the building itself. All originals and rejected candidates remain saved.

## Review and remaining work

Open scenes/main_menu_art_preview.tscn for the existing menu, or scenes/world_journey.tscn for the journey. The editor's current Route 1 launch is preserved and now joins the same connected WorldJourney. New Game begins at home.

The supplied reference files inspected were coromon hometown.jfif, Hayville coromon.webp and coromon route 1.webp in Preston's OneDrive HollowTide Sprites/Game-Ideas folder. Applied their spatial principles: separate maps, recognizable yards/streets, multiple screens between entrances and purposeful path bends. Hollowtide keeps its existing materials, couriers, cottonwoods and river character.

This is a playable scale/transition slice. It is not a finished hometown/city or a completed competitive game world. Distinct house variants, yards/fences/residents/interiors, further spacing of the older route quest cluster, named fictional districts and additional gate connections remain. The older historic-address activity candidate is preserved but uninstalled. New district entrances should use this same explicit transition pattern. Save persistence, rewards and battle rules remain with their established owners.

No area implementation blocker. The later Coalcrest front-fin request is tracked separately. Preston explicitly approved the sprite/mask upload after automatic approval review requested authorization. The first paid candidate was rejected for changing pose/transparency; the focused repair remains in separate review.
