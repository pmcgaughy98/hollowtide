# Creature cutout rig status — 27 September 2026

These are reversible, additive Godot pilot scenes. No approved source sprite was edited. The Cinderhide pilots still use full-canvas RGBA head and body layers. Preston rejected Clinkerhide's separated muzzle motion and then chose the earlier whole-sprite battle breathing over the shoulder-only shader study. The Clinkerhide front and rear comparisons now use intact sprites with `scripts/whole_sprite_breath_preview.gd`, matching the battle loop's asymmetric inhale, scale change, and foot correction. The active battle renderer already uses this whole-sprite approach; it was not changed for this preview.

| View | Source | Split | Pivot (source px) | Idle | Playable comparison | Status |
|---|---|---|---|---|---|---|
| Cinderhide front | `assets/sprites/creatures/cinderhide.png` 100×100 | 1,071 head / 3,109 body | (58,53) | head down 1 px, 1.8 s loop | `scenes/cinderhide_rig_preview.tscn` | Preston viewed and approved the pilot |
| Cinderhide back | `assets/sprites/creatures/cinderhide_back.png` 100×100 | 892 head / 3,167 body | (62,45) | head down 1 px, 1.8 s loop | `scenes/cinderhide_back_rig_preview.tscn` | Played at 3× player scale with no game errors; needs Preston's visual review |
| Clinkerhide front | `assets/sprites/creatures/clinkerhide.png` 100×100 | No split; full sprite | None | Battle-matched squash/stretch, depth 0.026, period 1.9 s | `scenes/clinkerhide_rig_preview.tscn` | Preston prefers the earlier whole-sprite method; preview pending review |
| Clinkerhide back | `assets/sprites/creatures/rig_pilot/clinkerhide_back_source_candidate.png` 128×128 | No split; full sprite | None | Battle-matched squash/stretch, depth 0.026, period 1.9 s | `scenes/clinkerhide_back_rig_preview.tscn` | Art candidate still pending Preston's approval |

The visible Cinderhide layers and retired Clinkerhide mask experiments remain in `assets/sprites/creatures/rig_pilot/`. The current Clinkerhide scenes use intact art and `scripts/whole_sprite_breath_preview.gd`. Their scene paths remain `scenes/clinkerhide_rig.tscn` and `scenes/clinkerhide_back_rig_candidate.tscn` for preview compatibility.

## Clinkerhide motion direction from Preston

Preston considered a shoulder shrug like a powerlifter after intense effort, then preferred the earlier whole-sprite breathing. Keep the planted stance and existing battle timing. A true articulated attack rig would still need full head and shoulder pieces with painted overlap hidden behind them; the retired muzzle masks cannot supply that. This does not block whole-sprite idle breathing.

## Clinkerhide back source

The user's original magenta-background art is `docs/HollowTide Sprites/Creatures-Back/Clinkerhide-Back.jfif` (SHA-256 `210B4819431CD9F77E0F76BEE968FCF47B89885D4D0A19CB82C5A20363CA6E30`). It was converted to its native 128×128 block grid with the project's existing Forge converter, then cleaned in a separate candidate copy to remove 280 magenta fringe pixels and recolor 24 interior fringe pixels. The original JFIF remains untouched. The candidate was not assigned to `data/creatures/101_clinkerhide.tres`: that resource currently names a missing `clinkerhide_back.png`, and the 128×128 rear art should be accepted at battle scale before it becomes the official back.

## Source integrity

- Cinderhide front SHA-256: `4C6403594E71A93C698E453A7AEF62DF44BBB2C4E03CBDA1AD130FE274A5E22E`.
- Cinderhide back SHA-256: `4C523A530665EA29322C72B18B492150AFFFBFAE7C109BB466DBED3D49F49988`.
- Clinkerhide front SHA-256: `1E64190C2333E0E6D5330F3CE6E35DEE7727E46C9566D67EC816CD967E17AFE5`.

## Battle hookup gate

The existing `scripts/battle_screen.gd` expects a `Sprite2D` for attack effects, frame swaps, flashes, sizing, and hit reactions. Preview approval establishes the visual loop, not compatibility with every battle action. Connect a selected rig as a child of the existing sprite, then test a complete fight and transition before replacing any live art. A hand-drawn attack pose can coexist with cutout idle; do not force rigid cutouts through elbow/knee bends that need new pixels.

The project's startup scene was restored to `res://scenes/main.tscn` after the first rig pilot had accidentally become the startup scene. The subsequent previews kept that setting unchanged.
