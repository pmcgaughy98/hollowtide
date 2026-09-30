# Gemini Deep Research prompt: layering game sound effects like a professional

Preston, 2026-09-29: the Vitrecrag meltdown buildup sounds great. At the release, though, there is just hissing and bubbling, and it sounds like isolated audio. It needs complementing layers, the way professionals build a sound. The aim is to raise Hollowtide's whole audio game, not just this one sound.

Paste everything inside the block into Gemini Deep Research. Save the report into `docs/Gemini DeepResearch(Hollowtide)/`. The prompt holds game design only, no personal or work material.

```text
Honesty rule: only state what you can source. If a technique, a studio's process or a game's implementation is uncertain, say so plainly instead of guessing. Cite a source for every factual claim, and mark anything you infer as inference. Prefer primary sources: GDC talks, sound designers' own breakdowns, postmortems, and audio middleware and Godot documentation.

I am a solo developer making Hollowtide, a 2D pixel-art monster-collecting RPG in Godot 4.x (GDScript) with turn-based, side-view battles. I design each creature's sounds from its physiology. Example: Vitrecrag is a massive armored beetle-like creature with a molten-glass core. Its signature move is a meltdown: the core overloads and molten glass pours out onto the opponent. I generate raw sounds with ElevenLabs Sound Effects (one clear sound per generation) and mix them in code (Python and numpy, with filters, speed and pitch ramps, gain envelopes and peak normalizing). Godot plays each finished sound on a chosen animation frame.

Current result:
- The 2.6 s buildup works well. A brass-and-locomotive "voice" (the creature's core sound) starts muffled as if inside the shell, then opens up and rises in pitch. Under it, glass boils faster and faster, a furnace rumbles, plates groan, and heat-stress glass pings thicken.
- The release falls flat. It has a crack, a burst of hissing and sizzling, and bubbling glass pouring, but it sounds thin and isolated, like a single effect rather than a climax.

Research, with sources:
A. How professional sound designers layer a big impact or release, for example a creature's ultimate attack, an explosion or a magic climax. Cover:
   - The standard layer roles. Transient or attack, body or mid, low-end or sub, "sweetener" details, tail and decay, and the space or reverb. What each does, and how loud each sits relative to the others.
   - Frequency slotting: giving each layer its own band so they do not mask each other.
   - Using a creature's own "voice" at the payoff, so the release is still that creature rather than generic stock sound.
   - Contrast: why a drop to near-silence or a pitch-down right before the hit makes the release bigger, and how long that gap should be.
B. What makes a sound read as "isolated" or "thin", and the fixes: room tone or reverb for the space, stereo width, a low-end sub drop, a tail that lets it breathe, and ducking other sound under the hit.
C. Worked examples from games known for strong creature or combat audio, with the designer's own explanation where it exists. Candidates: Pokemon (mainline and Legends), Monster Hunter (monster roars and impacts), Hollow Knight, Hades, Cassette Beasts, Sea of Stars, Final Fantasy XVI (summons), Dead Cells, and any GDC talk on creature sound design (for example the "Creature Sound Design" or "layering" talks).
D. Designing sound from anatomy and physiology: how creature sound designers derive a creature's sounds from its body, materials and biology. What source material they record or blend, and how they keep one creature's sounds consistent across all its moves.
E. Mixing and implementation for a small Godot 4 game:
   - audio buses (SFX, UI, music, creature voice) with a limiter on the master;
   - sidechain-style ducking of music under big moves;
   - reverb and delay send buses for space;
   - pitch and volume randomization on repeated sounds so they do not machine-gun;
   - loudness targets (LUFS) for game audio;
   - how many voices can play at once before it turns to mud.
   Include Godot 4 specifics: AudioBus layout, AudioEffect types, and AudioStreamRandomizer.
F. What works in a code-built mixer like mine (numpy: filters, envelopes, saturation, pitch ramps), and what honestly needs a DAW or plugins such as a transient shaper, multiband compression, convolution reverb or an exciter. Include the simplest numpy approximation of each where one exists.

Deliverables:
1. A layer recipe for a signature "release" moment: each layer's role, band, timing relative to the hit, and relative level. Then apply it to Vitrecrag's meltdown release (a molten-glass core bursting out of an armored shell, with a brass-and-locomotive voice as its core sound): what to add, what to generate with ElevenLabs as single-sound prompts, and how to mix it.
2. A checklist for any big creature sound before it counts as finished.
3. A starter audio bus and mixing setup for a small Godot 4 battle game, with levels.
4. The ten techniques most likely to lift an indie game's audio from "stock sound effects" to "designed", ranked, each with a source.
5. Open questions where sources disagree.

Keep the report skimmable: headings, short paragraphs, tables. Put sources at the end.
```
