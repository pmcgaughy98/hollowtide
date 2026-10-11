# Inventory evidence, October 11, 2026

The parent [AI asset inventory](../ai-asset-inventory.md) is the reader-facing record. This folder contains a repository media/resource census and source-reference index, not a release package manifest.

`asset-groups.csv` groups every recognized image, audio, font, shader, scene and Godot resource under `assets`. It includes unused takes/backups. Classification describes documented family workflows; mixed/legacy rows deliberately do not certify each file's provider. Counts exclude Godot `.import`/UID metadata, font license text and non-media JSON. `source-references.json` lists literal `res://` strings in first-party scripts, scenes, resources and dialogue. Dynamic interpolation, concatenated paths, optional resources and scene reachability prevent interpreting literal counts as shipped-file counts.

`scan.py` and `package.py` reproduce the census/register from the live source path specified in them. They read sources and write only to their own work directory. `validation.json` records count coverage and local evidence-link checks. No image or audio generation, rights clearance, native gameplay tests or build export were performed for this Markdown task. The official Valve policy link was read on October 11; provider licensing terms were not researched for this inventory.

The snapshots are dated evidence. Claude is working concurrently, so new assets/copy may appear after the census. Rerun the census against the eventual export source and reconcile the actual package and store media before submission. Preserve existing originals and generated-source receipts.

`original-docs/` retains the three queue/handoff documents before this task's status update. Installation changes documentation only. No game art, audio, scripts, settings or old checks were changed.
