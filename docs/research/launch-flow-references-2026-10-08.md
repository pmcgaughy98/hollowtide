# Launch flow references and Hollowtide proposal, October 8, 2026

This is a design comparison for Preston's requested launch-to-starter slice. The playable wrapper was built before Claude's brief was attached; the research below reviews and supports the finished structure, rather than claiming that competitor source code produced it. Claude's brief is reference material. Preston's direct request still sets the scope. Everything proposed here remains a proposal, not story canon.

The sources establish player-facing choices, not private implementations. Exact title-menu order, professor dialogue, save schemas, autosave timing and time-to-first-choice are unverified unless stated. No rival text, image, code or balance value was copied. Public pages were read with Codex's web tools; Claude's Firecrawl credentials were not accessed.

## Pokemon Brilliant Diamond / Shining Pearl

The official story page describes appearance selection at the beginning and a first partner chosen from three before the journey. It does not document the exact title/intro screens or disk-write timing. [Official story page](https://diamondpearl.pokemon.com/en-au/story/).

| Documented step | Shows | Asks | Save write verified | Next documented step |
| --- | --- | --- | --- | --- |
| Appearance choice | Protagonist appearances | Choose your appearance | No | First partner choice during the opening |
| First partner choice | Three named species and their types | Choose one partner | No | Adventure across the region |

Structure retained: separate the player's appearance decision from the first partner decision, and keep a small comparison set. Hollowtide uses its approved courier designs and three established starters. Left out: a professor monologue, rival name entry and Pokemon's quest fiction. No canonical Hollowtide introduction was supplied.

## Coromon

The developer's starter guide presents three partners at Lux Solis and encourages comparison by appearance and combat style. The developer's game page describes configurable challenge rules and character customization. These sources do not establish the exact position of the difficulty screen within the opening. The older community-wiki pages suggested by the brief returned fetch errors, so their full prologue order was not treated as verified. [Developer starter guide](https://coromon.com/wiki/guides/starters/), [developer game page](https://coromon.com/games/coromon/).

| Documented step or setting | Shows | Asks | Save write verified | Next documented step |
| --- | --- | --- | --- | --- |
| Difficulty configuration | Rules and challenge options | Shape the challenge | No | Exact opening placement unverified |
| First partner at Lux Solis | Three starters with distinct designs and battle strengths | Choose a partner | No | Travel and battles |

Structure retained: show the three partners together and explain their play styles with short readable descriptions. Hollowtide reads its own essences and front-view idles from CreatureData and describes its existing arena kits. Left out: potential rolls, evolution previews, difficulty presets and a training-facility prologue. Difficulty settings need supported combat rules and persistent configuration before appearing as a product promise. Coromon's current official pages also distinguish classic designs from Remastered previews, so the research is version-specific.

## Nexomon: Extinction

The publisher's starter announcement establishes a set of nine starters. Its currently retrievable article contains the headline but not the original full body, so the precise selector layout and intro sequence remain unverified. [Publisher announcement](https://pqube.co.uk/news/nexomon-extinction-starters/).

| Documented step | Shows | Asks | Save write verified | Next screen verified |
| --- | --- | --- | --- | --- |
| First partner choice | Nine starter options | Choose a starter | No | No |

Structure retained: make the initial creature choice an intentional moment with distinct identities. Left out: nine options. Hollowtide has an established three-starter set; adding six more to the opening would change roster direction without a user decision. No assumptions were made about Nexomon's confirmation or save behavior.

## Cassette Beasts

The game's wiki documents two early tapes supplied by a companion. This is a community gameplay reference, rather than proof of a title-screen sequence or save implementation. [Bansheep page](https://wiki.cassettebeasts.com/wiki/Bansheep).

| Documented step | Shows | Asks | Save write verified | Next screen verified |
| --- | --- | --- | --- | --- |
| Early companion encounter | A choice involving two starter tapes | Obtain a starting tape | No | No |

Structure retained as a presentation idea: treat a starter as a companion rather than a stat bundle. Hollowtide's matching portrait and hometown welcome make ownership visible. Left out: the tape/transformation system, companion dialogue and two-option roster. Any narrative delivery of the partner remains a later proposal.

## Monster Sanctuary

The publisher describes selecting one of four spectral familiars, then entering the opening areas. It also describes using monster powers to extend exploration. [Publisher page](https://www.team17.com/games/monster-sanctuary).

| Documented step | Shows | Asks | Save write verified | Next documented step |
| --- | --- | --- | --- | --- |
| Familiar selection | Four familiars | Choose one | No | Opening exploration and battles |
| Exploration | Obstacles affected by monster powers | Use the team to explore | No | Expanded reachable world |

Structure retained: visibly connect the chosen companion to the first playable area. Exploration abilities are a promising next-world proposal, not part of this opening. Left out: ancestry lore, familiar count, platforming and copied ability gates.

## Hollowtide sequence, implemented proposal

| Screen | Shows | Asks | Writes | Next screen |
| --- | --- | --- | --- | --- |
| Launch prelude | Existing wordmark, essence line | Optional skip | Nothing | Approved animated menu |
| Main menu | Existing painting, actors, water, wordmark and music | New Game / Options / Quit | Options persist separately | Courier choice or existing panels |
| Courier choice | Existing two courier portraits | Select courier and Continue | Courier preference only | Partner comparison |
| Partner comparison | Three existing front idles, data-derived essences, current kit summaries | Compare / select / Back | No party mutation | Confirmation |
| Confirmation | Selected front idle and partner identity | Begin Journey / Keep looking | On successful entry: fresh run-local party containing the chosen starter | Connected hometown |
| Hometown welcome | Matching animated face portrait and real owned partner | Move freely; P opens party | No disk progress save | Existing courier assignment |

The existing menu's art-led composition was preserved from the project itself. Continue with location/party/time belongs here once a real progress file can be loaded and summarized; it is not added to suggest a save exists. The supplied reference screenshots remain design references, not imported game art.

Presentation timings (1.8-second prelude, half-second reveal, short entry fade, 4.5-second welcome and eight-frame playback) are UI drafts for Preston's visual review. This slice changes no combat numbers for Grok. Native end-to-end assertions and screenshots are in `docs/ui/opening-flow-2026-10-08`; their README records save limitations, runtime diagnostics and protected assets. The next proposal is a complete first delivery with a reliable save/reload path and a supported arena/campaign bridge.
