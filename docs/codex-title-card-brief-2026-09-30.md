# Codex brief: signature title card pictures (Ironvent, Oxbowarchon)

From Preston, 2026-09-30, written up by Claude. Vitrecrag's title card picture "looked great so nothing needs done for
that". Ironvent's "just didn't look like an enhanced picture for its title card like Vitrecrag's". Oxbowarchon has
none.

## Where the picture is used now
Every signature opens with a five-second title card (`battle_screen.gd`, `_signature_card`). On the music's accent,
3.6 s in, the band opens taller and the move's close-up (`MoveData.attack_cut_in`) slams in at 3x beside the move
name. It is no longer shown mid-attack for signatures. A move with no `attack_cut_in` shows its owner's battle sprite
enlarged, which is what Oxbowarchon does today.

## The reference: what makes Vitrecrag's work
`assets/sprites/creatures/attacks/vitrecrag_lava_pour/style_matched/titlecard.png` (120 x 93).
- It is the signature's peak moment, not a battle pose: the furnace window blazes pale gold and molten glass pours
  from the collar.
- Same anatomy, outline and palette as the approved front sprite, with more light and more detail.
- Whole body in frame, nothing cut off, facing right (the game mirrors it for the wild side).

## 1. Ironvent, Furnace Roar (replace)
Current: `assets/sprites/creatures/attacks/ironvent_furnace_roar/style_matched/cutin.png` (123 x 85). It is the roar
pose with an orange mouth; the body is as cool and grey as the idle sprite, so it reads as a battle frame.

Wanted: the moment of full pressure, lit the way Vitrecrag's is.
- Every vent row along the back and flanks blazing, brightest at the vent mouths, with the glow cast onto the plates
  around them.
- The open jaw white-hot at the throat, stepping out to orange at the teeth.
- The seams between the armour plates lit from inside.
- No new anatomy, no flames or smoke drawn outside the body (the battle draws those).
- Reference for the heat colours: the move's own `pressure`, `open` and `roar` frames in the same folder, and
  `assets/sprites/effects/ironvent/vent_heat/`.

## 2. Oxbowarchon, Kingstone Rail (new)
No picture exists. Forge prompt, if a generation is needed:
`docs/oxbowarchon-kingstone-rail-cutin-forge-prompt-2026-09-29.md`.

Wanted: braced and fully charged.
- Both jade rails raised steeply at the sky.
- The jade sphere between them at full charge: bright mint centre, emerald rim, thin arcs linking it to both rails.
- Every jade seam and crystal on the body glowing mint, as if the energy is being drawn into the sphere. Dark stone
  and slate plates stay dark so the glow reads.
- Starting points: the move's `full.png` and `full_b.png` frames in
  `assets/sprites/creatures/attacks/oxbowarchon_kingstone_rail/style_matched/` and the front sprite
  `assets/sprites/creatures/oxbowarchon.png`.

## Technical contract (both)
- One PNG, transparent background, no magenta left (run `tools/clean_spill.py`).
- Same art-pixel density as the creature's battle sprite (one drawn pixel is one PNG pixel). Do not upscale.
- At most 130 px tall, so it fits the card at 3x. Around 120 to 140 px wide.
- Snapped to the creature's own palette. Facing right.
- Save as:
  - Ironvent: over `built/cutin.png`, then re-run `tools/retouch_attack_texture_2026_09_29.py` so `style_matched/cutin.png`
    follows. Keep the old file as `cutin_roar_pose.png`.
  - Oxbowarchon: `assets/sprites/creatures/attacks/oxbowarchon_kingstone_rail/style_matched/titlecard.png`, and set
    `attack_cut_in` in `data/moves/oxbowarchon_kingstone_rail.tres` to it (leave `attack_cut_in_frame` at -1).
- Check in the engine with `scenes/ironvent_roar_preview.tscn` and `scenes/oxbowarchon_rail_preview.tscn`: the picture
  appears about 3.6 s after the title card opens. Show Preston candidates before replacing anything he approved.
