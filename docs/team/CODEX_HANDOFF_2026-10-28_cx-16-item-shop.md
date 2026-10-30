# Codex task-run handoff: cx-16-item-shop, 2026-10-28

STOPPED at the queue eligibility blocker. Zero batches generated or installed in this run.

Read AGENTS.md, CLAUDE.md, the latest docs/AI_COLLABORATION.md and CODEX_ART_TASKS_2026-10-26.md, including How Codex delivers and installs.

## Done and verified by running read-only inspection

Python enumerated every current batch in order and checked its DELIVERY.md and review.json. All 16 listed batches (cx-01 through cx-16) already have DELIVERY.md, with no active batch locks. The instruction to skip every such batch leaves no eligible batch. A delivery marker does not mean approval or that a later re-brief is satisfied.

Existing review records contain 54 pending, one yes (Tower reference key) and three redo entries. Those counts include the obsolete cx-01 shop entry and are not counts of distinct current slots. No review answer was changed.

Python/Pillow and registry inspection confirmed the cx-16 inconsistency:

| Item | Verified current state |
|---|---|
| Task brief and live registry | trading_post, 204x192, door [79,142,22,48], 8x3 base, roof-first design |
| slots.json registry stamp | 2d9b461262c916bc1555519d5181ded20a2b692668e25e741ace2a69ec6a959e; matches live registry |
| refs/town.building.shop.json | older lean_to, 204x144, door [79,94,22,48] |
| refs/town.building.shop.png | older 204x144 target; associated grid/card also retain that earlier layout |
| Existing cx-16 prepared.png | 204x144, the earlier lean_to |
| Existing cx-16 review | pending |

The revised task explicitly supersedes both the cx-01 box and the same-morning cx-16 lean_to. Do not install either. The old DELIVERY.md is historical evidence, not a delivery of the revised trading post.

## Source issues for Claude / resume condition

1. Explicitly reopen the revised cx-16 batch despite its existing DELIVERY.md, or provide a new batch id. Do not delete a prior delivery marker to bypass the skip rule.
2. Re-export its current reference JSON/target/grid/card. The registry and slots.json already agree; the per-slot reference export is outdated.
3. Obtain Preston's approval before a credit-spending generation call. A new exact-size candidate must pass prepare/validate and receive his visual yes before installation.

## Unverified and not run

No new image, prepare_slot.py, validate_slot.py, review sheet, Godot launch, install_slot.py or post-install checks in this run. Historical PASS lines apply to the previous contract and are not claimed against the current 204x192 brief. No new visual approval, in-game appearance, gameplay, v1/v2 or export result is asserted.

After integration is eligible and approved, the required post-install command is (NOT RUN):

    python tools/debug/run_checks.py hub_town building_template art_slots --jobs 1 --fixed-fps 30

The runner accepts --fixed-fps 30 and passes it to Godot internally.

This handoff is the only file written in this task run, at the location expressly requested by the latest message. No generation or credit spend, asset/registry/source/review edit, creature sprite or data change, Route 1 change, access to docs/creatures/riftfin-redo-2026-10-28, real save, commit or cross-chat message.