# Route 1 old-landing loop | October 3, 2026

## Installed play

The crest road now branches into the old landing and returns along the shaded bank to the bridge approach. The detour gives the existing relay, undated high-water cuts and uncertain river calls a clearer place in the journey. A three-dot notice at the turn explains the lower footpath and higher crest.

The returning path passes behind the existing southern cottonwood. Its crown fades gently while it covers the courier, then returns to full opacity on leaving; the lower trunk/roots stay solid. The approved tree image is unchanged. Existing source art, bridge, river flow, terrain shading and male/female models remain.

[Actual notice during the ordinary journey](review/full/walkthrough-landing-notice.png). [Courier visible under the crown](review/full/walkthrough-bank-return-341.png). [Installed overview](review/installed-overview.png). [Bank and bridge return](review/installed-return.png).

## Exact files

| File | Change |
| --- | --- |
| scripts/route1_landing_loop.gd | New native path renderer, notice/label/foot collision and crown visibility |
| scripts/route1_crossing.gd | Four lines install LandingLoop after the terrain relief |
| scripts/first_route_prototype.gd | One notice site, E prompt/dispatch case and descriptive message using the existing dialogue system |
| assets/sprites/world/route1_landing_loop_2026_10_03/landing_footpath.png | New 152x154 RGBA terrain overlay anchored at (292,258) |
| assets/sprites/world/route1_landing_loop_2026_10_03/canopy_visibility.gdshader | Alpha-only crown fade; lower trunk preserved |

Normal PNG import and script/shader UID metadata are included in the [runtime manifest](runtime-file-manifest.json). Before/current files and exact two-file integration diffs are saved under source/ and review/source-before/. This record and the new top entry in docs/AI_COLLABORATION.md document the pass.

The path is assembled offline in the native engine from existing approved soil/terrain and current surface masks, at the same world-coordinate texture phase. Revised bake: 866 ms offline, 5,016 drawn pixels, no texture painting or paid image generation. Runtime loads its saved surface. Existing cached roads/banks and relief textures remain byte-identical.

Existing quest sites, all original route flags, both report choices, notes, party, save/battle/creature rules, route scene and launch setting are preserved. The only new interaction is the repeatable notice; reading it twice was tested not to change any quest flag. It grants no clue, reward or inventory entry. The notice adds a small foot collision; existing collision geometry is unchanged.

## Review and corrections

The initial isolated preview had a missing object type declaration; removing a candidate-only root-script assignment then left an indentation error. Both failed fixture diagnostics are retained. Shared runtime was not edited until the corrected preview ran.

The first visual candidate left a small upper path seam and its label was hidden by foliage. The entrance was extended into the existing clearing, and the label was moved above the notice. v1/v2 images and the first path bake are retained.

The first ordinary trip passed, but the courier was fully hidden on part of the bank return. The final crown fade fixes that visibility issue. A previous installed-view fixture also quit with ObjectDB/ResourceCache exit diagnostics; final probes release their file/scene references and let cleanup settle. The final full, bypass, installed-view and native-canopy runtime stderr logs are empty. Headless imports separately retained the existing audio-bus UID/empty-resource-save-path pair and CanvasItem/ObjectDB shutdown warnings.

Before/candidate/installed overviews and close-ups are explicitly camera/position review fixtures. Native canopy renders are isolated material fixtures. Actual gameplay screenshots under full/ and bypass/ come from ordinary-control trips; earlier before-canopy copies remain labelled.

## Ordinary-control proof

**Full loop, male courier:** accept the pouch, read the levee sign and landing notice, walk the new entrance into the relay, deliver, inspect the height post, hear the calls, return under the cottonwood along the new bank path, cross to the city clerk/board, return, reread the notice without changing flags, repair the route marker, and file the full report. All eleven existing flags are true. Recorded scene readiness: 810 ms.

**Direct route, female courier:** use the main crest/bridge, visit the city clerk/board, deliver at the relay, repair the marker and file the simple report. The calls, height observation and both related report flags remain false. Recorded scene readiness: 827 ms. The route can be completed without taking the optional clues or bank return.

Both journeys use movement and E/Down/Enter inputs, with no teleports or quest overrides. The female model is selected before Player._ready for that fresh test instance; no preferences are changed. [Full inputs/flags](review/full/walkthrough-results.json), [bypass inputs/flags](review/bypass/walkthrough-results.json).

**Canopy proof:** native 112x96 source and shader-at-full-opacity renders match every pixel. All lower-trunk pixels at UV y >= 0.73 match through the fade. 3,332 crown-alpha pixels change as intended. Ordinary-path opacity reaches 0.35 behind the tree and restores to 1.0 at the end of the return. [Play and canopy audit](review/final-play-and-canopy-audit.json).

[Source/function/site/art preservation](verification/preservation-and-final-audit.json). Owned checks exited; the user's editor remained untouched. No staging, commits, deletions, external messages or new quest/save framework.

## Remaining world work

No blocker for this loop. The route still lives in the compact staging map, so it is not a completed hometown or city sector. Next implement actual hometown/riverfront connections with clear arrivals, camera bounds, collision boundaries and consistent returns, then distinct historic/works/northern/trade areas using the saved regional synthesis. Coordinate any inventory/reward/persistence change with Claude's existing ownership; do not duplicate those systems.

The [world checkpoint](../route1-landscape-2026-10-03/WORLD_DESIGN_NEXT.md) remains the wider acceptance bar. The broad world goal stays active and Route 1 is still in development. Fictional world names remain open. User runs Gemini Deep Research; prompts only if requested.

If native geography/material inputs change, regenerate affected cached surfaces and this loop from their preserved builders, then walk both optional and direct journeys again.
