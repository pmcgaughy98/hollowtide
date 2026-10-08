# Riftfin back view and matched back idle (Claude, 2026-10-06)

The old back (RD rotation) lost Riftfin's catfish tail. Two direct generations from the front ($0.36): take 1 kept Riftfin's colours and tail; take 2 copied Scourmaw. Take 1 is installed in the Unity project as `riftfin_back_2026_10_06/riftfin_back_v2.png` (centred on the 224 canvas, feet on the front's foot row).

The back idle no longer comes from a separate RD animation. `tools/unity_port/matched_back_idle.py` measures the front idle's 8 frames (the body sinks 0 to 6 art pixels with the feet planted, the head side dipping more) and bends the back sprite the same way frame for frame, with a 2 px tail sway on the same beat, picking whole pixels only so the art stays crisp. Frame i of the back plays with frame i of the front. Unity's bone deformation was considered and not used: at battle zoom it resamples pixel art and smears it. The RD back frames are kept in Unity as `back_rd_f0..7.png`.

Checked in Unity play mode, Riftfin against Riftfin (`unity_riftfin_vs_riftfin.png`): frames step together, no errors. `riftfin_idle_compare.gif`: front, old back, new back side by side. The new back draws a little smaller than the front (its generated body is 160 px wide against the front's 184).
