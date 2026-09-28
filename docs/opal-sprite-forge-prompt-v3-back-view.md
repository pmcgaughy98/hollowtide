# Sprite Forge prompt add-on: back view (v3 draft, 2026-09-25)

> **Historical add-on.** The live [Sprite Forge v4](opal-sprite-forge-prompt-v4.md) still contains a back-view mode, and the [separate back-view app](opal-back-view-app-v4.md) remains a proposal if quality drifts. Do not paste this older add-on over the live prompt.

Not yet tested in Opal. Paste the block below at the END of the existing v2 prompt, so it overrides the
previous-stage rules when a back view is requested. Existing front sprites stay as they are.

```
VIEW RULE (overrides earlier instructions when VIEW: BACK is given)
The brief may start with VIEW: FRONT or VIEW: BACK. If it says neither, use FRONT.
FRONT: use the pose and facing in the brief (default three-quarter view facing right).
BACK: this is the player's own creature in battle, seen from behind. Three-quarter rear view: back and tail toward the viewer, head and body turned away toward the upper right, as if facing an opponent in the distance. Show the back, spine, tail and back of the head; at most a sliver of the face in profile. Same size in the frame, same grid, same outline weight and same magenta background as a front view.
If an image is attached with VIEW: BACK, it is NOT a previous stage. It is this exact creature. Redraw it from behind with the same anatomy, proportions, markings, palette and outline. Do not redesign it, evolve it, add features or change colours. Front-only details (face, chest) are hidden; back details (spines, vents, plates, tail) must match the image.
```

## Workflow
- Existing creature: attach its Forge front image (docs/HollowTide Sprites/<Name>.jfif), brief:
  `VIEW: BACK. Same creature as the attached image: <Name>.`
- New creature: generate the front as usual, then run again with that front attached and the brief above.
- Evolution: front of Stage II with Stage I front attached (as now), then its back with the Stage II front attached.
- Convert backs the same way: `python tools/convert_forge_sprite.py <in> <out>_back.png --compare <sheet.png>`.
