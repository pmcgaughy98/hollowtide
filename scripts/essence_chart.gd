class_name EssenceChart
extends RefCounted

## Which essences beat which. Nothing here holds state, so you call it
## directly: EssenceChart.multiplier(attacker_essence, defender_essence)
##
## The whole chart comes straight out of THE_CONCEPT.md, and every entry is
## meant to be guessable from the names alone. That is the test a good chart
## passes and the one the old eleven-element system failed.

const STRONG := 2.0
const NEUTRAL := 1.0
const WEAK := 0.5

## Attacker essence -> defender essences that are not neutral.
##
## The four-part cycle: Ember burns Bloom, Bloom breaks Stone, Stone dams Tide,
## Tide quenches Ember. Each of those also runs backwards at WEAK, which is why
## every cycle row has one STRONG and one WEAK.
##
## Gale scatters everything but commits to nothing, so it has no hard advantage
## of its own and every Gale row is neutral.
##
## Hollow consumes but cannot create. It hits everything but itself at STRONG,
## and everything hits it back at STRONG. That is the same rule stated twice,
## once from each side, which is why HOLLOW appears in every other row too.
const CHART := {
	CreatureData.Essence.EMBER: {
		CreatureData.Essence.BLOOM: STRONG,   # burns
		CreatureData.Essence.TIDE: WEAK,      # quenched by
		CreatureData.Essence.HOLLOW: STRONG,
	},
	CreatureData.Essence.TIDE: {
		CreatureData.Essence.EMBER: STRONG,   # quenches
		CreatureData.Essence.STONE: WEAK,     # dammed by
		CreatureData.Essence.HOLLOW: STRONG,
	},
	CreatureData.Essence.STONE: {
		CreatureData.Essence.TIDE: STRONG,    # dams
		CreatureData.Essence.BLOOM: WEAK,     # broken by
		CreatureData.Essence.HOLLOW: STRONG,
	},
	CreatureData.Essence.BLOOM: {
		CreatureData.Essence.STONE: STRONG,   # breaks
		CreatureData.Essence.EMBER: WEAK,     # burned by
		CreatureData.Essence.HOLLOW: STRONG,
	},
	CreatureData.Essence.GALE: {
		CreatureData.Essence.HOLLOW: STRONG,
	},
	# Electric and Ice (added 2026-10-01). Only the Hollow rule applies until
	# Preston approves their matchups (proposal in docs/creatures/electric-ice-essences-2026-10-01.md).
	CreatureData.Essence.ELECTRIC: {
		CreatureData.Essence.HOLLOW: STRONG,
	},
	CreatureData.Essence.ICE: {
		CreatureData.Essence.HOLLOW: STRONG,
	},
	CreatureData.Essence.HOLLOW: {
		CreatureData.Essence.EMBER: STRONG,
		CreatureData.Essence.TIDE: STRONG,
		CreatureData.Essence.STONE: STRONG,
		CreatureData.Essence.GALE: STRONG,
		CreatureData.Essence.BLOOM: STRONG,
		CreatureData.Essence.ELECTRIC: STRONG,
		CreatureData.Essence.ICE: STRONG,
	},
}


## How hard `attacker` hits `defender`. 2.0, 1.0 or 0.5.
static func multiplier(attacker: CreatureData.Essence, defender: CreatureData.Essence) -> float:
	var row: Dictionary = CHART.get(attacker, {})
	return row.get(defender, NEUTRAL)


## The line the battle prints after a hit. Empty for a neutral hit, because
## saying "it was averagely effective" every single turn is noise.
static func effectiveness_text(mult: float) -> String:
	if mult > NEUTRAL:
		return "Very effective!"
	if mult < NEUTRAL:
		return "Not very effective."
	return ""
