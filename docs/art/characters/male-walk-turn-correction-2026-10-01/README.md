# Male courier: matched right-facing turns

Preston approved the male left walk, then reported that right turned its head and that up-right differed in size and pose from up-left.

The corrected version mirrors the approved left frames into right and the approved up-left frames into up-right, beat for beat. No scaling, interpolation or regeneration is used. Right retains the approved left profile; both rear diagonals now have identical height, stride and foot placement. Accessories follow the reflection.

The previous up-right visible heights were 69 to 72 native pixels, versus 62 to 64 for up-left. The corrected up-right matches up-left exactly on every frame. All six other rows, including the approved left and up-left, are pixel-identical to the original.

Runtime atlas:
assets/sprites/player/retro_diffusion_chibi_walking_2026_10_01/male_chibi_walk_matched_turns_native80.png

The original 640 x 640 atlas remains untouched. player.gd, player.tscn and male_chibi_walk_frames.tres now use the corrected sibling atlas. Cells remain 80 x 80, eight frames per direction, eight frames per second, with the existing 72px foot registration and 30/64 display scale. Female art and animation are unchanged.

review/male_turns_matched.gif and male_turns_matched.png show all corrected beats. male_turn_correction.json records the exact mirror and unchanged-row checks. The four corresponding directions were also played through all eight frames in the actual map, with screenshots and live state receipts.
