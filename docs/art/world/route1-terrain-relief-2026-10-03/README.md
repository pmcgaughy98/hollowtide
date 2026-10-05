# Route 1 grassy levee and path refinement | October 3, 2026

## Installed and verified

The levee now has a broader shaded southwest grassy face and a brighter northeast crest shoulder, with the existing grass texture visible through both. The dispatch, relay and old-landing path joins have softer contours. The existing approved wet shoreline, roots, reeds, repaired bridge and flowing river remain in place. This advances the active Hollowtide world goal; Route 1 and the full world are still in development.

Two textures are baked offline from the existing approved native materials. Runtime only creates two nearest-filtered sprites sharing the terrain finish. The measured new-layer build was 0 ms at millisecond resolution. The full route still took 13.008 seconds to become ready in the recorded run; older crossing/landscape builders remain a performance limitation.

[Installed crest view](review/installed-crest.png). [Installed overview](review/installed-overview.png). [Actual ordinary-control city arrival](review/walkthrough-bridge-arrival.png). [Actual completed return report](review/walkthrough-report-complete.png).

## Exact changed runtime files

| File | Change |
| --- | --- |
| scripts/route1_terrain_relief.gd | Replaces the saved inactive builder with a fast renderer for two baked native surfaces |
| scripts/route1_crossing.gd | Adds TerrainRelief after the existing landscape; no geography or interaction logic changes |
| assets/sprites/world/route1_terrain_relief_2026_10_03/levee_grass_slopes.png | 296x248 RGBA surface anchored at (136,216) |
| assets/sprites/world/route1_terrain_relief_2026_10_03/rounded_dispatch_landing_paths.png | 416x248 RGBA surface anchored at (0,80) |

Normal PNG import and script UID metadata are recorded with the two scripts and two textures in [runtime-file-manifest.json](runtime-file-manifest.json). The new textures match the saved offline output byte-for-byte. No paid image generation was used.

The crossing change is the four-line child installation only. Source/current and source/before retain exact copies and per-file diffs. The previous terrain candidate and all supplied references remain saved. Original terrain/soil sources and the route scene are hash-verified; 14 prior consistency-pass runtime files are unchanged. [Preservation and final audit](verification/preservation-and-final-audit.json).

Record/handoff changes: this README and its source/review/tools/verification/manifests, plus the new top entry in docs/AI_COLLABORATION.md. The prior README and prior collaboration guide are retained under source/. Older sprite/landscape records describe their state at that time; this entry supersedes their statement that the terrain pass is inactive.

## Review decisions

The saved initial candidate was rendered and rejected: it left the levee too flat, produced a narrow exposed-bank strip that weakened the accepted shoreline, and took 30.709 seconds to build. It changed 20 old-lane pixels and made three surfaces.

The revised offline builder keeps the existing WetBankContours. It strengthens the grassy shoulder shading and uses three radius-six majority contour passes on the older lane mask while excluding the accepted crest core. Its build took 15.784 seconds, producing 13,659 slope pixels and 785 lane changes across two surfaces. This work runs offline and is not part of runtime loading.

Baseline, rejected candidate, revised candidate and installed views are preserved separately in review/. Candidate/revised/installed overview and close-up captures are camera/position review fixtures. They are not ordinary traversal proof. Earlier candidate fixture HUD labels were stale because route processing was paused; installed fixtures update the route HUD once. Actual ordinary-input screenshots are prefixed walkthrough-.

The offline builder, preparation, staging and guarded install records are in source/build/; probe sources are in tools/. Archived scripts use .txt so they do not become runtime duplicates.

## Ordinary gameplay proof

The native Summer renderer walked from the default hometown staging spawn using movement keys and E/Down/Enter interactions. There were no teleports or quest-flag overrides.

Passed: accept the pouch, read the levee entrance, traverse the crest and bridge, register with the city clerk, read the city direction board, return to deliver at the relay, observe high-water marks and two calls, repair the marker, and return to the dispatcher with the full report. All eleven existing quest flags are true. Final position: (82.35247,203.9769).

[Recorded inputs, positions and final flags](review/ordinary-walkthrough-results.json). Final walkthrough and installed-review stderr logs are empty. The isolated checks used offscreen fixed-60-FPS rendering, Dummy audio, API/publishing disabled. Owned check instances exited; the user's editor PID 25788 remained running.

Headless editor import separately logged the existing default-audio-bus UID/empty-resource-save-path diagnostics and shutdown CanvasItem/ObjectDB warnings. These retained import diagnostics are distinct from the clean game-runtime logs.

## Limits and next justified work

No implementation blocker for this pass. Overall route startup still needs attention before expanding level production. Then continue the [world checkpoint](../route1-landscape-2026-10-03/WORLD_DESIGN_NEXT.md): a purposeful optional loop, actual connected hometown and riverfront maps, distinctive district architecture, sound, interactions and repeat-visit behavior. Coordinate reward/save/state work with Claude rather than creating a parallel state system.

The current compact first-route map is staging for the west-bank hometown-to-levee-to-east-bank journey. Final fictional world names remain open. Existing quest/collision geometry, player/creature/menu/battle rules and launch setting were not changed by this terrain pass. No staging, commits, deletions or external messages. The [completed Ironvent/menu/sprite consistency work](../../review/consistency-2026-10-03/README.md) remains installed.

The broad world goal remains active. User runs Gemini Deep Research; prompt files only when requested.
