# Canvaswing diagonal walk repaired, October 22, 2026

[Before / after, slowed](review/before-after.gif) · [Dungeon loop](review/dungeon-walk.gif) · [Town loop](review/town-walk.gif) · [Small loop](review/small-walk.gif)

Task1 of [Claude's October22 queue](../../team/CODEX_TASKS_2026-10-22.md) is installed. Source SE f3-f7 are five complete new poses; source f0-f2 remain exact RGBA. Dungeon/town/small SE and mirrored SW f3-f7 account for30 changed runtime PNGs. No duplicate-f1 shortcut or remaining slab/ghost frame. Existing dimensions are39x39,59x59 and41x41. All stills, action frames, other directions and diagonal f0-f2 are exact original files.

## Art and provenance

One built-in `image_gen.imagegen` edit used the original4x2 sheet, enlarged three intact frames and the approved SE still as references. [Exact prompt/ledger](generation-ledger.json), [unmodified generated output](generated-raw.png), [original source/contact](references/original-contact-2x.png). Exact image-model version is not exposed by the tool. The five generated cells were cropped, reduced to native128px cells, alpha hardened and locked to the existing26-colour good-frame source palette; the original first three cells were copied back unchanged. This remains AI-generated source art with AI-assisted preparation, not human-drawn art or a new creature design.

The source sheet remains512x256 in the original4x2 layout. Native generated frames have24 colours, complete bodies and at least17px margins. Runtime frames have18-23 colours and278-695 opaque pixels according to set, versus the old outline-only ghosts and full-frame tan square. The exact per-frame measurements are in [final-build.json](final-build.json); boundaries and SE/SW mirrors are asserted. Preview GIFs are enlarged and slowed for review; they do not change game timing.

## Build and preservation

The unchanged builders were run for Canvaswing only:

```text
python tools/arena/build_dungeon_set.py canvaswing
python tools/arena/build_dungeon_set.py canvaswing --set=town --scale=1.5
python tools/arena/build_small.py canvaswing
```

Current small scale is0.95; dungeon mass target and town1.5 factor remain unchanged. A bare rebuild differs in palette choices from the installed finish, so only the30 repaired results were palette-locked to the installed f0-f2 colour sets; all unselected rebuilt PNGs were restored from fresh originals. [Actual commands, selected paths and metrics](final-build.json). No builder, actor, gameplay or material code changed.

[Receipt](receipt.json):31 installed files including the source sheet; 2152 other protected files exact. 11 concurrent script changes were detected before installation, preserved and separately archived. Installed files are guarded by their original hashes. `original-installed/` is the exact replaced scope; `installed/` is the final scope. No stash/reset/commit or external paid generation call.

## Native verification

Godot4.7.2, OpenGL Compatibility, fixed30fps, isolated APPDATA/LOCALAPPDATA and private save:

- **64/64 candidate and64/64 installed live**, with clean final logs.
- All48 SE/SW textures across the three sets load and retain visible body/transparent margins; native material gallery reviewed: [live sets](native-live/sets.png).
- A real private Rootbank instance creates Canvaswing through `_make(8,0,1,...)`. Its actual `_process` and `_set_tex` select all16 expected textures: frames0-3 on even turns and4-7 on odd turns, both diagonals. Candidate textures were injected only in the private fixture; final live verification loads installed `res://` resources after import.
- [Rootbank actor](native-live/rootbank-actor.png), [native driver](native_check.gd), [live log](native-live.log), [live command/profile](native-live-command.json), [import log](import.log). No natural dungeon-clear or full pilot-chain claim.

## Source issues for Claude

Source issues for Claude: rebuilding current recoloured sheets/stills does not reproduce the installed palette pixel choices (216 set PNGs differ), and rebuilding from the preserved pre-recolour inputs plus the old colour transform still differs. This pass keeps all unselected installed bytes and locks only the30 changed rebuild outputs to installed f0-f2 palette colours. Please document/unify the complete finishing order before a bulk rebuild; do not replace the approved sets with a bare builder run. Generated walk jobs also need per-frame body/edge/colour checks before being accepted: the original job was nominally eight frames but five were damaged. The headless editor import also reports Dialogue Manager theme_values.gd:51 Nil-to-int errors and an unresolved default-audio-bus UID (uid://blm6ps3r8bf7l); process exit0 and reimport completes, but that import log is not clean. Final native live resources match all48 candidate PNGs pixel-for-pixel and the runtime64/64 log is clean. No game-source fix was made for these editor-only diagnostics.

## Reproduction and earlier diagnostics

The actual source-generation prompt and raw image are preserved. `finish_preparation.py` records native slicing/palette/alpha preparation from the raw; `build_final.py` records the successful builders, bounded palette preservation, unselected-file restoration and review exports. `prepare.py`/`build.py`/`rebuild_finished.py` preserve earlier staging attempts and the palette-reproduction mismatch, not successful baseline claims. A scratch file initially called `inspect.py` shadowed Python's standard module; it was renamed `source_inventory.py` before the successful preparation. No failed staging output was installed. Use a fresh D-work folder and retain the original scope snapshots when reproducing; do not bulk-copy scratch sets into live.

Task2 portraits are next. Title Options/settings files changed concurrently during this art pass; those tasks are not marked verified here. All artwork still follows Preston's review authority.
