# Hollowtide: playable world and product direction, October 8, 2026

Preston asked to continue the game map, use the Google Maps connection and Game Ideas references, and work toward a product that can compete with Nexomon and Coromon. This is a proposed quality plan, not a claim of release readiness or commercial success. Later direct decisions remain authoritative.

## What this slice adds

A separate 768 x 640 city relay yard, entered through the riverfront's eastern lane and exited through its western lane. Existing native artwork is composed into an office, workshop and garden bays, a loading court, shaded tree borders and a quieter return loop. A small sorting exercise asks the courier to inspect three handling notices and route living cuttings. Wrong choices remain recoverable. Completion and inspected notices survive leaving and returning during this run.

The yard keeper opens the existing practice matchup picker. Escape returns from the fight to the picker, then from the picker to the same yard. Practice is an opt-in exhibition using the arena's current roster and kits. It does not recruit creatures, evolve the owned party or produce campaign rewards. No combat rules or disk-save architecture change.

Names, activity dialogue and layout are proposals implemented for play review. Existing source art is reused; there is no new paid generation. Original sprite refinements, backup archives, the darker Oxbowarchon reference and concurrent Claude work are preserved. The game's current main scene is left as found. Launch `scenes/city_relay_yard.tscn` with F6 to review this addition, or enter it from the connected riverfront world.

## Reference decisions

Local source: `C:/Users/pmcga/OneDrive/Documents/HollowTide Sprites/Game-Ideas/`. Inspected the Coromon hometown, Hayville, Route 1 and river references; Nexomon river and town references; and the Nexomon battle reference. Principles adopted: activity spaces framed by foliage, readable path junctions, a useful loop back, distinct loading destinations, and a clear main exit. Reference images remain outside shipped assets; no rival map or art is copied into the game.

Live Google Maps Grounding Lite MCP search: `Pony Express Museum and Patee House Museum, St Joseph Missouri United States`. The result confirms nearby but distinct courier heritage destinations. That relationship is a research input, not fictional geometry or a literal modern route. Required attribution: [Pony Express Museum - Google Maps](https://www.google.com/maps/place//data=!4m2!3m1!1s0x87c01a54e827d44f:0x9f792b3e117cc2b5), [Patee House Museum - Google Maps](https://www.google.com/maps/place//data=!4m2!3m1!1s0x87c01a5317d4edd7:0x64c2a7f8d7d3cd3d).

Additional primary online references: [National Park Service: Pikes Peak Stables](https://home.nps.gov/places/pikes-peak-stables.htm) describes preparation at the stables before collecting mail at the headquarters. [St. Joseph's parks](https://stjosephmo.gov/577/Parks) and [community attributes](https://stjosephmo.gov/346/Community-Attributes) support planted routes linking city activity spaces. The yard's separation of handling bays and planted return path is our fictional interpretation, not a reconstruction of those sites.

## Competitive target

[Nexomon: Extinction's official Steam listing](https://store.steampowered.com/app/1196630/Nexomon_Extinction/) presents a story, 381 creatures, distinct regions, side quests and rematches with stronger opponents. [Coromon's official game page](https://coromon.com/games/coromon/) presents more than 120 creatures, tactical battles, six biomes, puzzles, secrets and configurable difficulty. These are finished adventure benchmarks. Matching their creature counts is not this project's next milestone; Hollowtide retains its directed 20-line / 60-form target.

The proposed differentiator is a courier adventure in a lived-in river region, with creature partners whose anatomy determines their work and real-time arena roles. Deliveries should lead to decisions, discoveries and battles, rather than repeated walks between markers. Hollowtide's current prototypes do not yet demonstrate that full commercial loop.

| Priority | Demonstrable milestone | Current boundary |
| --- | --- | --- |
| 1 | A stranger can play a 20-30 minute chapter: choose partner, deliver, explore a side branch, fight, obtain a partner, use it, finish a chapter objective | World traversal and arena practice exist separately. Campaign recruitment and the arena-to-world handoff need an agreed design and implementation with Claude. |
| 2 | Save, quit and reload restores party, completed deliveries, location and campaign progress | Existing world activities and PlayerParty are run-local. Reliable disk saves remain a required product milestone. |
| 3 | Every map has a memorable landmark, a clear through-route, one optional discovery and a reason to return | Yard has a tested local task and return loop. Broader district identity, habitat encounters and meaningful rewards remain unfinished. |
| 4 | Every included creature is readable at game size and has a useful role; player understands targeting and timing | Seven arena lines / 21 forms exist. Balance, controller play, tutorials and sustained play feedback remain gates. The seven-form material pass has documented residual walk variation. |
| 5 | A cohesive presentation at the intended display sizes | Existing world materials are reused here. New yard prop identity, richer transitions, audio mixing, control hints and actual player feedback still need review. |
| 6 | An exported build works for a new player without editor tools, with no blocking crashes, lost progress or navigation traps | This addition receives native runtime checks. That is not a release-build, campaign or market validation. |

Proposed next completion after this map review: one visible overworld encounter that enters the current arena, returns to the exact courier location and retains the existing party and delivery state. Decide campaign recruitment at that boundary with Preston and Claude. Do not replace Claude's current combat AI or infer a capture rule from the superseded turn-based battle.

## Review evidence

The isolated review project and logs are at `D:/dev/hollowtide-map-20261008/`. Native checks exercise both couriers, movement and real entrance triggers, wrong/correct routing choices, the quiet loop, practice selection and fight, two Escape returns, cached completion and party/controller/quest preservation. Screenshots and structured results are under `review/`. Initial diagnostic runs remain preserved separately. Verification details and any remaining errors are recorded after the final run; screenshots alone do not certify saves, recruitment or the full campaign.

The test project has its own user-data directory, with the editor MCP autoload and plugin disabled only in that copy. Live settings are untouched. The first preparation omitted the project's root audio-bus resource; it was copied into the stage before the final runtime checks. Import exit codes are zero; early import UID/empty-resource-path and sandbox editor-settings diagnostics are retained in their actual logs. Final runtimes retain the Windows certificate-store diagnostic under the sandbox. No final script errors are accepted. Native captures also caught and corrected a launcher layer that hid the arena HUD; the final test checks that the arena HUD draws above the practice map.

The final native combat snapshot hash and the later live hash are in `installation.json`. Claude was actively changing combat while this map was built, so native evidence certifies the tested snapshot only. Codex installs only the listed world connections, the new scene/practice wrapper, the debug check and this handoff. The core arena script is never replaced by this installer.
