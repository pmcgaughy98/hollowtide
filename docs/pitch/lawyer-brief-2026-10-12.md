# Brief for a games lawyer (R8 of the genre synthesis; drafted by Claude for Preston, 2026-10-12)

Preston: this is what to send, with the attachments at the bottom, before a public pitch or a store page. It is
a list of questions with the facts a lawyer needs to answer them, not advice. Cut anything you do not want to
share. Expect to pay for a short consultation; an hour or two should cover the first pass.

## Who and what

Hollowtide is a one-person game made with AI tools, by Preston McGaughy Jr (St. Joseph, Missouri), aiming at a
pitch to collaborators or a publisher and later a Steam page. It is a turn-based dungeon crawl: you play a
creature in a flooded river town, join its courier guild (the Wayline), carry the mail through dungeons, raise a
team, and wake a shrine. The structure follows a genre (Rogue, Torneko, Shiren, Azure Dreams, Pokémon Mystery
Dungeon); all art, text, names, music and code are our own or made with the tools listed below. Nothing from
any of those games is in the project.

Honesty line: prototype art, sound and some text were made with generative AI tools (Retro Diffusion, ElevenLabs,
PixelLab) and edited by hand; code was written with Claude and Codex. We intend to disclose this on Steam and in
every pitch, and to budget human artists for the real game.

## Questions, in the order they matter

1. **The title "Hollowtide".** Is it clear as a game title (trademark classes 9 and 41, US first)? Any existing
   games, books or marks close enough to matter? Should we file, and when?
2. **The genre label and comparisons.** We never call the game a "Mystery Dungeon" (Spike Chunsoft's series name).
   In a pitch deck and a store page, may we say "inspired by Pokémon Mystery Dungeon: Explorers of Sky" or list it
   as a comparable game, as nominative use? What wording keeps that safe?
3. **Creature and place names (attachment A).** Are any of these too close to existing characters or marks in
   games, toys or cards? We are especially unsure about common-word names (Second Wind, Sense, Storage, Postmaster,
   Orders) and about names that could resemble existing creatures (Rimefin, Stormwick, Starward, Skimlet, Dustkite).
4. **The recruiting rule.** A wild creature the team has beaten sometimes asks to join (a chance by its stage, a
   cap on team size). There is no thrown object, no capture device, no riding. Given the Nintendo and Pokémon
   Company suit against Pocketpair over patented capture-throw and riding mechanics, does our rule carry any
   patent exposure in the US or Japan? Is a patent landscape scan of attachment B worth the cost before a pitch?
5. **Look and feel as a sum (Tetris v. Xio).** Our screens follow the genre's skeleton: a grid dungeon with
   floors and stairs, a lantern as the clock, a hub town, a guild hall with a morning scene, a job board, a
   defeat that sends the team home without its bag, a team of creatures with orders, growth at a shrine. We have
   deliberately changed the words, the morning scene (a mail call, not a line-up and cheer), the deliveries, the
   rising water, the storage, and the dialogue frame. Is the remaining set of borrowed structure a risk as a
   whole, and which pieces would you change first?
6. **AI-made content.** (a) Who owns, and what copyright exists in, the sprites, portraits, sounds and lines
   made with Retro Diffusion, ElevenLabs and PixelLab under their current terms (attachment C has the links)?
   (b) What must the Steam AI disclosure say for this project, and what should a pitch deck say? (c) Does the
   lack of copyright in raw AI output change what a publisher can license from us, and does hand editing
   change that?
7. **AI-written code.** The code was written with Claude and Codex under Preston's direction. Anything a
   publisher or a co-founder will want to see about ownership of it?
8. **Licences (attachment C).** Fonts under the SIL Open Font License; the tool terms; a reference folder of
   third-party 3D models used only for study and kept outside the project. Anything to fix before a pitch?
9. **Business basics.** An entity before any money changes hands (LLC in Missouri?), what a first collaborator
   agreement (an artist, a composer) should contain, and what to put in a pitch deck footer.

## Attachment A: the names

- **Title and world:** Hollowtide; the Wayline (the courier guild) and Wayline Hall; the Postmaster (its head);
  Highbank (the town); the Hollow, Hollow Mouth, Rootbank Warren (dungeons); the Quietwater Warden (a boss);
  Gruntle's bunch, the Shortcut Crew (the rival crew); the Growth Shrine; the Bluff Lookout, Old Ferry Landing,
  Ferry Dock, Crossroads, Scroll Keeper, Training Yard, Item Shop, Storage.
- **Game terms:** Sense (a creature's wit, grown by runs), Orders (Stay Close, Push On, Hold), a nest (a room of
  sleeping wilds that wake at once), Second Wind (a root that gets the leader up once), "went down" (a knockout),
  Courier Rank, the Job Board, mail call, growth (a creature grows into its next form), the lantern (the run's
  clock), the stone.
- **Items:** Reedberry, Lamp Oil, River Stone, Second Wind, Parcel, scrolls named after moves.
- **Traps:** Snare, Silt Pit, Warp Eddy.
- **Creatures (every form in the game's data, 2026-10-12):** Archroot, Bend Caller, Canvaswing, Cinderhide,
  Clinkerhide, Coalcrest, Cutbank Listener, Dustkite, Fusern, Galeshear, Gruntle, Highsignal, Huskward, Ironvent,
  Kithflare, Mirekit, Oathfen, Oxbowarchon, Ozbender, Preostmar, Punchybun, Quietwater Warden, Rampartroot,
  Riftfin, Rimefin, Scourmaw, Skimlet, Slagglass, Sparkjab, Sparkwick, Springvault, Starward, Stormwick,
  Tallowroot, Troughspine, Valvekin, Vitrecrag, Wayburn, Waywhistle, Whinet, Windcut.
- **The Hall's crew:** Wayling, Grubbit, Stillwade, Wickglow, Muskin, Slipjaw, Rinsepaw.
- **Moves and passives** carry plain names (Rake, Ember Feint, Seed Pod, Root Snare, Ambusher, Finisher, Quiet
  Steps, Fall Back, Step Aside, Berry Sense); the full list is in `scripts/arena/arena_prototype.gd`.

## Attachment B: the mechanics, one line each (for a patent scan)

1. A turn-based grid dungeon with random floors, stairs down, items on the floor, traps, and a boss floor.
2. A lantern that drains with turns and is the run's clock; low light shrinks what can be seen.
3. Defeat sends the team home without its bag; levels, moves, partners and story progress stay.
4. A beaten wild creature sometimes asks to join (chance by stage; team size cap). No capture object.
5. Partners act on orders the player cycles (stay close, push on, hold) and on traits they earn (Sense).
6. Growth: a creature changes form at a shrine when its level and run conditions (knockouts, floors, flanks) are met.
7. A job board posting rescue, lost-item and delivery requests; a delivery is judged at the client by a
   condition (lantern lit, within N turns, no trap sprung) and paid accordingly.
8. Rising water on a floor: a row floods every N turns; the current carries creatures and items a tile
   downstream; water creatures swim.
9. A storage that keeps items through defeat, opened by clearing a route.
10. A save at the town and a one-time resume of a run left mid-dungeon at the top of its floor.
11. A nest: a room of sleeping wild creatures that wake together.
12. Moves taught by scrolls, gated by a creature's body parts.

## Attachment C: tools and licences to check

- Retro Diffusion (sprites, portraits, a low-poly test model): https://www.retrodiffusion.ai (terms of service).
- ElevenLabs (sound effects): https://elevenlabs.io (commercial terms by plan).
- PixelLab (sprite tools): https://pixellab.ai/termsofservice.
- Godot Engine (MIT), Dialogue Manager addon (MIT).
- Fonts under the SIL Open Font License: Pixelify Sans, Silkscreen, Jersey, Vollkorn, Alegreya Sans SC.
- Third-party 3D models (Horizon fan recreations, Zoids sprites) are study references kept outside both projects.

## Attachment D: store text to review (drafts)

- One line: "A courier guild dungeon crawl on a flooded Missouri river: you wake up as a creature, find a partner,
  and deliver the mail through ruins that rise out of the water."
- AI disclosure (draft): "Hollowtide's prototype art, sound effects and some dialogue were generated with AI tools
  (Retro Diffusion, ElevenLabs, PixelLab) and edited by hand. Its code was written with AI assistance under the
  designer's direction. No generative AI runs while you play."

## Sources the questions rest on

US Copyright Office, "Games" and "What does copyright protect?"; Tetris Holding v. Xio Interactive, 863 F.Supp.2d
394 (D.N.J. 2012); Nintendo and The Pokémon Company v. Pocketpair (Tokyo District Court, filed 2024); Steam's AI
content disclosure rules (2024). All as summarised in `docs/design/genre-synthesis-2026-10-12.md`, section 1.
