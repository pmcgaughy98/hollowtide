# Legacy source packs

On 2026-09-27, the complete `Sound FX Starter Pack Vol. 1` folder was moved here from `docs/crystal-creatures-concept` before that obsolete nested project is removed. It contains 144 WAV files and the package's `Royalty-Free License (Link).pdf`. The full folder has 292 files and occupies 224,030,741 bytes. Its sound files are not wired into the current game.

This directory sits beneath `docs/archive/.gdignore`, so Godot does not import the sound library. The `.gitignore` here keeps this large third-party source package out of Git; keep a separate backup if it should survive a new checkout. Review the included license link before shipping any of its sounds.

The nested `crystal-creatures-concept` project has no active paths referenced by the live game's scenes, scripts, resources, or `project.godot`. Its `assets/tilesets/overworld_tiles.png` is already byte-identical to the live project's copy. Its Godot AI addon is version 3.2.1; the live project already has version 4.2.3. Its other creature data, scripts, scenes, concept, and art directions are old versions and must not replace the live files. Its platformer character, mob, HUD, tree, and environment art packs are unused and do not match the current approved art direction. Generated `.godot` cache, `.import` sidecars, `__MACOSX`, and nested `.summer` metadata do not need migration.
