# Godot sprite import, September 26

The source artwork Preston is keeping lives in `docs/HollowTide Sprites/Creatures/`. Keep those `.jfif` originals intact. The current game uses transparent PNGs in `assets/sprites/creatures/`.

## Current keepers

| Form | Forge original | Game PNG |
|---|---|---|
| Cinderhide | `Creatures/Cinderhide.jfif` | `assets/sprites/creatures/cinderhide.png` |
| Clinkerhide | `Creatures/Clinkerhide.jfif` | `assets/sprites/creatures/clinkerhide.png` |
| Ironvent | `Creatures/Ironvent.jfif` | `assets/sprites/creatures/ironvent.png` |
| Kithflare | `Creatures/Kithflare.jfif` | `assets/sprites/creatures/kithflare.png` |
| Wayburn | `Creatures/Wayburn.jfif` | `assets/sprites/creatures/wayburn.png` |
| Coalcrest | `Creatures/Coalcrest.jfif` | `assets/sprites/creatures/coalcrest.png` |
| Fusern | `Creatures/Fusern.jfif` | `assets/sprites/creatures/fusern.png` |
| Slagglass | `Creatures/Slagglass.jfif` | `assets/sprites/creatures/slagglass.png` |

`scenes/sprite_review.tscn` displays the eight front sprites together in Godot. Open that scene and run the current scene (F6) to review size, transparency, and facing. This gallery is for art review; it does not make proposed forms playable. Cinderhide is already used in the battle scene.

## Redraw next

- Rimefin Stage I: the old 96×88 PNG is outside the keeper folder. The copy-ready redraw brief is in `docs/creature-roster-draft.md` under **Line 5**. Keep its recognizable river-shark design, generate it in the Forge, then use that Forge original for Stage II.
- Cutbank Listener Stage I: Preston requested a redo. The previous teal image is a saved experiment, not the current keeper. The brief is under **Line 6**; start with the optional prior-stage image empty.
- Marlward, Skirr, Tallowroot, Hushmire: the remaining Stage I starter briefs are under Lines 9, 13, 17, and 21.
- Every line now has three stages in the working roster. Stage names beyond established forms remain proposals.

## Each new Forge image

1. Save the chosen original `.jfif` in `docs/HollowTide Sprites/Creatures/`. For Stage II or III, attach the immediately previous original from the same line in Sprite Forge.
2. Convert it with `tools/convert_forge_sprite.py` and `--compare`. The converter reads the actual block grid, removes magenta, and keeps one output pixel per block. The old browser converter shrinks to 64×64 and should not be used for these sprites.
3. Inspect the comparison at three times size for pink edge bleed and missing details. Put the approved transparent PNG in `assets/sprites/creatures/`, keeping the original image.
4. Refresh Godot’s filesystem. Open `scenes/sprite_review.tscn` to see the sprites together. Add a `CreatureData` resource and evolution link only after the form and trigger are approved.

The roster draft currently has 20 lines and 60 forms, while `THE_CONCEPT.md` still states the older 24-line structure. That roster count remains a design decision for Preston.
