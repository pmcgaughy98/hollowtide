# Mortarback, Stage II of the Flintram line (2026-10-14, Claude)

Proposal art; not in `assets/` until Grok's numbers and Preston's approval.

Preston's direction: "mortar" is artillery, so Mortarback is a living mortar battery, and a new stage must look
evolved, not just grown (memory: evolve-not-grow). The front came from the Opal Evolution Forge v5.1 with Flintram's
se view (from its canon eight-view sheet) as the previous stage. Preston: "That works but we need 8 angle views."

- `mortarback_8dir_raw.jpg`: the Forge's VIEW: EIGHT sheet, untouched (1024 px JPEG, 152,476 bytes, sha12
  f38b9596f7c8). Second attempt: the first sheet drifted (a frill and back spikes) and broke format (a text label,
  grid lines, no empty centre). The second put the format rules first and used the Mortarback front as both the
  reference and the style anchor.
- `mortarback_8dir_snapped.png`: this sheet has no coarse pixel grid (drawn finely), so it was shrunk by 3.25 with
  each output pixel taking the most common colour in its area (`gemini_sprite.py snap --scale 3.25 --colours 40
  --pockets --tol 60`); background pockets between the legs cleared.
- `views/`: the eight views on the Stage II 144 canvas, feet on row 120.
- `contact_views.png`: the eight in game order at 2x.

Measured: heights 89 to 93 (Stage II target 85 to 100), mirror pairs e/w 0.973, se/sw 0.977, ne/nw 0.892; no
magenta left on the creature.

The front itself was not saved to disk; it lives in Opal (blob 1404555e-637e-46cc-b7eb-dd49be8db52f).
