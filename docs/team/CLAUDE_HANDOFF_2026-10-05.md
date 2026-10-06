# Claude handoff, 2026-10-05

Written at the end of a long Claude chat so a fresh chat can pick up cheaply.

## Required reading (read in full before the first answer)
1. This file.
2. The top sections of `docs/AI_COLLABORATION.md` down to "Kithflare line review" (Codex's Oct 2 to 4 world and creature work; this chat did not see it).
3. Only if touching creatures, moves or evolution: `docs/creatures/DESIGN_RULES.md` (Grok now owns future creature and move rules; see CLAUDE.md).

## State right now
- Everything through Oct 5 is committed (`64b1bf3`, `f8fec8d`). Do not commit unless Preston asks; when he does, use the usual exclusions (`docs/Codex`, `docs/archive/legacy-source-packs`, `**/__pycache__/**`, `project.godot.bak`).
- `scenes/main_menu.tscn` deletion was confirmed by Preston and committed in `f8fec8d` (Oct 5). Nothing referenced it; the project starts in `city_riverfront.tscn`.
- **Retro Diffusion balance: about $2.50** after the starter lines, Oct 5 (shared with Codex). Check `get_balance` and tell Preston the cost before any paid run.

## What this chat built (all in git)
- Signature camera cut: the title card covers the swap, a band sweep cuts back. Signature stages: `MoveData.signature_stage` + `signature_stage_floor_y`, painted RD scenes, platforms under both creatures (`battle_screen.gd`: `_set_stage`, `_dress_stage`, `_platform_texture`).
- VFX: `scripts/effects/vfx_sprite.gd` (`VfxSprite`) plays RD VFX sheets (4x4, 16 frames). Molten Glass uses a volcano eruption at the crater and an animated impact.
- Creature lines with RD fronts, 8-direction sheets and back views: Kithflare line, new Fusern/Slagglass/Vitrecrag (Vitrecrag keeps Molten Glass via a 12-frame RD eruption animation), back views for Rimefin and Clinkerhide.
- Candidates not in the game: redone Preostmar and Oathfen (`docs/creatures/stone-line-rd-2026-10-01/`), memorial ferret Stage I.
- Electric and Ice essences exist in code (Hollow rule only); matchup proposal in `docs/creatures/electric-ice-essences-2026-10-01.md` is unapproved.

## New collaborator (Oct 5)
- Preston now runs **Grok Build** (the terminal CLI) on this repo. It did a lot of the signature, evolution and creature-data work in the uncommitted `data/creatures` and `data/moves` changes, but left no handoff file. Ask Preston or Grok Build for one before touching creature data.
- Oct 5: Coalcrest keeps Codex's back view with the default framing. Its tail is too thin and the rear leg a stub; they only pass because the message box hides them. Do not expose them. Wayburn's front back line smoothed. Coalcrest front still needs refining.
- Preostmar, Oathfen and Punchybun (Stage I) are in the game as provisional data (Oct 5); see the stone-line and memorial-ferret READMEs.

## Open threads, in Preston's priority as last stated
1. **Signature VFX pass.** Molten Glass, Furnace Roar finale and Kingstone Rail hit all play in live battles. Oct 5: Kingstone's stray orange flame removed and Furnace Roar's rock mound stripped (`docs/battle/vfx-2026-10-02/README.md`). Still drawn art: the Furnace Roar field geysers and the falling jade sphere; replace only if Preston asks. Preston had not yet reacted to Molten Glass's VFX version.
2. **Memorial ferret ("Punchybuns", for Adrianna, requested by her twin Gabrielle).** Only Stage I take 1 exists, in `docs/creatures/memorial-ferret-2026-10-01/` (README has the design and the open questions: favourite colours, personality words, Stage II/III names). Nothing is in the game. Handle with care; wait for Gabrielle's answers or Preston's go before Stage II/III. Creature data now follows Grok's rules.
3. Preostmar/Oathfen and the ferret need game data, which is Grok's area now (stats, moves, evolution).
4. Signature kit idea (title-card portrait via RD Pro per signature) proposed, not started.

## Hard-won lessons (do not relearn these)
- RD Rotate's 3x3 sheet does not keep one cell order: pick each back view (back three-quarter facing up-right) by eye. Check every front and cell for clipped edges before showing Preston; outpainting ($0.18) fixes a clipped head.
- RD inpainting returned unusable photo-like images; for small additions, paint pixels by hand or outpaint.
- RD VFX draws its own rock base under effects: strip it (grey and dark pixels) before use.
- A synchronous RD call can error yet still charge; recover the output with `list_inference_jobs` instead of re-running.
- Battle captures need a window, one battle per process: `tools/debug/battle_capture.gd` (usage in its header). RD MCP tools load only at session start; `tools/debug/rd_client.py` calls the server directly otherwise.
- Stage paintings need their floor row set by eye at the far spot (stage x about 305) or creatures float.
