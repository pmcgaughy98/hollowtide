# Village lighting integration — October 9, 2026

Preston asked to blend the dedicated menu creatures into the town as with the old sunset Cinderhide. Read the original `docs/art/menu/cinderhide-dusk-integration-2026-10-01/README.md`: warm sandstone/amber armor, colored shade/contour, upper light, ground bounce and a contact footprint. This revision adapts those principles to the amber/moss village, using a menu-only rendering treatment across the existing eight-frame loops.

Punchybun's bright cream becomes parchment/ochre with muted warm markings. Cinderhide's armor and orange seams pick up the town's light. The shared silhouette/detail finish still runs first, with its outline color set locally to dark moss/brown. The menu shader then reduces saturation, warms high values, puts olive/earth in the shadows, and adds restrained upper-edge and ground light. RGB only: source alpha and every original animation PNG remain unchanged. No opacity fade, blur, resampling, model redraw or generation.

Only `scripts/ui/village_menu_actor.gd` and `scripts/creature_opening.gd` change at runtime. The former derives a local Shader from the actual shared finish source and guards its output marker; the latter adds an outer contact shade beneath each existing footprint. Timings, anchors, frames, artwork, wordmark, town, New Game story and Reduce Motion retain their existing behavior. Original scripts and notes are backed up. No gameplay/data/settings change or commit.

The final `title.png` and `menu-loop.gif` are native Godot captures. Nine animation checks and seven actual mouse/keyboard input checks pass, including all frames, fixed placement, freeze/resume and awakening/return. The existing Windows certificate-store diagnostic remains; final logs have no script/resource/shader errors. This verifies the menu, not the concurrent dungeon updates.

The installation manifest records hashes and any concurrent changes to protected files; the installer writes only the two owned scripts and its appended collaboration note. Prior menu sprites and all creature originals/palette refinements/backups remain exact. No paid calls.
