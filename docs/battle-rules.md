# Hollowtide battle rules, as the game runs them today

Written 2026-09-30 from the code, not from design notes. The numbers live in `scripts/battle_rules.gd`; the turn
order lives in `scripts/battle_screen.gd` (`_on_move_pressed`). The balance simulator
(`tools/balance_sim.gd`) runs these exact rules. Stats and powers here are placeholders until Preston approves real ones.

## A battle
- One creature on each side: your active party creature against one wild creature. Both start at full HP.
- Each turn the wild creature picks its move first, **at random** from its moves that have uses left. If its move can be
  interrupted, the game shows it ("Wild X readies Y. Your move?").
- You choose one action: a move, Catch, or Flee.
- The battle ends when either side reaches 0 HP, you catch the wild creature, or you flee.

## Turn order
1. Guard moves go first, before speed (yours, then the wild one's). A guard uses up that creature's action.
2. Then the faster creature acts, then the slower one. **Speed is compared once, at the start of the battle. Ties go to
   you.**
3. An action that was interrupted is skipped. A creature at 0 HP ends the battle immediately.

## Damage
`damage = attack × move power ÷ (defence × 4) × essence multiplier`, rounded down, never below 1.

- With every stat at 60, a move does a quarter of its power: power 32 = 8, 40 = 10, 50 = 12, 60 = 15 (neutral).
- **No randomness:** no damage variance, no misses and no critical hits. The same attack always does the same damage.
- A move's essence decides the multiplier, not its user's essence. There is no bonus for a move matching its user's
  essence.
- **Damage lands on contact,** during the animation, so the number and the picture agree.

## Essence chart (attacker against defender)
- Strong (×2): Ember → Bloom, Bloom → Stone, Stone → Tide, Tide → Ember.
- Weak (×0.5): the same four pairs run backwards (Ember → Tide, and so on).
- Hollow hits every other essence ×2, and every other essence hits Hollow ×2. Hollow against Hollow is neutral.
- Gale has no strong or weak matchups except against Hollow.
- The gap between a strong and a weak matchup is ×4.

## Moves
- Each move has a power and a use limit (`max_uses`, where 0 means unlimited). Uses are spent when the move is
  performed, and refill every battle.
- Every Ember line today uses the same pattern: 32 power unlimited, 40 power ×6, 50 power ×4, 60 power ×2.
- **Strike** (power 40, the user's own essence) replaces the first move once every limited move is spent. It only
  appears for creatures with no unlimited move.
- **Kinds:**
  - **Damage:** a normal hit.
  - **Guard:** brace before speed order; the next hit this turn does `guard_damage_fraction` of its damage (0.5 by
    default).
  - **Interrupt:** a hit that also cancels a slower opponent's committed move, if that move is marked interruptible.
  - The code supports guards and interrupts, but **no move uses either yet.**
- **Signature** changes only presentation: the title card, music, camera and effects. It carries no rules bonus.

## Catching
- Chance = 20% at the wild creature's full HP, rising in a straight line to 80% at 0 HP.
- There are no items and attempts are unlimited. A failed attempt costs your action, so the wild creature still acts.
- A full party cannot catch; that costs nothing.

## Evolution
- If your active creature defeats a wild creature and has an `evolves_into`, it evolves right after the win.
- It keeps its current HP, capped at the new form's maximum. Evolution is not a free heal.

## Not in the game yet
Levels and experience, stat growth, status effects, accuracy, critical hits, damage variance, items, switching
creatures mid-battle, trainer battles and a smarter wild AI.

## What the first simulator run found (all stats at 60)
Full tables: `docs/balance/sim-report.md`. Rerun:
`Summer.exe --headless --path . --script res://tools/balance_sim.gd`

1. **Speed ties decide mirrors.** Every creature has speed 60, so you always act first and win every mirror match.
2. **Essence outweighs everything else.** Rimefin knows only Strike, yet it beats all nine Ember creatures in three
   turns, because Tide hits Ember ×2 and Ember hits Tide ×0.5.
3. **Kingstone Rail is unlimited at power 60,** the power every other line limits to two uses. Oxbowarchon wins every
   matchup, 100% of the time.
4. **Signatures are inconsistent.** Molten Glass is Vitrecrag's weakest move (32, unlimited), while Furnace Roar is
   Ironvent's strongest (60 ×2).
5. **Use limits never come into play.** Battles last 2 to 6 turns, so no 50 or 60 power move runs out.
6. **The nine Ember kits have identical numbers,** so they play out identically. Only names and art differ.
