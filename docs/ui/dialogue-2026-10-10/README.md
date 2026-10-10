# Pixel frames and dialogue portraits (Claude, 2026-10-10)

Preston: "make dialogue portraits for stage 1 starters then warden for boss scene. Also the text boxes
and the graphics for U.I look so plain... it doesn't blend with the game."

## What changed
- **The UI is pixel art at the world's 3x scale.** `tools/ui/build_frames.py` places every pixel of
  the frames by hand in code (no generated art): a moss-weave panel with a bevelled brass band and corner
  studs, a brighter version for the chosen button, a see-through version, a brass name tab, a parchment
  portrait well, and the "next" arrow. Godot stretches them as 9-slices (`UI.frame`, `UI.panel`).
- **Every `UI.panel` uses it**: the dungeon HUD, the town, the team screen, the evolution scene, the soul
  prologue. The pause menu's panel and buttons use the same frames.
- **Dialogue the Explorers of Sky way** (`UI.dialogue`): the portrait framed above the box's left corner,
  the speaker on a brass tab, the line in parchment text, a bobbing arrow. Structure only; nothing of
  theirs is copied.
- **Portraits** (`tools/ui/build_dialogue_portraits.py`): Kithflare, Tallowroot, Rimefin and the
  Warden, cut from their own detailed front idles and shrunk to 40x40 (Explorers of Sky's portrait size)
  with their palettes kept. Shown at 3x.
- The boss scene shows the partner's and the Warden's portraits. The soul prologue's voice has a "???"
  tab and no portrait, since it is unseen.

## Stills
`boss_partner.png`, `boss_warden.png`, `soul_talk.png`, `soul_choose.png` from
`tools/debug/dialogue_capture.gd`; the rest of the screens are in `docs/ui/ui-tour-2026-10-10/`.

## Open
- The Warden crop shows the crest and eye from the side; it can move once Preston has seen it.
- Main menu and Codex's creature prologue still use their own flat boxes (Codex owns the launch flow).
