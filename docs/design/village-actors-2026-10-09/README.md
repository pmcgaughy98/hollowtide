# Dedicated village menu actors — 2026-10-09

Preston requested creature animation made specifically for the village menu, as with the original Cinderhide title animation. Punchybun performs one small hop then rests; Cinderhide breathes and glances. The quiet timing keeps the choices and carved title readable.

## Model correction and art preparation

Preston rejected the first Punchybun redraw because it changed the original model. That still and its animation are evidence only. The installed animation instead starts directly from `assets/sprites/creatures/punchybun_2026_10_05/punchybun_front.png`, fitted with nearest sampling into an 80x80 transparent canvas. Its short rounded ears, fluffy tail, cream/pink markings and small glove paws remain recognizable. Cinderhide uses the selected dedicated left-facing still, referenced against the existing model.

Both loops contain eight actual generated frames. Preparation removes only near-white matte connected to the canvas exterior, retaining internal cream highlights; every alpha bounding box stays clear of the canvas edge. Native 2x sampling, fixed canvas anchors, quiet timing and the shared `creature_finish.gd` apply in Godot. Reduce Motion freezes both characters and ambient life. No battle or dungeon sprite PNG is overwritten.

## Scope

- Existing runtime edit: `scripts/creature_opening.gd` only.
- New controller: `scripts/ui/village_menu_actor.gd`.
- New assets: sixteen frame PNGs plus `animations.json` in `assets/sprites/menu/village_actors_2026_10_09/`.
- Town, carved lettering, awakening, identity/partner choice, menus and music retain their existing flow.
- Project settings, gameplay systems, balance data, seven-form refinements, dark-jade Oxbowarchon, Listener finish, Galeshear repair and prior backups are preserved. No commit.

## Verification and evidence

`menu-loop.gif` is the actual Godot menu captured at fixed 60fps and sampled at 10fps, rather than an art composite. `title.png` is the native Reduce Motion view. The nine animation assertions exercise both eight-frame loops, fixed placement, finish materials, freeze/resume and New Game. Seven separate checks drive actual mouse/keyboard inputs through the awakening and back to the title. Alpha bounds are checked separately during frame preparation. This does not validate a full dungeon run or Claude's combat updates.

Final logs and check JSONs are in `evidence/` and `logs/`; initial failed preview and first import timeout are retained as diagnostics. Original menu controller, unchanged settings snapshot and collaboration notes are in `originals/`. Preparation/test/install scripts are in `reproduction/`. `installation.json` records exact installed hashes and preservation; `preserved-sha256.json` records every protected pre-existing source file.

## Generation records

Retro Diffusion produced four stills and three animations. Two early 80px stills clipped, the larger Punchybun redraw changed the model and was rejected, its animation was discarded, then the approved original Punchybun was animated. All trials and prompts remain in evidence. The two installed jobs are Cinderhide `09a3fe3e-16ad-473e-8d2d-3da1db8f1fae` and original-model Punchybun `f831f579-1c0f-42f3-bfdd-a8cde4a293ad`.

Returned generation receipts total **$1.36**: four stills at $0.18, Cinderhide idle at $0.14, rejected Punchybun action at $0.25, corrected Punchybun action at $0.25. Shared account balance changes are recorded separately and may include concurrent usage; they are not attributed to this task. Hosted result links expire; accepted raw GIFs and frames are archived locally.

## Concurrent update during installation

The first post-write preservation assertion detected a concurrent change to `scripts/dungeon/dungeon.gd`; the scoped installer never writes that path. Independent verification confirmed all installed files match the tested review version, settings remain unchanged and all other 12,415 protected files retain their exact hashes. The newer dungeon controller was retained. See `post-install-verification.json` for before/after hashes. No dungeon regression is claimed.
