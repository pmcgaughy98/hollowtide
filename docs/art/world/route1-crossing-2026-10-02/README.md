# Route 1 river crossing, October 2, 2026

## Latest refinement: one bridge peg and flowing river

The peg immediately right of the one below the character has a complete outline and foot. A bounded Retro Diffusion edit preserves every other pixel of the accepted bridge. The existing teal river now has a slow downward current and sparse moving highlights, preserving the bank contour and stationary bridge. A normal-control city-and-home round trip and frame-stamped motion checks passed: zero observed errors, eleven existing warnings. RD charge $0.18, remaining $3.08.

[Current exact files, preserved sources, prompt/receipt, motion preview and verification](peg-and-river-flow/README.md). Earlier revisions below are retained.

## Latest refinement: stone supports and native city landing

The patched corner extensions were replaced with coherent paired Retro Diffusion supports; white fringe was removed while the original wooden span stayed registered. The east-bank landing now tapers from the bridge into the existing courtyard using the same native soil phase and turf/earth border as the west road. A normal-control round trip to the city courier and home passed with zero observed errors; eleven existing warnings remain. RD spend $0.37, remaining $3.26.

[Current exact files, before/after images, prompts, receipts and verification](bridge-abutment-refine/README.md). The earlier revisions below and their original sources are retained.

## Latest correction: complete bridge corners and matching road entrance

The four clipped stone corners were completed with Retro Diffusion, with the original core preserved and clear canvas edges. The road now shares the old lane's width, soil texture/phase and borders at a joined junction. A normal-control round trip reached the city courier and returned home. Runtime/script validation passed; existing warnings and the resolved historical console preload are documented. RD spend $0.74.

[Current exact changes, before/after captures, prompts and verification](complete-bridge-junction/README.md). This supersedes the bridge-source and road-junction details in the prior revisions retained below.

## Latest correction: bridge banks and grounded road

The bridge is centered over the river with both stone approaches overlapping dry land. The levee road now joins the hometown lane, uses the existing loess colors and narrow turf edging, and has gently shaded shoulders without a detached shadow. A leftover western dirt fragment was removed. The final ordinary-control walk reached the city clerk and returned home. Latest diagnostics: 0 errors, 10 existing warnings. This fix added no paid generation.

[Latest correction, before/after captures, exact files and verification](bank-road-fix/README.md). The initial crossing record below and its original captures are retained.

## Initial crossing implementation and verification


The playable prototype now connects the fictional hometown's dispatch lane to a raised grassy levee road, a river bridge and a small city riverfront arrival. This implements Preston's confirmed west-bank home → levee entrance → bridge → east-bank city order. Final Hollowtide place names remain open. The actual hometown and city districts are still future maps.

## Play and review

Run `scenes/first_route_prototype.tscn`. Move with WASD or arrows; E interacts, J opens field notes, P opens the party. Speak to the hometown dispatcher, leave southeast to the river-road sign, follow the crest track to the bridge and walk east into the arrival courtyard. The clerk records your arrival; the board describes the future historic, works, older school and inland trade quarters. Return across the bridge to the existing landing and finish the delivery.

The launch setting was preserved. The female preview inherits this prototype scene.

- [Levee entrance](review/verified_levee.jpg)
- [Bridge walk](review/verified_bridge.jpg)
- [City arrival](review/verified_city.jpg)
- [City directions](review/verified_board.jpg)
- [Preserved landing](review/verified_return_landing.jpg)
- [Both report choices](review/verified_report_choices.jpg)
- [Completed assignment](review/verified_full_report.jpg)
- [Exact changed files](CHANGED_FILES.md)

## Implementation

World and camera limits extend to 1024×640. The original scene's 40×24 authored tile data remains exact; surrounding ground is added at runtime. The river occupies x=448..672. Water collision is solid above and below the bridge, leaving the player's feet a y=408..432 walking corridor.

The levee uses the approved ground texture on a broad grassy crest and shaded earth shoulder, with a worn track. The older masonry remains a separate retaining structure. The deck draws beneath actors and its south rail sorts by its foot, keeping the walker above the deck.

The city branch temporarily reuses the approved hall. The clerk reuses the approved female chibi. New entrance, clerk and board interactions add discoveries to field notes without replacing the courier assignment. The original post, marker, calls, high-water observation and both report choices retain their code.

## Verification

A disposable deterministic 60fps game, seed 20261002, was driven using ordinary movement actions and actual key inputs. No teleport was used for traversal.

| Probe | Physics frame | Result |
| --- | ---: | --- |
| Home | 2358 | Player (48,192), pouch not accepted |
| Levee entrance | 2582 | Player (216,264), pouch and sign recorded |
| Bridge center | 16176 | Player (551.792,415.792), visibly on deck |
| City clerk | 17726 | Arrival registered |
| City board | 20509 | Directions recorded |
| Bridge north boundary | 22542 | Up input stops at y=408.003 |
| Bridge south boundary | 22612 | Down input stops at y=431.999 |
| Return and full report | 29458 | Player back at dispatch, all eight original and three new flags true |
| Alternate simple report | 31578 | Report complete, calls omitted, height marks recorded |

For the alternate report test only, `report_done` was reset in memory after the completed round trip. The first choice was then selected through the real UI with Enter. This fixture did not modify any file or move the player. Field-note text includes all three new discoveries.

Final observed diagnostics: **0 errors, 11 existing warnings**, consisting of battle variable shadowing and the Rimefin UID fallback. This is evidence for this playable slice, not a full project audit. The capture archiving child editor also completed with no boot or script errors. All test instances were stopped.

[Full probes, diagnostics and input scripts](review/verification.json) are saved. Source checks confirm unchanged authored terrain and unchanged marker, post, river, height, report-choice and report-recording functions. Exact before/installed source copies and their hashes are archived here.

## Bridge generation and preservation

One Retro Diffusion `rd_pro__topdown` still, 256×80, used the approved hall and current ground atlas as style references. Confirmed charge **$0.18**, remaining balance **$4.37** at the returned receipt. Request: `792a9501-5f48-4ad7-9869-e8c99ca51a2d`.

The original is `bridge_rd_original.png`; the exact prompt and receipt are `bridge_prompt.txt` and `bridge_receipt.json`. Runtime `river_bridge.png` is 272×96 after transparent 8px padding on every side; all original pixels remain unchanged. No further paid generation was made.

Menu art, creature/battle work, approved source assets and unrelated dirty files were preserved. No staging, commit or deletion was performed.

## Remaining

This is a first playable geography pass. Full hometown streets, city sectors, final names, interiors, distinct city architecture and additional vegetation variation remain. Refine the levee bends, path transitions and bridge bank dressing visually before expanding districts. The original bluff/landing descent can receive terrain polish within this established geography.
