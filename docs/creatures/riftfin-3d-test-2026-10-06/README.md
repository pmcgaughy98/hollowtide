# Riftfin 3D test (Claude, 2026-10-06)

Question (Preston): would 3D models rendered down to pixel sprites fix back views and per-view animation? Preston keeps the 2D pixel style; only the render-to-pixel "middle path" was on the table.

Test: one Retro Diffusion Low-Poly model (Detailed, 128 texels, $1.20) from Riftfin's front, the old rotation's side view and back take 1, plus an auto-rigged idle ($0.50). Total $1.70. `make_model.py`, `pixelize.py`, `turntable.png`, `riftfin_2d_vs_3d.png`.

Result: the model stays consistent from every angle (tail, fin, barbels and crest in every view), but it is not comparable to the 2D art: long newt-like build instead of squat, mouth closed, blocky shapes, noisy camo texture. Pixelized to sprite size and palette with an outline, it still reads as a cruder, different creature. Preston: "no point." **Verdict: dropped.** Better rendering cannot fix the model's own quality, and the 256-texel tier ($3) is the same low-poly style.

What the test did show: Riftfin's missing tail came from the RD rotation step. Direct generation with the front as a reference (back take 1) kept it. Make future backs by direct generation and check each beside its front.
