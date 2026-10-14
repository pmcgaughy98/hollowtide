# Synthesis bonanza: the dungeon turn loop's feel (Claude, 2026-10-14)

Preston: "/synthesis-bonanza Skill up with the synthesis, upgrade and refine game pass."

Structure only. No frames, sprites, text or data from Explorers of Sky are in the repo. The footage and stills
stayed in the scratch folder.

## Target, primitives, route

- **Target:** where Hollowtide's dungeon turn loop is slower, noisier or less clear than finished games of its
  kind, measured on both sides, with the top fixes built and re-measured.
- **Primitives:**
  - Hollowtide's `dungeon.gd`, its checks, Godot and Summer Engine.
  - Explorers of Sky footage (playthrough part 1, YouTube `7OaHECgPzHM`, 42:00 to 42:40).
  - The official Explorers of Sky manual (Nintendo EU PDF) and Bulbapedia.
  - Player talk through Grok, with the posts later checked in the Reddit archive.
  - Gemini for existence checks.
- **Route:** measure ours, measure theirs, collect what players report and confirm the controls, put the numbers
  side by side, build the biggest gaps, then break the result.

## What was measured

| | Hollowtide | Explorers of Sky | Source |
|---|---|---|---|
| Walking pace | 111 ms a step, about 9 tiles/s, partner included | 2.45 tiles/s while a direction is held. About 1.1 to 1.7 tiles/s over a whole floor, counting stops | Ours: timed probe. Theirs: measured twice, by scroll correlation and by counting map-dot steps |
| Running | None before this pass. Now 57 ms a step, about 18 tiles/s | About 30 tiles/s or more, limited by the 30 fps capture; roughly 12x their walk | The footage, five run steps |
| Bump attack and reply | 215 to 296 ms | Not measured | |
| Speed options | None; we are already faster than their Fast setting | Regular and Fast | Bulbapedia (two later games: 2 vs 5 tiles/s). Its Explorers of Sky row, 1 s vs 0.5 s a tile, is uncited and conflicts with the footage |
| Controls | Walk, Shift turns in place, Z rests, Tab autopilot, pause-menu message log | Walk; **B + pad runs**; Y turns in place; B + A passes a turn; **L + B shows the message log**; R + pad moves diagonally | The manual's controls table and the game's own on-screen Controls list agree |

## What players report

All four posts Grok found were confirmed in the Reddit archive by the adversarial pass (post ids in its report):
- The default walk feels too slow; long-time players learned of the Fast option late (2015 and 2024 threads).
- Partner AI is the most repeated complaint: allies won't move one square to help (2023).
  - Already handled here: partners can never set off a trap, and Orders exist.
- Rescue Team DX's 300 to 400 ms input lag and slow menus are disliked (2020; measured by the poster).
- DX players lean on Auto Mode (explore, or go for the stairs) for long dungeons.
  - We have Tab autopilot. Splitting it into explore and stairs modes is a candidate, not built.

## Built

1. **Run (Ctrl + direction).**
   - One press dashes at twice walking pace and follows a hall's bend.
   - It stops for:
     - a foe coming into sight, or a foe in sight closing to 2 tiles;
     - a hit, or a warp;
     - a prompt, a scene or dialogue;
     - an item or the stairs newly alongside, or a seen trap one step ahead;
     - a hall opening into a room or a fork;
     - a wall or a creature ahead;
     - the pause menu or any key.
   - `dungeon.gd` `act_run`; the stop reason is kept in `run_stop`.
   - The stop rules are our own. Neither source says when Explorers of Sky's run stops. The bend-following comes
     from one observed run, so it is a design choice, not a copied rule.
2. **L brings the message box back** after it has slid away. This is Explorers of Sky's L + B; the full history
   stays in the menu's Message log.
3. **A fourth key line**, "Ctrl run   L messages", on the HUD. The pause menu's Controls page lists both keys.
4. **`tools/debug/run_stop_check.gd`**: 19 checks.
   - The key test goes through `Input`, as a player presses a key.
   - It also checks that nothing else fires after the run stops.

## The adversarial pass

The subagent was given read-only access. It found:

| Finding | Status |
|---|---|
| Gemini said the manual names Regular and Fast. The manual has only a Speed line. | Recorded; Gemini's citation was wrong. |
| "Any key ends a run" was dead code: the input poll returned while busy before reaching it. My first check passed only because it set the flag itself. | Fixed: the guard sits before the busy return, keys held at the start are primed, and the test uses real input. |
| An unseen warp did not end a run: the leader walked on from the new room. | Fixed: "carried off". |
| A learn prompt or a boss scene mid-run did not end it. | Fixed: "prompt". |
| Starting beside the stairs or an item ended a run after one step. | Fixed: only things newly alongside stop it. |
| A foe already in sight could close in without stopping the run. | Fixed: "foe close" at 2 tiles. |
| A run moved at walking pace, while theirs is far quicker. | Fixed: half the step time, about 18 tiles/s. |

After the fixes, the run check passes 19 of 19 and the UI fit check 30 of 30. Re-run results are in the
work-plan entry.

## Not built, and why

- **A speed option:** our walk is already faster than their Fast setting.
- **Partner trap avoidance:** partners can't set traps off here.
- **Autopilot modes (explore or stairs):** a real candidate, but a design call for Preston.
- **Menu input lag:** players complained about it in DX. Ours was not measured this pass.

## Ledger

**Used, and what each gave:**
- **Godot from the command line:** our timings and every check.
- **Summer Engine:** the live look. It played `dungeon.tscn` and sent a real Ctrl+D through its input
  script. One press ran the leader across the room to the east wall with the partner following, and the idle
  message box had slid away. The new key line showed on the HUD.
- **yt-dlp and ffmpeg:** the reference clip.
- **Python with numpy:** the scroll measurement.
- **Firecrawl:** Bulbapedia, plus the manual PDF (34 credits).
- **Claude in Chrome:**
  - Grok (Expert, 53 s, 113 sources): the player themes and post leads.
  - Gemini: errored twice, then answered once with a wrong citation.
- **The adversarial subagent (about 242k tokens, over the 50 to 150k estimate):** the bugs above, and the Reddit
  confirmations through the Arctic Shift archive.
- **Skills:**
  - `synthesis-check` and `connector-routing`: the route.
  - `chrome-browser`: the browser steps.
  - The multi-model protocol: the honesty lines and quirks.
  - The `watch` skill, fixed last pass, was not needed once frames came from ffmpeg directly.

**Skipped:**
- The paid generators (Higgsfield, Retro Diffusion, PixelLab, SpriteCook, ElevenLabs): no art or sound gap.
- Blender, Canva, Drive, Notion, Calendar: not on the route.
- The bio-research connectors: noise.

**Still uncertain:**
- What setting the reference footage used.
- When Explorers of Sky's run actually stops.
- Whether a run at about 18 tiles/s reads well to Preston. That is a feel call for him.

**What would change the answer:** Preston playing a few floors with Ctrl runs and saying it is too fast, too
eager to stop, or not eager enough. The rules are one function and one constant (`RUN_PACE`).
