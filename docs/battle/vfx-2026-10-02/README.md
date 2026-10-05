# Ultimate VFX sheets, 2026-10-02

Same pipeline as Molten Glass (`rd_animation__vfx`, 96px, 16 frames, 4x4, $0.07 each). Five calls, $0.35. The last balance the tool returned was $2.19.

Installed:

- Furnace Roar finale: `assets/sprites/effects/vfx_rd_2026_10_01/furnace_roar_geyser_4x4.png` from `furnace_take2.png`. White knocked out. Wired as `geyser_vfx` on `scenes/effects/ironvent_pressure_field.tscn`. The field geysers stay Preston's art. The two-frame eruption is the fallback if the sheet is cleared.
- Kingstone Rail hit: `kingstone_impact_4x4.png` from `raw_a.png`, purple mound removed. Wired as `impact_vfx` on `scenes/effects/oxbowarchon_sky_rail.tscn`. It replaces the two still burst frames. Flash, column, rings, debris and the core stay.

Not installed: `raw_b.png` (a volcano with a face), `jade_take2.png` (a diagonal comet), `jade_take3.png` (reads as a small creature). A battle was not played.

## Battle check, 2026-10-05

Both moves were played in a live battle (`tools/debug/battle_capture.gd`, Ironvent vs Cinderhide and Oxbowarchon vs Ironvent). Both sheets appear and both deal 15 damage. Captures: `battle_check_2026-10-05_a.png` (7, 9, 11 s) and `_b.png` (Kingstone 8 to 10.5 s, Furnace Roar 10 and 10.5 s). Problem found: the Furnace Roar finale still stands on RD's grey rock mound with a red mouth, which hides the target. The original take is `furnace_take2.png`, so stripping the mound is free.

## Fixes, 2026-10-05 (Preston's request)

- Kingstone Rail: the orange flame at the hit was the generic Strike pop (`basic_hit_pop.tscn`). Kingstone Rail is the only signature with no plain `effect`, so `_drawn_impact_effect` fell back to it. Signatures now skip that fallback (`scripts/battle_screen.gd`).
- Furnace Roar finale: rebuilt from `furnace_take2.png` by `strip_mound_2026-10-05.py`. The grey cone and lava pool are gone, the 194 white-hot highlights the first cleanup punched out are back, and the column base sits on the old ground line. The previous sheet is kept as `furnace_roar_geyser_4x4_with_mound_2026-10-02.png`.
- Checked in live battles after a reimport: `battle_check_2026-10-05_c_fixed.png` (top Kingstone 9.3, 9.6, 9.9 s; bottom Furnace Roar 9.8, 10.2, 10.6 s). No flame, no mound, damage still 15. Free; no RD spend.
