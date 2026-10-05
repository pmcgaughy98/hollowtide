# Route 1 startup: exact saved surfaces | October 3, 2026

Route 1 now opens without regenerating the approved crest road, city landing, river mask and wet banks. Four exact native outputs are saved as lossless PNG textures; the existing node anchors, depth, filtering, shaders and animation remain. This removes a long pause before the player can move and supports the next map-production work. The active world goal and Route 1 are still incomplete.

## Measured result

| Check | Before | After |
| --- | ---: | ---: |
| Same profiling fixture: scene load/instantiate/ready | 13,693 ms | 1,100 ms |
| Scene attach/ready portion | 12,627 ms | 330 ms |
| Crest road builder | 4,891 ms | 0 ms at millisecond resolution |
| City landing builder | 6,790 ms | 0 ms at millisecond resolution |
| River surface builder | 261 ms | 1 ms |
| Wet bank builder | 60 ms | 0 ms at millisecond resolution |

The profiling fixture preserves actual builder operations and adds timing only. Independent unmodified-runtime runs measured 1,238 ms for the first route load in a fresh process, then 207/244 ms for repeat scene loads. The ordinary-input walkthrough separately measured 853 ms. These timings cover route resource loading, instantiation and ready work on this PC, not total engine/application boot, the menu's authored fade, or a guaranteed loading time on every machine.

[Before profile](review/before-profile.json), [after profile](review/after-profile.json), [unmodified runtime samples](review/after-unmodified-startup-samples.json).

## Exact runtime files

| File | Change |
| --- | --- |
| scripts/route1_crossing.gd | Uses saved water mask/crest-road/city-landing textures; removes their CPU pixel builders and unused helpers |
| scripts/route1_landscape.gd | Uses saved wet-bank texture; vegetation/ground finish/wind remain live |
| assets/sprites/world/route1_static_surfaces_2026_10_03/river_water_mask.png | Exact 224x640 alpha mask, at (448,0), z -2 |
| assets/sprites/world/route1_static_surfaces_2026_10_03/joined_levee_road.png | Exact 320x264 crest-road surface, at (144,184), z -1 |
| assets/sprites/world/route1_static_surfaces_2026_10_03/joined_city_landing.png | Exact 336x240 landing surface, at (672,336), z -1 |
| assets/sprites/world/route1_static_surfaces_2026_10_03/wet_bank_contours.png | Exact 296x640 wet bank, at (408,0), landscape z 0 |

Normal import metadata and the two existing script UID companions are included in the twelve-entry [runtime manifest](runtime-file-manifest.json); UID snapshots are retained, not newly redesigned files. All imports are lossless, no mipmaps or alpha-border rewriting, and native surfaces retain nearest filtering.

Updated records: docs/AI_COLLABORATION.md, this README and the accompanying source/review/tools/verification/manifests. The exact before/current code and diffs are retained. No paid generation or source-art repainting was used.

## Verification

- All four imported surfaces match the original CPU-generated RGBA pixels exactly.
- Five fixed-clock actual-engine captures are pixel-identical: full overview, levee entrance, crest, old landing and city arrival. All 746,496 pixels in each view match.
- All 420 scene nodes match the recorded class/position/depth/scale, sprite offset/region/filter/texture pixels, rectangular collision geometry and terrain cells. Eighteen protected construction/animation functions are text-identical. The route scene, quest script, map polish, terrain-relief layer and project settings are hash-identical. Fourteen other sprite-consistency runtime files remain unchanged.
- An ordinary-control walkthrough completed the default spawn → dispatch assignment → levee sign → crest/bridge → city clerk/direction board → relay delivery → high-water observation/two calls → marker repair → full dispatcher report. All eleven flags are true, with zero teleports or quest overrides.
- Three unmodified-runtime scene loads start with fresh quest flags and running water/foliage processing. A separate live-motion capture observed river offset (0,0) → (0,5) and wind clock 0.1833 → 2.6833 over 2.5 scene seconds.
- Before/after fixture, ordinary walk, repeat-load and live-motion stderr logs are empty. The headless import separately retained known CanvasItem/ObjectDB shutdown warnings; it logged no asset-import failure.

[Exact scene/render comparison](review/exact-scene-comparison.json), [ordinary inputs and flags](review/after-ordinary-walkthrough-results.json), [live motion](review/live-motion-results.json), [preservation audit](verification/final-preservation-audit.json).

Review fixtures deliberately place the camera/player and fix animation clocks for pixel comparison. They are separate from ordinary traversal, which uses movement and E/Down/Enter inputs only. Live-motion fixture placement is also explicitly recorded.

Owned checks exited. The user's editor PID 25788 and its running game were not stopped or controlled. No staging, commit, deletion, external messaging, battle/save/state or game-rule change occurred.

## Future map changes and next work

These textures describe this exact authored map. If its ground atlas, soil, river footprint, crest contour or city trail footprint changes, regenerate and review the affected surfaces. Do not silently keep an old bake after a geography edit. The full original native builders are retained under review/source-before/scripts/ and in tools/startup_profile_crossing.gd.txt and tools/startup_profile_landscape.gd.txt. Copy archived scripts into an isolated workspace as .gd and update their local preload/output paths when rebuilding; the profile preparation script normally reads current runtime and is not by itself a replacement for those original builders.

source/inputs/ preserves approved material inputs. review/source-before-manifest.json and static-surface-manifest.json identify the code and outputs used in this pass. Archived scripts end in .txt and docs/.gdignore keeps them out of normal game imports.

No blocker for this optimization. Next work returns to the [world checkpoint](../route1-landscape-2026-10-03/WORLD_DESIGN_NEXT.md): purposeful optional exploration, actual hometown/riverfront map connections and distinctive district architecture. Coordinate inventory/rewards/save persistence with Claude's ownership. Final fictional names remain open. The saved [levee terrain pass](../route1-terrain-relief-2026-10-03/README.md) and [menu/sprite finish](../../review/consistency-2026-10-03/README.md) remain installed. This result does not certify the complete world or a finished Route 1.
