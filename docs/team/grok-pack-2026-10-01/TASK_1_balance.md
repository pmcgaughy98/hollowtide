# Task 1: balance proposal (Grok's main job this week)

**Attach:** `00_GROK_CONTEXT.md`, `attach_battle-rules.md`, `attach_sim-report.md`
**Paste this prompt:**

```text
Read the three attached files. Propose stats and move numbers that fix the six problems listed at the end of battle-rules.md. Use the game's exact damage formula and show turns-to-faint math for at least three matchups. Do not change the rules themselves, only numbers. Label every number PROPOSAL. Be honest about anything you cannot calculate. End with one JSON block in the exact overrides format below, using in-game names, and nothing after it.
{"creatures": {"Name": {"base_hp": 0, "base_attack": 0, "base_defense": 0, "base_speed": 0}}, "moves": {"Move Name": {"power": 0, "max_uses": 0}}}
```

**Good answer has:** different stat spreads so the nine Ember creatures play differently; no speed ties between likely opponents; Kingstone Rail no longer unlimited at 60; battles long enough that use limits matter (about 4 to 8 turns); a short reason per change.

**Save the result:** copy the whole answer into `docs/team/grok-pack-2026-10-01/RESULT_task1_balance.md`, and the JSON block alone into `RESULT_task1_overrides.json`. Claude runs it through the simulator when it is back (one command) and reports what changed. Nothing touches the game until you approve.
