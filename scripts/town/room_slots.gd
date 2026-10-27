extends RefCounted
## The rooms' art slots (Claude, 2026-10-26, placeholder factory lane R). Every finished picture in Highbank's rooms is
## a named slot in scripts/art/slots/town_rooms.gd, read through ArtSlots, so a file Codex or Grok hands in at exactly
## the slot's size takes the place of today's art with no code change, and HT_FORCE_PLACEHOLDERS=1 shows the rooms'
## code painting (their placeholder) instead. The room painters ask this file rather than ArtSlots for two reasons:
##   1. The Hall's floors and the Home are painted on a worker thread (hub_town.gd _rooms_ahead) while the street goes
##      on drawing, and ArtSlots keeps its caches in static dictionaries for the main thread. Off the main thread this
##      file reads the same sources in the same order (forcing, the slot's file, the legacy file, the placeholder)
##      straight from disk and never writes those caches. town_room.gd art_off_main() reads the registry on the main
##      thread first, so the worker only ever reads it.
##   2. Four props are drawn at a size their file is not (DRAWN). Until a file is installed for their slot, the room
##      draws today's resize of the old file, so nothing changes on screen; ArtSlots' own placeholder for them (a flat
##      block within C2-C4) shows only when forcing.
##   RoomSlots.image(id) -> a copy the caller may change; real(id) -> whether there is finished art to show.

const UI := preload("res://scripts/ui/ui_style.gd")
const FOLDER := "res://assets/sprites/world/hall_floors_2026_10_11/"
## Slot -> the file today's room resizes to the slot's size (hall_floors_art.gd PROPS rects, read 2026-10-26).
const DRAWN := {
	"town.prop.chamber.rug": FOLDER + "teal_rug.png",            # 192x120 drawn 216x120
	"town.prop.chamber.window_wide": FOLDER + "window_wide.png", # 68x32 drawn 96x32
	"town.prop.runners.window": FOLDER + "window.png",           # 44x32 drawn 36x32
	"town.prop.runners.river_map": FOLDER + "river_map.png",     # 96x32 drawn 48x28
}


static func _main() -> bool:
	return OS.get_thread_caller_id() == OS.get_main_thread_id()


## Where the slot's picture comes from: "file" (installed for the slot), "legacy" (today's file), "drawn" (today's
## resize, DRAWN) or "placeholder".
static func source(id: String) -> String:
	var src := ArtSlots.source(id) if _main() else String(_off_main(id, false)[1])
	if src == "placeholder" and DRAWN.has(id) and not ArtSlots.forcing() and UI.res_exists(String(DRAWN[id])):
		return "drawn"
	return src


## Whether the slot has finished art to show (its file, today's file or today's resize). False on the placeholder,
## where the room keeps its code painting, as it always did when an art file was missing.
static func real(id: String) -> bool:
	return source(id) != "placeholder"


## The slot's picture, RGBA8 at the slot's sheet size, a copy the caller may change.
static func image(id: String) -> Image:
	if DRAWN.has(id) and source(id) == "drawn":
		return _drawn(id)
	if _main():
		return ArtSlots.image(id).duplicate() as Image
	return _off_main(id, true)[0]


## Today's resize: the old file, nearest-neighbour to the slot's size, as hall_floors_art.gd has drawn it.
static func _drawn(id: String) -> Image:
	var size: Vector2i = ArtSlots.spec(id).get("size", Vector2i.ONE)
	var img := UI.res_image(String(DRAWN[id]))
	if img.get_size() != size:
		img.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
	return img


## Off the main thread: [image, source] read from disk in ArtSlots.texture's order, touching none of its caches.
## With `paint` false the placeholder is not painted (only the source is wanted).
static func _off_main(id: String, paint: bool) -> Array:
	var s := ArtSlots.spec(id)
	var want: Vector2i = s.get("sheet_size", Vector2i.ZERO)
	if not ArtSlots.forcing():
		for pair in [[String(s.get("file", "")), "file"], [String(s.get("legacy", "")), "legacy"]]:
			if pair[0] == "" or not FileAccess.file_exists(pair[0]):
				continue
			var img := Image.load_from_file(ProjectSettings.globalize_path(pair[0]))
			if img != null and not img.is_empty() and img.get_size() == want:
				if img.get_format() != Image.FORMAT_RGBA8:
					img.convert(Image.FORMAT_RGBA8)
				return [img, pair[1]]
	return [PlaceholderPainter.paint(id, s) if paint else null, "placeholder"]
