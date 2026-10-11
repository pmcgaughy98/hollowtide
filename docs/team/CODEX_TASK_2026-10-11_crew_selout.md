# Codex task: sel-out the Wayline Hall crew (Preston, 2026-10-11)

> Folded into `docs/team/CODEX_TASKS_2026-10-11.md` (task 1), which also adds Rinsepaw, Cairnshell and Crawdukes. Start there.

Preston: "give Codex sel-out task for new creatures etc." Approved crew: `docs/creatures/guild-crew-2026-10-11.md`.

## What to finish
Five new creatures, every sprite the game reads:
- `assets/sprites/arena/<name>/` full-size facings (s, se, e, ne, n, nw, w, sw)
- `assets/sprites/arena/<name>/dungeon/` and `/town/` stills and `walk_<facing>_f0..f7.png`
- names: `grubbit` (mole, stage 1), `muskin` (muskrat, stage 1), `slipjaw` (otter, stage 1),
  `stillwade` (heron, stage 2), `wickglow` (firefly, stage 2)

Also the NPC idle fronts used for the showcase and portraits (they hold their job objects; keep them):
`docs/creatures/arena-starters-2026-10-07/forms/<name>_arena_front_chosen.png`.
Rinsepaw (raccoon) waits for Preston's recolour; leave it out.

## How
- Match the finish already on Starward, Wayling and the townsfolk: Claude's `tools/arena/selout.py --black`
  (dark line recolour, black outer line, backups to `docs/creatures/selout-2026-10-10/before/`), or your
  own pass if it gives the same result. Do the full-size art and both sets, so they match at every size.
- Keep the palette: no new colours beyond the line colour.
- Check every walk frame after (Preston found walk-cycle faults by eye; Claude's frame sheets method:
  one row per facing, eight frames, numbered).

## Order
Wait for Claude's note below before starting: three walks are being redone (muskin s, stillwade s,
wickglow se) and the sets rebuilt. Slipjaw's floating whisker specks are already removed
(`tools/arena/remove_specks.py`, backups in `docs/creatures/speck-backup-2026-10-09/slipjaw/`).

## Status
- [x] Claude, 2026-10-11: walks fixed (muskin s rebuilt from its first frame's body, stillwade s redone, wickglow se glow recoloured, slipjaw specks removed) and both sets rebuilt for all five. Ready for you.
- [ ] Codex: sel-out pass, frame check, short note here
