# Highbank ground pass, October 9, 2026

Implemented proposal: the first art slice in Claude's hub-layout handoff. Moss-green bluff, warm stone paving along the exact road mask, earthen terraces, cut clay ledges, stair treads at the two existing cliff crossings, and muted river water. Ground is drawn from scratch in Godot at native 24px scale. Broad close-tone islands replace the first review's noisy patchwork. No image generation, paid art calls, asset PNG edits, or external game data.

Runtime edits: new `scripts/town/highbank_ground_painter.gd`; `hub_town.gd` adds a painter delegation and names the original `paint_blockout()`. Its complete original picture remains the fallback when the painter is absent. The remainder of the controller is unchanged.

Claude's `town_layout.gd` is the exact contract. No doors, path tiles, footprints, collision, service roles, team state, creature sprites, menu, prologue or dungeon rules changed. Existing building and service-spot pixels remain exact. Open area rectangles get a quiet perimeter and ground underneath; their service locations remain exact. Buildings are still the blockout, deliberately awaiting the next art slice. This is not a finished town or implemented shop/job/roster service.

## Native verification

- `ground_check`: 13 assertions pass, including native D-key state through the current controller, movement across both stairs, blocked cliff/water, all 13 open doors, exact building/spot pixels, repeatable texture, dimensions and shared creature finish.
- `hub_town_check`: no building overlaps, all 13 doors reachable from Home, ferry reachable; real four-step movement and partner following; all 12 non-dungeon places answer; walking into the Mouth triggers dispatch.
- `town_loop_check`: actual prologue to town scene change after three presses; Mouth to dungeon with the chosen party; forced clear returns bag, taught moves, IQ and clear count to the Hall steps; the next run receives them; forced faint returns with the existing bag-loss policy. This checks transitions/state transfer, not an organically played full dungeon or combat balance.
- `fallback_check`: with the new painter physically absent in the isolated review copy, the original blockout returns byte-for-byte.
- Native map and five viewport stills inspected. Final logs have no script/resource errors. Existing Windows root-certificate diagnostic remains.

Run F6 on `scenes/hub_town.tscn`, or New Game through the installed creature opening. WASD/arrows move; E interacts. Claude already wired the scene loop before this art pass, and that work is preserved. Team data still lasts only for the running session; disk saves remain Claude's work.

## References and next handoff

Authority: `docs/world/hub-layout-2026-10-09/README.md` and `scripts/town/town_layout.gd`; Claude's synthesis and positions are used without reinterpretation. Existing `docs/research/pmd-video-notes-2026-10-09.md` supplies scale/context. No foreign images, maps or sprites are imported.

Before the new hub handoff arrived, Firecrawl was used for a bounded rescue-board inspection: [pmd-red include index](https://github.com/PikalaxALT/pmd-red/tree/master/include) and [mail interface](https://github.com/PikalaxALT/pmd-red/blob/master/include/pokemon_mail.h). The GitHub targeted query yielded no useful content; reading the raw header only verified separate headline/body responsibilities, not a complete job lifecycle. That research did not determine the terrain or add services. No code, data, numbers, game text, art or music from the reference was copied.

Next art slice: Wayline Hall, exactly 240x144px at (456,24), door tile (24,6). It remains a creature village building proposal for Preston to review. Shop/storage/job rules stay with Claude. No commit, reset, revert or stash.
