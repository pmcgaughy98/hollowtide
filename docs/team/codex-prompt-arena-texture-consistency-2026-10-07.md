# Codex prompt: arena sprite texture consistency (Claude, 2026-10-07)

Paste the block below into a fresh Codex session.

```
You are working in the Godot 4.7 project at C:\Users\pmcga\dev\hollowtide (Hollowtide, a pixel-art creature game). Read docs/AI_COLLABORATION.md (top entries) and docs/creatures/arena-starters-2026-10-07/README.md first.

Context: on 2026-10-07 Preston pivoted Hollowtide to a 2D top-down arena fighter (scenes/arena_prototype.tscn, press F6). Its creature sprites came from Retro Diffusion: one base take per form, turned into 8 facings by RD's rotation, plus RD walk cycles. Each AI pass drifts a little, so the same creature does not look the same from every side. Preston: "kithflare stage 2's textures don't match so it looks faded out at points", and all textures need fixing up for consistency. He says Kithflare (stage 1) is the best one so far: use it as the quality bar.

Your job: make every arena sprite of each form consistent with that form's approved base take, and the nine forms consistent with each other, without changing shapes, poses, sizes or the game code.

The nine forms (line: stage 1, 2, 3): Kithflare, Sparkwick, Stormwick | Tallowroot, Huskward, Rampartroot | Rimefin, Riftfin, Scourmaw.

Files:
- Approved base takes (the source of truth for colours): docs/creatures/arena-starters-2026-10-07/{kithflare,tallowroot,rimefin}_arena_front_take2_clear.png and docs/creatures/arena-starters-2026-10-07/forms/{sparkwick,stormwick,huskward,rampartroot,riftfin,scourmaw}.png
- Full-size facings: assets/sprites/arena/<form>/<s|se|e|ne|n|nw|w|sw>.png (cut from the RD rotation sheets by tools/arena/slice_rotations.py; some facings are mirrors, see the CELLS table there)
- Walk cycles: docs/creatures/arena-starters-2026-10-07/walk/<form>_<facing>_sheet.png (4 x 2 grids of 8 frames; only the three stage 1 forms have them so far)
- Game sprites: assets/sprites/arena/<form>/small/<facing>.png and small/walk_<facing>_f0..f7.png, built by tools/arena/build_small.py, which shrinks to a third with tools/arena/downscale.py. The game only loads the small/ files.
- Useful existing tools: tools/unity_port/sprite_study.py (measures colours, outline, brightness) and tools/unity_port/finish_back.py (maps an image onto another image's exact palette, outline colour and brightness; adapt it, do not change its behaviour for its current use).

What Claude measured (mean brightness 0-255 per facing, order s se e ne n nw w sw):
- sparkwick 121 119 123 99 102 126 123 125: the north and north-east facings are about 25 darker (this is the "faded" look)
- stormwick 82 90 92 85 77 84 90 89; scourmaw 62 64 64 65 56 65 65 64; rampartroot 70 74 72 69 65 66 70 75; rimefin 90 97 101 101 99 100 101 98
- kithflare 127 123 122 124 123 122 122 123 (the best: spread 6)
- walk frames drift too, e.g. tallowroot walking south 104 105 93 99 93 91 93 103
Saturation, palette and outline colour also vary between facings; measure them yourself.

Do:
1. Per form, lock every full-size facing and every walk frame to its base take: exact palette (nearest colour from the base take's own colours), outline colour, brightness and saturation, without moving any pixel's position. Mirrored facings must stay exact mirrors.
2. Across forms, keep each line's look consistent from stage to stage (same family colours), using Kithflare's clarity and contrast as the bar.
3. Fix visible defects you find (stray background pixels, half-transparent pixels, broken outlines, colour noise) with deterministic local scripts.
4. Rebuild the game sprites with python tools/arena/build_small.py and check them at game size.
5. Write your scripts into tools/arena/ with a docstring each, re-runnable from the original files (keep every original; write fixed versions alongside or keep backups, so nothing is lost).

Do not: change shapes, poses, canvas sizes, foot rows, facing assignments or any .gd/.tscn file; resize anything except through the existing pipeline; spend Retro Diffusion credit or call any paid generation without Preston's explicit approval (balance is about $1.28; free RD tools are fine).

Prove it:
- A before/after table: brightness, saturation and colour count per facing for all nine forms, with the per-form spread before and after (target: spread under about 8 brightness, like Kithflare).
- Contact sheets: each form's 8 facings side by side, before and after, at game size (3x), saved under docs/creatures/arena-starters-2026-10-07/consistency/.
- Run the game check: Godot_v4.7.2 at C:\Users\pmcga\Games\Tools\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe with --headless --path . --import, then --path . --fixed-fps 30 --script res://tools/debug/arena_stages.gd (saves stills to the Godot user folder arena_captures/); confirm no script errors and include the stills.
- Then add a short README in that consistency folder and a dated entry at the top of docs/AI_COLLABORATION.md. Do not commit.
```
