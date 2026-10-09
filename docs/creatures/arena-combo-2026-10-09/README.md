# Follow-ups (Claude, 2026-10-09)

**Preston, 2026-10-09:** item 5 of the feel plan, the last one: combos, so the rhythm of press, hit, press pays off. Every number here is a draft for Grok.

## What changed (`scripts/arena/arena_prototype.gd`)
- **The window:** when an ability lands, its user gets a 0.9 s follow-up window that remembers which ability it was. (My first draft said 0.4 s; an ability's recovery plus the basic's telegraph is about half a second, so 0.4 could never be met by anyone.)
- **The follow-up:** a basic that lands inside the window hits 1.3 times, gives 0.5 s of that ability's cooldown back (one charge, for a move with charges), prints "Follow-up" over the target, and closes the window. A basic outside the window is plain.
- **Everyone's:** the AI gets the same rule, and Kit Sense now prefers its basic while its window is open (desire 1.4), so the rhythm is the game's and not a player-only bonus.
- **Feedback for you:** while your window is open the reach ring under your creature turns gold and winds down with the time left; a follow-up flashes the refunded ability's card and plays a higher hit sound.
- Essence combos (shatter, kindle, quench, conduct, overgrow) are a separate, older system and stack with this.

## Check (`tools/debug/arena_combo_check.gd`)
- Vent Barrage landed: window 0.9 s, remembered as Vent Barrage.
- A 20 basic inside the window took 26, the same basic outside it 20; Vent Barrage went from 6.0 s to 5.5 s; the window closed.
- A basic 1.3 s after the ability: 20, plain.
- AI 1v1 Stormwick vs Ironvent for 60 s: 5 windows opened, 0 follow-ups landed. Two finals that dodge, Phase and kite rarely land an ability and then a basic inside 0.9 s; a probe with the stage 1 forms (Kithflare, Cinderhide) opened 15 windows and landed 2 follow-ups in 20 s. The rule works for the AI; the finals' rhythm seldom allows it. **Grok:** the window length is the lever if the AI should combo more.
- Chain and reach checks still pass.
- Stills: `window.png`, `follow_up.png`.

## Known
- The window (0.9 s), the bonus (1.3) and the refund (0.5 s) are drafts; so is the AI's 1.4 preference. Grok owns them.
- The window opens on the ability landing, not on the press, so a whiffed ability opens nothing.
