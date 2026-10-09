# Attack on press (Claude, 2026-10-09)

**Preston, 2026-10-09:** "Combat still needs to feel more dynamic, I don't feel when I use my moves; also the basic attack function and targeting could use some upgrades." Of the five-item plan he said "do 1": attack on press, always. Items 2 to 5 (cast feedback, mouse aim and target lock, your own range ring and telegraph ghost, combos) are not built.

## What changed
- **Before:** holding J only unlocked the AI's move chooser for your creature, which fired the basic when its own range check agreed. Out of range, nothing happened and nothing said why. The press itself did nothing.
- **Now:** the basic is a button (`_player_attack` in `scripts/arena/arena_prototype.gd`). A tap or click starts it at once. When your target is in reach it goes at the target as before. When it is not, it is a **free swing** down the line you are steering (or the way you face): the telegraph and the swing happen, the sweep arc is drawn, and whoever is inside the arc is hit, nearest first, target or not. Nobody there: it whiffs, with the whiff label and slash, and the cooldown and recovery are paid like any whiff.
- **Buffer:** a tap during recovery, a wind-up, hitstun or a cooldown is kept for 0.3 s and fires the moment the creature is free (an input buffer, after fighting games), so a press just before you are ready is never lost.
- **Hold:** holding J or the button repeats on the move's own rhythm (telegraph, recovery, cooldown): Cinder Claw lands three times in 4 s.
- The AI chooser no longer touches the steered creature at all; abilities stay on 1 to 3 (unchanged), auto mode (Tab) still fires everything for you.
- Ranged basics (Whistle Dart, Molten Beam, Fireball) use the same path: a free shot goes down your steering line and hits whatever it crosses.

## Check (`tools/debug/arena_press_check.gd`)
- Tap out of range: the swing started at once, aimed where you steered, the sweep went down that line, the enemy 160 px away took 0, cooldown paid (0.8 s left).
- Tap in range: the enemy 24 px away took 24.
- Buffer: a tap during 0.2 s of recovery did not fire at once (buffer 0.27 s left), then fired on its own when recovery ended; the enemy took 26.
- Held for 4 s: 3 swings of Cinder Claw (cooldown 1.2 s plus telegraph and recovery), 62 dealt.
- Free swing in a 3v3 with the target 200 px away and Scourmaw 26 px down the steering line: Scourmaw took 18, the target took 0.
- AI 1v1 for 20 s with nobody steering: both sides scoring (Stormwick 169, Ironvent 132), so the AI path is untouched.
- The motion check's "Attack on J" step still passes with the new path.
- Stills: `whiff.png`, `hit.png`, `held.png`, `free_arc.png`.

## Known
- A free swing still needs a living enemy somewhere for the move code to run (it borrows the target's index); with every enemy down the match is over anyway.
- Area basics and lobs aimed free land at the basic's range along your line; no cursor aim yet (item 3).
- The buffer length (0.3 s) and the free-swing rule are drafts; Grok's numbers.
