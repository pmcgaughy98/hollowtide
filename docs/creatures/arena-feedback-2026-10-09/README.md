# Cast feedback (Claude, 2026-10-09)

**Preston, 2026-10-09:** item 2 of the feel plan ("I don't feel when I use my moves"): every press gets an immediate answer, and a failed press says why.

## What changed (`scripts/arena/arena_prototype.gd`)
- **A good press** (basic, 1 to 3, 4, C): the card lights white for a quarter second, a ring in your line's colour spreads at the creature's feet, and a cast sound plays, pitched per slot (basic low, 1 to 3 rising, the ultimate lower, the charm highest) so your ear knows what you pressed before the move lands.
- **A failed press** shakes the card, outlines it red for a moment, and a reason shows over the bar for a second: `CREST RAM IN 2.4 S`, `OUT OF RANGE (215 PX)`, `HUSHED`, `HELD` (stunned, dazzled or airborne), `NOT YET` (mid wind-up, hidden, charging), `ROOTED`, `NO TARGET`, `ULTIMATE 40%`, `NO ULTIMATE YET`, `BEADS IN 20 S`, `NO MOMENT FOR IT` (Beads with nothing to break).
- **Out of range is refused.** An attack with a reach, pressed with the target beyond it, no longer fires and whiffs; it is refused and nothing is spent. Charges and other mobility moves (Crest Ram, Lantern Volley) still go, because closing the gap is what they are for. The basic attack is not refused: it swings free down your line (item 1).
- **A heavy ability of yours landing** (15 or more, from an ability, by the creature you steer) adds 0.05 s of hitstop and a small camera nudge toward the hit with a touch of shake. AI hits and your basic do not nudge the camera, so the nudge means something.
- `_play_pitched` joins `_play` (which now always resets pitch to 1).

## Check (`tools/debug/arena_feedback_check.gd`)
- Good press of Crest Ram: card lit 0.25 s, one ring at the feet, cast sound at pitch 1.0, wind-up started.
- On cooldown: card shakes 0.3 s, reason `CREST RAM IN 2.4 S`.
- Vent Barrage (reach 85) with the target 300 px off: `OUT OF RANGE (215 PX)`, cooldown untouched, no wind-up.
- Hushed: `HUSHED`; stunned: `HELD`; ultimate at 40%: `ULTIMATE 40%`; Beads cooling: `BEADS IN 20 S` with the C card shaking.
- A 20 ability hit of yours: camera nudge 0.18 s, hitstop 0.12 s; the same hit from the AI: no nudge.
- The press check and the charms check still pass.
- Stills: `press_ok.png`, `press_cooldown.png`, `press_why.png`.

## Known
- Numbers (flash and shake lengths, the heavy threshold of 15, pitches) are drafts; Grok's call.
- Refusing out-of-range abilities is a feel decision made here; if Preston would rather have them fire and whiff like the basic, it is one condition in `cast`.
- Remaining items of the plan: 3 mouse aim and target lock, 4 your own range ring and telegraph ghost, 5 combos.
