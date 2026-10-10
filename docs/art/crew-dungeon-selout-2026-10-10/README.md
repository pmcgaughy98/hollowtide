# Rival crew and both dungeons: selective outlines, October 10, 2026

Preston requested sel-out for the new Mirekit and Whinet rival courier lines and the scenery of both dungeons. Inspected the installed facings, animation sets, approved take 1s, portraits, current painters, instructions and latest collaboration notes before editing. This covers the two installed stage 1 forms; no later stages were invented.

## Installed appearance

- Mirekit and Whinet use the existing shared Hollowtide Sprite finish with bounded internal contour ink at 0.65. The material follows standing/walking/action texture changes. Original PNGs, alpha, poses, foot rows, sizes and animation timing are unchanged. White fur and bright pale wing highlights remain intact; thin legs and wing silhouettes match the previous rendered finish exactly.
- Rival dialogue portraits use the same detail strength on a creature-only child draw layer. Claude's emotion backgrounds remain behind the art, and his anger/worry marks draw above it through an unshaded child. Native mark pixels were verified for both rivals. Frames, text and other portraits retain their previous drawing. Closing dialogue clears the layer.
- Rootbank Warren's clay banks, the Hollow's new meadow/hills valley, its stone structure, and the original bank fallback use the same shared contour algorithm with a geometry mask. It reaches exposed wall edges/faces and stairs, with face heights matching each painter. Walking surfaces and quiet hill/wall interiors remain original. No terrain PNG or painter rewrite.
- Claude's concurrent Rootbank Warren name, `ValleyPainter`, dungeon selection, crew dialogue/expressions, moves, bosses and Warden pond are retained. The seven-form refinements, darker jade Oxbowarchon, Sparkwick palette correction, town detail finish and original source/backups are preserved.

Seven rendering files plus the collaboration note are installed. Dungeon integration adds only the mask application and a portrait draw child/reset. No controller, collision, floor generation, save model, spawns, creature data, kits, learning, evolution, VFX, title, settings or commit changes.

## Verification

Native Godot 4.7.2 Compatibility renderer, fixed 30 FPS:

- 544 installed rival textures: both small/dungeon sets, all eight facings, walking, attack, hurt and sleep frames. Rendered alpha/silhouettes and bright pale highlights exact to the old finish. Additional contour ink measured in actual GPU output.
- All 33 other installed dungeon forms render byte-exact to the prior finish, including Oxbowarchon and Sparkwick. Texture switching resets rival detail and retains Sparkwick's correction. Explicit town-building detail mode remains byte-exact.
- Original and finished native renders compared for riverbank, ruin, valley and bank fallback. Every pixel outside each geometry mask stays exact; walls/stairs gain measured ink.
- Actual first floor/crew boss, both rival dialogue portraits with anger/worry marks, clearing dialogue, the Hollow valley/stone floor, and Warden pond intro rendered and checked. 22 finish checks pass.
- Claude's current `dungeons_check.gd`: crew boss composition/dialogue, Rot Spit and halved healing, Drain Bite healing, valley/ruin/Warden pond, and town dungeon choice.

Final logs are the authority for check counts. `review/` contains native renders, before/after texture and map samples, actual dungeon screenshots, and both portraits. The text in `mirekit-dialogue.png` and `whinet-dialogue.png` is fixture-only; no story text was installed. `review/after/` captures the real dialogue and move effects.

Review preparation initially hit stale copied import references, followed by an editor import crash on an MP3. Those failed logs are retained. The review was repaired by read-only copying of the live project's already imported payloads and native runs then succeeded. No live cache, audio source or import setting was changed. Native logs retain the existing Windows root-certificate-store diagnostic; no claim of empty stderr.

An earlier `dungeons_check` used Claude's newly updated expected valley look against the preceding candidate made from an older dungeon snapshot. It failed that look comparison. The candidate was rebuilt from current live code, preserving the new name/painter; the current check was rerun. `initial-originals/` and `originals/` retain both integration snapshots. This was an art refinement; a natural dungeon clear is not claimed, and Preston's visual approval is not claimed.

## Maintenance

`scripts/arena/creature_finish.gd` selects extra detail only for Mirekit/Whinet resource paths; approved other forms retain their defaults. `scripts/dungeon/dungeon_finish.gd` makes a mask at floor construction; its shader includes shared `sel_out.gdshaderinc` with map-only vertex/mask handling. The macro is absent from existing creature/building materials, keeping their native rendering exact. New terrain looks with different face/stair geometry need a matching mask. No generation service or external game assets were used.

`candidate/` is the exact installed rendering scope. `originals/` is the pre-install code; `baseline.json` hashes active assets/code and source takes/walk/actions. Guarded installation refuses an unexpected live change. `audit.json` records protected file verification and concurrent differences without reverting them. Local scripts and failed diagnostics are retained for reproducibility.

The final preservation audit additionally retains Claude's six concurrently replaced Kithflare emotion portraits and current town/expression-tool changes. Those are recorded as external changes, not claimed byte-exact to the initial snapshot. This task edits no PNGs. Existing art archives/backups are outside its installation targets.

Final live checks: 22/22 finish checks and Claude’s current dungeon regression pass. 11,212 protected paths and 10,685 original art/source paths are exact; eight installed files are exact. Nine concurrent changes (six Kithflare emotion portraits, town code and two tools) were preserved and separately snapshotted. No live script errors or shutdown leaks in the final checks.
