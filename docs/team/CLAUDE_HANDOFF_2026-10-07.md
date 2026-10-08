# Claude handoff, 2026-10-07

Start a new Claude session here. **Required reading (read in full before the first answer):**
1. This file.
2. `docs/creatures/arena-starters-2026-10-07/README.md` (how the arena was built, pass by pass).
3. `docs/creatures/arena-balance-2026-10-07.md` (kits, essence chart, simulator results, open issues).

Then the top entries of `docs/AI_COLLABORATION.md` as usual.

## Where things stand
**Hollowtide is now a 2D top-down real-time arena fighter inside a courier campaign** (Preston's pivot, 2026-10-07). Still Godot 4.7.2, still pixel art. The Unity project at `D:\dev\hollowtide-unity` is parked; ignore it. The turn-based battle screen and its back views are reference only now.

**Play it (updated the same evening):** press F5. The main scene is now the matchup picker (`scenes/move_preview.tscn`): your creature, the enemy, 1v1 or 3v3, FIGHT. In the fight your creature's AI moves and fights on its own; LEFT/RIGHT pick the enemy it goes for, UP lets it choose, K fires the signature, ESC returns to the picker. The arena's own test keys (1-4 line, F/G stages, T rival, N team size, B rocks, V shake, M arena, R rematch) still work. Later entries in `docs/AI_COLLABORATION.md` cover the evening's work: team fights, the Ironvent line and kit, boulders, hitstop, telegraphs, the control model. (2026-10-08: keys 1-3 fire abilities and 4 the ultimate; the picker has six columns, the sixth the Oxbowarchon line; Vitrecrag is a tank.)

**What's built** (`scripts/arena/arena_prototype.gd`, `arena_signature.gd`, `hollow.gdshader`):
- All nine starter-line forms as arena sprites, 8 facings, walk cycles, colour-locked by Codex (`assets/sprites/arena/`).
- Rendering: the fight draws at 384 x 216 in a SubViewport shown at 3x (true chunky pixels); effects restyled from the "Pokemon Arena" reference; four painted RD impact animations.
- Kit system: `KITS` (role, moves, speed, HP, passive, AI movement profile), `MOVES`, and per-move AI rules in `_wants`. Three full kits: **Stormwick** (skirmisher; lightbulb physiology: spark, heat and light), **Scourmaw** (long-range glass-cannon assassin; Hollow = absence, not ghost; Phase, Sinkhole, Riptide, decay; signature Undertow is the dive from below), **Rampartroot** (tank; roots that hold and cripple movement abilities, walls, thorns). The other six forms carry one basic move each; their draft kits are in `docs/creatures/arena-kits-2026-10-07.md`.
- Signatures: Stormlantern (paralyses every opponent, then one lantern strike), Root Rampart, Undertow (dive).
- Preston's essence triangle as `ARENA_CHART`. **Conflicts with `scripts/essence_chart.gd` and THE_CONCEPT; Preston and Grok to reconcile.**
- `tools/debug/arena_sim.gd`: AI vs AI balance simulator, headless, about a minute for 50 matches per pairing. Current: Stormwick 52% vs Rampartroot, Scourmaw 56% vs Stormwick, Rampartroot 74% vs Scourmaw (each favoured side per the triangle).

**Audio:** all music retuned to A = 432 Hz (`tools/retune_432.sh`, originals kept); UI sounds rebuilt at 432 and the menu sounds made soft and warm.

## Preston's decisions this session (all recorded in memory too)
- Pivot to the arena fighter; keep the pixel style; no real-time 3D; AI low-poly models rejected.
- Battle model: player moves and fires the signature; the creature's AI uses the rest of its kit strategically; kits include non-damage moves; every form gets a passive; roles (skirmisher, assassin, tank, and more).
- Hollow is void/absence. Stormwick is a lightbulb (Ember/Electric: current, heat, light) with Flashstep. Scourmaw: long-range assassin, signature is the dive. Rampartroot: tank whose roots stop evasive creatures; Phase breaks roots (frees from the hold, stays crippled).
- Modes: 1v1 plus at least 2v2, 1v1v1, 2v2v2v2. He is wary of support kits being dead in 1v1; proposed rule: **no dead moves** (every support move works alone and scales with allies).
- The campaign stays (courier world). Proposal: `docs/world/arena-battles-in-the-courier-world-2026-10-07.md` (the arena is the battle system wherever you are; modes map to story situations; Wayline trials as the ladder). Three questions there for Preston.

## Next steps (suggested order)
1. Preston's answers: main mode, the Wayline/courier framing, catching in the arena, essence chart reconciliation.
2. Make the arena handle any number of fighters on teams (no code path should assume two), then 2v2 in the simulator.
3. Kits for the other six forms from the drafts, once Preston and Grok approve; balance each with the simulator.
4. A first campaign slice: one route encounter that starts an arena fight on that route's ground.

## Next build: arena physics (added late 2026-10-07)
Preston rewatched the reference and wants three things:
- **Destroyable objects** (rocks).
- **Collisions into walls.**
- **The psychic lift** (Mewtwo lifting a rock).

Every event in the video is listed by timestamp in `docs/research/arena-comparison-2026-10-07/event-inventory.md`, with frame sheets in `inventory/`. The build plan is at the bottom of that file:
1. Rocks that block and break, leaving rubble.
2. Wall and rock slams.
3. A lift-slam-throw move.

Build them in that order. Who gets the lift is open; Claude suggests Rampartroot heaving a rock with its roots. Re-run `arena_sim.gd` after each step, because rocks change kiting and cover.

## Watch out for
- **Nothing is committed since `c864fac`: about 146 changed or new files** (arena, art, audio retune, tools, docs). Ask Preston before committing; commit with `-c user.name="Preston McGaughy Jr" -c user.email="pmcgaughy98@gmail.com"`.
- Every combat number is a placeholder for Grok; Grok owns creature and move rules.
- Retro Diffusion balance $6.80. Use queued jobs (`tools/arena/rd_*.py`); `tools/debug/rd_creature.py front` can pick up the wrong job if a sync call drops while several run in parallel.
- The arena's world is not scaled in code (the SubViewport does the 3x); draw world things in map pixels. The bash heredoc sometimes breaks on long Python edits; write the script to a scratch file instead.
- Older work still valid: Riftfin back v6 and matched idles in Godot; the starter turn-based art. Godot test tools for the arena: `arena_capture.gd`, `arena_movie.gd`, `arena_roles_movie.gd`, `arena_vfx_check.gd`, `arena_stormwick_check.gd`, `arena_sim.gd` (all in `tools/debug/`, run with `--fixed-fps 30`).
