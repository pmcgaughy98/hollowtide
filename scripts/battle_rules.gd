class_name BattleRules
extends RefCounted
## The battle's numbers in one place: damage, guarding, turn order and the
## catch chance. The battle screen calls these, and so does the balance
## simulator (tools/balance_sim.gd), so a change here changes both and the
## simulator can never test different rules from the ones you play.
##
## Nothing here holds state or plays animation. See docs/battle-rules.md for
## the rules in plain language.

## Strike: what a creature uses when it has no moves, or every limited move is
## spent. It hits with its user's own essence.
const STRIKE_NAME := "Strike"
const STRIKE_POWER := 40

## Catching: 20% at full HP, rising in a straight line to 80% at 0 HP.
const CATCH_BASE := 0.20
const CATCH_BONUS := 0.60


## Damage is attack times move power, divided by defence times four, then
## scaled by the essence matchup, never below 1.
##
## With every stat at 60 and a power of 40 the base is 10 a hit. A strong
## matchup doubles that to 20, a weak one halves it to 5, so a 60 HP creature
## falls in three hits or twelve depending on what is hitting it.
##
## No random variance on purpose. It keeps the number predictable while you are
## learning what the formula does, and it makes the battle testable. Variance is
## one multiplication when you want it.
static func damage(attacker: CreatureData, defender: CreatureData, power: int, multiplier: float) -> int:
	var raw := attacker.base_attack * power / (defender.base_defense * 4.0)
	return maxi(1, int(raw * multiplier))


## The damage that gets through a guard. `guard_fraction` is 1.0 when the
## defender is not braced; a guard move sets it lower for the next hit only.
static func after_guard(raw_dealt: int, guard_fraction: float) -> int:
	return maxi(1, int(ceil(float(raw_dealt) * guard_fraction)))


## The faster creature acts first for the whole battle. Ties go to the player.
static func player_acts_first(player: CreatureData, foe: CreatureData) -> bool:
	return player.base_speed >= foe.base_speed


## The chance a catch attempt succeeds, 0 to 1, from the wild creature's HP.
static func catch_chance(foe_hp: int, foe_max_hp: int) -> float:
	var ratio := float(foe_hp) / maxi(1, foe_max_hp)
	return CATCH_BASE + (1.0 - ratio) * CATCH_BONUS
