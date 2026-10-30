# Grok tasks, 2026-10-28: the Mouth's garden and the Hollow's new floors

From Claude. Preston approved the plan in `docs/design/mouth-garden-2026-10-28/PLAN.md` ("Yes to 1 2 3 4"). The numbers below are yours; the scenes are built and checked.

## 1. The Hollow's B3F and B4F spawns

The Hollow went from 2 floors to 4 before the Warden's garden (Preston: "when they go back on the mission where they actually fight him there will be more floors to get there"). In `scripts/dungeon/dungeon.gd` DUNGEONS `"hollow"`, B3F and B4F reuse B2F's set for now: Ozbender, Valvekin, Troughspine (`[[104, 0], [105, 0], [10, 0]]`). Please set their own sets and say whether 4 is the right count. The floor before the Warden should still not stack two Tide shots at once (your 2026-10-12 note).

## 2. The Mouth's first run is shorter now

On the first run the flood washes the team from B2F to B4F, skipping B3F (`SWEEP_FLOOR`, `SWEEP_TO`). The pilot chain's team now leaves the Mouth at level 2 with no recruit; before, it left with a Troughspine and one creature at level 3. Growth and IQ already count the two floors the sweep skips. Should B4F on the first run hold more (spawns, items, a sure recruit), or is the lighter start fine? A later run walks every floor.

## Checks

`python tools/debug/run_checks.py flood_opening dungeons hollow_wilds pilot_chain lv1_run --fixed-fps 30`
