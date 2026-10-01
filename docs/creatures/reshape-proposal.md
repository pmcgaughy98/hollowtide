# Reshaping: essences, evolution, and what it costs

Written 2026-09-11 after reading the Grok design thread and running a second Grok query into
firsthand player complaints about type charts.

This is a proposal, not a change. `THE_CONCEPT.md` is untouched until you sign off, because the
essence list is yours.

---

## What the research actually found

The question was "how many essences can I have." The answer that came back is that the number is
not the constraint, and the evidence is unusually strong because it includes developers of the
games in question conceding the point.

### The number is not the problem. Inferability is.

**Temtem has 12 types. Pokémon has 18. Players find Temtem's chart harder.**

- u/Solstar82 (r/PlayTemtem, Jul 2020): "in Pokemon, for how farfetched they were, they could be
  realized by thinking about it 'water douse flames, fire melts ice etc'... but here i have
  troubles understanding the reasoning."
- The official Temtem account (@PlayTemtem, Apr 13 2026), replying to a player: "the type chart is
  def complicated, I feel you."
- @PlayTemtem again, Jul 9 2019: "Trouble remembering the types chart?" while linking a fan-made
  chart. The developer was routing around their own chart on day one.

Fewer types, harder chart. The work is relearning, not incrementing. A new game gets no muscle
memory grace period, which is the thing Pokémon is actually coasting on.

**This validates the test already written in `THE_CONCEPT.md`:** "Every relationship is reasonable
from the name alone. That is the test a good chart passes and an arbitrary one fails." That
sentence is the whole design constraint. Keep it and the count matters much less.

One number worth holding loosely: a TTRPG designer thread put the mental ceiling at roughly **6 to
9 types** when a human has to hold the chart without software. Treat that as a rule of thumb from
one discussion, not a verified figure.

### LumenTale is the cautionary tale, and it is the system you were copying

13 elements, no shared chart, plus 5 attributes as a second axis.

- Steam review, Jun 1 2026: "the type chart is fake and weaknesses are only related to the species
  itself. This makes it a game about scanning Animon so you can stare at the UI icons... There's
  little reason to engage with types as a system at all."
- On the attributes: "add meaningful tactical depth" but "introduced far too late... the lack of a
  tooltip to remind players of these attribute effects forces them to dig through the tutorial."
- Another: starters are presented by attribute, not by type, so "you're basically picking blind."
- DualShockers (May 2026) con line: "Needlessly complex." RPGFan (Jun 2026): "packed with too many
  systems" and "almost no explanation."

Temperament is a real lever. The failure mode is not having it, it is shipping it untaught.

### Coromon solved exactly your problem, and said so out loud

This is the finding that matters most.

Coromon has **7 defensive types** on creatures and a **larger set of move-only types** on skills.

- Official @CoromonTheGame (Sep 9 2020): "Skill types were added later to bring more depth to the
  typing system without needing to add more Coromon."
- Dev AMA (r/JRPG, Mar 2022): started at 7 types, "felt that this lacked depth," and skill-only
  types let them build a better table without a full extra roster.
- u/spritelessg (r/coromonthegame, Dec 2021): "There's 13 types, but only 7 defensive types. So my
  choice of moves are similar to early Pokemon, but I don't have to memorize as much new type
  combinations." And: "Pokemon takes a lot of memorization... this game has less of that."

Two type counts. Players only memorize the small one. And critically, **move types cost zero
sprites.**

---

## The arithmetic nobody has done yet

`THE_CONCEPT.md` says, in its own words: "Forty-four sprites, not seventy-two. That difference is
the project being finishable." That number came from staging lines **unevenly**.

Going all-three-stage removes that lever. Sprites become lines times three, with no exceptions.

| Essences | Lines each | Total lines | Sprites |
|---|---|---|---|
| 6 | 2 | 12 | 36 |
| **8** | **2** | **16** | **48** |
| 10 | 2 | 20 | 60 |
| 12 | 2 | 24 | 72 |
| 8 | 3 | 24 | 72 |
| 10 | 3 | 30 | 90 |

Two rows in that table are 72, the number the document already rejected by name.

One line per essence is not an option either, and the document says why: "One creature per type
means no type ever has a roster." That was the stated failure of the old eleven-element system.

**So the real constraint is: at all-three-stage, the approved art budget buys about fifteen lines.**

---

## The proposal

**Eight defensive essences, two lines each, all three stages. Forty-eight sprites.**

Plus a separate, larger set of **move-only essences** that exist on skills and never on creatures.

This gets you:

- More than six essences, which is what you asked for
- All three-stage, which is what you asked for
- Two lines per essence, so every essence has a roster
- 48 sprites against an approved 44, so the finishability argument survives
- Memorization load of eight, inside the 6 to 9 range players named
- Extra chart depth at **zero additional art cost**, which is the exact reason Coromon's developers
  gave for doing it

The move-type layer is the part that makes "more essences" cheap. Creatures stay readable and few.
Attacks get variety.

### What stays

Temperament as the second axis, but **taught in the first hour**, not late. That is the single
correction LumenTale's reviews are asking for and it costs nothing to get right early.

### What has to be decided by you

**Which two essences join the six, and how the cycle extends.**

The current six run a four-part cycle (Ember burns Bloom, Bloom breaks Stone, Stone dams Tide, Tide
quenches Ember) with Gale neutral and Hollow as a glass cannon. Two more can extend that into a
six-part cycle, or form a second smaller cycle, or add two more role-based essences like Gale and
Hollow.

Whatever they are, they have to pass your own test: the relationship has to be guessable from the
name. That is the one rule the research says actually predicts whether players enjoy a chart, and
inventing names for you is how the generic result happens.

---

## Scope flag on the world

The world vision from the Grok thread is good and it is the right direction. An English market town
under a Babel-like tower, a dungeon that is the town's economy, moors and abbeys and coast outside,
a monster settlement in the wilds that grows. The loop Grok distilled is a genuinely strong north
star:

> Leave a living town, cross a distinct landscape, meet a creature that belongs there, fight in a
> readable space, come home heavier.

Hold that as the destination. But name what is in it: guild ranks, a dungeon with floors, town
rebuilding, a growing settlement, ability-gated traversal, arenas and ladders. Each of those is a
system on the scale of the entire battle system, which took one session to build at its simplest.

The scope order in `THE_CONCEPT.md` still applies and nothing above changes it. The next unbuilt
step is evolution. The world does not need deciding to build it.

**The Outernauts idea is the exception worth acting on early**, because it is structural rather
than content: same space for walking and fighting, creatures visible on the ground rather than
random encounters, discrete named destinations rather than corridors. That changes how the
overworld is built, so it is cheaper to know now than to retrofit. It is also, as you said, the one
almost nobody will recognise.
