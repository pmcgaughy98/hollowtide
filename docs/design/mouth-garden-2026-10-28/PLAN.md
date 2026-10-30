# The first dungeon ends in the Warden's garden, 2026-10-28

Preston: "for the first dungeon add the pond garden where warden is scene with them finding it because its also room where exit is. Then after they leave wardens shadow appears on pond surface with its menacing eyes showing hinting at the monster below. And when they go back on the mission where they actually fight him there will be more floors to get there. We'll compensate with the first dungeon having little floors to get to garden with a scene with them somehow end up on lowers floors closer to exit floor where warden is. whether its because the flood or whatever makes most sense."

Story choices below are mine, as he allowed ("whatever makes most sense"). The lines are proposals for him to rewrite.

## What the game does now (read from the code, 2026-10-28)

- **Hollow Mouth** (`"mouth"` in `scripts/dungeon/dungeon.gd` DUNGEONS): the flood escape. 4 ruin floors, no boss. Its last stairs are the way out. On them, `_mouth_exit()` plays: a rumble from "a presence below" while the partner shows the parcel it saved (`story.parcel = "saved"`). Then the road talk.
- **The Hollow** (`"hollow"`): 2 floors, then the boss floor. The boss floor is the pond garden, drawn in code by `scripts/dungeon/boss_intro.gd` (meadow, pond, fish, lilies, reeds, fireflies), with the Warden's whole entrance: the voice, the shadow rising under the water, the burst, the landing, the Listeners, the talk, the fight.
- The garden exists only as The Hollow's boss floor (floor kind `"boss"`, room `BOSS_ARENA`, pond placed from the stairs).

## The new shape

### Hollow Mouth (the first run): few floors, the flood takes them down

| floor | what happens |
|---|---|
| B1F | As now: the flood behind them; it teaches moving, the partner, items and the stairs. |
| B2F | Partway across, **the flood catches up.** Water bursts through the wall behind them, and the old floor, soaked through, gives way. The team drops with the water down an old drain shaft. |
| B4F | They come to, washed up, deeper than they meant to go. (B3F is skipped: the water carried them past it.) One floor to the stairs. |
| **The garden** | The bottom of the ruin, and the way out. |

Why the flood: the Mouth is already a flood escape ("The water's up behind you"), so the water that chased them is what carries them down. The second time there's no flood, so they walk every floor.

### The garden as the Mouth's exit room

1. **Finding it.** They come down the stairs into the meadow: quiet music, fireflies, a still pond. The partner reacts before it says anything useful. A draft, in the house voice: "...Well. Would you look at that. Who keeps a garden down a hole?"
2. **The way out** is across the garden: the old steps up out of the ruin, where the Warden's room has its stairs. No wild creatures here and no fight.
3. **The parcel beat moves here:** the partner shows the parcel at the way out (the same `_mouth_exit` beat, now in the garden).
4. **They leave.**
5. **After they leave, the hint at the monster below.** The camera stays on the empty garden. The fireflies go out one by one, and the pond goes still. A huge shadow slides up under the surface, and two eyes open in it, menacing. They hold, narrow, then sink. Fade out to the road talk as now.

This reuses what the Warden's entrance already draws: the garden, the pond and the rising shadow. The eyes are new.

### The Hollow (the Warden mission): more floors

- **Floors 2 → 4**, then the garden boss floor with the full entrance, unchanged. The floor count and the spawns for the two new floors are Grok's numbers. Until Grok sets them, B3F and B4F reuse B2F's spawn set.
- Its objective line can point back to the place they've seen: "Go back down to the garden at the bottom of the Hollow."

## Build order (one slice at a time, each checked before the next)

1. **The garden as the Mouth's exit room.** A new floor kind for the Mouth: a fixed garden room after its last floor, drawn by `boss_intro.gd` without the Warden, with the way out at the stairs. Then the finding scene, and the parcel beat moved to the garden.
2. **The Warden's eyes after they leave.** A short scene after the exit fade, using the entrance's shadow drawing plus new eyes.
3. **The flood sweep on B2F.** The scene, then the jump to B4F with a washed-up arrival.
4. **The Hollow's extra floors**, plus the objective line, plus a brief to Grok for B3F and B4F.

Checks to run after each slice: mouth_escape, flood_opening, story_gate, lv1_run, road, save, timing, faint. Run pilot_chain (about 12 minutes) at the end, because the story path changes.

## Built

Preston said yes to all four slices the same day ("Yes to 1 2 3 4").

**Slice 1, the garden as the Mouth's exit room (built, checked).**
- `scripts/dungeon/dungeon.gd`: the Mouth has `"garden": true`. `floor_kind()` returns `"garden"` for the floor past its last (B5F until slice 3 lands). The room is the Warden's (`BOSS_ARENA`, 25x18) with the pond under the stairs, drawn by `boss_intro.gd` with no Warden: meadow, pond, fish, fireflies. No wilds, no jobs, the rest-floor music.
- The way out is the garden's stairs, past the pond. The clear now waits for them.
- `_garden_found()` plays once (`story.garden_found`): the camera rests on the pond, the partner walks up and reacts. The lines are proposals.
- The parcel beat (`_mouth_exit`) moved to the garden's stairs. Its rumble now comes from under the pond, and the pond answers with a ring.
- `tools/debug/flood_opening_check.gd` walks both stairs now and checks the garden, no wilds, the scene, the parcel and the clear.
- Checks passing: flood_opening (new garden lines all ok), mouth_escape, story_gate, lv1_run, road, road_tower_view, save, faint, timing (timing failed once while four checks ran together, then passed alone; the slow floor was Rootbank Warren, which this did not touch).
- Not seen in a game window yet.
- **Pilot chain caught a real bug.** The first run stalled in the garden: the walkers' distance fields were built from the map's tiles, where the pond is floor, so the autopilot (and any partner following) stood at the near shore forever. Fixed with `_walk_tiles()`, which walls the pond off for path-finding; `_field_round_traps` uses it too. After the fix: flood_opening, dungeon_boss, warden_yield, stone, lv1_run and mouth_escape pass.
- **Pilot chain passes after the fix** (all ok in 65 s): the Mouth clears through the garden with the parcel saved, then the Warren, the Hollow with the Warden, the stone, the first growth and the end card.

**Slice 2, the Warden's eyes after they leave (built, checked).**
- `dungeon.gd` `_garden_eyes()` plays once (`story.garden_eyes`) on the black after the garden's stairs, before the clear. The team is gone (hidden), the music stops, and the camera stays on the pond: the fireflies go out one by one, the pond goes still, the shadow rises (to 0.85), two eyes open, narrow into a glare, and sink with the shadow. Then the fade and the road talk as before. About 14 seconds.
- `boss_intro.gd` draws it: `_eye()` (a 9-pixel lens with a hot core, a dark slit, and its top edge dropping toward the other eye as it narrows), the `still` flag that stops the idle rings, and the fireflies' one-by-one fade (`lights_out_at`, `FIREFLY_OUT`).
- The garden now plays the `pond_garden` music, the track the Warden's entrance uses in the same place.
- flood_opening_check watches it play: eyes peak 1.00, shadow peak 0.85, fireflies out, once. dungeon_boss, warden_yield, stone and mouth_escape pass.
- Not seen in a game window yet. A capture script (like `tools/debug/boss_intro_capture.gd`) would save stills for Preston to look at.

**Slice 3, the flood sweep (built, checked).**
- `dungeon.gd`: on the Mouth's B2F, once the leader is halfway to the stairs by walking distance (or after `SWEEP_TURNS` = 40 turns there), `_flood_sweep()` plays once (`story.swept`). A roar builds and the walls run with water, the partner walks up and hears it, then the water bursts in (big shake, the view floods blue then goes black) and the floor gives way. The team lands on B4F, skipping B3F. Growth and IQ count the two floors.
- `_washed_up()`: the card lifts on the team with stars circling (the entrance's daze), a line, then the partner reacts. Then the run goes on.
- `act_stairs`' arrival half is now `_arrive(washed)`, so the sweep lands on a floor the same way the stairs do.
- A later run of the Mouth walks every floor (B3F included).
- flood_opening_check walks it: the walk across B2F is 15 steps, the sweep lands on B4F, B3F is never built, the team is dazed on arrival and free to move after.

**Slice 4, the Hollow's extra floors (built, checked).**
- The Hollow has 4 floors before the garden. B3F and B4F reuse B2F's spawns and the ruin look until Grok sets them (`docs/team/GROK_TASKS_2026-10-28.md`, which also asks about the Mouth's shorter first run).
- The objective now reads "Go back down to the pond garden": "You're runners now. The garden you climbed out of is at the bottom of The Hollow, through the (gate)."
- dungeons_check walks all four floors now. dungeons, hollow_wilds, hollow_approach, water, warden_yield, stone, dungeon_boss, hub_town and story_gate pass.

## Open points (proposals, Preston can change them)

- The sweep lands them on B4F, one floor above the garden, so they find the garden by its stairs. The alternative is washing up on the garden's shore.
- The Hollow goes to 4 floors before the garden (Grok to tune).
