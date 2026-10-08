# Adoption note: "2D Arena Fighter Research" (Gemini, 2026-10-07)

Source: Preston's Google Doc of that name, from `gemini-prompt-arena-fighter-reference-2026-10-07.md`. Read by Claude 2026-10-07. Sourcing is mostly Reddit threads, two Fandom wikis and one PokeCommunity thread, so the numbers are rules of thumb. **One caution: Gemini's source 5 is our own `event-inventory.md`.** Every claim it attributes to "reference video analysis" (boulder proportions, wall-slam stun, persistent rubble, 4 to 8 debris chunks) is our measurement read back to us, not independent confirmation.

## What is new and worth having
1. **The reference is identified.** "Pokemon Arena" by chickenpicnic, Unity, a custom "Park Engine", six years of development, controller-first, up to four fighters. Developer thread: https://www.pokecommunity.com/threads/pokemon-arena-real-time-action-rpg-pvp-combat-simulator.436711/ (not yet opened by Claude; worth a read for the devlogs). Two other projects share the name: a GBA ROM hack (Pokemon Emerald Arena) and a Pokemon GO raid simulator. Ours is chickenpicnic's.
2. **Its telegraph system** (from the devlogs, per Gemini): ground shapes before a move lands. Red outline = a normal hit coming, yellow = an uninterruptible move, an exclamation mark = a fast projectile, nothing = a utility move. No random accuracy; status is deterministic or built on a visible meter that can over-fill.
3. **Its stat and role scheme**: six stats compressed to Power, Defense, Speed; four archetypes (Physical, Special, Support, Specialist). Preston's role list is finer than this; no change proposed, but Grok may want the comparison.
4. **Anti-infinite rules**: one hard stun per combo; juggles get heavier each hit; grounded targets get shrinking hit windows then invulnerability. Not relevant yet (no juggles), noted for later.
5. **Hit feedback numbers**: hitstop 2 to 4 frames for light hits, 8 to 10 for heavy, never over 100 ms on normal attacks; the defender shakes 1 to 2 px along the hit direction during it; a 1 to 2 frame white flash; shake kept to 2 to 6 px for 100 to 250 ms with a setting to turn it off.
6. **Hybrid control finding**: player-steers, AI-fires schemes work only when the AI is deterministic about proximity and **player inputs override the AI at once**; AI firing that breaks the player's setup is the top frustration. Ranked "Avoid: full AI autonomy over secondary attacks".
7. **Resolution**: 480 x 270 recommended over our 384 x 216 (integer 4x to 1080p; shows the whole arena with 32 to 48 px creatures). Ours is 384 x 216 at 3x into a 1152 x 648 window, which is not an integer fit to 1080p.
8. **Acquisition in action games**: Pokemon Rumble's floor drops (instant, no friction), Palworld's aimed capture during the fight (risk, since throwing leaves you open), Cassette Beasts (recording during combat). Player sentiment favours skill-based or deterministic capture over low-odds RNG. This supports the Proving proposal (`docs/world/creature-recruitment-proposal-2026-10-07.md`).
9. **Legal**: mechanics are not protectable; expression is. PMD SpriteCollab art is CC BY-NC and derivative of Nintendo's designs, so never shippable. Same conclusion as before; not legal advice.

## Adopt (Claude's domain, proposals until Preston says yes)
- **Hitstop.** The arena has flash and shake but no freeze. Add 2 to 4 frames on normal hits and 8 to 10 on signatures and slams, with the defender shivering 1 to 2 px. Cheap, and the research ranks it first.
- **Telegraphs for AI moves.** In a 3v3 the player cannot read six AI kits. A ground shape before Club Slam, Crest Ram, Deep Jet or Root Snare lands (red outline; yellow for a move that cannot be interrupted) is the readability fix the research ranks second. Keep Preston's colours if he wants different ones.
- **Shake cap and toggle.** Ours peaks at 9 map px on signatures (27 screen px). Cap normal hits at about 2 map px and add a setting. The reference's own shake is modest.
- **Player override of the AI.** Today your creature's AI fires on its own schedule and you only choose the signature. Worth a Preston decision: should a movement input cancel an AI wind-up, or should some moves be player-fired? This touches the battle model, so it is his call, not a build.

## Not adopted
- 480 x 270. Changing resolution now would redo every arena map and the HUD layout. Note it for when the window size is decided.
- Beam clashes as mashing. If beam clashes come, use timing, not mashing (ranked "Avoid").
- Juggle and anti-infinite systems. No aerial combat in Hollowtide.

## Open for Grok
- Deterministic status meters (build-up bars instead of chances) fit "no RNG" and the arena. Gemini credits the idea to the reference's devlogs.
- Slam daze: the research's range is 300 to 750 ms; ours is 800 ms. Trim to 600 if it feels long.
