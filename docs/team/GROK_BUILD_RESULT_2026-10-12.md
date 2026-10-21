# Grok Build result, 2026-10-12 (filed 2026-10-16)

Lane: The Hollow's floors against the pilot team. No story flags, scenes, art, save model, or names. Nothing committed. `pilot_chain_check.gd` was not run.

## Why seed 99 died on B1F

The old B1F rolled Listener, Troughspine, and Skimlet. Troughspine was the creature that downed the leader, with one wild killed in 41 turns.

Spring Spit is range 110. At 24 px a tile that is 5 tiles, one past Ember Shot. It is Tide. Into Kithflare (Ember, second Electric) the chart is 1.5 times 0.9 = 1.35. With wild damage 0.7 the hit is `10 * 0.6 * 1.35 * 0.7` = 5.67, about 6 into 40 HP. Rake into Troughspine's Tide half is `14 * 0.6 * 0.75` = 6.3, about 6. Seep heals 6, so one heal cancels one Rake. Troughspine has about 29 HP (`180 * 0.2 * 0.8`). A seep then lasts 3 more turns at 6 each, 24 HP back. Listener on the same floor is a second Tide shot (Echo Tap, 3 tiles). The autopilot walks at the nearest foe and does not focus the healer. That targeting is Claude's. The floor was still the wrong stack. Autopilot was not changed.

## What changed

In `scripts/dungeon/dungeon.gd` only.

- Hollow B1F is Listener and Skimlet. Troughspine is off that floor.
- Hollow B2F is Ozbender, Valvekin, and Troughspine. Listener is off that floor, so the floor before the Warden is not two Tide shots.
- Troughspine learns Spring Spit only. Archroot learns Seep on evolving. Heal 6 and `SEEP_TURNS` 3 stay. No new move id.

Spring Spit range stays 110. `EXP_PER_KO` 8, `EXP_BOSS` 110, and the level curve stay as set on October 11. Boss multipliers stay. Wild count stays 3, so a quiet Hollow still pays 6 times 8 before the Warden room.

## Probe

`tools/debug/warden_probe.gd`, three seeds, 2026-10-12. Log: `docs/design/warden-probe-2026-10-12.log`. The aim was the Warden met on at least two of three. It was met and beaten on all three. Faints 0.

```
WARDEN seed 99: cleared after 323 turns (3358 frames); reached B3F of 3; Warden met true, its health lowest 0 of 168; the leader went down on ? to nothing after 0 turns, 0 wilds downed (Lv 6, max 41); faints 0
WARDEN seed 7: cleared after 423 turns (3466 frames); reached B3F of 3; Warden met true, its health lowest 0 of 168; the leader went down on ? to nothing after 0 turns, 0 wilds downed (Lv 6, max 41); faints 0
WARDEN seed 31337: cleared after 259 turns (3285 frames); reached B3F of 3; Warden met true, its health lowest 0 of 168; the leader went down on ? to nothing after 0 turns, 0 wilds downed (Lv 8, max 44); faints 0
```

The probe starts the team at level 5 and prints the level at the end, not when the Warden wakes. Seeds 99 and 7 finish at 6. From the scripted start (level 5, 14 EXP) a quiet Hollow plus the Warden pays 194, which crosses the 120 to level 6 and leaves 88 of 140. Seed 31337 finishes at 8. A quiet floor cannot do that. Extra KOs did, and the log does not say whether that seed was already above 5 on entering the room.

Shader sampler lines in `docs/design/warden-probe-2026-10-12.err` say Continuing. They did not stop the check.

## Still open

`pilot_chain_check.gd` was not run after this change. The essence chart and the health-carry re-measure were not in this task. Valvekin's only move is still Glass Guard.
