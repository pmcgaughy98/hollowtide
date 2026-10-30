# Sprite pipeline: what each tool does best (2026-10-28)

Claude's synthesis of the 2026-10-28 Gemini Deep Research report (read as a checklist, see
`sprite-research-2026-10-28/README.md`) and what this project has measured itself. Measured results outrank the
report. Proposal for Preston; nothing here changes who owns what in `docs/team/agent-role-charter-2026-09-27.md`.

## Each tool's job

| Tool | Best at (measured here unless marked) | Weak at | Cost |
|---|---|---|---|
| **Opal Forge** (Nano Banana Pro) | Designing a new stage and drawing all eight views in one sheet. Riftfin try 1 and try 3 passed every judge check (mirrors 0.99); Flintram's sheet is canon. | Copies the pose guide's body plan (try 2's side views became a swimming fish). Can put the diagonals in the wrong columns. Back diagonals sometimes show the face. | Free until 2026-11-17 |
| **Nano Banana 2.1** (SpriteCook) | Repainting one view with our own sprites as references: 0.82 on a held-out view. Its raw output beats our heavy finishing. | Its grid-exact model can't take references (report, matches what we saw). | Paid credits |
| **PixelLab** | Turning one sprite into 8 directions; the best rotation we have seen. The report says it is strongest on two-legged bodies (one Reddit thread, unverified). Its free pixel workbench does exact hand edits. | Limited generations; quadrupeds drift (report). | Limited |
| **Retro Diffusion** | A native pixel grid; walk, idle and attack animation per direction; image_edit for back views; fix_pixel_art to snap a soft image back onto the grid. | Rotations drift from the front; grey debris blocks in takes; two jobs at once misfile output. | Paid credits |
| **Codex image (GPT)** | One missing view at a time: a single back view passed every check. | Full sheets: side views 15% short, mirrors 0.64, details changing between views. | His plan |
| **Codex agent** | Asset prep, slicing, installing and wiring; maps, rooms, buildings, UI art (role charter). | Not the creature designer. | His plan |
| **Gemini** (Deep Research, MCP) | Research checklists and reading references. | Cites our own prompt as a source and invents numbers; the image API's free tier allows zero calls. | Free |
| **Blender** | A 3D stand-in for pose and angle only, then repaint in the house style (report and our 0.56 vs 0.82 result agree). | Raw renders read as 3D ("roblox"). | Free |
| **Our code** | Judging (sheet_judge), one scale and one palette for all eight views, slicing, mirroring, swapping misfiled views, erasing strays, walk_lock (body still, legs move). | Drawing a creature from scratch looks wrong. | Free |
| **Grok** | Creature rules, numbers and kits (owner). Not sprites. | | |

## The pipeline, with Claude as the head

Claude writes every brief, picks the tool, judges every result and does all code fixes. Preston approves each design.

1. **Design sheet.** Opal Forge, VIEW: EIGHT, previous stage's sheet as the POSE GUIDE. The guide's body plan
   leaks in, so say in the brief what must change (try 2 lesson).
2. **Pick the front.** Preston picks; the best front three-quarter (se) cell becomes the approved front.
3. **Final eight.** Opal Forge, VIEW: EIGHT from the approved front, no guide, with tail and symmetry rules (try 3).
4. **Judge and fix by code.** sheet_judge, then look for the two things it cannot see: diagonals in the wrong
   columns, and a face on ne/nw. Swap, mirror, erase strays. Free.
5. **Redraw only what fails.** One view at a time: Codex image or Nano Banana 2.1 with the passing views as
   references. Three tries at most, then stop and report.
6. **Walk.** Retro Diffusion walk per direction (or PixelLab), then walk_lock, then the walk audit (body boil, limbs,
   facing). Four-legged bodies under about 48 px merge their legs in the passing pose: separate them by hand or code.
7. **Install** after Preston's yes, then rebuild the small and dungeon sets.

## Open questions for Preston

- Mirrored views flip the upper-left light to upper-right on the west side. Accept it, or add a relight pass?
- The Opal Forge stops being free on 2026-11-17. Steps 1 and 3 need a replacement before then
  (Gemini app skills or paid Nano Banana Pro).
