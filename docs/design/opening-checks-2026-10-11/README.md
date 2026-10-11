# Current opening checks, October 11, 2026

Task 6 of Claude's master queue is complete. `opening_flow_check.gd` now loads the campaign title explicitly, regardless of the F5 dungeon development scene. It follows actual scene changes through title, storm, soul, Dialogue Manager flood talk and playable riverbank. Mouse/keyboard input selects New Game, the starter and its partner. Both choices must survive in the real team record.

`first_morning_check.gd` is retired as an entry point. Running it prints the reason and replacement and exits **2**, with **no gameplay assertions**. Its shared navigation/input helpers remain for `world_navigation_check.gd` and `riverfront_quay_check.gd`; both inheritors still parse. Their retained human-courier modes were not replayed or claimed current campaign coverage. The old hardcoded D: output path is replaced by `user://legacy-world-check/`, created by initialization.

## Verification

Native Godot 4.7.2 Compatibility, isolated APPDATA, owned processes only. Three staging runs and three installed-live runs each pass **83/83 assertions** in total:

- Kithflare / first offered partner: 27/27.
- Tallowroot / second offered partner / Reduce Motion: 27/27.
- Rimefin / first offered partner / unskipped natural storm: 29/29, including time freeze/greyscale and automatic soul transition.

All three starter choices, both partner-response positions, normal/reduced motion, storm skip and natural storm are covered. This is not a six-combination matrix, natural dungeon clear, combat balance or later pilot-chain check. Native captures and JSON results are in `review/stage/` and `review/live/`.

Retired entry reports exit 2 in staging/live. Both helper inheritors pass Godot `--check-only`; this proves preserved inheritance/parser compatibility, not their old navigation gameplay. Final installed opening logs have no script/resource/shutdown errors. Staging retains the existing Windows certificate-store diagnostic. The two initial native candidate runs exposed Dialogue Manager's retained evaluated-expression resource references at shutdown; the final check clears that transient **in-memory** cache after freeing its scenes. It changes no dialogue file or plugin source. Final natural-storm staging and all three installed-live runs have clean resource teardown.

The archived old-driver runs reproduce the reported `_boot_done` access on `dungeon.gd`, then hit the owned runner timeout. They occurred before the candidate check reached staging and are explicitly failures, not passes. A broad staging refresh did not complete; `stage_checks.py` refreshed the current opening dependencies and two candidates before successful verification.

## Run it

Use a separate APPDATA profile to avoid changing personal menu preferences. `run.py` does this automatically:

```powershell
python run.py manual --live hero=1 partner=1 reduced
python run.py natural --live hero=2 partner=0 automatic-storm
python run.py retired --live --retired
python run.py navigation --live --parse world_navigation_check
```

The driver uses the documented local Godot path and current live/staging roots. Godot's equivalent is `--path <project> --rendering-method gl_compatibility --fixed-fps 30 --script res://tools/debug/opening_flow_check.gd -- hero=1 partner=1 reduced`; results/captures go to `user://opening-flow-check/`. Exit 0 means every recorded assertion passed, exit 1 means failure; only the separate retired entry exits 2. Audio uses the Dummy driver in automated review, so this verifies audio wiring only incidentally, not listening quality.

## Scope and preservation

Only the two named checks and queue/handoff documentation were installed. Original checks and status documents are in `originals/`; exact before/after diff and hashes are alongside this note. Existing `.uid` files, F5 setting, game scripts, art, audio, rules and Claude's concurrent work remain. No generation, paid calls or commit. Preston's next explicit request is finishing **Rootbank Warren** dungeon presentation; its existing wiring/layouts are the contract.
