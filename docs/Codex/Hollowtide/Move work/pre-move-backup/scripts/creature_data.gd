class_name CreatureData
extends Resource

## One creature. Every creature in the game is one of these files sitting in
## data/creatures/. To add one, right click that folder in the FileSystem dock,
## choose New Resource, and pick CreatureData. No code needed.

## The six essences.
##
## This is a fixed list rather than free text on purpose. A text field would let
## a typo or an invented essence into the data. With a fixed list the Inspector
## gives you a dropdown and the bad value is simply not offerable.
##
## The essence cycle (Ember burns Bloom, Bloom breaks Stone, Stone dams Tide,
## Tide quenches Ember) is deliberately NOT encoded here. It is a combat rule,
## and it lives in EssenceChart, which BattleScreen uses for attack effectiveness.
enum Essence {
	EMBER,
	TIDE,
	STONE,
	GALE,
	BLOOM,
	HOLLOW,
}

## Dex number.
@export var id: int = 0

## The creature's name, as one field.
##
## This used to be split into gemstone and animal so an alliteration rule could
## be checked automatically. That rule is gone, because it is what made the old
## roster run dry and start repeating itself. Names are now free text and are
## yours to coin.
@export var creature_name: String = ""

@export var essence: Essence = Essence.EMBER

@export var sprite: Texture2D

## Yours to write. Left blank deliberately rather than filled with invented lore.
@export_multiline var description: String = ""

## The move this creature uses in battle. Leave empty for Strike.
##
## One move, not a list, because battles are still one move each. A move list
## needs a way to choose between moves, and that is its own step.
@export var move: MoveData

@export_group("Evolution")
## What this creature turns into. Leave empty for a creature that does not evolve.
##
## One link, not a list, and that is a design decision rather than a shortcut.
## A list would allow branching lines where one creature can become several
## things. A single link forward still allows the other bad shape, two creatures
## both pointing at the same destination, so CreatureRoster.validate_evolutions()
## rejects that across the whole roster.
##
## Both rules come from what you said you like about Digimon: the line should
## make sense, and nothing should share a destination.
@export var evolves_into: CreatureData


@export_group("Base Stats")
## Placeholder values, all identical on purpose. Balance is a design decision
## and guessing at numbers here would quietly turn them into canon.
@export var base_hp: int = 60
@export var base_attack: int = 60
@export var base_defense: int = 60
@export var base_speed: int = 60


## The Dex number padded for display, so 1 reads as "001".
var dex_number: String:
	get:
		return "%03d" % id


## Turns the stored essence into readable text, so HOLLOW reads as "Hollow".
func essence_name() -> String:
	return String(Essence.keys()[essence]).capitalize()
