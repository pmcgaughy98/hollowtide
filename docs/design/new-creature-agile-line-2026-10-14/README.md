# New agile line (2026-10-14, Claude): proposal art

Preston's direction: "a new creature thats more agile like pawniard, sceptile, shiftry. Kind of like a quiet but
righteous and competent line." Those games set the vibe and structure only; no design is copied. There is no name
or essence yet, and nothing here is in `assets/` until Grok's numbers and Preston's approval.

All sheets came from the Opal Forges in the built-in browser. Each is the untouched 1024 px Forge output.

## Stage I

- `stage1_step1_8dir_raw.jpg`: the first eight-view sheet (gold crest version). Preston: the east and west views
  were missing the pointed ears.
- `stage1_ear_edit_raw.jpg`: the ear-edit design (no gold crest). Preston preferred it.
- `stage1_ears_8dir_raw.jpg`: the current Stage I. Evolution Forge v5.1 VIEW: EIGHT with the ear-edit sheet as
  pose guide and its east view as design and anchor. It has thin black cell lines to strip before slicing.

## Stage II, eight angles first (Preston's order: 8 views, then a front, then the final 8)

Proposed evolution: an adult build with longer legs and a smaller head for its size. The two ears become long,
swept-back, pale-gold blade-ears. The forearm leaf-blades grow past the elbow like folded swords. The crimson
throat leaf spreads into a short leaf mantle over the shoulders. The tail ends in a gold blade fin, and the body
is a darker forest-teal. The wedge head, calm eyes, ears, throat crimson and forearm blades carry the lineage.

| File | Made with | sha12 |
|---|---|---|
| `stage2_step1_8dir_raw.jpg` | Evolution Forge v5.1 VIEW: EIGHT: Stage I sheet as the stage to evolve from; Stage I east view as anchor | 8f2693326f31 |
| `stage2_step2_front_raw.jpg` | Sprite Forge v5 TASK: REDRAW of the step-1 bottom-left cell; Tallowroot anchor | 033ce14c0c0d |
| `stage2_step3_8dir_raw.jpg` | Evolution Forge v5.1 VIEW: EIGHT: step-1 sheet as POSE GUIDE, step-2 front as the design and anchor | 19ac41d64766 |

Step 1's front views had short ears and its side views had long gold ones. The step-2 front settled on the long
gold blade-ears, and step 3 carries them into all eight views.

The Opal blob ids are 96fea0ce (step 1), f993e55b (step 2) and 374f2477 (step 3).

`compare_stage1_stage2.png` puts Stage I (left) beside the Stage II final (right).

## Stage III, same three passes

Proposed final form, a master swordsman: the tallest and leanest of the line. Exactly one pale-gold brow crest sweeps
back between the two blade-ears like a helm. The crimson mantle becomes a leaf cape hanging to the knees, and each
forearm blade becomes one long curved sabre reaching past the hand. A pale-gold leaf plate covers the chest, the
tail ends in one slim blade, and the body is a deeper pine-teal with darker limbs.

| File | Made with | sha12 |
|---|---|---|
| `stage3_step1_8dir_raw.jpg` | Evolution Forge v5.1 VIEW: EIGHT: Stage II final sheet to evolve from; Stage II front as anchor | 11d876e2c7b6 |
| `stage3_step2_front_raw.jpg` | Sprite Forge v5 TASK: REDRAW of the step-1 bottom-left cell; Tallowroot anchor | 1606271380e2 |
| `stage3_step3_8dir_raw.jpg` | take 1: Evolution Forge v5.1 VIEW: EIGHT: step-1 sheet as POSE GUIDE, step-2 front as design and anchor | 62d70961b608 |
| `stage3_step3_take2_8dir_raw.jpg` | take 2: the same, but the Stage II final sheet as POSE GUIDE | 0b5a1f8a7132 |

The two takes trade faults:
- **Take 1** keeps the tall, lean build, long sabres and knee-length cape. It copied two faults from the step-1
  sheet: black cell lines, and faces showing in the two back-corner views.
- **Take 2** fixed both, but it borrowed Stage II's poses and drifted toward Stage II's shorter build. Its sabres
  are shorter too.

The Opal blob ids are 7e8b6a21 (step 1), cb1228f7 (step 2), 789da88b (take 1) and bd0b2f0b (take 2).
`compare_stages_1_2_3.png` shows, left to right: Stage I, Stage II, Stage III take 1, Stage III take 2.

**Preston chose take 1 (2026-10-14).** He picked take 2 first, then switched to take 1. Take 2's cut views are kept in
`stage3_take2_views_160/` and `stage3_take2_8dir_snapped.png` in case he wants them back.

## Cut to game size

The `stageN_8dir_snapped.png` files were made as follows:
1. **Strip the cell lines.** A scratch script cleared Stage I and Stage III take 1's black cell lines. It clears
   only rows and columns that the line covers edge to edge, plus one pixel. A wider strip clipped the feet, which
   reach to within a pixel of the line.
2. **Snap to art pixels** with `tools/art/gemini_sprite.py snap --scale S --colours 40 --pockets --outline`.
   `--outline` repaints a pinkish-purple rim, left by the JPEG magenta background, with the creature's darkest
   colour.
3. **Slice** each sheet with `tools/art/slice_grid.py`.

| Stage | Shrink | Tolerance | Canvas, feet row | Measured heights |
|---|---|---|---|---|
| I | 3.68 | 90 | 128, 104 | 74 to 81 |
| II | 3.43 | 90 | 144, 120 | 91 to 95 |
| III (take 1) | 3.02 | 60 | 160, 136 | 109 to 110 |

Stage III keeps tolerance 60 because its darker background sits close to the crimson cape, and tolerance 90 ate 18%
of the creature.

The Stage II sheet came out mirrored: the cells the Forge should have drawn facing right face left. Its views were
relabelled when cut (e and w swapped, se and sw swapped, ne and nw swapped). All three stages now face the same way
in `contact_all_stages.png`, which shows Stages I, II and III in rows, with views in the order s, se, e, ne, n, nw,
w, sw, at 2x on a shared baseline.

Not done yet:
- **Stage III back corners:** the ne and nw views show the face. They need a redraw from behind.
- **Stage I specks:** two small leftovers need a hand pass, a purple ring on the chest (the throat leaf) and a
  one-pixel dot at the hip.
- **Into the game:** nothing is in `assets/` until there's a name, Grok's numbers and Preston's approval.
