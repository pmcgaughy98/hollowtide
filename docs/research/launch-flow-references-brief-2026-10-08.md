# Brief for Codex: reading shipped games for the launch flow, menu and world (Claude, 2026-10-08)

Preston asked for the method used on the arena today to be used for Codex's slice: how the game looks and behaves at launch, the main menu, pressing Start, everything up to choosing starters, and then the world. His words on the method: "take what we like from them and make our own version... take complete parts from games... seeing its internal structure... accelerate what we're doing but also enhance the result, then we'll refine to fit Hollowtide."

## The method (what worked on the arena)
1. Pick one shipped structure per question. Read the page that describes how it works, not a let's-play.
2. Write down the **structure** (the sequence, the states, the rules, what each step asks the player), never the text, art, names or numbers.
3. Build the Hollowtide version, cut to our size, and name in the write-up: the source, what was taken, what was left out and why, and which numbers are drafts for Grok.
4. Verify it runs (a check script or a native playthrough log) before calling it done.
The arena write-up is the template: `docs/research/combat-references-2026-10-08.md` (one section per structure, same four parts each time).

## Access
Firecrawl is connected to Claude's session as a claude.ai connector (about one credit a page; Reddit and some wikis refuse it). Codex has no access to it through Claude. Options for Codex, in order: its own fetch of public pages (wikis and the Fighting Game Glossary are plain HTML); a Firecrawl MCP server in Codex's own config, if Preston wants to add his key there; or Codex lists the pages it needs in its handoff and Claude reads them through Firecrawl and leaves the extracted structure in `docs/research/`. Do not scrape sites whose terms forbid it, and never paste copyrighted text or GPL/proprietary code into the repo.

## Structures worth reading, by question
**Launch to first choice (the slice in progress).**
- Pokemon's opening sequence (title, press start, Continue/New Game/Options, the professor's intro, name entry, the starter table). Bulbapedia's pages on the main menu, the professor's introduction and starter Pokemon describe the screens and their order. Take: the sequence, what is saved when, how long before the first real choice.
- Nexomon: Extinction and Coromon, the two games Preston wants to compete with. Coromon's opening puts a difficulty and rules choice before the game (Normal, Hard, Insane, custom), then a tutorial facility, then the starter choice from three. Nexomon offers nine starters across types. Take: where the difficulty choice sits, how many starters, how the choice screen presents them (one at a time, in a row, with a short trial).
- Cassette Beasts and Monster Sanctuary for a starter choice that is a character/companion choice rather than three on a table.
- Output: a table per game: screen, what it shows, what it asks, what it writes to the save, next screen. Then the Hollowtide sequence under it, labelled proposal.

**Main menu shape.**
- The console standard: Continue (with the save's summary: location, party, time), New Game, Options. Where Mystery Gift style extras sit. Take: what a save summary shows and the order of items.
- Coromon's and Nexomon's menus for how a 2D monster game's menu is art-led (a moving scene behind the items). Take: the layout structure, not the art.

**World and first route (next).**
- Pokemon's route to town to gym loop; Coromon's Titan loop (the regional objective structure); Monster Sanctuary's interconnected map with ability gates. Take: the loop length between objectives, what gates progress, how the map reveals.
- Nexomon's overworld (a hub town and radial routes) against Pokemon's line of routes. Take: which shape suits a courier game.

## Rules carried over from the arena pass
- Names invented along the way are placeholders; Preston owns names and art direction.
- Label every proposal as a proposal in the doc; nothing becomes canon by being written.
- One runnable completion per slice: the first deliverable is the reference doc plus one screen that runs, not the whole flow.
- Put the extracted structures in `docs/research/launch-flow-references-2026-10-08.md` (or one file per question) and add a top entry to `docs/AI_COLLABORATION.md` saying what was taken.
