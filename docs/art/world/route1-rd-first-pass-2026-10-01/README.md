# Route 1: first Retro Diffusion art pass

Historical first pass. The current terrain, Dispatch Hall and complete-crown tree are documented in [the October 1–2 polish pass](../route1-rd-polish-2026-10-01/README.md).

Preston explicitly reopened Route 1 work on October 1, 2026, after approving both eight-direction courier walks. This overrides the earlier menu-only pause. THE_CONCEPT.md remains the design authority. This is an installed first pass on the existing assignment map, not a finished full route.

## Installed
- Native 16px ground tiles for muted cottonwood grass, loess path, shoreline and river. The 32px texture repeats retain their phase through the 16px cells; the original 960 cell positions and river barrier remain.
- A larger Wayline office, cottonwoods, dispatcher, three-dot marker, relay post, height post and six sparse reed placements.
- The marker has exactly three dots. The relay post has a dry delivery slot and an empty return-mark recess. The height post keeps undated cuts.
- Camera limits keep the 640 x 384 map inside the view.
- Dialogue grows upward from the lower edge, keeping Continue and report choices on the 1152 x 648 screen.

Runtime assets: assets/tilesets/route1_rd_2026_10_01/ and assets/sprites/world/route1_rd_2026_10_01/. This pass used route1_ground_atlas_refined.png; the current scene now uses route1_ground_atlas_polished.png with route1_ground_polished.tres. The initial route1_ground_atlas.png is preserved but unused.

## Sources and cost
PROMPTS.md and source/retro_diffusion_requests_and_receipts.json preserve the exact prompts, generation parameters and task receipts. raw/ preserves all ten original outputs and the rejected roof outpaint. Known successful charges total $1.14, including the $0.18 rejected outpaint. Three initial texture requests with tiling flags failed with gateway 502; no successful output or cost receipt was returned for those failures.

The raw ground outputs were too noisy and did not obey the requested palette closely enough. Preparation maps them onto compact six-tone material ramps, uses a discrete neighbourhood majority filter and locks texture borders. This uses hard pixel clusters without interpolated scaling. Prop finishing preserves the office body, adds a transparent roof margin and one-pixel ridge cap, and makes the route marker and relay details explicit. The rejected outpaint added baked checkerboard; it is not installed.

## Verified
Both gender models: all eight directions and every walk frame in the actual map, with equal cardinal and diagonal speed. The full assignment was played using movement and real interaction keys: pouch accepted, marker restored, delivery made, undated height cuts observed, two river calls heard, and the full report submitted. The final board records all three observations. Dialogue and both report choices were inspected on screen.

review/ contains live screenshots with same-frame state receipts. source/live_validation.json contains the walk and assignment logs. Short UI accept taps in a suspended deterministic test did not activate buttons; the report was verified with real key input in an unsuspended game.

## Next polish recorded at this first pass (subsequently addressed)

The current pass replaces the wall and field creature presentation, hides the old river-call SVG, adds prop occlusion/collision, fixes crown clipping and installs the front-facing Dispatch Hall. Individual tree variants remain pending.

The original retaining-wall study, river-call indicator and static field Cinderhide remain. Finish those with the same material language before expanding the map. Add deliberate prop occlusion and collision once the route composition is approved. Frame zero is still the existing standing substitute; dedicated chibi idle sets and a character selection flow are separate work.

Do not regenerate completed menu research. Preston runs Gemini Deep Research themselves.
