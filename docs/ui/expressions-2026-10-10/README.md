# Expression portraits (Claude, 2026-10-10)

Preston sent Explorers of Sky's portrait sheet and asked for "specialized portraits like these... the
different expression ones too for the dialogue". Structure only: one bust per creature, the same framing
and facing for every face, a fixed set of faces (Explorers of Sky keeps about 20 per creature; ours is a
core set). Nothing of theirs is used.

- **How:** `tools/ui/rd_expressions.py <form> <face> ...` hands Retro Diffusion `image_edit` ($0.18 a face)
  the creature's own portrait crop at 3x, told to change only the face; the result is shrunk to 40x40 and
  every pixel snapped to the creature's own portrait colours, so its palette cannot drift.
- **Faces ready:** `happy`, `joyous`, `surprised`, `angry`, `sad`, `worried`, `determined`.
- **Pilot (Preston chose):** Kithflare happy, joyous, surprised, angry ($0.72). `kithflare_sheet.png`.
- **In dialogue:** a line's third field names the face (`["{partner}", "...", "surprised"]`); the portrait
  is `<form>_<face>` and falls back to the plain one when that face is not made yet (`UI.dialogue_portrait`).
  The Warden scene and the crew's talk now tag the partner's lines. `in_game_angry.png` shows one.
- **Next:** the rest of the core faces for the starters, then the Warden and the crew ($1.44 a creature
  for all eight).

## Same day, later: backgrounds by face, the rest of the starters
- **Backgrounds** (Preston's references: hand-made portrait sets colour the background by the emotion):
  `UI.portrait` paints a stepped gradient per face behind the creature, with a motif in 3x pixel blocks:
  normal blue-teal; happy and joyous yellow with rays; surprised pale green with a burst; sad pink;
  worried lilac with a sweat drop; angry red-pink with a jagged line and an anger mark; determined
  orange with speed lines. Drawn in code (`FACE_BG`, `_face_bg`, `_face_mark` in `scripts/ui/ui_style.gd`).
- **All seven faces** for Kithflare, Tallowroot and Rimefin.
- **Lesson:** an edit call that comes back empty can still be charged (two were, $0.36). The crop is now
  kept under the edit tool's 256 px limit, and the batch stops at the first failure instead of retrying.

## Review, 2026-10-10 (Preston)
- Warden: angry (teeth), sad and worried rejected and moved to `rejected/`. Boss lines use determined; happy and surprised kept. Not worth retakes, since the Warden art is placeholder until hand-made art replaces it.
- Whinet: the edits drew a mouth under the proboscis (cream legs, a toothy far eye, a jaw on angry). `tools/ui/fix_whinet_legs.py` copies the legs, proboscis and far eye back from the plain portrait; rerun it after any new Whinet edit. Kept: happy, surprised, angry, sad, determined. Joyous and worried moved to `rejected/`.
- Second review: the mouth was a dark line along the head's underside (cream legs below it as teeth) and a bar between the eyes. `fix_whinet_legs.py` now keeps each edit's near eye and restores the rest of that area from the plain portrait; surprised also takes the plain red eye in place of the white one.
- Third review: the far eye kept the plain open lid on angry, sad and determined; `fix_whinet_legs.py` now draws a matching lid on it by hand (FAR_LIDS).
