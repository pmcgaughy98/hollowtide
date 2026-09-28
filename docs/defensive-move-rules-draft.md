# Defensive move rules for Hollowtide

**Design direction approved by Preston, 26 September 2026:** River Listener's four-slot kits should include guards and interruptions. **Guard and Interrupt now have a generic first-pass resolver in `MoveData` and `BattleScreen`; exact River Listener moves and balance remain proposals.** This file records the intended behavior and the remaining content work.

## Current battle shape

`BattleScreen` runs one active creature per side. A player picks one move, then player and wild creature each act once in speed order; a failed catch also gives the wild creature an action. `MoveData` has one essence, power, per-battle uses, and an optional effect scene. The existing Ember resources are still Damage-kind moves. `MoveData` now exposes Damage, Guard and Interrupt kinds, a committed-action `interruptible` flag, and a guard damage fraction. The foe selects its action when the player's choice opens, and the HUD announces only actions explicitly marked interruptible. No River Listener move is assigned to a creature yet, and there is still no secondary essence.

## Guard: spend this action to absorb one hit

**Input:** choose a Guard-kind move from one of the four battle buttons.

**Response:** the creature braces before the opposing action, regardless of ordinary speed order. It gives up its attack that round. The next incoming damaging hit that round is reduced; a first-pass tuning value is 50% of final calculated damage, rounded up so a hit that connects still deals at least 1 HP. The guard expires at the end of that round, used or unused. It does not stack with another guard and does not persist through a catch attempt or a new battle.

**Feedback:** a short plant/brace pose, quiet pressure ripple around the bracing creature, and a text line that names the reduced amount at contact. The HP bar still slides to the exact remaining percentage. Do not launch the usual attack projectile or show a target hit number when the guard itself activates. A person playing without audio can read the brace and number; sound can add one muted low pulse rather than a heroic shield chime.

**Failure and counterplay:** guard cannot prevent all damage. If the opponent uses a non-damaging action, the guard expires with no benefit. A foe can choose a lower-power action to conserve a costly move, if later AI includes that choice. Repeated guarding consumes the move's limited uses; a creature always retains its unlimited basic attack.

**Depth:** the player chooses between spending a scarce defensive use now or accepting damage to preserve a future answer. The decision needs a visible reason, such as a foe's declared heavy wind-up, rather than a blind guess every round.

## Interruption: hit before a committed action resolves

**Input:** choose an Interrupt-kind attack. It still makes a normal, limited-damage hit.

**Response:** the move follows ordinary speed order. If it lands before the foe acts **and** the foe declared an interruptible action for this round, that action is canceled. The foe loses that action; the next round starts normally. If the foe acted first, or its queued action is not interruptible, the move deals its listed damage but cancels nothing. An interrupted action is not consumed before it executes; uses are deducted on execution, not on declaration.

**Feedback:** show the foe's committed action in a compact intent cue during player choice, for example “Wild X readies Ridge Pulse.” At contact, use the existing impact timing and a distinct short break in the foe's wind-up pose. The text names the canceled action. If no action was canceled, show an ordinary damage result; avoid a false “interrupted” flourish.

**Failure and counterplay:** an interrupt cannot lock every move. Only explicitly marked committed actions are interruptible, and ordinary quick attacks remain available. A slower creature cannot retroactively cancel an action already taken. A guard can soften the interrupt's damage but does not turn itself into an interruptible wind-up. The foe's AI should favor a quick move sometimes, so the player cannot repeat a guaranteed cancel against every turn.

**Depth:** the player reads an intention, weighs speed and limited move uses, and decides between damage, guard, and disruption. The information is public enough to make a deliberate choice but does not reveal an entire future sequence.

## Implemented first pass and remaining design

- `MoveData` has Damage, Guard and Interrupt kinds, an `interruptible` flag, and a guard damage fraction. Existing resources default to Damage and not interruptible. A move still has one essence.
- `BattleScreen` selects and stores the foe action before showing the player's buttons, announces an interruptible intent in the existing message area, resolves guards before speed order, and cancels a still-pending committed action when an Interrupt hit lands. Uses are deducted when actions execute. Guard and cancellation state reset each round and at battle end. If all equipped limited moves are spent, the first button becomes unlimited Strike.
- Keep the current lunge, projectile, hit stop, recoil, continuous HP, and battle camera behavior for damaging moves. A guard gets its own short animation path rather than calling the damage impact function with zero damage.
- A failed catch lets the foe's already declared action execute; a successful catch or flee ends the round. A guard cannot be chosen during catch/flee. The first pass retains the current lunge, projectile, hit stop, recoil, continuous HP and battle camera for damaging moves. Guard has a short planted squash and no projectile or damage number.

## Grok balance pass

Start with a visible heavy action on selected foes, two uses for a strong guard, and two uses for a modest interrupting hit. These are tuning seeds, not approved numbers. No live resource has been assigned these kinds yet. Grok should compare expected damage saved, the value of a lost attack turn, speed order, and how often foes choose interruptible actions. Avoid tuning from one matchup only.

## River Listener content connection

The [River Listener move draft](river-listener-moves-draft.md) contains Stage I braces, Stage II misdirection and counterplay, and Stage III protection. The chosen direction is guards and interruptions; exact move names, art, costs, and timing remain reviewable. A reactive counter and Hollow secondary essence are later extensions. Implement Guard and Interrupt cleanly first; do not make every planned move playable by silently turning support actions into damage moves.

## Verification boundary

Godot reported zero script errors for `scripts/move_data.gd` and `scripts/battle_screen.gd` after this first pass. A battle run and visual review have not been performed. The River Listener line still needs approved sprites, move resources, effects, balanced values and a playable encounter before these mechanics can be judged in use.
