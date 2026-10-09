# Explorers of Sky and Rescue Team DX: gameplay video notes (Claude, 2026-10-09)

Preston linked two no-commentary playthroughs as references. **Structure only.** No frames, sprites, text, music or numbers from them go in the repo. The sampled frames stay outside it.

## The playlists
- **Explorers of Sky (DS):** 15 parts, about 34 hours. https://www.youtube.com/playlist?list=PLFUok4zd76qFUDFd7imZwKNmjnAjQ44CV
- **Rescue Team DX (Switch):** 11 parts, about 12 hours. https://www.youtube.com/watch?v=nD0Lux35ZBs&list=PLak4835myE6mpneksgnLvlZqi9GJSKcZa

**Sampled so far:** 16 frames from each game's first-dungeon stretch (Explorers of Sky part 1, 25:00 to 75:00; DX part 1, 15:00 to 60:00).
- **How to sample more:** a frame sheet script (yt-dlp for the stream address, ffmpeg seeking to timestamps). For Explorers of Sky, ask for format 18/134.
- **Watch whole parts only for a specific question.** 46 hours is not a read.

## What the frames show (structure)
| Topic | Explorers of Sky | Rescue Team DX | For Hollowtide |
|---|---|---|---|
| Dungeon HUD | One top line: floor, level, HP numbers and bar | Top-right stack: portrait, level and HP bar for each teammate, plus a round belly gauge | Ours lists the team down the left. A portrait stack is a candidate for Codex's portrait job. |
| Map | A see-through wireframe drawn over the play view | A small translucent minimap at the top left | Ours is a corner minimap. The wireframe-over-view is worth a try. |
| Messages | A bordered box at the bottom; names coloured | A log at the bottom centre; names coloured | Ours matches; coloured names are a cheap add. |
| Moves | Named in the log | **The move's name pops over the user** ("Quick Attack!") | **Built 2026-10-09:** `_callout` in `dungeon.gd`; the basic stays quiet. |
| Move growth | (not seen in this stretch) | The dojo text: moves "grow" with use, faster at the dojo | Proposal for Grok: move mastery from use, fits the move tables. |
| Teaching moves | (not seen) | A TM handed over as a town reward | Our move scrolls; the hall could also give them as job rewards. |
| Items | The bag as a list with a one-line description; thrown items fly in a line | Items picked up from the floor | Ours matches. |
| Town | The guild, NPC dialogue with emotion portraits | The base, a town square, a dojo | Codex's hall and portrait jobs. |
| Scale | A creature about one tile; the dungeon fills the screen | The same, in 3D | Matches the stage-size pass. |

## Next looks worth doing (one question each)
- How a Monster House plays out (DX, later parts).
- A boss floor (DX part 4 is "Zapdos boss").
- The Explorers of Sky job board and the guild's daily loop (part 1, before 25:00).
