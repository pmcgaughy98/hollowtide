# Four new essences (proposal for Preston; the chart for Grok) — 2026-10-10

Preston: "having this little amount of essences makes it hard for me to choose just single types for a creature because they'd be obsolete... one should be a play on fighting or physical type hitters like Punchybun's line... idk what physiology Scourmaw looks like it would have besides Hollow but let's think of one that makes sense and isn't too personalized so a lot of creatures could have it... for Tallowroot something like a ground type essence where it burrows... don't name them fighting or ground, they should fit the naming sense of our current essences; also how many and what new ones to balance it out."

**Approved by Preston, 2026-10-10 ("Ok now add them"); built the same day.** The matchup numbers are Grok's (ARENA_CHART); until he sets them the four are neutral (the chart's default).

## How many: four, for twelve

THE_CONCEPT's own research puts the workable range at ten to eighteen; we have eight. Four more makes twelve: enough that a single essence is a real identity (no creature is "just Stone" by default), few enough that the chart stays readable from the names. The four fill the archetypes the roster keeps reaching for and has no word for: the physical striker, the burrower, the predator of the dark, and poison and rot.

## The four

| Essence | Domain | Name alternatives | Who has it now |
|---|---|---|---|
| **Sinew** | the body as the weapon: muscle, impact, grapples, discipline | Grit, Brawn | Punchybun line (Sinew; Sparkjab and Starward Sinew/Electric) |
| **Loam** | the ground that moves: soil, burrowing, roots' earth, tremors | Silt, Clay | Tallowroot line (Bloom/Loam; Stone leaves the line, Preston's call); later the burrowing Deepcut line |
| **Murk** | the deep and the dark: ambush, predation, cunning, things below the surface | Gloom, Shade | Rimefin line (Tide/Murk; Hollow leaves it, Preston's call): Scourmaw is a plated jaw that waits in murky water |
| **Blight** | rot, venom, spores, corruption: Bloom's shadow | Venom, Rot | no line yet; a marsh or fungus line later |

Why these names: like Ember, Tide, Stone, Gale, Bloom and Hollow, each is one short, plain word for a thing in the world, never a game term ("Fighting", "Ground", "Dark", "Poison" are what they stand in for, not what they are called).

**Hollow gets sharper.** Its domain was "absence, decay, entropy"; decay moves to Blight, so Hollow is absence and entropy only, the void the game is about. The Quietwater Warden keeps Tide/Hollow and is now the first boss.

**Optional, Preston's call:** Electric and Ice are the two names that break the pattern (an adjective and a material term). If wanted: Electric to **Spark**, Ice to **Frost**. Nothing depends on it.

## The chart sketch (for Grok to set the numbers)

The rule from THE_CONCEPT: every matchup should make sense from the names alone. Two strengths and two weaknesses each:

| Essence | Strong against | Because | Weak against | Because |
|---|---|---|---|---|
| Sinew | Stone, Ice | a blow cracks rock and shatters ice | Gale, Hollow | you cannot punch the wind or nothing |
| Loam | Electric, Ember | earth grounds the spark and smothers the flame | Tide, Bloom | water washes soil away; roots hold it |
| Murk | Hollow, Electric | the dark fills the void and swallows light | Sinew, Ember | plain strength and firelight drive it off |
| Blight | Bloom, Tide | rot kills growth and fouls water | Stone, Ember | it cannot eat rock, and fire burns it clean |

## What changes when approved (Claude builds it)

- `CreatureData.Essence` gains the four **at the end** (so every saved essence number stays the same).
- Hand-drawn icons for the four, colours, impact sounds (an ElevenLabs batch), essence colours in the dungeon.
- Moves take their essence: Jab and Counter Jab to Sinew, Burrow and Root Snare's pull to Loam, Needle Bite and Lunge to Murk.
- The creature data: Tallowroot line Bloom/Loam, Rimefin line Tide/Murk, Punchybun line Sinew (then Sinew/Electric).
- THE_CONCEPT's essence table and `docs/creatures/creature-roster-draft.md` updated.

## Done today, from Preston's decisions

- **The Quietwater Warden is the first boss** (Tide/Hollow), with two Cutbank Listeners as its escort; it replaced Scourmaw. `dungeon_boss_check` passes (168 health, its scene and banner, the sealed stairs, autopilot clears it). Its kit is the listener line's (Echo Tap, Interrupt Call), lighter than Scourmaw's; **Grok**, its strength is yours.
