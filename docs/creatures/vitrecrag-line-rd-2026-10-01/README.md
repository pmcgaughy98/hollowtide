# New Fusern line (2026-10-01, candidates, not in the game)

Preston: the old Vitrecrag and Slagglass could never get workable back views, so the line is remade with Retro Diffusion, where every angle comes from one model. The new Vitrecrag must be able to use Molten Glass.

| Stage | Design (proposal) |
|---|---|
| Fusern | Small kiln beetle: brick-red stone dome with glowing cracks, peeks out under its rim, six short legs. |
| Slagglass | The shell cracks open into layered plum volcanic-glass plates with glowing seams and a furnace window; long legs lift it high, front pair like shovels. |
| Vitrecrag | A walking volcano: massive glass-and-slag shell whose top is a crater brimming with molten glass, thick pillar legs, low armoured head, furnace window. |

Files: `*_front_160.png` (RD Pro, each stage from the previous as reference), `*_front_pad_192.png`, `*_8dir_3x3_192.png` (RD Rotate; centre cell empty; cell 3 is the battle back view). Every front and every rotation cell was checked for cut-off edges: none.

## Carrying Molten Glass over
The move's effects, camera shots, sounds, music and finale are independent of the model. Only three things belong to the old Vitrecrag: its 14 attack poses (`attack_frames`), where the glass leaves its body (`attack_emitter_offset`, `attack_river_offset`), and the title-card close-up (`attack_cut_in`). Plan: animate the new front with RD advanced animation (the crater wells up and overflows), map those frames onto the move's 14 beats and holds, move the emitter to the crater, and use the new sprite for the title card until a new close-up exists. The old move file stays in git history.

## Installed 2026-10-01 (Preston: "do it")
- Creatures 106/107/108 use `assets/sprites/creatures/{fusern,slagglass,vitrecrag}_rd_front_2026_10_01.png` (192px) and `_rd_back_`. Battle backs are back three-quarter views facing up-right, picked by eye per sheet because Rotate does not keep one cell order: Fusern cell 6, Slagglass cell 3, Vitrecrag cell 3 of re-roll B (`vit_8dir_3x3_192_reroll_b.png`; the first roll's back showed only a shell). Sizes: battle_size 1.1 / 1.45 / 1.75 (your side 1.5x / 2x / 2.5x).
- Molten Glass, Molten Cannon and Plate Lunge use 12 RD custom-action frames (`assets/sprites/creatures/attacks/vitrecrag_rd_2026_10_01/f00-f11.png`: crater swells, erupts, overflows, settles). Molten Glass: beats [0,1,2,3,4,5,6,7,6,7,8,7,9,11], strain overload f04, title-card close-up f05, gush from the crater rim (14,-44), river from in front of the feet (60,70). Cannon fires from the crater (0,-48). Vitrecrag's old idle flame overlay and mouth smolder removed; aim points moved to the new head (36,31) and furnace window (29,-2).
- Verified in battle captures: wild and player Molten Glass (player via the reverse shot; Cinderhide 60 to 52), Molten Beam, Plate Lunge, Molten Cannon both sides. Old art kept on disk, nothing deleted.
