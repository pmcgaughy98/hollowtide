---
name: mech-rpg-synthesis
description: Lessons and tools from the mech RPG Claude session (2026-10-20) for art passes, measuring art against references, generating world and UI art with Grok Build, and working alongside Codex. Use before an art refine, a Grok image run, an install over Codex-finished art, or a commit after other agents have worked.
---

# Skill-up from the mech RPG session (Claude, 2026-10-20)

Full write-up: `docs/team/SYNTHESIS_FROM_MECH_RPG_2026-10-20.md`. Hollowtide's own rules win: read the top of
`docs/AI_COLLABORATION.md` first, and Grok's role here (creature and attack rules, 2026-10-02) is unchanged.

## Before changing any art
1. Equal-height grid of ours against the reference (10% lines); read positions, do not eyeball.
2. Colour-family shares of opaque pixels, ours against the reference (near-black is the usual tell).
3. Region crops (rear, middle, front), zoomed.
4. Find which part owns the problem area before editing it.
5. Count single light specks (four neighbours all 50+ darker) before and after.

## Grok Build images (`tools/grok_image.py`)
- `python tools/grok_image.py make <style_ref.png> <out.png> "<what to make>" [--aspect 16:9]`, then
  `python tools/grok_image.py reduce <in.png> <out.png> <w> <h> <colours>` and compare with the installed file.
- It runs in a temporary folder holding only the reference. Never run Grok from the Preston Hub.
- One image per run (about $0.06 to $0.13 reported on the Grok Lite login); Preston picks before anything installs.
- Good for world and UI art; it drifted on creatures in the mech RPG (ask Preston before using it for creatures here).

## Installing and committing alongside Codex
- Read every new result file from Codex and Grok before an install or a commit; another agent may have finished the
  same asset.
- After a source fix on hand-finished art, replace only the frames or files that actually changed.
- Ask Codex to list source issues for Claude in each result; its audits found real bugs.

## Checks that each saved a round
- After any size change, check every view's content box against the render frame edge.
- After renaming a part or asset, compare triangle or pixel counts: name filters and sorted-order passes shift.
- Grep for names a builder creates twice (Blender's ".001" silently breaks name-based binding).
- When generated art goes into a scene slot, check the scene script for placeholders drawn over it.
- One Godot at a time: `tasklist | grep -qi "Godot_v4"`.
