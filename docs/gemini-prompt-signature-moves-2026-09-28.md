# Gemini Deep Research prompt: signature moves vs shared moves

Preston, 2026-09-28. Paste everything inside the block into Gemini Deep Research. Save the report into
`docs/Gemini DeepResearch(Hollowtide)/`.

```text
Honesty rule: only state what you can source. If a detail about a game is uncertain, say so plainly instead of guessing, and cite a source for every factual claim about a specific game. Mark anything you infer as inference.

I am a solo developer making Hollowtide, a 2D pixel-art monster-collecting RPG (Godot 4). Creatures belong to six essences (elemental types) and evolve through three stages. Battles are side view: my creature on the left, the enemy on the right. Each creature is a hand-directed sprite about 128x128 pixels, and every custom attack animation currently costs about four AI-generated sprite sheets plus manual cutting and cleanup, so fully custom animation for every move of every creature does not scale.

The design problem: I want every creature to feel unique (signature abilities, moves that fit its body and physiology), but if every move needs a custom animation, each creature is stuck with the same four moves forever. I need a structure where creatures can learn and swap many moves while still having signature moments.

Research how monster-collecting and creature-battling RPGs solve this. Cover at least: Digimon Story: Time Stranger and Digimon Story Cyber Sleuth (signature moves vs shared skills), Pokemon (per-move animations shared across species; signature moves such as Spirit Shackle or Z-moves), Yo-kai Watch (Soultimate moves), Cassette Beasts, Temtem, Coromon, Monster Sanctuary, Dragon Quest Monsters: The Dark Prince, Shin Megami Tensei V, and any 2D sprite-based indie that handles this well.

For each game, report:
1. How many moves a creature can hold and how it learns or swaps them.
2. Which moves are unique to one creature or line and which are shared, and roughly the ratio.
3. How animation is produced: a unique animation per creature, a shared animation per move played on any creature, or a hybrid (a generic body action such as lunge, cast, or breath plus a shared effect overlay).
4. How signature or ultimate moves are gated: a meter, once per battle, evolution stage, or held item.
5. How the game makes shared moves still feel like they belong to each creature's body (for example, the effect starts from the mouth, horn, or vent).

Then give:
A. A comparison table of the games above.
B. Two or three structures a solo developer could realistically ship, with the approximate animation cost per creature for each (count sheets or animations).
C. Your recommended structure for Hollowtide, given six essences, three-stage lines, sprite-sheet animation cost, and the goal that every creature feels unique. Include how many shared moves each essence would need, how many generic body actions each creature would need, and how signature or ultimate moves could fit (for example, one signature per evolution line or one ultimate per creature).

Keep the final report skimmable: headings, short paragraphs, tables. Put sources at the end.
```
