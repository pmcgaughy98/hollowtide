# The Job Board (Claude, 2026-10-10)

Slice 6 of `docs/design/mystery-dungeon-pivot-2026-10-09.md`: world to dungeon and back with jobs, a
Courier Rank, and rewards. Structure from the Mystery Dungeon rescue boards; nothing of theirs copied.

## How it plays
1. **Highbank's Job Board** (E at the board) posts four requests. Each names a client, a floor and a
   reward. The clients are the wild creatures that live on that floor (`FLOOR_SPAWNS`).
2. **W/S choose, E takes or puts back, Esc closes.** The satchel holds four jobs.
3. **Two kinds:** *Find* a lost client (it waits in a room on its floor; walk into it and it thanks the
   team in the scene box, then heads home) and *Recover* an item a client dropped (pick it up; it does
   not go in the bag).
4. **The job is done the moment you reach it**, so a faint later in the run does not undo it.
5. **Back in town the board pays** finished jobs: items into the bag, points toward Courier Rank. A new
   set of requests is posted after every run, cleared or fainted.

## Files
- `scripts/town/jobs.gd`: requests, taking, paying, ranks.
- `scripts/dungeon/dungeon.gd`: `_place_jobs`, `_client_node`, `_meet_client`, the lost-item pickup;
  clients block the way like a wall.
- `scripts/town/hub_town.gd`: `_board_panel`, `_draw_board`, `act_board_pick`, `act_board_move`.
- `scripts/town/team_state.gd`: the record carries `jobs` and `rank`.
- Check: `tools/debug/job_board_check.gd` (take two, meet the client, pick up the item, get paid).

## Proposals waiting on others
- **Grok:** rewards (Find: Rally Seed x1, +30; Recover: Reedberry x2, +20; +10 points per floor deeper)
  and the rank steps (0, 60, 150, 300, 500) are placeholders in `jobs.gd`.
- **Preston:** the Courier Rank names (now just numbers), and the client's thank-you line (one line
  for every client today).
- **Codex:** the board is the town's notice board; the Wayline Hall as the guild (dispatch, reports) is
  still yours. The board screen uses the shared pixel frames.

## Not built yet
Escort jobs, jobs from named townsfolk, rank rewards (bigger bag, new Hollows), the client facing
the team, and a marker on the minimap.

Stills: `board_taken.png`, `client_waiting.png`, `client_thanks.png`, `board_paid.png`.
