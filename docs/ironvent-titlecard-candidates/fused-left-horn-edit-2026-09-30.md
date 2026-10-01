# Ironvent fused left horn candidate

Built-in image generation edit, 2026-09-30. Preston approved this revision for Godot. The native version is installed at `assets/sprites/creatures/attacks/ironvent_furnace_roar/style_matched/titlecard.png` and was visually checked in Summer's Furnace Roar title card with both horn tips fully visible and zero engine errors. Claude's preceding native version is preserved beside this note as `ironvent_titlecard_claude_repositioned_native_2026-09-30.png`.

- Edit target: Codex generated `exec-423f9f19-5df8-48ad-a98d-c0ea3c648c12.png`, the larger-horn version Preston selected as good and very close.
- Anatomy reference: `C:/Users/pmcga/OneDrive/Documents/HollowTide Sprites/Creatures/Ironvent.jfif`.
- Generated original: `C:/Users/pmcga/.codex/generated_images/01a0d912-667c-7ad1-b075-359c4f5e42c4/exec-ef6080b4-f7a5-4fdd-9cc0-b7663c16f07f.png`.
- Full-size candidate: `ironvent_titlecard_fused_left_horn_candidate_2026-09-30.png` (1511 x 1041, transparent).
- Native candidate: `ironvent_titlecard_fused_left_horn_native_2026-09-30.png` (140 x 96, nearest-pixel reduction). One dark magenta pixel was cleaned with `tools/clean_spill.py`; no alpha pixel was removed.

## Final edit prompt

Use case: precise-object-edit. Image 1 is the edit target and the version the user chose as good and very close. Image 2 is original Ironvent horn anatomy reference only. Change ONLY the LEFTMOST large top horn in image 1 (the visible near horn at the back/left of the skull). Its smaller pointed inner spur at the lower/right edge should FUSE into the main curved horn, as one continuous whole solid stone horn like the original sprite. Join the spur and main shaft with a continuous broad stone face and base; remove the impression of two separate horns or disconnected/forked pieces. Keep a single tall upward swept curved tip, the same overall length and base position, and original-reference integrated broad horn structure. Keep its dark stony shading and orange heat along the inner edge. Preserve the other top horn EXACTLY as it is in image 1; do not move either horn base, change their heights, or reposition the head. Keep the joined side/cheek horn, clean nostril, entire body, eye, open jaw, teeth, fire, tail, armor, dorsal vents, feet, lighting, palette, canvas and transparent background identical to image 1. No horn on the nostril, no new horns, no magenta background. Full body transparent output.
