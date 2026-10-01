# Hollowtide music prompts (Suno)

## Main menu intro (Preston, 2026-09-29, used)

```text
A quietly ambitious chiptune score with a moody, character-led RPG feel: muted square-wave melodies and warm triangle-wave bass drift over a loping 6/8 pulse, with rain-softened field-recording textures and sparse piano. Pixel-art bleeps meet bowed cello and brushed percussion; battle cues add tight snare hits, distorted synth impact, brief stop-start silence, and sliding arpeggios. Intimate, handmade, and deceptively simple. No talking.
```

## Wild battle theme (Claude, 2026-09-29, draft)

It keeps the menu's sound (square lead, triangle bass, cello, the rain texture) and its "battle cues" line, but raises the energy and makes it loop.

**Style of Music:**

```text
Instrumental chiptune battle theme for a moody, handmade monster-collecting RPG, same world as a gentle 6/8 title theme. Driving but restrained, about 150 BPM in 6/8 with a galloping triplet pulse. Muted square-wave lead carrying a short, memorable minor-key motif; warm triangle-wave bass locked to the kick; tight dry snare and brushed hi-hats; bowed cello doubling the bass on the big phrases; sliding square arpeggios between phrases; one distorted synth impact at each section change; a brief stop-start silence before the melody returns. Faint rain-softened texture underneath. Tense, determined, never cheesy. Seamless loop, no fade-out, no vocals, no talking.
```

**Lyrics box** (song-structure tags only, so Suno keeps a clean loopable shape):

```text
[Instrumental]
[Intro: 4 bars, snare pickup and distorted synth hit]
[Main Theme: square-wave motif over galloping triangle bass]
[Build: sliding arpeggios, cello enters]
[Break: one bar of silence, then snare fill]
[Main Theme: full band]
[Loop back to Main Theme]
```

**Tips:**
- **Make it sound like the same game:** if your Suno plan allows audio upload, use the menu track as the reference (Cover, or Extend from its ending) with the style above. The battle theme then inherits the menu's instruments and mix.
- **Picking takes:** generate a few, and pick the one whose first 4 bars sound like a clear intro and whose middle section repeats cleanly. Godot can then play the intro once and loop the rest (set the loop point on the imported file).
- **Ducking:** the battle's Music bus already ducks under attack sounds (`default_bus_layout.tres`), so signature moves like Molten Glass will cut through the music.

**Status:** Preston made it ("Galloping Triplet Pulse"; the current take is 1:36). It is in the game as `assets/audio/music/battle_theme.mp3`: it fades in when a battle starts, loops, plays at -10 dB on the Music bus (ducking under attack sounds), and fades out when the battle ends. Change it with `battle_music` and `music_db` on the BattleScreen node.

## Route 1: Highbank to the Old Ferry Ward (Claude, 2026-09-29, draft)

**What it scores:** from `docs/world-bible.md`:
- **The walk:** a runner carrying a sealed pouch down Switchback Road through oak-hickory bluffs, past old fields, to the ferry landing and the river trail.
- **The mystery:** a two-note creature call seems to come from the far bank, and a weaker copy answers. Calls arrive from the wrong direction.
- **The job:** it should feel like a walk with purpose, lived-in and a little uncanny, never ominous.

**Style of Music:**

```text
Instrumental chiptune overworld theme for a moody, handmade monster-collecting RPG, same world as a gentle 6/8 title theme. Walking pace, about 96 BPM in 6/8, hopeful but wistful, like setting out on a delivery through river bluffs at the end of a rainy day. Warm triangle-wave bass walking steadily; muted square-wave lead with a simple folk-like melody; a recurring two-note call motif that echoes back softer and slightly delayed, as if answered from across a river; plucked acoustic guitar and sparse piano; bowed cello swells on the long phrases; light brushed percussion. Soft rain and distant river texture underneath. Intimate, curious, a little uncanny, never ominous. Seamless loop, no fade-out, no vocals, no talking.
```

**Lyrics box:**

```text
[Instrumental]
[Intro: rain texture, two-note call and its softer echo]
[Theme A: walking triangle bass, square-wave melody]
[Theme B: cello swell, guitar and piano answer]
[Interlude: the two-note call returns, echoed from far away]
[Theme A: full, then loop]
```

**Tips:** use the menu track as the audio reference, as with the battle theme. Pick a take where the two-note call is clear and the echo is audibly softer. That call can later double as an in-game sound, since the route's story hinges on it.

**Status:** Preston made it ("Two-Note Call", 3:04). It is in the game as `assets/audio/music/route1_two_note_call.mp3`, played by `AreaMusic` (`scripts/area_music.gd`) in `first_route_prototype`. It fades out and pauses when a battle starts, and picks up where it left off after the battle. Verified in a run.

**Main menu:** Preston's "Pixel rain" (3:45) is at `assets/audio/music/main_menu_pixel_rain.mp3`. There is no menu scene yet; add an `AreaMusic` node with this stream when there is.

## Highbank, home town (Claude, 2026-09-29, draft)

**What it scores:** a town layered up the bluff, with homes, shops and the Dispatch Hall up top, and switchback lanes down through gardens to the ferry. It is the courier guild's home base. The guild's emblem is a three-dot route mark, so the town gets a three-note motif, which Route 1's two-note call answers.

**Style of Music:**

```text
Instrumental chiptune town theme for a moody, handmade monster-collecting RPG, same world as a gentle 6/8 title theme. Home-base warmth: about 84 BPM in 6/8, cozy and lived-in, a river town built up a bluff with a courier guild at its heart. Warm triangle-wave bass; muted square-wave lead singing a simple three-note motif that keeps returning like a familiar signal; fingerpicked acoustic guitar, sparse piano, soft music-box accents; bowed cello under the second phrase; light brushed percussion and a faint far-off train whistle texture. Gentle rain easing off in the background. Friendly, nostalgic, quietly hopeful, a place you are glad to come back to. Seamless loop, no fade-out, no vocals, no talking.
```

**Lyrics box:**

```text
[Instrumental]
[Intro: music box plays the three-note motif]
[Theme A: guitar and triangle bass, square-wave melody]
[Theme B: piano and cello, warmer and slower]
[Bridge: the three-note motif passed between instruments]
[Theme A: full, then loop]
```

**Suno budget:** 21 generations until 2026-10-30, each giving 4 takes. Suggested next tracks after Highbank:
- the Old Ferry Ward (uncanny landing);
- a victory jingle;
- a signature or boss battle theme;
- an evolution jingle.

**Status:** Preston made it ("Courier Guild Blues", 2:36). It is at `assets/audio/music/highbank_courier_guild_blues.mp3`. There is no Highbank town scene yet; give it an `AreaMusic` node when there is.

## Old Ferry Ward (Claude, 2026-09-29, draft)

**What it scores:** the old landing where the first Hollowtide reports came from. On still evenings, familiar calls arrive from the wrong direction, messages reach the landing with a sentence missing, and river creatures gather even when the banks are quiet (`docs/world-bible.md`). So the music has gaps where a bar goes missing, and Route 1's two-note call comes back from the wrong side.

**Style of Music:**

```text
Instrumental chiptune area theme for a moody, handmade monster-collecting RPG, same world as a gentle 6/8 title theme. An old river ferry landing on a still, foggy evening where something is slightly wrong. Slow, about 66 BPM in 6/8. Sparse muted square-wave melody that sometimes stops mid-phrase and leaves a bar of near silence, as if a sentence went missing; a two-note call motif that answers itself from the wrong side, softer and slightly out of time; low bowed cello drones; warm but distant triangle-wave bass; lonely piano notes; soft lapping water, a creaking dock and far-off fog texture. Curious and uneasy, quiet, beautiful, never horror. Seamless loop, no fade-out, no vocals, no talking.
```

**Lyrics box:**

```text
[Instrumental]
[Intro: water and fog, a single piano note]
[Theme A: square-wave melody over cello drone]
[Silence: one bar, the melody drops out]
[Theme A: resumes where it left off]
[Interlude: the two-note call, answered from far away, a little late]
[Theme B: triangle bass and piano, then loop]
```

## Victory jingle (Claude, 2026-09-29, draft)

**What it scores:** winning a battle. It must be short, and Suno makes full-length songs, so ask for a short piece and trim the first few seconds in the game (a jingle plays once and does not loop).

**Style of Music:**

```text
Instrumental chiptune victory fanfare for a moody, handmade monster-collecting RPG, same world as a gentle 6/8 title theme. Very short and bright: a quick rising square-wave arpeggio into a warm triumphant three-note phrase, tight snare roll, triangle-wave bass landing on a big resolved chord with a soft cello swell, then a gentle ring-out. Relieved and proud rather than bombastic. Under 10 seconds, ends cleanly, no vocals, no talking.
```

**Lyrics box:**

```text
[Instrumental]
[Short Fanfare]
[Big Final Chord]
[End]
```

**Tip:** pick the take whose first 6 to 8 seconds make a complete phrase ending on the final chord. Claude can trim it and add a short fade-out.

## Signature or boss battle (Claude, 2026-09-29, draft)

**What it scores:** the big fights: a guardian, a rival, or a wild creature whose signature moves take over the scene. It is the same world as the regular battle theme, but heavier and more cinematic. It must still duck cleanly under signature sounds like Molten Glass, so it leaves space in the low end for them.

**Style of Music:**

```text
Instrumental chiptune boss battle theme for a moody, handmade monster-collecting RPG, same world as a gentle 6/8 title theme and a galloping battle theme. Heavy and urgent, about 160 BPM in 12/8 with a pounding half-time feel. Aggressive muted square-wave lead with a dark minor motif; driving triangle-wave bass; tight snare and heavy low toms; bowed cello and low strings playing ominous stabs; distorted synth impact on section changes; sliding square arpeggios rising in tension; sudden stop-start silences before the motif crashes back in. Rain and thunder texture underneath. Epic but handmade, desperate and determined. Seamless loop, no fade-out, no vocals, no talking.
```

**Lyrics box:**

```text
[Instrumental]
[Intro: thunder, distorted synth hit, low toms]
[Main Theme: dark square-wave motif over pounding bass]
[Build: cello stabs and rising arpeggios]
[Break: sudden silence, then drums crash back]
[Main Theme: full intensity, then loop]
```

## Evolution jingle (Claude, 2026-09-29, draft)

**What it scores:** a creature evolving. It is short, and plays once. It builds suspense, then blooms, matching the evolution flash.

**Style of Music:**

```text
Instrumental chiptune evolution cue for a moody, handmade monster-collecting RPG, same world as a gentle 6/8 title theme. Short and magical: a shimmering square-wave arpeggio that slowly rises and quickens with a soft swelling cello and a heartbeat-like triangle-wave pulse, a moment of held breath, then a bright warm bloom into a major chord with music-box sparkles and a gentle ring-out. Wonder and pride, intimate rather than bombastic. About 12 to 15 seconds, ends cleanly, no vocals, no talking.
```

**Lyrics box:**

```text
[Instrumental]
[Rising Shimmer]
[Held Breath]
[Bloom: final chord]
[End]
```

**Tip:** as with the victory jingle, pick the take whose opening makes the complete arc (rise, pause, bloom) and Claude will trim it.

**Status, 2026-09-29:** all of Preston's tracks are in `assets/audio/music/`:
- `main_menu_pixel_rain` (3:45);
- `highbank_courier_guild_blues` (2:36);
- `route1_two_note_call` (3:04), live on the route;
- `old_ferry_ward_mist` (2:53);
- `battle_theme` (1:36), live in battles;
- `boss_thunderous_motif` (2:18);
- `victory_triumph_resolved` (38 s, needs trimming to the jingle);
- `evolution_rising_shimmer` (1:58, needs trimming).

The menu, town, Ferry Ward and boss tracks wait for their scenes or triggers.

## Signature-move cue (Claude, 2026-09-29, draft)

**What it scores:** the signature staging itself. The scene dims, the title card cuts in, the creature strains, everything holds its breath, then the release. One track, three parts: a build, a hard stop, and one huge hit. Claude cuts it into `signature_build` and `signature_hit`:
- **The build** starts with the signature and is silenced by the battle's existing hush (`_hush_cues`).
- **The hit** plays on the release frame with the move's own sound.
- **Battle music** steps aside for the whole signature.

This lines up for every signature, whatever its strain length.

**Style of Music:**

```text
Instrumental chiptune signature-move cue for a moody, handmade monster-collecting RPG, same world as a gentle 6/8 title theme. A creature is unleashing its ultimate move. Part one, about 5 seconds: tension rising fast, a bold four-note signature motif on muted square wave climbing higher each repeat, heartbeat-like triangle-wave pulse speeding up, bowed cello tremolo swelling, ticking hi-hat accelerating, rain texture fading away. Then a sudden hard stop into complete silence for one beat. Part two: one enormous hit, distorted synth impact, full snare and low tom crash, the whole band landing on a huge minor chord with cello and square-wave arpeggio ringing out for 3 seconds. Cinematic but handmade, awe and danger. About 12 seconds total, ends cleanly, no vocals, no talking.
```

**Lyrics box:**

```text
[Instrumental]
[Build: signature motif rising, heartbeat pulse, cello tremolo]
[Silence]
[Impact: huge final chord]
[Ring Out]
[End]
```

**Pick the take with:**
- a clear climb;
- true silence at the stop;
- a hit that lands as one blow.

Only the first 12 seconds matter. **Later:** per-essence versions (Ember brass and furnace, Stone deep drums), if the shared cue works.
