# Cinderhide menu white-pixel cleanup | October 1, 2026

Preston requested a small touchup around the tail and upper-left head/neck during the menu animation. This pass fixes exactly 12 opaque white pixels in the current courier-style Cinderhide sheet. It does not generate replacement artwork.

- Frame 2: restore four transparent gap pixels between the neck plates. Those coordinates are transparent in every other frame.
- Frame 3: recolor two white tail-seam pixels to the existing dark color (10, 9, 9).
- Frames 4 and 5: recolor three white tail-seam pixels in each frame to that same dark color.
- Frames 0, 1, 6 and 7 remain byte-identical at the decoded-pixel level.
- Every other RGBA pixel, frame boundary, foot/contact pixel and the fixed lower band from y=62 remain unchanged. The cleaned sheet has zero visible white pixels.
- No new generation cost.

## Runtime integration

The review menu now loads [cinderhide_idle_courier_style_clean_atlas.png](../../../../assets/sprites/menu/retro_diffusion_idle_2026_10_01/cinderhide_idle_courier_style_clean_atlas.png) from scripts/main_menu_art_preview.gd. The prior cinderhide_idle_courier_style_atlas.png and all generated originals remain preserved.

The new texture is still 640x80: eight 80x80 cells. Cinderhide retains 2x nearest filtering, a 3.2-second cycle, phase 0.8, and fixed actor position (353, 304). Courier, scenery, menu behavior, battle assets and project launch settings were not changed.

A fresh offscreen menu-pixel-review run showed the frame sequence 2,3,4,5,6,7,0,1,2 while menu time advanced from 0.017 to 3.217 seconds. The actor position stayed fixed in every probe. Actual screenshots inspected frame 2 at process frame 3270 and frame 4 at process frame 5396. The disposable instance was stopped after the check.

The menu run had zero debugger errors and zero open-script validation errors. The editor log retains 10 unrelated battle/essence parse-error entries mentioning ELECTRIC and ICE, alongside 10 existing warnings. The current creature enum declares both entries; this menu-only pass does not validate or repair the concurrent battle changes. See runtime_check.json for the captured evidence.

## Opal / Gemini asset access

Found Preston's folder at C:/Users/pmcga/OneDrive/Documents/HollowTide Sprites/Opal. It contains 10 exported Opal graph definitions plus source/candidate images. The exports include Character Model, Idle, Walk, Creature, Back View, Evolution, Attack, Effect and World Asset Forges. Image-generation nodes use image-pro, except the Back View Forge's image mode.

Opened the linked [Hollowtide Idle Sprite Forge](https://opal.google/app/1p1-aH_DX-Ys83Fy3rxKL0fKQgChEcNs8) using the browser computer-use capability. Its saved editor and Start button were accessible without a sign-in blocker. No new asset generation was started. The downloaded graphs are workflow definitions, not a standalone Gemini API connection.

Preston authorizes Gemini/Opal for asset work. Current work remains the main menu. Retro Diffusion remains the selected creature angle/animation workflow. Gemini Deep Research still belongs to Preston; menu research is complete.

## Files saved in this pass

- assets/sprites/menu/retro_diffusion_idle_2026_10_01/cinderhide_idle_courier_style_clean_atlas.png
- scripts/main_menu_art_preview.gd: change only Cinderhide's texture filename.
- docs/team/MENU_RETRO_DIFFUSION_HANDOFF_2026-10-01.md: add this latest cleanup and access check.
- This new record folder: README.md, cleanup_manifest.json, runtime_check.json, white_spots_before_review.png, cinderhide_clean_frames_review.png, cinderhide_clean_idle_review.gif, cinderhide_clean_idle_transparent.gif, menu_cinderhide_clean_review.jpg.

[Animated review](cinderhide_clean_idle_review.gif) | [All eight prepared frames](cinderhide_clean_frames_review.png) | [Actual menu capture](menu_cinderhide_clean_review.jpg) | [Exact pixel edits and hashes](cleanup_manifest.json)
