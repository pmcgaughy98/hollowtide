from pathlib import Path
import shutil
W=Path(__file__).parent; C=Path('D:/dev/hollowtide-world-refinement-20261008/project')
def edit(r,a,b):
 p=W/'candidate'/r;s=p.read_text();assert s.count(a)==1,(r,a);p.write_text(s.replace(a,b))
def add(r,s):
 p=W/'candidate'/r;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s)
edit('scripts/arena/creature_finish.gd','finish.set_shader_parameter("sparkwick_palette", is_sparkwick(path))','finish.set_shader_parameter("sparkwick_palette", is_sparkwick(path))\n\t\tfinish.set_shader_parameter("detail_ink", 1.0 if details else crew_detail(path))')
add('scripts/ui/crew_portrait_canvas.gd','''extends Node2D
## Only rival portraits pass through the creature material. Frames and text stay separate.
var draws: Array = []

func _ready() -> void:
 texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 var finish := ShaderMaterial.new()
 finish.shader = preload("res://scripts/arena/creature_finish.gdshader")
 finish.set_shader_parameter("detail_ink", 0.65)
 material = finish

func clear() -> void:
 draws.clear()
 queue_redraw()

func paint(tex: Texture2D, dst: Rect2) -> void:
 draws.append({"tex": tex, "dst": dst})
 queue_redraw()

func _draw() -> void:
 for d in draws:
  draw_texture_rect(d["tex"], d["dst"], false)
'''.replace('\n ', '\n\t').replace('\n\t ', '\n\t\t'))
p=W/'candidate/scripts/arena/creature_finish.gd'
p.write_text(p.read_text()+'''

static func crew_detail(path: String) -> float:
	for form in ["mirekit", "whinet"]:
		if ("/arena/" + form + "/") in path or path.ends_with("/dialogue/" + form + ".png"):
			return 0.65
	return 0.0
''')
edit('scripts/arena/sel_out.gdshaderinc','\t// One texel of room for pale edge repairs, including art close to its canvas edge.','\t#ifndef SEL_OUT_MASKED_MAP\n\t// One texel of room for pale edge repairs, including art close to its canvas edge.')
edit('scripts/arena/sel_out.gdshaderinc','\tUV = (UV * (1.0 / TEXTURE_PIXEL_SIZE + 2.0) - 1.0) * TEXTURE_PIXEL_SIZE;','\tUV = (UV * (1.0 / TEXTURE_PIXEL_SIZE + 2.0) - 1.0) * TEXTURE_PIXEL_SIZE;\n\t#endif')
edit('scripts/arena/sel_out.gdshaderinc','\tCOLOR = c * tint;','\t#ifdef SEL_OUT_MASKED_MAP\n\t// Map floors retain the original painter exactly; ink only the supplied geometry mask.\n\tc = mix(sample_art(TEXTURE, UV), c, texture(detail_mask, UV).r);\n\t#endif\n\tCOLOR = c * tint;')
add('scripts/dungeon/dungeon_finish.gdshader','''shader_type canvas_item;
render_mode unshaded;
#define SEL_OUT_DETAIL_DEFAULT 0.75
#define SEL_OUT_MASKED_MAP
uniform sampler2D detail_mask : filter_nearest, repeat_disable;
#include "res://scripts/arena/sel_out.gdshaderinc"
''')
add('scripts/dungeon/dungeon_finish.gd','''extends RefCounted
## Shared sel-out, bounded to exposed wall faces/edges and the stairs.
## Generated topology, authored terrain and walking surfaces are never rebuilt.
const Gen := preload("res://scripts/hollow/hollow_gen.gd")
const SHADER := preload("res://scripts/dungeon/dungeon_finish.gdshader")

static func floor_at(data: Dictionary, x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < data.w and y < data.h and data.tiles[y * data.w + x] != Gen.WALL

static func mask(data: Dictionary, t: int, look: String) -> Image:
	var image := Image.create(data.w * t, data.h * t, false, Image.FORMAT_RGBA8)
	image.fill(Color.BLACK)
	var face_h := int(t * (0.62 if look == "riverbank" else (0.45 if look == "valley" else 0.6)))
	for y in data.h:
		for x in data.w:
			if data.tiles[y * data.w + x] != Gen.WALL:
				continue
			var p := Vector2i(x * t, y * t)
			if floor_at(data, x - 1, y):
				image.fill_rect(Rect2i(p, Vector2i(2, t)), Color.WHITE)
			if floor_at(data, x + 1, y):
				image.fill_rect(Rect2i(p + Vector2i(t - 2, 0), Vector2i(2, t)), Color.WHITE)
			if floor_at(data, x, y - 1):
				image.fill_rect(Rect2i(p, Vector2i(t, 2)), Color.WHITE)
			if floor_at(data, x, y + 1):
				image.fill_rect(Rect2i(p + Vector2i(0, t - face_h), Vector2i(t, face_h)), Color.WHITE)
	# Both code painters have the same 24x20 stair surround. The atlas uses the whole tile.
	var st: Vector2i = data.stairs * t
	var stairs := Rect2i(st, Vector2i(t, t)) if look == "bank" else Rect2i(st + Vector2i(t / 2 - 12, t / 2 - 10), Vector2i(24, 20))
	image.fill_rect(stairs, Color.WHITE)
	return image

static func apply(sprite: Sprite2D, data: Dictionary, t: int, look: String) -> void:
	var finish := ShaderMaterial.new()
	finish.shader = SHADER
	finish.set_shader_parameter("detail_mask", ImageTexture.create_from_image(mask(data, t, look)))
	sprite.material = finish
''')
edit('scripts/dungeon/dungeon.gd','const BankPainter := preload("res://scripts/dungeon/riverbank_painter.gd")','const BankPainter := preload("res://scripts/dungeon/riverbank_painter.gd")\nconst DungeonFinish := preload("res://scripts/dungeon/dungeon_finish.gd")\nconst CrewPortraitCanvas := preload("res://scripts/ui/crew_portrait_canvas.gd")')
edit('scripts/dungeon/dungeon.gd','\tlayer.add_child(_hud)','\tlayer.add_child(_hud)\n\tvar crew_portraits := CrewPortraitCanvas.new()\n\tcrew_portraits.name = "CrewPortraitFinish"\n\t_hud.add_child(crew_portraits)')
edit('scripts/dungeon/dungeon.gd','\t_map.texture = ImageTexture.create_from_image(painter.paint(data, T, floor_seed))','\t_map.texture = ImageTexture.create_from_image(painter.paint(data, T, floor_seed))\n\tDungeonFinish.apply(_map, data, T, look)')
edit('scripts/dungeon/dungeon.gd','func _draw_hud() -> void:','func _draw_hud() -> void:\n\t_hud.get_node("CrewPortraitFinish").clear()')
edit('scripts/ui/ui_style.gd','\t\tc.draw_texture_rect(tex, dst, false)','\t\tvar crew_layer := c.get_node_or_null("CrewPortraitFinish")\n\t\tif crew_layer != null and preload("res://scripts/arena/creature_finish.gd").crew_detail(tex.resource_path) > 0.0:\n\t\t\tcrew_layer.paint(tex, dst)\n\t\telse:\n\t\t\tc.draw_texture_rect(tex, dst, false)')
# Preserve Claude's newly added emotion marks above the creature-only material.
add('scripts/ui/crew_portrait_canvas.gd', (W/'portrait_detail_source.gd').read_text())
edit('scripts/ui/ui_style.gd','\t\t_face_bg(c, r, face)\n\tif tex != null:', '\t\t_face_bg(c, r, face)\n\tvar crew_layer := c.get_node_or_null("CrewPortraitFinish")\n\tvar crew_finished := tex != null and crew_layer != null and preload("res://scripts/arena/creature_finish.gd").crew_detail(tex.resource_path) > 0.0\n\tif tex != null:')
edit('scripts/ui/ui_style.gd','\t\tvar crew_layer := c.get_node_or_null("CrewPortraitFinish")\n\t\tif crew_layer != null and preload("res://scripts/arena/creature_finish.gd").crew_detail(tex.resource_path) > 0.0:', '\t\tif crew_finished:')
edit('scripts/ui/ui_style.gd','crew_layer.paint(tex, dst)', 'crew_layer.paint(tex, dst, face, r)')
edit('scripts/ui/ui_style.gd','\tif face != "":\n\t\t_face_mark(c, r, face)', '\tif face != "" and not crew_finished:\n\t\t_face_mark(c, r, face)')
for p in (W/'candidate').rglob('*'):
 if p.is_file():q=C/p.relative_to(W/'candidate');q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
s=(W/'before_capture.gd').read_text().replace('/review/before/', '/review/after/')
(W/'after_capture.gd').write_text(s)
print('Built rendering-only candidates. No live files installed.')
