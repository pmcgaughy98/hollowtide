# Gemini Deep Research prompt: what Hollowtide needs from "Pokemon Arena" style 2D arena fighters (Claude, 2026-10-07)

**For Preston to paste into Gemini Deep Research.** It is written for Gemini's limits: it asks for sources, separates documented facts from opinion, and names what we already know so Gemini does not repeat it. Our own frame-by-frame inventory of the one reference video is in `docs/research/arena-comparison-2026-10-07/event-inventory.md`; this prompt asks for the context around it.

---

## The prompt

I am designing a 2D pixel-art, top-down, real-time arena fighter where small monsters battle. My reference is the fan-made "Pokemon Arena" style game: creatures move freely on a stadium floor, fire projectiles and beams, use big cinematic signature moves with a close-up card, and the arena has destroyable crates and boulders, wall collisions, and debris that stays on the floor. I already have a second-by-second breakdown of one gameplay video, so do not describe that video. I need the context around it.

Research the following and write a report with these sections.

**1. Identify the reference.** What is the fan game or games commonly called "Pokemon Arena" (2D top-down, pixel art, real-time, stadium with crowd, sprites credited to the PMD SpriteCollab community)? Who makes it, where is it published (itch, YouTube, Discord, GitHub), what engine, is it playable, and is there any developer writing, devlog, or interview about its design? Give links. If there are several games with similar names, list them and say which matches my description.

**2. Lineage.** Which released games does this style descend from? I am thinking of top-down real-time monster or character arena fighters with free movement, projectiles and ring-outs or walls: for example Pokemon Rumble, Pokemon Unite's lane fights, Smash-style arena brawlers viewed top-down, Brawl Stars, Battlerite, Bomberman-style arenas, Hyper Light Drifter's bosses, and Digimon or Temtem spin-offs. For each relevant game: how a fight is controlled, how long a fight lasts, how many fighters are on the field, and what players say made it feel good or bad. Cite sources (reviews, postmortems, GDC talks, developer blogs). Separate what is documented from your opinion.

**3. The core mechanics I need to understand, with documented examples.**
   - Player control of one creature plus AI-chosen moves (the player steers and times one big move; the creature's AI uses its other moves). Which games have done something like this, and what did players think?
   - Hit feedback in top-down pixel games: hitstop, knockback distance, screen shake, hit flash, dust, and how these are tuned. Any numbers from developers (milliseconds, pixels).
   - Destroyable arena objects (crates, boulders, pillars): how they are sized relative to characters, how they break (crack stages, chunk counts), whether debris persists, and whether they block shots. Examples from released games with screenshots or developer notes.
   - Wall and object slams: games where being knocked into a wall does extra damage or stuns, and how that is telegraphed.
   - Lift and throw mechanics (telekinesis, grabbing an object or enemy and hurling it) in 2D arena games: how the lifted object is drawn (shadow stays on the floor, tether line), timing, and how it is balanced.
   - Beam clashes (two beams meeting and pushing): which games have them, how the push is decided (mashing, damage stat, timing), and how long they last.
   - Team modes in small arenas: 2v2, 3v3 and free-for-all. How do games keep a 3v3 readable on one screen (team colours, outlines, rings, HUD layout)? What makes support or utility moves useful in 1v1 as well as team fights?

**4. Pixel-art production for this style.** At what resolution do these games draw their arena (for example 384 x 216, 480 x 270) and at what scale are they shown? How big are creatures in pixels relative to the arena? How are effects kept on the same pixel grid as the sprites? Any developer notes on drawing projectiles, beams, fire and smoke in low-resolution pixel art.

**5. Obtaining creatures in action games.** Briefly: in real-time or action monster-collecting games (not turn-based), how do players recruit or capture creatures, and what do players say works? Two or three examples with sources.

**6. Legal.** The reference uses community sprites under CC BY-NC. Summarise, with sources, what a commercial game must avoid when it is inspired by a fan game of a licensed property: what is a mechanic (not protectable) versus what is expression (protectable). Say clearly that this is not legal advice.

**7. What I should steal, and what I should skip.** End with a one-page list: the mechanics and presentation choices from this genre that the evidence says players value most, and the ones that commonly disappoint. Rank them, and say which evidence each rank rests on.

Honesty rules: cite every factual claim; say "I could not find a source" where that is true instead of inventing one; mark opinion as opinion; if a game or developer I named does not exist or does not match, say so.

---

## After Gemini answers
Save the report as a Google Doc with a clear title (for example "Arena Fighter Reference Research"), then tell Claude the title. Claude reads Gemini reports from Drive by title and writes an adoption note in `docs/research/`, as with the monster-taming report.
