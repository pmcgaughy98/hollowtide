# Factory pass 8, the live audit's loop: result (2026-10-26)

Plan: [PASS8_PLAN_2026-10-26.md](PASS8_PLAN_2026-10-26.md). Six Claude lanes (dungeon, street, rooms, story, ui,
floors), then one integrator (Claude). Nothing is committed or staged. The pass sits on `dc37005af`.

## In short

- **48 of 49 lane items are done.** U9 (the last capture run of places nobody has filmed) waited for the lanes to land;
  the integrator's re-shoot covers part of it. Three dungeon sub-parts needed no change once measured (D3's box wrap,
  D5's boss bar, D11's card lantern).
- **Suite: 99 PASS, 0 FAIL, 0 TIMEOUT, 0 BROKEN, 4 RAN** (pass 7: 99 PASS, 0 FAIL, 0 TIMEOUT, 0 BROKEN, 4 RAN). The first full run had one FAIL,
  dungeon_evolve: the crew's den hung its autopilot. The integrator found and fixed the cause (below); the check then
  passed 3 of 3 alone and the next full run was 99 PASS, 0 FAIL.
- **Timing improved everywhere it is measured.** Slowest floor 1.40 s (pass 7: 1.57), mean floor 0.74 s (0.79), the
  dungeon scene ready in 1554 ms (1685), Highbank's first arrival 4268 ms (4527), memory +14.6 MB (+14.6).
- **Re-shot the live audit's screens** (Summer Engine connected this time, plus the windowed probe). Of the 33
  findings, 21 now read fixed, 5 partly, 6 are Codex's title and soul items and 1 is art on Codex's hold.
- **Two more faults found in the loop and fixed by the integrator:** the den hang above (found by the suite), and a
  single bright frame when Highbank comes up after the dawn walk (found by the re-shoot).

## Integration

Every cross-lane request whose old text still matched went in once, with the file's own line endings (hub_town.gd and
ruin_painter.gd are CRLF; mouth_escape.gd, ui_fit_check.gd and opening_flow_check.gd are LF). A dry run matched each
old text exactly once first. The script and the floors lane's tested copy are in
`C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\integ8\apply_xlane.py`;
ruin_painter.gd now matches the floors lane's tested `ruin_painter_proposed.gd` line for line.

| From | File | What |
|---|---|---|
| street (T5) | scripts/mouth_escape.gd | The dawn walk starts `hub_town.bake_ahead`, so Highbank's street paints on a worker during the road talk. |
| street (T4, T2), three edits | tools/debug/ui_fit_check.gd | ui_fit measures the street sign with the street's own `sign_layout` (talk size, growing upward) and the run line's real text. |
| rooms (R8) | scripts/town/hub_town.gd `_lift` | Leaving the street for a room, the fade waits until the room has built, plus one frame, so a long build no longer eats the fade. |
| story (S1) | tools/debug/opening_flow_check.gd | Waits 12 frames before its E on the partner choice, because an answer list now takes accept only 0.3 s after it appears. |
| floors (F1), four edits | scripts/dungeon/ruin_painter.gd | The Mouth's wall tops end in the cap row, a dark line, then black: no ragged band. About 9% faster to paint. |

Codex was working during the integration: it finished A2 (the soul flash under Reduce motion, soul_prologue.gd) and
the C7 input slice (main_menu.gd, storm_open.gd, soul_prologue.gd; `_ensure_menu_inputs` is gone) between 14:58 and
15:15, with two new handoffs. The integrator touched none of those files. The final suite ran after both; the title
re-shoot ran before them.

Not applied, routed instead: the ui lane's U7 request for `scripts/main_menu.gd` (the title's Quit stops its sounds
first). It matched, but main_menu.gd is Codex's file, so it went to Codex as line 16 of the new CODEX_TASKS section.

The integrator's own changes, both found in this loop:

| File | What and why |
|---|---|
| scripts/dungeon/boss_intro.gd `_walk_to` | Before each step it lets a running tween on that creature finish, and it stops if the creature's picture was freed. In the crew's den the scene gathers the team in the same frame Mirekit falls, often walking the partner whose blow felled it. Its step killed that blow's lunge tween, which `use_move` was waiting on, so the turn never ended and `busy` stayed set: dungeon_evolve's autopilot sat in the den for its whole 900 s (FAIL in the first suite, and 2 of 2 runs alone). A targeted probe (the partner fells Mirekit from three tiles off the leader) showed the blow never returning with the wait disabled and returning after 6 frames with it, the scene ending in 180 frames. The file was restored byte for byte after that test (hash checked). In a real game the player's E still reads the lines and the floor is left after the scene, so it showed only in the check, but it left a coroutine hung. |
| scripts/town/hub_town.gd (street T5's hold under black) | The two frames the town waits "under black" before fading in now put the shared black up when none is there. The dawn walk ends on its own veil, which leaves with its scene, so arriving from it the street showed at full light for a frame and then dropped to black to fade in. Luminance before: 0.0, 9.9, **96.9**, 16.4, 32.3 ... After: 0.0, 0.0, 0.0, 16.3, 32.2 ... The town's 583 ms build frame is now fully black and still. Headless checks never take this path. |

Every touched script parse-checks clean (40 game and tool scripts). creature_prologue.gd, mouth_escape.gd and
opening_flow.gd report only their autoloads (DialogueManager, PlayerParty), which is normal in that mode.

## The suite, before and after

| | Pass 7 (after-pass7-checks.md) | Pass 8, first run | Pass 8, after the den fix | Pass 8, final run |
|---|---|---|---|---|
| PASS | 99 | 98 | 99 | 99 |
| FAIL | 0 | 1 (dungeon_evolve) | 0 | 0 |
| TIMEOUT, BROKEN | 0, 0 | 0, 0 | 0, 0 | 0, 0 |
| RAN (judges nothing) | 4 | 4 | 4 | 4 |
| WINDOW, RETIRED, SKIPPED | 6, 3, 1 | 6, 3, 1 | 6, 3, 1 | 6, 3, 1 |

The final run came after the black fix in hub_town.gd and after Codex's two edits today (below). Its table is
[after-pass8-checks.md](after-pass8-checks.md). pilot_chain passed in 66, 95 and 73 s in the
three full runs (pass 7: 108 s); its random runs differ each time, so the time is not a verdict. No suite run rewrote a
tracked file (git status before and after differs only by the new table). Nothing else heavy ran during the suites.

### Timing, before and after

timing_check alone on a quiet machine, twice, the final code (second run in brackets). Pass 7's numbers are its own
quiet-machine run.

| Measure | Pass 7 | Pass 8 |
|---|---|---|
| Slowest floor build (20 floors) | 1.57 s | 1.40 s (1.42) |
| Mean floor build | 0.79 s | 0.74 s (0.73) |
| Ruin floors, mean | 0.59 s | 0.53 s (0.52) |
| Riverbank floors (Warren), mean | 1.06 s | 1.02 s (1.01) |
| Valley floors, mean | 1.22 s | 1.13 s (1.13) |
| Dungeon scene ready with its first floor | 1685 ms | 1554 ms (1554) |
| Highbank first arrival, painted (headless, one call) | 4527 ms | 4268 ms (4323) |
| Highbank warm arrival | 62 ms | 60 ms (59) |
| `TownRoom.prepare('hall')` / Hall arrival after it | 248 ms / 196 ms | 274 ms / 160 ms (272 / 163) |
| `prepare('hall_low')` / arrival | 858 ms / 2 ms | 801 ms / 2 ms |
| `prepare('home')` / arrival | 109 ms / 4 ms | 102 ms / 3 ms |
| Static memory over 20 floors | +14.6 MB | +14.6 MB |
| Static memory at the end | 144.9 MB | 145.6 MB |

No regression. The Hall's prepare is 26 ms longer because the desk art moved into it (R8), which is why its arrival is
36 ms shorter. The Mouth paints faster with the ragged band gone.

### Live stalls (windowed, wall clock)

The street lane's own probe (no screen readback), final code, fresh user folder:

| Where | Before pass 8 | Now |
|---|---|---|
| First arrival in Highbank by Continue (the card) | one 956 to 1123 ms frame under the moving card | worst 231 and 235 ms, none over 250 (town ready 5.3 s) |
| Return to Highbank | 280 ms | 217 and 246 ms |
| Setting out for The Hollow after 12 s in town | 1381 ms | worst 35 ms |

From the live probe (its own per-frame readback adds up to about 150 ms): the flood talk entry and the Hall's runners
scene logged no frame over 250 ms; Highbank after the dawn walk is ready 2 ms after the walk ends (the street was baked
during it), with its one 583 to 862 ms build frame fully black and still; every long dungeon frame (339 to 1192 ms on
stairs) fell on the still black floor card.

## Per lane

**dungeon (11 of 11; three small parts needed no change).** D1: the log no longer bolts 'It bites deep!' or 'It barely
scratches.' onto a damage number; the first non-neutral hit on each foe per floor gets its own matchup line naming the two
essences ('Bloom is strong against Tide!', 'Tide shrugs off Ember.'), kept once per foe per floor. Damage and multipliers
are Grok's and unchanged. D2: item text in sentence case with units ('Heals the leader 15 HP.'), 'Picked up the Lamp
Oil.', and the partner's pickup lesson names the item. D3: the 'there's one of 'em' lesson fires only with a wild on
screen and in sight; the keys moved out of the partner's mouth into a device-aware chip under the talk box that lists
only filled move slots. D4: the party panel keeps one face and case on every floor ('Sense' spelled the same in every
row). D5: banners start right of the party panel; on a boss floor the camera aims between leader and boss. D6: the
crew's den plays one victory jingle (the parcel's). D7: the bag and learn panel take whichever side covers less of the
team. D8: 'denied' plays on the UI bus in the Hollows too. D9: at the Mouth's way out the partner walks beside the
leader and the camera holds both; on the faint page the leader lies down. D10: a job's client appears only in its own
Hollow. D11: a Hollow's first arrival loads its art in short slices under the black card; the worst frame went from
849 to 1098 ms to 193 ms.
Not changed, measured instead: the talk box already wrapped at its inner width (the 'two thirds' look was the old
two-sentence line); the boss bar was not moved (from 4 tiles up the Warden is taller than the view can hold with the
leader above the move cards); the dungeon's floor card has no lantern to start.

**street (11 of 11).** T1: partners keep off shared tiles, building footprints and facade rows on arrival, after every
scene and at doors, in Highbank and on the Hollow approach (hub_town_check asserts it with a team of four). T2: the run
line takes its place name from the gate's layout entry ('The Mouth of the Hollow starts a run'). T3: inside Hollow Mouth
the Objective has its own line; after the end card it reads the record (who is ready at the shrine, else a done or
taken request, else new requests). T4: street signs and the Highbank arrival panel use the talk box's type. T5: the
street is painted on a worker during the road talk (with the mouth_escape.gd line the integrator applied), the card's
lantern breathes while it waits, and the return to Highbank does its heavy frame under black: a fresh first arrival is
ready 542 ms after the talk instead of holding the card about 5 s. T6: the Hollow approach's pictures are made on the
town's warm-up worker: setting out went from a 1381 ms worst frame to 33 ms. T7: board rows align (the parcel has its
own column), one board never posts two jobs for the same item, and titles are short sentences. T8: the town hint's use
key is the 'interact' binding, the same key Rebind keys lists. T9: the MENU chip hides while a panel or the shrine is
open. T10: the dashed rectangle was the board's reading-spot marker; it is worn earth now. T11: no code fault; the
audit's silent Storage door came from its own probe opening the pause menu; hub_town_check now asserts the door sound.

**rooms (8 of 8).** R1: followers stand on separate open tiles behind the leader in every room, after scenes and at the
door (town_room_check fails on a shared tile, a solid or a sprite off its tile). R2: no prop ever drew over the talk
box; what showed was the box's 92%-opaque weave. The box now has an opaque backing. R3: the Hall's doorway is painted
as an opening (sill, lit threshold, a spill of daylight), and both tiles under the carpet's end lead out. R4: the
runners' line-up is one row with leader and partner centred. R5: after the bed the team is spaced round the leader.
R6: new Roster Board panel (`scripts/town/roster_panel.gd`): swap waiting creatures into slots 2 to 4; the leader never
moves; changes are saved. R7: the full mail call plays once per story stage. R8: the Hall's 759 ms frame came from
every scene line loading the leader's and partner's whole creature files for their names (Rimefin 626 ms cold); names
are now read once on a thread, and the Hall's worst frame through the runners scene is 53 ms.

**story (7 of 7).** S1: answer lists in the flood talk and the road talk take accept only from a fresh press 0.3 s
after they appear, and the highlighted answer has a visible cursor. S2: the dawn walk is regraded to morning, the mist
round the ruin is gone, and the party walks off the trail's south-west edge before the HIGHBANK card. S3: the dawn walk
shows the whole party, up to four. S4: the crew's den, the Warden's entrance and the Warden's aftermath frame each line
on its speaker and the leader, and no teammate stands under the bottom bar (0 of 42 lines, was 8 of 13 in the crew
scene). S5: Starward's walk-on no longer leaves a '6:2' growth record. S6: the arch card reads HOLLOW MOUTH. S7: the
flood talk builds under black (no frame over 250 ms while anything shows); the arch's frame was already under black.

**ui (8 of 9; U9 left to run after the lanes).** U1: UI.HEAD (the old heading font) is gone. U2: Codex's shared
preference save is installed, with `.bak` readers as a second guard (12 of 12). U3: the growth box text is at talk-box
size. U4: growth counts stop at the goal ('3 / 3 DONE'), each condition has a plain line, and Sense is explained (the
leader's Sense does not grow, and the page now says so). U5: the pause menu's Objective headline fits two lines, the
town page is packed with margins, and a device-aware key row was added. U6: an empty second key reads a faint 'None';
the Use / stairs row tells a pad player that A also uses in town. U7: quitting from the pause menu or the window's X
stops every sound first; the leak report went from 11 instances to 0. U8: `tools/debug/live_play_probe.gd` is the
page-aware live probe (Hall gaps 4.01 s, street 5.74 s, all under 6). U9 (the last capture run of places nobody has
filmed yet) was left for after the lanes; the integrator's re-shoot covers part of it (see What remains).

**floors (3 of 3).** F1: the ragged black band along wall tops is gone. In the Warren, every bank edge now ends in a
clean back course of clay clods, a dark line, then black; the Mouth's own band is gone with the integrator's
ruin_painter.gd edit (the floors lane's tested request), which also paints the Mouth about 9% faster. Wall tops wrap
round outer corners. F2: Warren rooms have a rim like the Mouth's cap row. F3: Warren sand ripples vary in spacing,
offset, curve and length.

## Re-shot screens and what they show now

Summer Engine connected this session, so the re-shoot used it for a live pass on Preston's own save (title, Continue,
Highbank, pause, Objective; 7 frames) and the windowed probe for the rest: `tools/debug/live_play_probe.gd` (U8) with
two added phases in a scratch copy (the arch to the dawn walk to Highbank; a faint), each phase with its own user
folder under `%TEMP%\p8i` and its own copy of the pilot chain's saves. Stills and logs:
`C:\Users\pmcga\AppData\Local\Temp\claude\C--Users-pmcga-dev-hollowtide\a9e8a4f0-7051-47b8-8115-f9a36b2774b8\scratchpad\integ8\reshoot`
(mouthrun, dawn, faint, title, town, storage, padpad, menus, hollowtimenolum, storyintodungeontagpart1 and part2) and
`...\integ8\summer1`.

Save safety: before any of it, Preston's user data folder (3178 files outside logs/) was copied to
`...\integ8\userdata_backup` and hashed (SHA-256). The Summer pass changed four files there (the save, its .bak, Summer's
own settings file, and a re-baked street picture). All four were restored from the backup, the new street picture was
removed, and all 3178 hashes match the backup again (`userdata_hashes_restored.txt`, checked again at the end). At the end one file differed: `summer_engine_settings.cfg`, Summer Engine's own settings,
rewritten at 15:13 by Summer after the restore, not by the re-shoot (no Summer call ran after 14:31); it was left as
Summer wrote it. The save and its .bak were also written again at 15:01 and 15:02 by some other process, byte for
byte the same as the backup. Every one of the 3177 game files matches the backup. Every probe ran with its own user folder.

| Finding | Now | What the re-shoot shows |
|---|---|---|
| L01 team in a heap | fixed | Hall carpet (T14, S12), Storage (K03), the home and Highbank door (T04, P03, S03), the lower Hall at mail call (S47) and the Hollow approach (S53): four creatures on four tiles. Skimlet stands on the grass beside the home's wall, not on it. At the bed (T09) one teammate stands at the room's top edge, partly under the place panel. |
| L02 pillars over the talk box | fixed | Mail call (S47, S50): the box frame and its corner studs draw over the pillars' tops. |
| L03 one place, four names | partly | Arch card HOLLOW MOUTH (M03), floor card HOLLOW MOUTH B1F (M05), town hint THE MOUTH OF THE HOLLOW STARTS A RUN, the layout's own name. Two names remain (the dungeon and the gate): Preston's call. How to play (Codex) still says 'Mouth of the Hollow ... into a dungeon'; The Hollow's approach still reuses the Mouth's arch painting (S53, art for Codex). |
| L04 New Game over a save | Codex | Not re-shot. Codex holds the flag off until Preston picks the words. |
| L05 starter picked by a reading press | Codex, open | The probe's press 1.8 s after 'Choose the shape you will wear.' took Kithflare with no Yes/No. |
| L06 choices take the advance press | fixed | 'Whose voice do you answer?' stayed up 1.8 s and took the probe's first fresh press; the dawn walk's lists show a cursor (M31). The story lane's real-key probe: E held through the line picks nothing. |
| L07 dawn walk picture | partly | Morning grade, no mist at the ruin, the pair walks off the south-west edge (W37 to W39). The ruin still stands in the river at the top right while the lines say 'high and dry': the lines are Preston's call. |
| L08 speakers off screen | fixed | End of the Mouth (M19, M22): the partner beside the leader, both in frame. Faint (F07, F08): the leader lies down, the speaker stands in frame. Crew and Warden lines: the story lane's per-line probe, 0 of 42 lines with someone low or out of view (this probe does not shoot those lines). |
| L09 matchup words beside numbers | fixed | M08 to M10: 'Tide shrugs off Ember.' and 'Bloom is strong against Tide!' on their own lines; damage lines are plain. |
| L10 Objective inside the Mouth | fixed | M14: 'Find the stairs. The way out is below.' on two lines. Preston's save (Summer): 'Get the parcel back in / Rootbank Warren', two lines. |
| L11 small text in big boxes | fixed | Lane stills (street t4_arrival_panel, ui 14_growth_box); the re-shoot's growth result (S79) is in body size in a box fitted to it. |
| L12 ragged black wall tops | fixed | Mouth B1F (M17) and Warren B1F (F01): a clean cap row or clay course, a dark line, then black. |
| L13 Hall exit | fixed | Story part 1 walked down the carpet and out (both tiles under its end lead out); rooms lane still of the painted doorway. |
| L14 Highbank card with no cue | fixed on the story path | After the dawn walk the town is ready 2 ms after the walk ends. Continue with no street picture on disk still holds the breathing card about 5.3 s (no frame over 250 ms); on Preston's own save in Summer's hidden window it held about 10 s, once, because STREET_VERSION 3 re-bakes the street. |
| L15 long frames | fixed where listed | None over 250 ms on a lit or moving screen at the flood talk, the Hall, Highbank or the Mouth arrival. Long frames remain on black: stairs 339 to 1192 ms, the Hollow approach 1219 to 1244 ms when the team sets out within about 10 s of arriving (35 ms after a 12 s warm-up). |
| L16 party panel type | fixed | M13, S68: one face and case in every row, Cutbank Listener included; 'Sense' in every teammate's row. |
| L17 item text | fixed | Bag (P14): 'Brings the lantern back 40.', 'Thrown down a line for 8 damage.', 'The leader gets up once when it goes down.' The log reads 'Picked up the ...'; the lesson names the item ('somebody dropped this Second Wind'). |
| L18 partner reads out keys | partly | The wild lesson (M07) fires with the foe on screen, speaks no keys, and the chip reads 'J ATTACK  1 MOVE'. The item lesson still says 'Press I whenever you want to dig through the bag.' in the partner's words. |
| L19 board rows read templated | partly | One column of short sentences with the parcel in its own column, no repeated lost item (T11, P04). The second line still ends 'dropped there' on lost-item jobs. |
| L20 pad hint vs Rebind | fixed | P03: 'STICK WALK  X USE', the key Rebind lists for Use / stairs. |
| L21 over-quota growth counts | fixed on the Team page | X04: plain lines under each condition, Sense explained. The Growth Shrine panel still shows 'Knockouts 26 / 3', 'Floors cleared 11 / 2' (S74, S78): new, not in this plan. |
| L22 to L25 title, How to play, soul, save chip | Codex | O06, O18, O24: unchanged, as expected (Codex's files). |
| L26 letterbox cuts the team | fixed | Story lane's framing probe (above); not in this probe's frames. |
| L27 Warden half off screen | partly | S71: the camera holds the leader and the Warden together; the crest touches the top edge when the Warden stands far up (the dungeon lane's measured limit: 4 or more tiles). |
| L28 nest banner over the panel | fixed | Dungeon lane still (band from x 360 with three in the team). The re-shoot met 'A nest! They're all awake.' but its frame fell between shots. |
| L29 Rebind '-' | fixed | O14, X09: a faint 'None'. |
| L30 dashed box by the board | fixed | Street lane before and after stills (worn earth); not in this probe's frames. |
| L31 small buildings bottom right | art, on Codex's hold | Measured by the street lane: the Scroll Keeper's cellar at about a third of the street's scale, mid-town, so not distance. Codex's town art is on HOLD for the placeholder factory. |
| L32 pause menu | fixed | T05, P07, P16, Summer frame 4: a device-aware key row; the town panel inside the screen with margins. |
| L33 audio oddities | fixed | E at the Storage door: door.wav on SFX. 'denied' on UI in the Hollow (3) and town (1). One victory per crew's den (story part 1 and 2 audio logs). |

The LH8 leftovers with something to see: LH8-03 the runners' line-up is one row (S12); LH8-04 the bed spaces the team
(T09, one at the room's edge); LH8-05 one victory per den; LH8-06 no MENU chip with the board or shrine open (T11, P04);
LH8-07 the learn panel clear of the team on a pad (P10); LH8-08 no '6:2' growth key in either story save.

## New player-facing words (proposals, not canon)

All are in the game now and listed for Preston's veto; each is a one-line change back.

1. Matchup line (dungeon.gd, D1): '<attack essence> is strong against <foe essence>!' and '<foe essence> shrugs off
   <attack essence>.'
2. Item text (D2): 'Heals the leader 15 HP.' / 'Brings the lantern back 40.' / 'Thrown down a line for 8 damage.' /
   'The leader gets up once when it goes down.' / 'For a client below. It goes with the bag if the team goes down.' /
   scrolls: 'Teaches its move to a body with <parts>.' / log: 'Picked up the <item>.'
3. Partner lessons (D2, D3): 'Whoa, heads up, there's one of 'em. If it comes at us, hit it!' with the chip 'J ATTACK
   1 MOVE' (pad 'A ATTACK  RB+A MOVE'); 'Ooh, somebody dropped this <item>. It's ours now. Press <bag> whenever you
   want to dig through the bag.'
4. Run line (T2): 'The Mouth of the Hollow starts a run' (the gate's own name).
5. Objective inside Hollow Mouth (T3): 'Find the stairs. The way out is below.' / 'The water's up behind you. Take the
   stairs down on every floor; the way out of the ruin is at the bottom.'
6. Objective after the end card (T3): '<name> is ready to grow at the Growth Shrine.' / 'A request is done. The pay
   waits at the Job Board.' / '<name> is lost on <floor>.' / '<name>'s <item> is down on <floor>.' / '<name> waits for
   a parcel on <floor>.' / 'New requests on the Job Board.'; long form adds 'That's the first stretch. Run the Hollows
   again or rest at home.' and, when it is not a ready line, 'The shrine is there for whoever is ready next.'
7. Job Board notes (T7): '<name> got lost down there. Bring it home.' / '<name> dropped its <item>. Find it.' /
   'Deliver to <name>. It's waiting on a parcel.'
8. Roster Board (R6): title 'Roster Board'; 'Who runs and who waits at the Hall. The leader always runs.'; 'Waiting at
   the Hall'; 'The team'; 'Open'; 'leads'; 'Nobody is waiting yet.'; '<name> joins the team.'; '<name> waits at the
   Hall.'; '<name> joins the team. <name> waits at the Hall.'; 'Who waits at the Hall instead?'; 'Who joins the
   team?'; 'Who comes along instead?'; 'Nobody is waiting at the Hall yet.'; 'The leader needs someone along.'; keys
   'W/S  choose     A/D  column     E  pick     Esc  close' ('let go' while a creature is held); 'Lv <n>'.
9. Team page (U4): Level 'Fights earn EXP, and EXP raises it.'; KOs 'Foes it lands the last hit on.'; Floors 'Floors
   it finishes still standing.'; Pincer hits 'A friend behind the foe, or the foe asleep.'; Hits on sleepers 'Hits on
   a foe that is still asleep.'; Damage taken 'Damage it takes in fights.'; Slams 'Foes it charges into a wall or a
   creature.'; Health restored 'Health its spring gives back to the team.'; Sense 'How well it fights on its own. It
   grows with every floor and knockout.'; on the leader 'You steer the leader, so its Sense does not grow.'
10. Pause menu key rows (U5): 'ARROWS  CHOOSE   ENTER  SELECT   ESC  CLOSE' (pad 'D-PAD  CHOOSE   A  SELECT   B
    CLOSE'); Objective page 'ESC  BACK' (pad 'B  BACK').
11. Rebind keys (U6): an empty cell reads 'None'; the Use / stairs note: 'In Highbank, A also uses a place. It is
    Choose, under Menus and questions.' (keyboard: 'In Highbank, J and Enter also use a place. They are Choose, under
    Menus and questions.')

Renamed, not new: the arch card reads HOLLOW MOUTH (was THE HOLLOW), as the plan asked.

## Notes for Preston

- The crew's den could leave the game's turn stuck when your partner landed the last blow on Mirekit. You never saw it
  because pressing E kept the story going, but it showed up in the checks. It is fixed.
- Arriving in Highbank after the dawn walk flashed the street at full light for one frame. Fixed: it now fades up from
  black.
- The first time you press Continue after this pass, Highbank's card may hold about 5 to 10 seconds once. The street
  picture is repainted because its look changed (the worn-earth spot by the Job Board). After that it is instant.
- Your partner's item tip still names a key out loud ('Press I ...'), and the Job Board's second line still says
  'dropped there'. Both are small word fixes, waiting for your yes.
- The Growth Shrine still shows counts past the goal ('Knockouts 26 / 3'). The Team page is fixed; the shrine needs
  the same clamp.
- Pressing E at the Growth Shrine freezes the street for about half a second before the panel opens.
- If you set out for The Hollow within about 10 seconds of arriving in town, the black screen holds about a second.
  Wait a little longer and it does not.
- Roster Board: slot 2 can be swapped, but story scenes give the partner's lines to whoever is in slot 2. Locking slot
  2 is a one-line change.
- The Hall's talk box is now fully solid. Nothing ever drew over it; what showed was its slightly see-through fabric.

## Preston's calls (each has a default if unanswered)

1. The new words above. Default: they stay.
2. L03: rename the town gate ('Mouth of the Hollow') to 'the way down' and keep The Hollow for the third dungeon only?
   Default: leave the gate's name; the arch card says HOLLOW MOUTH and the town hint uses the layout's one name.
3. L07: rewrite the dawn walk lines ('the ruin sits high and dry', 'the river has gone down to a sulk', 'The trail
   climbs') or paint a new picture? Default: leave the lines; the picture is now regraded to morning.
4. L-07: stand the last few rescued clients in the Crossroads and by the board with one line each? Default: leave.
5. L-08: three or four thank-you lines per job kind and a short note per request? Default: leave.
6. L-10: new post-stone lines for Starward and the crew, and a fixed 'slip' line for Wayling? Default: leave.
7. L-06: what does a Courier Rank open (Item Shop, Scroll Keeper or Training Yard)? Default: leave.
8. L-12: should you pick the leader, as in Explorers of Sky? Default: leave (the starter leads).
9. L-05: should jobs pay something spendable once the shop opens? Default: leave.
10. L-03: later forms for Skimlet, Ozbender and Valvekin? Default: leave.
11. New: lock the Roster Board's slot 2 to the story partner? Default: leave it swappable.
12. New: the item lesson without a key ('Ooh, somebody dropped this Second Wind. It's ours now.' plus the key chip, as
    the wild lesson does) and the board's 'dropped there' line? Default: leave until you say.
13. L04 (Codex holds it): the New Game warning's words. Default: the warning stays off.

## Codex and Grok

Appended as "11. Pass 8 lines" to [CODEX_TASKS_2026-10-22.md](../CODEX_TASKS_2026-10-22.md) and "Pass 8 lines" to
[GROK_TASKS_2026-10-22.md](../GROK_TASKS_2026-10-22.md). Codex: the New Game warning (held for Preston's words), the
starter cards and soul fixes (L05, L24, C8, C9; C7's input slice and both Reduce motion flashes landed in Codex's A1 to
A3 results today), Options focus, How to play, the save chip, the threaded Continue, icon, splash and export, the arena fronts,
the foot-row data file, the art queue (town signs, lettering and the Scroll Keeper stay on Codex's hold), the arch
variant, the U7 quit request for main_menu.gd, and two FYIs (the shared preference save is installed; opening_flow_check
waits for the answer list). Most are already in Codex's newer [CODEX_TASKS_2026-10-26.md](../CODEX_TASKS_2026-10-26.md),
and the section names where. Grok: the Mouth's monster-house answer is in Grok's own result today and waits for Claude
to apply; Job Board clients and the Guardian step, partner growth, Troughspine's condition, reward caps, per-Hollow map
recipes, which Hollows post requests, and Courier Rank steps. No Grok number changed this pass.

## What remains

- **Next, Claude:** apply Grok's 2026-10-26 answers unchanged (no Monster House on Hollow Mouth B1F and B2F until
  "mouth" is beaten, the task 3 learnset cut, the task 4 delete of `fire_move.tres`), then rerun pilot, dungeon_chain,
  lv1 and move_table. Not done here: the integration came first.
- U9's last capture: the Hall's upper-floor mole, a street chat, Training Yard, Scroll Keeper, Bluff Lookout, 60
  nest-banner frames, hit_heavy.wav and measure.py contrast on the rooms, board, storage and the evolution scene. The
  probe exists (`tools/debug/live_play_probe.gd`); those places need walk targets.
- Found by the re-shoot, open: the Growth Shrine's over-quota counts; a 529 to 608 ms lit frame when the shrine panel
  opens; the item lesson's 'Press I'; the board's 'dropped there'; one 339 ms frame mid-fight on Warren B1F (once).
- Quitting right after a return to Highbank, while the town's warm-up is still painting rooms on a worker, hung one of
  two street-probe runs until it was killed at 300 s (the other quit in 14 s). The street lane saw one crash in the same
  window. The player's quit paths (pause Quit, the window's X) were not tested for it. Worth a slice of its own: make
  quit wait for the warm-up's task, or stop it.
- Setting out for The Hollow within about 10 s of arriving holds one black frame about 1.2 s (the warm-up has not
  finished); stairs hold the black card up to 1.2 s. Neither freezes anything on screen.
- The Warden's crest touches the top edge when it stands 4 or more tiles above the leader; D5's camera was measured
  with a 22 px bar gap and the gap was raised to 26 afterwards without a re-measure.
- `world_tile_art.gd clearings()` still lays an earth square at the board's reading spot under the new worn earth; its
  board branch can go.
- The town's MENU chip on a pad: the lane saw '[P]'; this re-shoot showed '[START]' on the pad (P03). Recheck once.
- Codex: everything in section 11. Grok: everything in 'Pass 8 lines'.
- The answer list is drawn by two copies of the same code (creature_prologue.gd and mouth_escape.gd); one shared
  helper in ui_style.gd would replace both.
