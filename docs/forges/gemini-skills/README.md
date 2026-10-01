# Portable Forge instructions

Each file contains a Forge's image prompt and the named inputs to supply in Gemini. Attach the reference images and paste the creature, character or asset brief. These are portable instructions, not installed tools or full app backups. Generated artwork still needs review and preparation for Godot.

## Current Character and Walk copies

The downloaded graphs predate the saved chibi/portrait revision. `tools/export_opal_forges.py` now applies that separately verified revision when generating these two files. It preserves the original downloaded graphs under `../opal-export/` and reads the current prompts from `../records/character-two-tiers-2026-09-30/verified-prompt-record.json`.

To refresh only these two copies from the project folder:

```text
python tools/export_opal_forges.py --forge character-model-forge --forge walk-cycle-forge
```

The exporter checks the downloaded graph fingerprint, input mapping and reopen-verification record before writing. If a newer download differs from the recorded base, it stops rather than applying an older revision over it. Review the new graph and update `../records/verified-export-revisions.json` with an appropriate current revision before exporting again. Previously downloaded files are retained in `../opal-export/history/` when replaced.

Preston's selected main character is the original teal/goggles chibi courier. Claude's integration handoff is `docs/art/characters/chibi-courier-preparation-2026-09-30/CLAUDE_HANDOFF.md`. Source cuts are ready; missing walking phases still need new art. Portrait mode translates the same identity into adult waist-up proportions.

## Current World copy

The World Forge now uses the selected chibi map courier's32x32 cell/about30px standing height. Its saved, reopened revision is in `../records/world-chibi-scale-2026-09-30/verified-prompt-record.json`; the exporter merges that record over its matching downloaded base and retains the original graph.

```text
python tools/export_opal_forges.py --forge world-asset-forge
```

Use the current Route1 prompt list: animated water is a four-cell2x2 surface run; bank transitions are separate sixteen-cell4x4 atlases, with one neighboring material per run. The chibi scale is a generation target, not approval of the optional reduced character cuts or confirmation that the missing walk phases are complete.
