# Team tactics, and creature size by stage (Claude, 2026-10-09)

## Team tactics
**Preston, 2026-10-09:** "Do team tactics next." This is pillar 3 of `docs/design/dungeon-position-2026-10-09/README.md`. The structure comes from Rescue Team DX's team orders and the arena's Kit Sense modes.

- **T** switches the partners' order and costs no turn. The HUD shows it under the bag (TEAM ... (T)), and the controls line lists it.

| Order | What partners do |
|---|---|
| FOLLOW ME (default) | Keep the chain; fight foes within 4 tiles of the leader. |
| GO AFTER FOES | Fight any foe they can see, at any distance. |
| GUARD ME | Stay beside the leader; fight only foes within 2 tiles of it. |

- **Partners flank.** When a teammate is already beside a foe, a partner walks round to the tile on the far side (`pincer_tile`), so every hit is a PINCER.
  - It will walk up to 2 tiles to get there (`FLANK_REACH`), but only while the foe has more than 40% of its health (`FLANK_WORTH`). A nearly beaten foe isn't worth the detour.
  - Any creature's attack choice now counts AMBUSH and PINCER bonuses, so a partner standing behind a foe picks its melee basic over a weaker shot.
- **Drafts for Grok:** `TACTIC_LEASH`, `FLANK_REACH`, `FLANK_WORTH`.

### Check (`tools/debug/dungeon_tactics_check.gd`)
| Case | Result |
|---|---|
| The order switch | three presses came back round; 0 turns spent |
| Pincer (melee partner Kithflare starting 2 tiles off) | reached the far side in 2 turns, then landed 6 PINCER hits in 8 turns (9 to 11 each, against 4 to 5 from its shot) |
| Far foe 6 tiles off | FOLLOW ME and GUARD ME left it alone; GO AFTER FOES took 23 off it |
| A foe beside the leader on GUARD ME | the partner fought it |
| Other checks | all dungeon checks still pass; pacing stays at its baseline (`dungeon_pace_check.gd`) |

Still: `pincer.png`.

**Known:** a ranged partner shoots from where it stands. Flanking is for when the far side is close. Setting it on a line through the leader for a ranged PINCER is a possible later step.

## Creature size by stage
**Preston, 2026-10-09:** "Kithflare and Tallowroot are just a tad too big, but I don't want making them smaller to ruin their look. They should be stage 1 size though and same for other stages."

- **What was wrong:** sizes had drifted line by line. Stormwick, a stage 3, was the same size as stage 1 Kithflare, and Sparkwick was barely bigger than either.
- **The fix:** `tools/arena/build_dungeon_set.py` builds `assets/sprites/arena/<name>/dungeon/` for all 30 creatures.
  - Each is resampled from its full-size art with the palette locked, the same method as the arena's sized creatures.
  - Size is measured as visual mass (the square root of solid pixels, averaged over eight facings), so tall and wide bodies compare fairly.
  - Targets: stage 1 = 15.5, stage 2 = 21, stage 3 = 30. Stage 1 fits inside a 24 px tile, stage 2 fills it, and stage 3 stands over it, as big creatures do in Explorers of Sky.
- **Where it applies:** the dungeon loads this set (`_load_art`). The arena keeps its own tuned small set.
- **Lineup:** `stage_sizes_after.png`, and `stage_sizes_before_after.png` (the first try, with stage 3 at 27).
- Preston approves the look. A rebuild after new art: `python tools/arena/build_dungeon_set.py <name>`.
