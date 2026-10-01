# Forge update, 2026-09-29: current rules for all six Opal Forges

Preston asked for the Forges to be fixed, optimized and brought up to date. Written by Claude from what this week's builds actually ran into. Each rule below names the problem it prevents, and every problem was measured on real output.

**Status: applied to the six live Opal Forges on 2026-09-29, plus the dedicated Back View Forge.** Codex edited each Generate prompt directly, changed its step title through the UI to commit the graph revision, and reloaded each page to confirm the rules and linked inputs persisted. The Evolution Forge's Previous Stage Front input was also renamed **Previous Stage Front / Pose Guide**, with instructions for its optional BACK-mode pose-guide use. No image was generated, so output quality remains unverified. The original paste-ready blocks below remain a reference for future revisions.

## Resolved live-Forge wording

| Where | Says now | Should say |
|---|---|---|
| Effect Sheet Generator | "Nature growth" / "Nature, not Bloom" | **Bloom** growth (Preston restored Bloom, 2026-09-29) |
| Effect Sheet Generator | Vitrecrag "beam and cannon" | Vitrecrag **cannon** only; Molten Beam was dropped |
| All creature Forges | 100x100 grid, 128x128 only for Vitrecrag | 128x128 for **Vitrecrag and Oxbowarchon**; 100x100 for the rest |
| `forge-live-status-2026-09-27.md` | The battle cannot time ranged, beam or hold frames | The battle now has emit and hit frames, a strain hold with a looping charge, taller frames, camera shots and sound cues. Ranged and beam sheets can go live. |
| Evolution Forge, BACK mode | "true three-quarter rear view" (too vague) | The camera block below |

## Block A: every Forge (creature, attack, effect, idle, walk)

Prevents: pink halos around glows, and art cut off at the edge. Both cost us repaired frames on Kingstone Rail, Molten Glass and Furnace Roar.

```text
EDGES AND BACKGROUND: Every pixel is either part of the drawing or pure flat #FF00FF magenta. Glows, flashes, auras, sparks and smoke are drawn as solid opaque clusters of stepped colours. Never let a glow, halo or soft edge fade into the magenta. Keep every part of every drawing, including flashes, beams, sparks, tails and feet, at least 6 logical cells inside the canvas or cell edge. If an effect would cross an edge, draw it smaller rather than cutting it off.
```

## Block B: creature Forges (Sprite, Evolution, Attack, Idle)

Prevents: frames that do not match each other (Codex's 2026-09-29 consistency pass had to fix outlines on every Molten Cannon, Furnace Roar and Kingstone Rail frame).

```text
HOUSE STYLE: Match the attached approved creature and Cinderhide's finish: a dark outline around the entire silhouette, about 20 to 36 colours, and shading in clean clustered shapes with very few lone single pixels. The brightness matches the approved creature; only its own glowing parts are brighter. Native grid: 128x128 for Vitrecrag and Oxbowarchon, 100x100 for every other creature.
```

## Block C: Attack Animation Forge

Prevents three problems:
- frames at different scales, which cost us a registration rework;
- near-duplicate frames, which add jitter instead of motion;
- tails clipped by the cell, which had to be patched on six Kingstone Rail frames.

Preston builds each attack from all of its sheets (usually four), so each sheet should give distinct in-betweens.

```text
FRAMES: All six cells show the same creature at the same scale, with the feet on the same baseline in every cell. The whole creature, including its tail, fits inside each cell with margin. The six frames are six DIFFERENT poses, each a clear step from the one before. Never repeat a pose, and prefer in-between poses over held ones. The move's own energy (a charge, a sphere, a flash) may be drawn in the frames, but it follows the edge and background rule and stays inside its cell.
```

## Block D: Evolution Forge BACK mode (replace the old VIEW: BACK paragraph)

Prevents the Vitrecrag failure, where every "rear" was the front pose again. The backs that worked (Oxbowarchon, Ironvent, Cinderhide) all show the hindquarters nearest and the head hidden.

```text
When VIEW: BACK: use Approved Evolved Front as this exact creature's identity, but NOT its pose. The camera is behind the creature's rear end and a little above; the creature walks away from the viewer toward the upper right. The rear end and hind legs are nearest the viewer and largest. The side of the body is seen only at a steep angle. The head and face are hidden or show as at most a thin sliver at the far upper right. The long side of the body must NOT face the viewer; that is a side view, not a back view. Put every marking, plate and limb in its correct place as seen from behind. Show only the limbs visible from behind, each with the foot shape that limb has on the front. Match the front's scale, palette and baseline. Never mirror the front, never show the face, never evolve or redesign. If the brief says Previous Stage Front is a POSE GUIDE, copy only its camera angle, body placement and leg positions from it; everything else comes from Approved Evolved Front and the brief.
```

## Block E: Effect Sheet Generator (replace the essence line)

```text
Ember means heat, fire and molten material; Tide water and erosion; Stone rock, grit and bound gemstone; Gale wind and dust; Bloom growth; Hollow absence, cracks and fading. Do not substitute lightning for Ember or Gale, or for Stone's gem energy.
```

## Not changed

- **Idle and Walk Forges:** their frame structures still work. They only need Blocks A and B.
- **Walk Forge:** it still covers the courier, which needs no creature grid.
