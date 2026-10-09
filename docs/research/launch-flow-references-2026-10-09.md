# Launch flow references, second pass (Claude, 2026-10-09)

**Preston, 2026-10-09:** "refine Codex's work on the world and the opening launch to menu to the first story where you get your starters. Use Firecrawl too." This reads two openings as structures through Firecrawl, sets them beside Codex's first morning (`docs/research/launch-flow-references-2026-10-08.md`, `docs/world/first-morning-world-2026-10-08/README.md`), and names what was taken. Nothing was copied: no text, art, names or numbers.

## Coromon, the prologue (Coromon Wiki, "Prologue" quest page, read 2026-10-09)
The page lists the prologue's logbook entries as a sequence. As structure:

| Step | What the player does | What it establishes |
|---|---|---|
| 1 | Leaves home, talks to a friend, takes a train to the campus | A place to be and a reason |
| 2 | Reports at reception; difficulty and a cosmetic choice | The player's terms, before any creature |
| 3 | Walks the facility to a named researcher | The world is a workplace with rooms |
| 4 | Steps into a machine | A ritual moment for the choice |
| 5 | Chooses the starter, receives a type manual, **battles the researcher at once** | The choice is tested immediately |
| 6 | One more errand, then the title "field researcher" | A role earned, the prologue closes |

Taken: the fight straight after the choice (step 5). Left out: difficulty at reception (no supported difficulty rules yet), the train and the facility tour, the type manual.

## Nexomon: Extinction, acts 1 to 3 (a GameFAQs walkthrough's opening section, read 2026-10-09)
A walkthrough, so the structure is as a player meets it, not the developer's design:

| Act | What happens | What it establishes |
|---|---|---|
| 1 | Name and appearance; a home with items hidden in plain sight; **routes out are blocked until you have a creature**, in character | No creature, no road |
| 2 | Friends split onto their own roads; you go to the woods to find your partner | The partner is found, not handed over |
| 3 | A stranger stops time with an omen; the stakes before the first catch | A hook before the first fight |

Taken: the road is blocked until you have a partner (Codex's first morning already does this at the levee gate), and a fight that happens on the road rather than in a lab. Left out: nine starters, the orphanage, time-stop omens; Hollowtide's hook is the dispatcher's missing return mark.

## Pokemon
The Bulbapedia page the brief named does not exist (404 on "Title screen"); Codex's pass already covered the official story page. Not re-read.

## What Codex's first morning already has, against these
- A place and a reason (the hall, the dispatcher's missing return mark): yes.
- Appearance before the creature: yes (courier choice at the menu).
- The partner met in the world, chosen after working beside each: yes, and better than a table.
- A blocked road until you have a partner: yes (the levee gate).
- **A fight straight after the choice: no.** The levee had the Cinderhide from the September turn-based route, with the turn-based battle screen behind it and no reaction to winning or losing.
- The role earned at the end (a title, a ribbon): partly (the route ribbon line).

## What was built today
The first fight: see `docs/world/first-fight-2026-10-09/README.md`. The Cinderhide on the levee is now fought in the arena, 1v1, the player steering the partner they chose, with the arena's story mode (no debug keys, the player's controls only). A loss returns to the levee with the creature still there and a hint; a win clears the road and points east. The launch setting now starts at the opening flow.

## Proposals left for Preston (not built)
1. **A partner trial before the choice.** Coromon lets you compare by combat style; Hollowtide's meetings are prose vignettes. A 20 s arena trial against crates with each partner, inside the "work beside each one" beat, would let the player choose on feel. Needs an enemy-less arena mode.
2. **The role earned.** After the first fight, the dispatcher's ribbon could become a visible courier mark on the HUD, Coromon's "field researcher" moment.
3. **Difficulty.** Coromon puts it at reception. Hollowtide has no supported difficulty rules; Grok's balance pass should settle numbers before a difficulty choice is promised.
