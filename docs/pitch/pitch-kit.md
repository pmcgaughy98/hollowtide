# Hollowtide pitch kit: the coloring book (Claude, 2026-10-11)

Preston: "I want this to eventually become a real game ... even if me and you make a legit game with just
vibecoding and AI, there will be holes we can't feel without a studio, devs, artists ... people who know what
they're doing to take this serious." This is the outline of what working developers and publishers expect,
with what we already have filled in and the blanks marked **[YOU]** (yours to write) or **[LATER]**.
Built from how real indie games get taken seriously (sources at the bottom), not from guesses.

---

## 1. The ladder (do these in order)
1. **Pilot = vertical slice.** 10 to 30 minutes of polished play that cuts through every layer (design, art,
   code, sound, UI) the way the finished game will. Ours: the soul's arrival to the first evolution.
2. **Show it to players and developers, take notes.** Not a pitch yet: feedback. Free, honest places:
   r/gamedev's weekly feedback threads, r/IndieDev, r/DestroyMyGame (blunt trailer and GIF critiques),
   Screenshot Saturday, an itch.io page for the build.
3. **A Steam page and a wishlist count.** Wishlists are the number publishers ask for first.
4. **Pitch** (publishers, or collaborators: an artist, a composer) with the deck below.
5. **Funding or a team.** Publishers fund in the hundreds of thousands, then take a share; they want to join
   12 to 18 months before launch, not at the end.

## 2. What the professionals look for (from the sources)
- **The first 30 seconds of the slice decide it.** Clear gameplay, no crashes, and the visual style the
  final game will have. "This will be better when it's finished" does not land; a polished small thing does.
- **A hook you can say in one breath.** tinyBuild's test: what would you say in an elevator in six
  seconds? "Mario Kart as a 2D platformer" works because it starts a conversation.
- **Proof players want it**: playtest notes, wishlists, a community, even a small one.
- **A team that can finish**: past work, a realistic scope, a budget and a timeline.
- **The right publisher**: one that has released games like ours. Send each one a pitch made for them.
- **They spend 15 to 20 minutes on a pitch.** Everything has to be quick to see.

## 3. The honest holes (things pros will notice that we can't fully feel from inside)
| Hole | Why it matters | What to do |
|---|---|---|
| **AI-made art, sound and text** | Steam requires disclosure of AI-made player-facing content (about 1 in 5 new releases now disclose). Hidden AI use draws backlash; games have had to pull it. Many developers are openly against generative AI. Some art communities ban AI posts. | Be upfront in every post and pitch: "prototype art made with AI tools; we are looking for an artist." Budget human art for the real game. Never call it hand-drawn. |
| **Looks like Pokémon Mystery Dungeon** | Familiar is good for a hook, too close is a legal and reputational risk (Nintendo and The Pokémon Company defend their IP hard, including a 2024 patent suit against Palworld's makers). | Keep our own creatures, names, world (the Wayline, the Hollow, Missouri rivers). Say "inspired by" in pitches, never copy UI, music or creature shapes. |
| **No outside playtests yet** | Every game feels clear to its makers. | Watch three people play the pilot without helping. Write down where they get stuck. |
| **Save and Continue** (built 2026-10-12) | A slice people can't come back to feels unfinished. | Done: Highbank saves on every arrival, departure and quit; a quit mid-run keeps the run, and Continue picks it up at the top of that floor, once; the title shows Continue when a save exists (`tools/debug/save_check.gd`). |
| **Music and sound** | Mostly generated takes and synth. | Fine for a pilot; budget a composer for real. |
| **Balance and numbers** | Grok owns them; untested by players. | Playtests first, then tune. |
| **Controller, settings, accessibility** | Expected on Steam. | **[LATER]** |
| **Team and track record** | A solo first-time designer with AI tools reads as risky to a publisher. | Show finished, playable work. Find one human collaborator (an artist is the biggest gap). |

## 4. The kit (fill in the blanks)

### The one-line pitch [YOU, Claude's drafts to start from]
- "A courier guild mystery dungeon on a flooded Missouri river: you wake up as a creature, find a partner,
  and deliver the mail through ruins that rise out of the water."
- "Explorers of Sky's heart in a river town of its own: carry the mail, raise your team, wake the shrine."
- Yours: **[YOU]** ______________________________________________

### The hook: what makes it not just another monster game [YOU]
Candidates we already have: the courier guild (jobs, deliveries, a rival crew who steal mail); evolution by
how you play (kos, floors, flanking), unlocked by the pond stone; a real place (Missouri rivers, St. Joseph
voices); a human soul who remembers a little.
Pick one to lead with: **[YOU]**

### Comparable games ("comps") and audience
| Game | Why it's a comp |
|---|---|
| Pokémon Mystery Dungeon: Explorers of Sky | the feel we're after: partner, guild, turn-based dungeons |
| Shiren the Wanderer | the roguelike dungeon tradition |
| Cassette Beasts (Bytten Studio, published by Raw Fury) | an indie monster game that got a publisher |
| Temtem, Coromon, Monster Sanctuary | indie creature-collectors on Steam |
Audience: **[YOU]** (who are you making it for? fans of Explorers of Sky who wanted more? cozy players?)

### The vertical slice (our pilot)
Status: plays start to the first growth and a replay in a checked run, `tools/debug/pilot_chain_check.gd`, all ok in
720 s on 2026-10-12 (`docs/design/faint-2026-10-12/pilot_chain_check3.log`); before that day the check had never
passed The Hollow. Story: `docs/design/pilot-story-2026-10-10.md`.
To make it pitch-ready: a title screen to pilot end with no dead ends, outside playtests, Codex's finishing pass
on art, and a two-minute capture of the best moments. Done since: the guild crew's portraits and their expression
faces (2026-10-12); a faint sends the team home with a defeat screen instead of a restart; the game's own words
(Sense, Orders, nests, growth) after the genre synthesis in `docs/design/genre-synthesis-2026-10-12.md`; the climax
is unlosable (once the Warden is awake, a fallen leader starts the stand-off); and the save: Highbank saves on
arrival, departure and quit, a quit mid-run keeps the run for one resume at the top of its floor, and the title's
Continue brings the team back (`docs/design/save-2026-10-12/`); the mail call (routes, not names), deliveries
with conditions on the Job Board, rising water on The Hollow's valley floor, the Storage that opens once the
river road past the Warren is clear, and our own dialogue frame (R3 to R7 of the genre synthesis; R8, a lawyer's
read, is yours to arrange).

### Pitch deck (10 to 15 slides) [YOU, with Claude's help]
1. Title and one-line pitch. 2. The hook. 3. Gameplay GIF. 4. The core loop (town, job, dungeon, home,
grow). 5. The world and tone. 6. The creatures and evolution. 7. Comps and audience. 8. What's built (the
slice). 9. Roadmap. 10. Budget and timeline. 11. Team, and who you need. 12. The ask.

### Roadmap and budget [YOU, ranges not exact]
- What the full game is: how many dungeons, creatures, hours? **[YOU]**
- Who you need and roughly what they cost: an artist (biggest), a composer, maybe a programmer. **[LATER, Claude can research rates]**
- How long: **[YOU]**

### Legal and housekeeping [YOU: send the brief]
- `docs/pitch/lawyer-brief-2026-10-12.md` holds the questions and attachments for a games lawyer (R8): the title,
  the genre label, every name, the recruit rule and patents, look and feel as a sum, AI-made content and code,
  licences, business basics, and the store text drafts.
- Asset licences: fonts are OFL; check ElevenLabs and Retro Diffusion commercial terms before any sale.
- A business entity before money changes hands.
- Steam AI disclosure wording (keep it specific: what was AI-made, what was edited).

## 5. The next three steps (no more than three at once)
1. **Finish the slice**: the pilot plays start to evolution with no dead ends (Claude).
2. **Three outside playtests**: watch, don't help, write down where they get stuck (you).
3. **Post it for feedback** with an honest AI note (r/IndieDev or a Feedback Friday thread) (you, Claude drafts the post).

## Sources (structure only)
- FirstLook, "A step-by-step guide to getting your indie game published": the slice, the deck, player data; begin 12 to 18 months before launch.
- tinyBuild, "How to pitch your game": the elevator pitch, visuals first, a build that shows why it's fun.
- Mind Studios, "Pitching your game in 2026": the first 30 seconds, market positioning, tailor each pitch.
- Promise Legal and Legal Moves (2026) on Steam's AI disclosure; StraySpark (2026) on disclosure wording and developer sentiment.
