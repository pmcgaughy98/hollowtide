extends RefCounted
## Every town area, by id (lane A, Claude, 2026-10-26; 02-town-rewire-design.md section 3.1). One file per area under
## scripts/world/areas/, each holding `const AREA := {...}` in the format of 02 section 3.2. scripts/town/town_layout.gd
## reads them; nothing else needs to know the files.
##
## With Highbank v2 off (the default) the town is V1 alone, today's map. With it on (HT_HIGHBANK_V2=1, the const
## TownLayout.HIGHBANK_V2, or scenes/debug/highbank_v2.tscn) the town is the V2 areas, joined by their exits. A new area
## is a file, a line in V2, and an exit each way (tools/debug/area_data_check.gd refuses a one-way exit).

const V1 := preload("res://scripts/world/areas/highbank_v1.gd")
const V2 := {
	"street": preload("res://scripts/world/areas/street.gd"),
	"hall_rise": preload("res://scripts/world/areas/hall_rise.gd"),
	"ferry_ward": preload("res://scripts/world/areas/ferry_ward.gd"),
	"east_quarter": preload("res://scripts/world/areas/east_quarter.gd"),
}
const V2_FIRST := "street"   # where a day starts in v2 (its "spawn" anchor)


## The area's data (read-only), or {} for an unknown id.
static func area(id: String) -> Dictionary:
	if id == V1.AREA["id"]:
		return V1.AREA
	if V2.has(id):
		return V2[id].AREA
	return {}


## The ids of v2's areas, in the order above.
static func v2_ids() -> PackedStringArray:
	return PackedStringArray(V2.keys())
