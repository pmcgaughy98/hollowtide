# Protocol: turning Opal attack sheets into a battle animation

**Preston's standing order (confirmed 2026-09-28).** Each Opal attack arrives as four sheets. Every assistant follows
these steps in order, for both front and back attack animations.

1. **Read the research first.** Before cutting anything, read the relevant reports in
   `docs/Gemini DeepResearch(Hollowtide)/`, at minimum
   `Monster Taming 2D Animation Research(IMPORTANT ANIMATION RESEARCH).docx` and
   `Pixel Art Combat Animation Pipeline Research.docx`, plus any report about the specific creature. Treat them as
   research, not canon (see `docs/AI_COLLABORATION.md`).
2. **Confirm the Summer Engine MCP connection** (`summer_get_project_context`). If the editor is closed, say so; the
   headless engine can still import and run scripted checks.
3. **Cut all four sheets into individual sprites before sequencing.** Inventory the four original sheet paths and
   use `python tools/cut_forge_frames.py <sheet> <out_dir> --prefix sheetN` for each one (add `--block 4` when
   detection reads 8 on a multi-frame sheet). Keep the originals untouched. Give every cut frame a unique
   `sheetN_fNN` identity and retain it in `assets/sprites/creatures/attacks/<creature>_<move>/frames/`. Count and
   visually inspect the cuts so touching frames, omitted frames, and stray effect fragments are caught. Do not
   assemble an animation yet.
4. **Analyze every individual frame, without grouping similar frames into one row.** In the move's README, record
   the source sheet and frame ID; what the body, head, legs and material are doing; the facing direction; candidate
   beat (rest, anticipation, release, contact or emission, follow-through, recovery); size and anatomy compared with
   the approved exact-view idle; art flaws; and keep/reject/reference-only decision with a reason. For a back-view
   attack, the creature must still read as facing away. Check that its head/collar remains at the far front and that
   its furnace and leg perspective do not flip between frames.
5. **Order the viable frames by the action they show, not by sheet number.** Record a numbered timeline using the
   original frame IDs and name any needed holds, reversals, code motion, or missing pose. Do not invent a smooth
   transition by repeating a frame that reverses anatomy or camera angle.
6. **Re-analyze the complete ordered strip before building.** Inspect it at native size and battle scale: action
   readability, consistent direction and anatomy, foot registration, head/furnace position, palette, contact or
   emission timing, return to idle, and any visual pop. Reorder, reject, or request a missing frame as needed.
   Finalize the frame choices and reasons in the README, then build and verify the animation in Godot.

## How to build it (Preston-approved method, 2026-09-28)

Preston approved Plate Lunge v2 ("this is what I want ... this is the protocol from now on"). Build every attack this way:

- **Use the whole Opal poses**, body, legs, lean and weapon together, so the creature really moves. Do not paste only a
  head or a weapon onto the unchanged in-game sprite; Preston rejected that (Plate Lunge v1) because nothing else moved.
- **Cut on the true grid so the poses match the in-game size.** Measure the body width at `--block 4` and scale the
  block so it matches the approved sprite (Vitrecrag: `--block 3.67` gives 115-123 wide against the in-game 122).
- **Clean each frame:** snap to the approved sprite's exact palette, remove stray crumbs, and register it on the
  approved canvas (lowest pixel on the approved foot line, rear edge on the approved rear edge). Reference build:
  `tools/build_vitrecrag_plate_lunge.py`.
- **Timing and delivery in the move file:** unequal holds, a brace frame (code draw-back and tremble when no drawn
  wind-up exists), the hit on the contact frame, and emitters or a volley for material that leaves the body.
- Where the Opal frames lack a pose, fill it in code or ask for another sheet rather than faking body motion.

Known finish issue for Codex: converted frames can come out slightly darker than the approved sprite and keep a
faint magenta edge; Codex handles that cleanup pass. For Vitrecrag Plate Lunge and Molten Glass, the reproducible
post-build pass is `tools/retouch_vitrecrag_attack_finish_2026_09_28.gd`; the live move resources use its
`style_matched/` output. Preserve the original `built/` and `v2/` frames when revising the finish. Compare each
new finish to the approved idle at battle scale, and verify the alpha mask, canvas and registration are unchanged.

Record the result, what was verified, and what awaits Preston's approval in `docs/AI_COLLABORATION.md`.
