# Refinement pass, nine tasks (Claude, 2026-10-14)

Preston: "skill-up with the synthesis then do 9 task refinement pass and upgrade of hollowtide."

The method was the synthesis pass: take stock of every tool on hand, measure the game and the reference, build,
look, score and repeat. Every task below has a number before and after, and `tools/debug/ui_fit_check.gd` now
guards all of them (29 measurements, all ok).

## 1. Stock-take: what was on hand and what each did

| Tool | Used for | Contributed |
|---|---|---|
| Codex's V4 pitch (`docs/trailer/v4/full/`) and its edit timeline | A survey of the whole game in 100 s, one frame per shot | Two of the bugs (the "Cutbank Listener" name running into its level; the title's "Quit" on the key line). Three of its shots are old cutaways, so the live game was checked as well. |
| The `watch` skill | Meant to sample the pitch | It failed: ffmpeg 9 removed `-vsync`. **Skill-up:** patched to `-fps_mode` in `~/.claude/skills/watch/scripts/frames.py` (backup `frames.py.bak-2026-10-14`) and re-tested. Frames came from ffmpeg directly in the meantime. |
| `tools/debug/ui_tour_capture.gd` (12 screens) | The live look at every screen | The other three bugs: the learn prompt drawn over its keys, the pause menu off the bottom, the town hint cut off. **Skill-up:** it now takes `-- --out res://...`, so a new tour no longer overwrites the 10-10 stills. |
| Reference notes `docs/research/pmd-video-notes-2026-10-09.md` (Explorers of Sky and DX frames) | The structure to aim at | Tasks 6 and 7: the message box that leaves when nothing is new, and the map drawn as see-through room outlines. Structure only; nothing copied. |
| Summer Engine MCP (connected mid-pass) | A live run of the real main scene | The title, as played: four rows in their old place (no save on this machine, so no Continue). Its `ui-basics` skill gave one rule worth keeping: lay a bottom menu out from the edge it must clear. Task 4 does that. |
| Godot 4.7.2 from the command line | Headless measuring and windowed stills | The fit check, the proof stills, and 13 of the project's own checks (below). |
| `godot-ai` MCP | | Failed to connect (30 s timeout); not needed. |
| Firecrawl, Retro Game Gather, Director's Lookbook, ElevenLabs, PixelLab, Retro Diffusion, SpriteCook, Higgsfield, Blender, Canva | Not used | This pass was layout and readability; there was no art, sound or new research gap to fill. Nothing paid ran. |

## 2. Measured, then fixed

| # | What | Before (measured) | After |
|---|---|---|---|
| 1 | The dungeon's team rows | Name and "Lv / Sense" share 246 px; "Quietwater Warden" or "Cutbank Listener" plus "Lv 4   Sense 0" ran past it, and the name sat on the level | `dungeon.hud_name_tag`: the tag tightens, then drops Sense (still on the team screen), and only then would the name be cut. All 39 creature names fit at Lv 99 with the widest row exactly 246 px; none is cut; 4 lose Sense on the HUD. |
| 2 | The learn prompt | "It knows four moves. Forget one?" (224 px) and the keys (322 px) on one row, drawn over each other | The keys move to their own footer row; the box grows 26 px. |
| 3 | The pause menu in the Hollow | Ten rows held at 49 px each by the frame's padding: 658 px on a 648 px screen; Quit Game off the bottom | 3 px padding (the pressed sink kept) and 40 px rows: it ends at 626. Any page that grows past the screen now moves up to fit (`_keep_on_screen`). All nine pages measured. |
| 4 | The title with Continue | Five rows from y 324 ended at 650, over the key line at 608 | `creature_opening.menu_top(rows)` lays the menu out from the key line up: five rows start at 270 and end at 596. Four rows keep 324 exactly (seen live). |
| 5 | Right-aligned text past its box | "The Hollow's mouth starts a run" is 210 px in a 194 px box and ran off the right edge of the screen | `UI.say` grows a right-aligned or centred line toward the left instead. The hint is now drawn from x 930 to 1140. This covers every screen. |
| 6 | The dungeon's message box | Always up, 600 x 108 px, even when it held only "B1F" | It slides below the screen edge 4 s after the last message and is back on the next one, as Explorers of Sky's box does. The menu's Message log keeps the history. |
| 7 | The corner map | 3 px a tile: B1F (42 x 20 tiles) was a 126 x 60 px filled smudge | Room and hall outlines with a faint fill, at 3 to 5 px a tile (`minimap_scale`): B1F is 210 x 100 px. Any map from 16 to 80 tiles stays left of x 888, clear of the team panel. |
| 8 | Em-dashes in player text | 4, all in the riverbank's key hints | 0 in scripts, dialogue, scenes and data. The hints use the house style ("WASD / arrows  walk"). |
| 9 | A check that keeps this fixed | None | `tools/debug/ui_fit_check.gd`, run headless to measure or in a window for stills (`docs/ui/ui-fit-2026-10-14/`). |

Evidence:
- `before_after.png`: the learn prompt, pause, team rows and message box, before and after.
- `minimap_before_after.png`: the corner map at 3x.
- `survey_v4_pitch_*.png`: the pitch survey.
- `docs/ui/ui-tour-2026-10-14/` (before) and `docs/ui/ui-tour-2026-10-14-after/` (after): the full tours.

## 3. Checks run after the changes

| Check | Result |
|---|---|
| `ui_fit_check` | 29 of 29 ok, headless and in a window |
| `opening_flow_check` (window, its own APPDATA) | 27 of 27 |
| `opening_launch_check` (window, its own APPDATA) | All four points true, including the fixed menu layout |
| `field_menu_check`, `save_check`, `storage_check`, `town_room_check`, `dungeon_learn_check`, `flood_opening_check` | Pass |
| `faint_check` | Pass after a fix to the check, explained below |
| `dungeon_check`, `hub_town_check` | Every logic step headless passed; their stills need a window, and they were not re-run windowed because they overwrite the dated evidence folders |
| The pilot chain | Run twice on the same code: **run 1** cleared the whole story but lost the post-pilot Warren replay five times (8 faints, 631 s); **run 2** was all ok, every dungeon on the first try (0 faints, 533 s). The check does not fix its floor seeds, so this is floor luck. The changes in this pass only draw or measure and change no game state. The earlier lethality spread is Grok's open B1F task. |

**The `faint_check` fix.** Its last step failed: in the Mouth, three presses did not leave the faint screen. The
cause was not this pass. Codex's dialogue-corner install today widened the portrait inset from 150 to 162, which
narrowed the text column from 540 to 528 px. At 528 px, "Kithflare! Hey... okay, you're still here. I've got you.
Back to the bank. We'll go again." wraps to three rows, which is two pages, so it needs five presses (measured). The
game is right; the check's fixed count went stale. It now presses until the screen leaves.

## Not done, or worth a look

- **Title with Continue:** the five-row title is checked by arithmetic only. There is no save here, and making one
  would touch the real save slot.
- **Long lines in the dialogue box:** with the 528 px column, a partner's line of about 90 letters now takes two
  pages. A writing pass could keep key lines to two rows.
- **File ownership:** `game_pause_menu.gd` and `creature_opening.gd` are Codex's files. The changes are small, but
  Codex should know (noted in `docs/AI_COLLABORATION.md`).
