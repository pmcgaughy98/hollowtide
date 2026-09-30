# Gemini Deep Research prompt: code-drawn pixel-art VFX

Preston, 2026-09-29: "skill up and refine how you make graphics without the sheets." The current code-drawn effects look good to him and he wants them as good as possible. Examples he named: the geyser, the flame ray, and the flames in Vitrecrag's mouth.

Paste everything inside the block into Gemini Deep Research. Save the report into `docs/Gemini DeepResearch(Hollowtide)/`. This prompt contains game design only, no personal or work material.

```text
Honesty rule: only state what you can source. If a technique's details, a game's implementation, or a claim about a studio's process is uncertain, say so plainly instead of guessing. Cite a source for every factual claim, and mark anything you infer as inference. Prefer primary sources (developer talks, postmortems, official docs, the artist's own breakdowns) over reposts.

I am a solo developer making Hollowtide, a 2D pixel-art monster-collecting RPG in Godot 4.x (GDScript, 2D renderer, Forward+). Battles are side view. Creature sprites are hand-directed pixel art about 100x100 to 144x176 pixels, drawn at an exact whole-number scale (3x or 4x) with nearest-neighbour filtering. The visual rule is that nothing may break the pixel grid: no smooth rotation or scaling of pixel art, no sub-pixel motion, no blurry glows.

Most attack art comes from AI-generated sprite sheets that I cut into frames. But many of the best effects are drawn in code, with no sheet at all. These are what I want to make better:

1. A river of molten glass that flows along the ground from the attacker to the target. It is built from squares one art pixel in size, with layers (dark outline, cooling edge, orange body, pale hot core), and it bends and grows over time.
2. A fragment shader for a molten-glass flood: a spill lying on the ground in art-pixel cells, with hot bands flowing outward, ripple rings, embers rising across the screen, and a cooling crust that spreads from the source.
3. Fire held behind a creature's closed mouth during its idle, which gasps when the jaws open, then shows a heat aura and resumes.
4. A creature-sprite shader that does whole-pixel "breathing" (the rows above a cut line rise by whole art pixels), an overheat glow in a creature's core, a pulsing idle glow in its vents, and a heat sweep that runs from tail to head.
5. Signature-move staging: the scene dims while the attacker is spotlit, then a white-hot flash, screen shake, a strain frame with escalating shake and a held silence before release, camera push-ins and pull-backs, and a cut-in band.
6. Ground geysers, firework sparks, falling projectiles with afterimage trails, and heat haze. The art for these comes from sheets, but code times, scatters, stacks and scales them.

Research, with sources:
A. How professional 2D pixel-art games make effects in code or shaders while keeping a strict pixel grid. Cover at least Eastward, Sea of Stars, Hyper Light Drifter, Dead Cells, Celeste, Noita, Blasphemous, Octopath Traveler (HD-2D contrast), Cassette Beasts, Coromon and TemTem, plus any documented breakdowns from pixel VFX artists (for example on Twitter/X, Bluesky, ArtStation, GDC, or 80.lv).
B. Fire, lava and energy in pixel art. Cover shape language (teardrop, tongue, flicker), colour ramps and value banding, limited palettes, dithering versus clean clusters, and animating on twos or threes (holding each drawing for 2 to 3 frames at 60 fps) versus every frame. Also cover noise-driven procedural fire that still reads as hand-drawn pixel art, and how many colours an effect should use next to a sprite with about 24 to 100 colours.
C. Godot 4 techniques, with GDScript or shader code patterns:
   - snapping shader output and particles to an art-pixel grid at 3x or 4x (SCREEN_UV versus UV versus world-space quantising);
   - GPUParticles2D versus CPUParticles2D versus hand-rolled Node2D pools for pixel effects;
   - palette-restricted glows (a glow made of stepped palette colours, not a blur);
   - additive versus normal blending for fire on dark scenes;
   - CanvasItem light and CanvasModulate for scene dims and flashes;
   - hit-stop implementation;
   - performance limits for hundreds of pixel squares.
D. Common failure modes that make procedural effects look "programmer art" next to hand-drawn sprites, and how to avoid each: too smooth, too symmetrical, even timing, too many colours, sub-pixel jitter, particles that ignore the sprite's lighting direction, and effects that are uniformly bright.
E. Impact and game feel for big signature moves in turn-based 2D battles. Cover anticipation length, hush before release, flash frames, camera moves and how far to push them, screen shake curves (trauma models), how long to hold the aftermath, and how Pokemon Black/White, Yo-kai Watch, Cassette Beasts, Sea of Stars and Octopath stage their biggest moves.

Deliverables:
1. A ranked list of the 10 techniques most likely to raise the quality of code-drawn pixel effects, each with a one-paragraph explanation, a short Godot 4 code or shader sketch, and its source.
2. A checklist I can run on any new code-drawn effect before calling it finished.
3. Specific recipes for: pixel fire (idle flame and burst), a molten flow along the ground, an erupting geyser column, an energy sphere charging (swirl, rings, sparks), a falling projectile with a pixel trail, and a heat-haze or shimmer that respects the pixel grid.
4. Open questions where sources disagree.

Keep the report skimmable: headings, short paragraphs, tables. Put sources at the end.
```
