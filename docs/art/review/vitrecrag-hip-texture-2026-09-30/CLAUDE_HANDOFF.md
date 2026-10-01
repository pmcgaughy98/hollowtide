# Vitrecrag: connected hips and matching front/back materials

Preston's latest direction: the middle and rear legs should read as thick limbs rooted in a solid body, like a rhino or elephant. This supersedes the older Gemini hip-fix prompt's outward tortoise attachment guidance. Vitrecrag keeps its existing six-legged beetle design and approved stance.

## Installed files

- `assets/sprites/creatures/vitrecrag_official.png`: a recessed continuous stone underside and connected stone hip roots behind the existing leg armor.
- `assets/sprites/creatures/idle/vitrecrag_flame/body.png`: exactly the same front pixel changes. Its removed mouth flame stays removed for the existing smolder overlay.
- `assets/sprites/creatures/vitrecrag_back_official_2026_09_30.png`: intermediate plum shading, stronger faceted stone light/shadow areas, a golden furnace core, and the former rust-red rear hip panel translated to the front's grey stone ramp.

All three remain 128x128. Alpha masks, outer contour pixels, foot baselines and body-part positions are unchanged. Only existing official-front colors are used. No resource paths, attack timing, emitter positions, shaders or battle scripts were changed. Existing resources pick up these files when reloaded.

## Review and backups

`front_back_final_review_4x.png` shows original front, corrected front and corrected back at the same scale. `mirror_match_before.jpg` is the actual running-game capture before editing. The other comparison isolates the initial back texture pass.

`front_original.png`, `back_original.png`, and `front_idle_body_original.png` are byte-identical pre-edit backups. Source hashes and painted coordinate regions are in `texture_pass_manifest.json`; installed hashes are in `installation.json`.

To rebuild from the archived originals into a separate output folder, run from this folder:

```text
python match_back_texture.py --front-source front_original.png --back-source back_original.png --body-source front_idle_body_original.png --output rebuilt
```

## Integration notes

Do not rebuild from the modified assets and call those the originals. The older back/titlecard preparation tool produces the earlier finish; copying its output over these files would lose this pass. Use the archived originals and this recipe for these idle files.

The front idle body is the texture actually shown with mouth smolder in battle. Updating only `vitrecrag_official.png` would miss that displayed front. Approved attack frames were not repainted in this idle/hip pass. Compare their return to idle before extending the new hip shading to moving poses, following the individual-frame protocol. Retain Preston's solid, weight-bearing torso direction.

The before/after pixels were visually inspected. The existing mirror match was captured before editing. No new game run or gameplay test was made. A running battle can retain old cached textures until it reloads.
