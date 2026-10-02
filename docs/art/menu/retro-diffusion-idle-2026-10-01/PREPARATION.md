Menu-only Retro Diffusion sources and generation receipts. Original GIFs and source sheets are unchanged. Prepared atlases live in assets/sprites/menu/retro_diffusion_idle_2026_10_01/.

Each raw idle has eight 80x80 frames. Extracted frames form a horizontal 640x80 RGBA atlas. Courier exterior near-white halo removal uses an eight-connected flood from the canvas borders, allowing existing transparent pixels and neutral colors with all RGB channels >=245 and channel spread <=4. Only alpha is removed; retained RGB values are unchanged. Preserve the first cleaned frame's lower ten-pixel band in every frame: y>=61 for courier, y>=63 for Cinderhide. This stabilizes feet and tail tip. Per-frame metadata records removed pixels and confirms identical lower bands.

No atlas scaling or palette conversion. Runtime nearest filtering at 2x. Courier 2.4s loop, Cinderhide 3.2s loop with 0.8s phase offset; both share the menu clock for Reduce Motion. Prepared preview GIFs reflect these cycle speeds, individually starting at frame zero.

Exact prompts, input choices, costs, job IDs, source caveat and runtime verification: docs/team/MENU_RETRO_DIFFUSION_HANDOFF_2026-10-01.md.
