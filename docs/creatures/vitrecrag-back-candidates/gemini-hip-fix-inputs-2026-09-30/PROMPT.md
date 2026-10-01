# Gemini prompt: Vitrecrag back view, hip fix (2026-09-30)

Preston: the back legs' toes are fixed now, but where each leg meets the body under the shell still looks wrong.

Attach, in this order:
1. `1_back_to_fix_8x.png`: the approved back sprite at 8x (each drawn pixel is an 8x8 block), on magenta.
2. `2_back_hips_circled_8x.png`: the same image with the four hip joints circled in cyan.
3. `3_front_anatomy_8x.png`: the approved front, for how the legs attach.

```text
Edit image 1. It is pixel art drawn on a grid of 8x8 blocks: every pixel of the art is one solid 8x8 block. Keep that grid exactly, keep the canvas size, and keep the flat magenta background.

Change ONLY the four circled areas shown in image 2: the tops of the legs, where each leg meets the body under the shell. Everything else stays exactly as it is in image 1: the shell, its straps and rivets, the glowing furnace window, the colors, the feet and toes, the outline, the pose and the size.

What is wrong now: the rust-red thigh armor on each leg is a big round pod hanging under the shell, as wide at the top as the leg is tall, and the area between the legs is a flat rust-red wall. The legs look stuck on, not attached.

What it should look like, matching the approved front in image 3:
- Each leg starts UP INSIDE the shell. Its hip is hidden under the shell's overhanging rim, so the top of every leg disappears into a dark shadow line under the rim.
- The rust-red thigh plate is a curved armor plate with rivets that follows the leg down: narrow where it tucks under the rim, then wrapping the upper leg, ending at the orange band at the knee. It is no wider than the leg itself.
- The legs angle slightly outward from the body, like a tortoise's, not straight down.
- Between the legs, under the shell, is the creature's underside in deep shadow: dark brown-black, recessed, so you can see the legs hang from under the shell. No flat rust-red wall.

Keep the same pixel-art style: crisp dark outline, flat clustered shading, no smooth gradients, no blur, no new colors. Return one image the same size as image 1.
```

**When it comes back:** save it in this folder and tell Claude. It converts back to the 128-pixel sprite with
`tools/convert_forge_sprite.py` (it finds the 8-pixel grid), goes over
`assets/sprites/creatures/vitrecrag_back_official_2026_09_30.png` after Preston approves it, and the battle back view
and the back-view Molten Glass both pick it up with no other change.
